import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:veda_client/veda_client.dart';

import '../main.dart';

/// Result of an upload operation.
class UploadResult {
  final bool success;
  final String? publicUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileType;
  final String? error;

  UploadResult({
    required this.success,
    this.publicUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
    this.error,
  });
}

/// Service for uploading files to S3 via Serverpod cloud storage.
class UploadService {
  UploadService._();
  static final instance = UploadService._();

  // ---------------------------------------------------------------------------
  // Core upload logic
  // ---------------------------------------------------------------------------

  /// Uploads bytes to S3 at [path]. Returns the public URL on success.
  Future<UploadResult> _uploadBytes({
    required String path,
    required Uint8List bytes,
    required String fileName,
  }) async {
    print('📤 [UploadService] Starting upload for: $fileName');
    print('📤 [UploadService] Path: $path');
    print('📤 [UploadService] Size: ${bytes.length} bytes');

    try {
      print('📤 [UploadService] Step 1: Getting upload description...');
      final description = await client.lms.getUploadDescription(path);
      if (description == null) {
        print('❌ [UploadService] Failed to get upload description (null)');
        return UploadResult(success: false, error: 'Failed to get upload URL');
      }
      print('✅ [UploadService] Got upload description (${description.length} chars)');

      print('📤 [UploadService] Step 2: Uploading to S3...');
      // Parse the upload description to get more debug info
      final descData = jsonDecode(description) as Map<String, dynamic>;
      print('📤 [UploadService] Upload type: ${descData['type']}');
      print('📤 [UploadService] Upload URL: ${descData['url']}');

      final ok = await _performUpload(description, bytes);
      if (!ok) {
        print('❌ [UploadService] S3 upload returned false');
        return UploadResult(success: false, error: 'Upload to S3 failed');
      }
      print('✅ [UploadService] S3 upload successful');

      print('📤 [UploadService] Step 3: Verifying upload...');
      final verified = await client.lms.verifyUpload(path);
      if (!verified) {
        print('❌ [UploadService] Verification failed');
        return UploadResult(
          success: false,
          error: 'Upload verification failed',
        );
      }
      print('✅ [UploadService] Upload verified');

      print('📤 [UploadService] Step 4: Getting public URL...');
      final publicUrl = await client.lms.getPublicUrl(path);
      print('✅ [UploadService] Public URL: $publicUrl');

      final ext = fileName.split('.').last.toLowerCase();
      return UploadResult(
        success: true,
        publicUrl: publicUrl,
        fileName: fileName,
        fileSize: bytes.length,
        fileType: ext,
      );
    } catch (e, stackTrace) {
      print('❌ [UploadService] Exception: $e');
      print('❌ [UploadService] Stack trace: $stackTrace');
      return UploadResult(success: false, error: e.toString());
    }
  }

  /// Picks a file with [allowedExtensions], then uploads to [pathBuilder].
  Future<UploadResult?> _pickAndUpload({
    required List<String> allowedExtensions,
    required String Function(String fileName, String ext) pathBuilder,
  }) async {
    print('📁 [UploadService] Opening file picker...');
    print('📁 [UploadService] Allowed extensions: $allowedExtensions');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      print('📁 [UploadService] User cancelled file picker');
      return null;
    }

    final file = result.files.first;
    print('📁 [UploadService] File picked: ${file.name}');
    print('📁 [UploadService] File extension: ${file.extension}');
    print('📁 [UploadService] File size: ${file.size} bytes');
    print('📁 [UploadService] Has bytes: ${file.bytes != null}');

    if (file.bytes == null) {
      print('❌ [UploadService] File bytes is null!');
      return UploadResult(success: false, error: 'Could not read file data');
    }

    final ext = file.extension?.toLowerCase() ?? '';
    final path = pathBuilder(file.name, ext);
    print('📁 [UploadService] Generated path: $path');

