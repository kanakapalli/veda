import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:veda_client/veda_client.dart';

import '../main.dart';

/// Callback for upload progress: value between 0.0 and 1.0
typedef UploadProgressCallback = void Function(double progress);

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
    UploadProgressCallback? onProgress,
  }) async {
    print('📤 [UploadService] Starting upload for: $fileName');
    print('📤 [UploadService] Path: $path');
    print('📤 [UploadService] Size: ${bytes.length} bytes');

    try {
      onProgress?.call(0.0);

      print('📤 [UploadService] Step 1: Getting upload description...');
      final description = await client.lms.getUploadDescription(path);
      if (description == null) {
        print('❌ [UploadService] Failed to get upload description (null)');
        return UploadResult(success: false, error: 'Failed to get upload URL');
      }
      print('✅ [UploadService] Got upload description (${description.length} chars)');
      onProgress?.call(0.05);

      print('📤 [UploadService] Step 2: Uploading to S3...');
      // Parse the upload description to get more debug info
      final descData = jsonDecode(description) as Map<String, dynamic>;
      print('📤 [UploadService] Upload type: ${descData['type']}');
      print('📤 [UploadService] Upload URL: ${descData['url']}');

      final ok = await _performUpload(description, bytes, onProgress: onProgress);
      if (!ok) {
        print('❌ [UploadService] S3 upload returned false');
        return UploadResult(success: false, error: 'Upload to S3 failed');
      }
      print('✅ [UploadService] S3 upload successful');
      onProgress?.call(0.90);

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
      onProgress?.call(0.95);

      print('📤 [UploadService] Step 4: Getting public URL...');
      final publicUrl = await client.lms.getPublicUrl(path);
      print('✅ [UploadService] Public URL: $publicUrl');
      onProgress?.call(1.0);

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
  /// If [onFilePicked] is provided, it is called after the user selects a file
  /// but before the upload begins — useful for showing loading UI.
  /// If [onProgress] is provided, it is called with values between 0.0 and 1.0.
  Future<UploadResult?> _pickAndUpload({
    required List<String> allowedExtensions,
    required String Function(String fileName, String ext) pathBuilder,
    void Function()? onFilePicked,
    UploadProgressCallback? onProgress,
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

    // Notify caller that a file was picked (before upload starts)
    onFilePicked?.call();

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
      onProgress: onProgress,
    );
  }

  /// Custom upload with detailed logging
  Future<bool> _performUpload(String description, Uint8List bytes, {
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final data = jsonDecode(description) as Map<String, dynamic>;
      final type = data['type'] as String;
      final url = Uri.parse(data['url'] as String);

      if (type == 'binary') {
        print('📤 [UploadService] Using binary upload mode');
        final totalBytes = bytes.length;
        final request = http.StreamedRequest('POST', url);
        request.headers['Content-Type'] = 'application/octet-stream';
        request.headers['Accept'] = '*/*';
        request.contentLength = totalBytes;

        // Stream bytes in chunks with progress tracking
        final chunkSize = 64 * 1024; // 64 KB chunks
        var bytesSent = 0;

        () async {
          for (var offset = 0; offset < totalBytes; offset += chunkSize) {
            final end = (offset + chunkSize < totalBytes)
                ? offset + chunkSize
                : totalBytes;
            request.sink.add(bytes.sublist(offset, end));
            bytesSent = end;
            // Progress: 5% (description) + 85% for upload
            final uploadFraction = bytesSent / totalBytes;
            onProgress?.call(0.05 + uploadFraction * 0.85);
          }
          request.sink.close();
        }();

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

        // Wrap the request to track progress
        final totalBytes = request.contentLength;
        final originalStream = request.finalize();
        var bytesSent = 0;

        final progressStream = originalStream.transform(
          StreamTransformer<List<int>, List<int>>.fromHandlers(
            handleData: (data, sink) {
              sink.add(data);
              bytesSent += data.length;
              if (totalBytes > 0) {
                final uploadFraction = bytesSent / totalBytes;
                onProgress?.call(0.05 + uploadFraction * 0.85);
              }
            },
          ),
        );

        final streamedRequest = http.StreamedRequest('POST', url);
        streamedRequest.headers.addAll(request.headers);
        streamedRequest.contentLength = totalBytes;

        // Pipe the progress stream into the streamed request
        progressStream.listen(
          streamedRequest.sink.add,
          onError: streamedRequest.sink.addError,
          onDone: streamedRequest.sink.close,
        );

        final streamedResponse = await streamedRequest.send();
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

  /// Static helper to upload bytes to S3 using an upload description
  /// Returns HTTP response for status checking
  static Future<http.StreamedResponse> uploadBytesToS3(
    String description,
    Uint8List bytes,
  ) async {
    final data = jsonDecode(description) as Map<String, dynamic>;
    final type = data['type'] as String;
    final url = Uri.parse(data['url'] as String);

    if (type == 'binary') {
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/octet-stream';
      request.headers['Accept'] = '*/*';
      request.bodyBytes = bytes;
      return await request.send();
    } else if (type == 'multipart') {
      final field = data['field'] as String;
      final fileName = data['file-name'] as String;
      final requestFields =
          (data['request-fields'] as Map).cast<String, String>();

      final request = http.MultipartRequest('POST', url);
      request.files.add(http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: fileName,
      ));
      request.fields.addAll(requestFields);
      return await request.send();
    }

    throw Exception('Unknown upload type: $type');
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

  Future<UploadResult?> pickAndUploadCourseImage(int courseId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/course-image.$ext',
      onProgress: onProgress,
    );
  }

  Future<UploadResult?> pickAndUploadBannerImage(int courseId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/banner-image.$ext',
      onProgress: onProgress,
    );
  }

  Future<UploadResult?> pickAndUploadCourseVideo(int courseId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _videoExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/video.$ext',
      onProgress: onProgress,
    );
  }

  Future<UploadResult?> pickAndUploadKnowledgeFile(int courseId, {
    void Function()? onFilePicked,
    UploadProgressCallback? onProgress,
  }) {
    return _pickAndUpload(
      allowedExtensions: _knowledgeExtensions,
      pathBuilder: (name, _) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        return 'courses/$courseId/files/$ts-$name';
      },
      onFilePicked: onFilePicked,
      onProgress: onProgress,
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

  Future<UploadResult?> pickAndUploadModuleImage(int courseId, int moduleId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/modules/$moduleId/image.$ext',
      onProgress: onProgress,
    );
  }

  Future<UploadResult?> pickAndUploadModuleBanner(int courseId, int moduleId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) =>
          'courses/$courseId/modules/$moduleId/banner.$ext',
      onProgress: onProgress,
    );
  }

  Future<UploadResult?> pickAndUploadModuleVideo(int courseId, int moduleId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _videoExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/modules/$moduleId/video.$ext',
      onProgress: onProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // Topic uploads
  // ---------------------------------------------------------------------------

  Future<UploadResult?> pickAndUploadTopicImage(int topicId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'topics/$topicId/image.$ext',
      onProgress: onProgress,
    );
  }

  Future<UploadResult?> pickAndUploadTopicBanner(int topicId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'topics/$topicId/banner.$ext',
      onProgress: onProgress,
    );
  }

  Future<UploadResult?> pickAndUploadTopicVideo(int topicId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _videoExtensions,
      pathBuilder: (_, ext) => 'topics/$topicId/video.$ext',
      onProgress: onProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // CourseIndex uploads
  // ---------------------------------------------------------------------------

  Future<UploadResult?> pickAndUploadIndexImage(int courseId, int indexId, {UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) => 'courses/$courseId/indices/$indexId/image.$ext',
      onProgress: onProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // Profile uploads
  // ---------------------------------------------------------------------------

  Future<UploadResult?> pickAndUploadProfileImage({UploadProgressCallback? onProgress}) {
    return _pickAndUpload(
      allowedExtensions: _imageExtensions,
      pathBuilder: (_, ext) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        return 'profiles/$ts/avatar.$ext';
      },
      onProgress: onProgress,
    );
  }

  /// Upload pre-picked profile image bytes (used during registration).
  Future<UploadResult> uploadProfileImageBytes(
    Uint8List bytes,
    String fileName,
  ) {
    final ext = fileName.split('.').last.toLowerCase();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return _uploadBytes(
      path: 'profiles/$ts/avatar.$ext',
      bytes: bytes,
      fileName: fileName,
    );
  }
}