    return _uploadBytes(
      path: path,
      bytes: file.bytes!,
      fileName: file.name,
    );
  }

  /// Custom upload with detailed logging
  Future<bool> _performUpload(String description, Uint8List bytes) async {
    try {
      final data = jsonDecode(description) as Map<String, dynamic>;
      final type = data['type'] as String;
      final url = Uri.parse(data['url'] as String);

      if (type == 'binary') {
        print('📤 [UploadService] Using binary upload mode');
        final request = http.Request('POST', url);
        request.headers['Content-Type'] = 'application/octet-stream';
        request.headers['Accept'] = '*/*';
        request.bodyBytes = bytes;

        final streamedResponse = await request.send();
        final responseBody = await streamedResponse.stream.bytesToString();

        print('📤 [UploadService] Binary response status: ${streamedResponse.statusCode}');
        print('📤 [UploadService] Binary response body: $responseBody');

        return streamedResponse.statusCode == 200;
      } else if (type == 'multipart') {
        print('📤 [UploadService] Using multipart upload mode');
        final field = data['field'] as String;
        final fileName = data['file-name'] as String;
        final requestFields =
            (data['request-fields'] as Map).cast<String, String>();

        print('📤 [UploadService] Multipart field: $field');
        print('📤 [UploadService] Multipart fileName: $fileName');
        print('📤 [UploadService] Multipart requestFields: $requestFields');

        final request = http.MultipartRequest('POST', url);
        request.files.add(http.MultipartFile.fromBytes(
          field,
          bytes,
          filename: fileName,
        ));
        request.fields.addAll(requestFields);

        final streamedResponse = await request.send();
        final responseBody = await streamedResponse.stream.bytesToString();

        print('📤 [UploadService] Multipart response status: ${streamedResponse.statusCode}');
        print('📤 [UploadService] Multipart response headers: ${streamedResponse.headers}');
        print('📤 [UploadService] Multipart response body: $responseBody');

        // S3 multipart returns 204 on success
        return streamedResponse.statusCode == 204;
      }

      print('❌ [UploadService] Unknown upload type: $type');
      return false;
    } catch (e, stackTrace) {
      print('❌ [UploadService] Upload exception: $e');
      print('❌ [UploadService] Stack: $stackTrace');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Image extensions
  // ---------------------------------------------------------------------------

  static const _imageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const _videoExtensions = ['mp4', 'mov', 'webm', 'avi'];
  static const _knowledgeExtensions = ['pdf', 'docx', 'txt'];

  // ---------------------------------------------------------------------------
  // Course uploads
  // ---------------------------------------------------------------------------

  Future<UploadResult?> pickAndUploadCourseImage(int courseId) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/course-image.$ext',
    );
  }

  Future<UploadResult?> pickAndUploadBannerImage(int courseId) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/banner-image.$ext',
    );
  }

  Future<UploadResult?> pickAndUploadCourseVideo(int courseId) {
    return _pickAndUpload(
      allowedExtensions: _videoExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/video.$ext',
    );
  }

  Future<UploadResult?> pickAndUploadKnowledgeFile(int courseId) {
    return _pickAndUpload(
      allowedExtensions: _knowledgeExtensions,
      pathBuilder: (name, _) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        return 'courses/$courseId/files/$ts-$name';
      },
    );
  }

  /// Upload pre-picked image bytes (used by onboarding after course creation).
  Future<UploadResult> uploadCourseImageBytes(
    int courseId,
    Uint8List bytes,
    String fileName,
  ) {
    final ext = fileName.split('.').last.toLowerCase();
    return _uploadBytes(
      path: 'courses/$courseId/course-image.$ext',
      bytes: bytes,
      fileName: fileName,
    );
  }

  // ---------------------------------------------------------------------------
  // Module uploads
  // ---------------------------------------------------------------------------

  Future<UploadResult?> pickAndUploadModuleImage(int courseId, int moduleId) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/modules/$moduleId/image.$ext',
    );
  }

  Future<UploadResult?> pickAndUploadModuleBanner(int courseId, int moduleId) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) =>
          'courses/$courseId/modules/$moduleId/banner.$ext',
    );
  }

  Future<UploadResult?> pickAndUploadModuleVideo(int courseId, int moduleId) {
    return _pickAndUpload(
      allowedExtensions: _videoExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/modules/$moduleId/video.$ext',
    );
  }

  // ---------------------------------------------------------------------------
  // Topic uploads
  // ---------------------------------------------------------------------------

  Future<UploadResult?> pickAndUploadTopicImage(int topicId) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'topics/$topicId/image.$ext',
    );
  }

  Future<UploadResult?> pickAndUploadTopicBanner(int topicId) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'topics/$topicId/banner.$ext',
    );
  }

  Future<UploadResult?> pickAndUploadTopicVideo(int topicId) {
    return _pickAndUpload(
      allowedExtensions: _videoExtensions,
      pathBuilder: (_, ext) => 'topics/$topicId/video.$ext',
    );
  }

  // ---------------------------------------------------------------------------
  // CourseIndex uploads
  // ---------------------------------------------------------------------------

  Future<UploadResult?> pickAndUploadIndexImage(int courseId, int indexId) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/indices/$indexId/image.$ext',
    );
  }
}
