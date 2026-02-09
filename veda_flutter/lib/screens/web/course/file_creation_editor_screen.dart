import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:veda_client/veda_client.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../design_system/veda_colors.dart';
import '../../../main.dart';
import '../../../services/upload_service.dart';

/// File Creation Editor - AI-assisted note/file creation with text editor
class FileCreationEditorScreen extends StatefulWidget {
  final int courseId;
  final FileCreationDraft? existingDraft;

  const FileCreationEditorScreen({
    super.key,
    required this.courseId,
    this.existingDraft,
  });

  @override
  State<FileCreationEditorScreen> createState() =>
      _FileCreationEditorScreenState();
}

class _FileCreationEditorScreenState extends State<FileCreationEditorScreen> {
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  final _quillController = quill.QuillController.basic();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  List<ChatMessage> _chatHistory = [];
  bool _isGenerating = false;
  bool _isSaving = false;
  FileCreationDraft? _currentDraft;

  // Speech-to-text
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';

  @override
  void initState() {
    super.initState();
    _loadExistingDraft();
    _initializeStt();
  }

  Future<void> _initializeStt() async {
    await _speechToText.initialize(
      onError: (error) => print('STT Error: $error'),
      onStatus: (status) => print('STT Status: $status'),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  /// Load existing draft if editing
  Future<void> _loadExistingDraft() async {
    if (widget.existingDraft != null) {
      _currentDraft = widget.existingDraft;
      _titleController.text = _currentDraft!.title;

      // Load content into Quill editor
      if (_currentDraft!.content.isNotEmpty) {
        try {
          final doc = quill.Document.fromJson(jsonDecode(_currentDraft!.content));
          _quillController.document = doc;
        } catch (e) {
          // If JSON parsing fails, treat as plain text
          _quillController.document = quill.Document()
            ..insert(0, _currentDraft!.content);
        }
      }

      // Load chat history
      if (_currentDraft!.chatHistory != null &&
          _currentDraft!.chatHistory!.isNotEmpty) {
        try {
          final historyJson = jsonDecode(_currentDraft!.chatHistory!) as List;
          _chatHistory = historyJson
              .map((msg) => ChatMessage(
                    role: msg['role'] as String,
                    content: msg['content'] as String,
                  ))
              .toList();
        } catch (e) {
          print('Failed to load chat history: $e');
        }
      }

      setState(() {});
    }
  }

  /// Start listening to user's voice
  Future<void> _startListening() async {
    print('🎤 [STT] Starting speech recognition...');

    final available = await _speechToText.initialize();
    if (!available) {
      print('❌ [STT] Speech recognition not available');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SPEECH RECOGNITION NOT AVAILABLE',
              style: GoogleFonts.jetBrainsMono(fontSize: 11),
            ),
            backgroundColor: Colors.red[900],
          ),
        );
      }
      return;
    }

    // Store the original text before starting to listen
    final originalText = _promptController.text;

    setState(() {
      _isListening = true;
      _spokenText = '';
    });

    print('🎤 [STT] Listening started...');

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
          // Update prompt field in real-time with spoken text
          if (originalText.trim().isNotEmpty) {
            _promptController.text = '$originalText $_spokenText';
          } else {
            _promptController.text = _spokenText;
          }
          print('🎤 [STT] Live transcript: "$_spokenText"');
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  /// Stop listening and finalize the recognized text
  Future<void> _stopListening() async {
    print('🎤 [STT] Stopping speech recognition...');
    await _speechToText.stop();
    setState(() => _isListening = false);

    if (_spokenText.isNotEmpty) {
      print('✅ [STT] Final text: "$_spokenText"');
      // Text is already in the prompt field from real-time updates
      // Just show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SPEECH RECOGNIZED',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: VedaColors.black,
              ),
            ),
            backgroundColor: VedaColors.white,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      print('⚠️ [STT] No speech recognized');
    }
  }

  /// Convert markdown text to formatted Quill content using Delta operations
  void _insertMarkdownContent(String markdown, int startIndex) {
    print('📝 [Markdown] Converting markdown to Quill format (${markdown.length} chars)');

    try {
      // Build a Delta starting from the insertion point
      final delta = Delta()..retain(startIndex);

      // Parse markdown line by line
      final lines = markdown.split('\n');

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];

        if (line.trim().isEmpty) {
          // Empty line
          delta.insert('\n');
          continue;
        }

        // Detect block-level formatting and extract text
        String textContent;
        Map<String, dynamic>? blockAttributes;

        if (line.startsWith('### ')) {
          textContent = line.substring(4);
          blockAttributes = {'header': 3};
        } else if (line.startsWith('## ')) {
          textContent = line.substring(3);
          blockAttributes = {'header': 2};
        } else if (line.startsWith('# ')) {
          textContent = line.substring(2);
          blockAttributes = {'header': 1};
        } else if (line.startsWith('- ') || line.startsWith('* ')) {
          textContent = line.substring(2);
          blockAttributes = {'list': 'bullet'};
        } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
          textContent = line.replaceFirst(RegExp(r'^\d+\.\s'), '');
          blockAttributes = {'list': 'ordered'};
        } else if (line.startsWith('> ')) {
          textContent = line.substring(2);
          blockAttributes = {'blockquote': true};
        } else if (line.startsWith('```')) {
          textContent = line;
          blockAttributes = {'code-block': true};
        } else {
          textContent = line;
          blockAttributes = null;
        }

        // Process inline formatting
        _processInlineFormatting(textContent, delta);

        // Add newline with block attributes
        delta.insert('\n', blockAttributes);
      }

      // Compose the delta into the document
      _quillController.document.compose(
        delta,
        quill.ChangeSource.local,
      );

      print('✅ [Markdown] Successfully converted and inserted formatted content');
    } catch (e, stackTrace) {
      print('❌ [Markdown] Failed to convert markdown: $e');
      print('Stack trace: $stackTrace');

      // Fallback: insert as plain text
      try {
        final docLength = _quillController.document.length;
        final fallbackIndex = docLength > 0 ? docLength - 1 : 0;
        _quillController.document.insert(fallbackIndex, '\n\n$markdown');
        print('✅ [Markdown] Inserted as plain text fallback');
      } catch (e2) {
        print('❌ [Markdown] Fallback also failed: $e2');
      }
    }
  }

  /// Process inline markdown formatting and add to delta
  void _processInlineFormatting(String text, dynamic delta) {
    var remaining = text;

    while (remaining.isNotEmpty) {
      // Find the next markdown pattern
      // Priority: bold (**) before italic (*) to avoid conflicts
      final boldPattern = RegExp(r'\*\*(.+?)\*\*');
      final italicPattern = RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)');
      final codePattern = RegExp(r'`(.+?)`');
      final strikethroughPattern = RegExp(r'~~(.+?)~~');

      // Find all matches
      final boldMatch = boldPattern.firstMatch(remaining);
      final italicMatch = italicPattern.firstMatch(remaining);
      final codeMatch = codePattern.firstMatch(remaining);
      final strikeMatch = strikethroughPattern.firstMatch(remaining);

      // Determine which pattern appears first
      Match? earliestMatch;
      String? matchType;
      int earliestStart = remaining.length;

      if (boldMatch != null && boldMatch.start < earliestStart) {
        earliestMatch = boldMatch;
        matchType = 'bold';
        earliestStart = boldMatch.start;
      }
      if (italicMatch != null && italicMatch.start < earliestStart) {
        earliestMatch = italicMatch;
        matchType = 'italic';
        earliestStart = italicMatch.start;
      }
      if (codeMatch != null && codeMatch.start < earliestStart) {
        earliestMatch = codeMatch;
        matchType = 'code';
        earliestStart = codeMatch.start;
      }
      if (strikeMatch != null && strikeMatch.start < earliestStart) {
        earliestMatch = strikeMatch;
        matchType = 'strikethrough';
        earliestStart = strikeMatch.start;
      }

      if (earliestMatch == null) {
        // No more formatting - add remaining text as plain
        if (remaining.isNotEmpty) {
          delta.insert(remaining);
        }
        break;
      }

      // Add plain text before the match
      if (earliestMatch.start > 0) {
        delta.insert(remaining.substring(0, earliestMatch.start));
      }

      // Add formatted text
      final formattedText = earliestMatch.group(1)!;
      delta.insert(formattedText, {matchType!: true});

      // Continue with remaining text after the match
      remaining = remaining.substring(earliestMatch.end);
    }
  }

  /// Generate content with AI based on user prompt
  Future<void> _generateContent() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    print('🤖 [FileCreation] Starting content generation');
    print('🤖 [FileCreation] User prompt: "$prompt"');
    print('🤖 [FileCreation] Chat history length: ${_chatHistory.length}');
    print('🤖 [FileCreation] Current title: ${_titleController.text.isNotEmpty ? _titleController.text : 'Untitled'}');

    setState(() => _isGenerating = true);

    try {
      // Add user message to history
      _chatHistory.add(ChatMessage(role: 'user', content: prompt));
      print('🤖 [FileCreation] Added user message to history (total: ${_chatHistory.length})');

      // Build system instruction for note generation
      final systemInstruction = '''
You are an AI assistant helping to create educational course materials and notes.

TASK: Generate well-structured, informative content based on the user's request.

GUIDELINES:
- Write clear, comprehensive notes suitable for course materials
- Use proper formatting with headings, bullet points, and paragraphs
- Focus on educational value and clarity
- Include examples where appropriate
- Structure content logically with introduction, main points, and conclusion
- Keep tone professional yet accessible

USER CONTEXT:
- Creating content for a course
- Current title: ${_titleController.text.isNotEmpty ? _titleController.text : 'Untitled'}

Generate the content now based on the user's prompt.
''';

      print('🤖 [FileCreation] System instruction prepared (${systemInstruction.length} chars)');
      print('🤖 [FileCreation] Calling Gemini API...');

      final stopwatch = Stopwatch()..start();

      // Call Gemini API
      final response = await client.gemini.chat(
        ChatRequest(
          message: prompt,
          history: _chatHistory.length > 1
              ? _chatHistory.sublist(0, _chatHistory.length - 1)
              : null,
          systemInstruction: systemInstruction,
        ),
      );

      stopwatch.stop();
      print('✅ [FileCreation] Gemini API responded in ${stopwatch.elapsedMilliseconds}ms');

      if (response.error != null) {
        print('❌ [FileCreation] Gemini returned error: ${response.error}');

        // Show user-friendly error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.error!.contains('API key')
                    ? 'GEMINI API KEY NOT CONFIGURED\nAdd geminiApiKey to veda_server/config/passwords.yaml'
                    : 'ERROR: ${response.error}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: VedaColors.white,
                ),
              ),
              backgroundColor: Colors.red[900],
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isGenerating = false);
        return;
      }

      print('✅ [FileCreation] Generated content length: ${response.text.length} chars');
      print('✅ [FileCreation] Content preview (first 200 chars): ${response.text.length > 200 ? response.text.substring(0, 200) : response.text}...');

      // Add AI response to history
      _chatHistory.add(ChatMessage(role: 'model', content: response.text));
      print('✅ [FileCreation] Added AI response to history (total: ${_chatHistory.length})');

      // Insert generated content into editor with markdown formatting
      // Get the current length (Quill document always has at least one character)
      final currentLength = _quillController.document.length;
      final insertIndex = currentLength > 0 ? currentLength - 1 : 0;

      // Add spacing if there's existing content
      if (insertIndex > 0 && _quillController.document.toPlainText().trim().isNotEmpty) {
        _quillController.document.insert(insertIndex, '\n\n');
      }

      // Convert markdown to Quill formatting and insert
      _insertMarkdownContent(response.text, insertIndex > 0 ? insertIndex + 2 : 0);
      print('✅ [FileCreation] Inserted formatted content into editor');

      // Clear prompt field
      _promptController.clear();
      print('✅ [FileCreation] Cleared prompt field');

      if (mounted) {
        print('✅ [FileCreation] Showing success notification to user');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'CONTENT GENERATED',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.black,
                letterSpacing: 1.0,
              ),
            ),
            backgroundColor: VedaColors.white,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      print('🎉 [FileCreation] Content generation completed successfully');
    } catch (e, stackTrace) {
      print('❌ [FileCreation] Content generation failed: $e');
      print('❌ [FileCreation] Error type: ${e.runtimeType}');
      print('❌ [FileCreation] Stack trace: $stackTrace');

      if (mounted) {
        print('❌ [FileCreation] Showing error notification to user');

        // Parse error message for user-friendly display
        String errorMessage = e.toString();
        if (errorMessage.contains('Connection refused') || errorMessage.contains('Failed host lookup')) {
          errorMessage = 'SERVER CONNECTION FAILED\nMake sure veda_server is running';
        } else if (errorMessage.contains('SocketException')) {
          errorMessage = 'NETWORK ERROR\nCheck your server connection';
        } else if (errorMessage.contains('API key')) {
          errorMessage = 'GEMINI API KEY ERROR\nCheck veda_server/config/passwords.yaml';
        } else if (errorMessage.length > 200) {
          errorMessage = '${errorMessage.substring(0, 200)}...';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.white,
              ),
            ),
            backgroundColor: Colors.red[900],
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      print('🔄 [FileCreation] Setting isGenerating to false');
      setState(() => _isGenerating = false);
    }
  }

  /// Save current content as draft
  Future<void> _saveDraft({bool silent = false}) async {
    print('💾 [Draft] Starting draft save (silent: $silent)');

    if (_titleController.text.trim().isEmpty) {
      print('⚠️ [Draft] Title is empty, cannot save');
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PLEASE ENTER A TITLE',
              style: GoogleFonts.jetBrainsMono(fontSize: 11),
            ),
            backgroundColor: VedaColors.white,
          ),
        );
      }
      return;
    }

    print('💾 [Draft] Title: ${_titleController.text.trim()}');
    print('💾 [Draft] Existing draft ID: ${_currentDraft?.id ?? 'none (new draft)'}');

    setState(() => _isSaving = true);

    try {
      // Get content as JSON from Quill
      final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
      print('💾 [Draft] Serialized content (${contentJson.length} chars)');

      // Serialize chat history
      final historyJson = jsonEncode(
        _chatHistory
            .map((msg) => {'role': msg.role, 'content': msg.content})
            .toList(),
      );
      print('💾 [Draft] Serialized chat history (${_chatHistory.length} messages, ${historyJson.length} chars)');

      final draft = FileCreationDraft(
        id: _currentDraft?.id,
        creatorId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
        courseId: widget.courseId,
        title: _titleController.text.trim(),
        content: contentJson,
        chatHistory: historyJson,
        fileType: 'md',
      );

      print('💾 [Draft] Calling server to save draft...');
      _currentDraft = await client.lms.saveDraft(draft);
      print('✅ [Draft] Draft saved successfully with ID: ${_currentDraft?.id}');

      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'DRAFT SAVED',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.black,
              ),
            ),
            backgroundColor: VedaColors.white,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SAVE ERROR: ${e.toString()}',
              style: GoogleFonts.jetBrainsMono(fontSize: 11),
            ),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Convert editor content to PDF
  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    // Get plain text from Quill document
    final plainText = _quillController.document.toPlainText();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _titleController.text.trim(),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                plainText,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Submit PDF to knowledge files
  Future<void> _submitToKnowledgeFiles() async {
    print('📤 [Submit] Starting PDF submission to knowledge files');
    print('📤 [Submit] Course ID: ${widget.courseId}');

    if (_titleController.text.trim().isEmpty) {
      print('⚠️ [Submit] Title is empty, cannot submit');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PLEASE ENTER A TITLE',
            style: GoogleFonts.jetBrainsMono(fontSize: 11),
          ),
          backgroundColor: VedaColors.white,
        ),
      );
      return;
    }

    print('📤 [Submit] Title: ${_titleController.text.trim()}');
    setState(() => _isSaving = true);

    try {
      // Generate PDF
      print('📄 [Submit] Step 1: Generating PDF from editor content...');
      final pdfBytes = await _generatePDF();
      print('✅ [Submit] PDF generated (${pdfBytes.length} bytes)');

      // Upload PDF to S3
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${_titleController.text.trim()}_$timestamp.pdf';
      final path = 'courses/${widget.courseId}/files/$fileName';
      print('📤 [Submit] Step 2: Preparing upload...');
      print('📤 [Submit] File name: $fileName');
      print('📤 [Submit] S3 path: $path');

      // Get upload URL
      print('📤 [Submit] Getting upload description...');
      final uploadDescription = await client.lms.getUploadDescription(path);
      if (uploadDescription == null) {
        print('❌ [Submit] Failed to get upload description (null)');
        throw Exception('Failed to get upload URL');
      }
      print('✅ [Submit] Upload description received (${uploadDescription.length} chars)');

      // Upload file
      print('📤 [Submit] Step 3: Uploading to S3...');
      final stopwatch = Stopwatch()..start();
      final uploadResponse = await UploadService.uploadBytesToS3(
        uploadDescription,
        pdfBytes,
      );
      stopwatch.stop();
      print('✅ [Submit] Upload completed in ${stopwatch.elapsedMilliseconds}ms');
      print('✅ [Submit] Response status: ${uploadResponse.statusCode}');

      if (uploadResponse.statusCode != 200 && uploadResponse.statusCode != 204) {
        final responseBody = await uploadResponse.stream.bytesToString();
        print('❌ [Submit] Upload failed with status ${uploadResponse.statusCode}');
        print('❌ [Submit] Response body: $responseBody');
        throw Exception('Upload failed: ${uploadResponse.statusCode} - $responseBody');
      }

      // Verify upload
      print('📤 [Submit] Step 4: Verifying upload...');
      final verified = await client.lms.verifyUpload(path);
      if (!verified) {
        print('❌ [Submit] Upload verification failed');
        throw Exception('Upload verification failed');
      }
      print('✅ [Submit] Upload verified successfully');

      // Get public URL
      print('📤 [Submit] Step 5: Getting public URL...');
      final publicUrl = await client.lms.getPublicUrl(path);
      if (publicUrl == null) {
        print('❌ [Submit] Failed to get public URL (null)');
        throw Exception('Failed to get public URL');
      }
      print('✅ [Submit] Public URL: $publicUrl');

      // Create knowledge file record
      final plainText = _quillController.document.toPlainText();
      print('📤 [Submit] Step 6: Creating knowledge file record...');
      print('📤 [Submit] Text content length: ${plainText.length} chars');

      final knowledgeFile = KnowledgeFile(
        fileName: fileName,
        fileUrl: publicUrl,
        fileSize: pdfBytes.length,
        fileType: 'pdf',
        textContent: plainText,
        courseId: widget.courseId,
      );

      print('📤 [Submit] Calling addFileToCourse (will generate embedding)...');
      final addFileStopwatch = Stopwatch()..start();
      await client.lms.addFileToCourse(knowledgeFile);
      addFileStopwatch.stop();
      print('✅ [Submit] Knowledge file added in ${addFileStopwatch.elapsedMilliseconds}ms (includes embedding generation)');

      // Delete draft if it exists
      if (_currentDraft?.id != null) {
        print('🗑️ [Submit] Step 7: Deleting draft (ID: ${_currentDraft!.id})...');
        await client.lms.deleteDraft(_currentDraft!.id!);
        print('✅ [Submit] Draft deleted successfully');
      } else {
        print('ℹ️ [Submit] No draft to delete');
      }

      if (mounted) {
        print('🎉 [Submit] Showing success notification and navigating back');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'FILE ADDED TO KNOWLEDGE BASE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.black,
              ),
            ),
            backgroundColor: VedaColors.white,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Go back to course creation screen
        print('🎉 [Submit] Submission completed successfully, returning to course screen');
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      print('❌ [Submit] Submission failed: $e');
      print('❌ [Submit] Stack trace: $stackTrace');

      if (mounted) {
        print('❌ [Submit] Showing error notification to user');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SUBMIT ERROR: ${e.toString()}',
              style: GoogleFonts.jetBrainsMono(fontSize: 11),
            ),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      print('🔄 [Submit] Setting isSaving to false');
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VedaColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with title and actions
            _buildTopBar(),

            // Main content area with editor
            Expanded(
              child: _buildEditorArea(),
            ),

            // Bottom prompt area
            _buildPromptArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VedaColors.zinc800, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: VedaColors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          const SizedBox(width: 24),

          // Title input
          Expanded(
            child: TextField(
              controller: _titleController,
              style: GoogleFonts.workSans(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: VedaColors.white,
              ),
              decoration: InputDecoration(
                hintText: 'UNTITLED DOCUMENT',
                hintStyle: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: VedaColors.zinc800,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Save Draft button
          TextButton(
            onPressed: _isSaving ? null : () => _saveDraft(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: VedaColors.zinc800, width: 0.5),
              ),
            ),
            child: Text(
              'SAVE DRAFT',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Submit button
          TextButton(
            onPressed: _isSaving ? null : _submitToKnowledgeFiles,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: VedaColors.accent,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'SUBMIT',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: VedaColors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorArea() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          // Formatting toolbar
          _buildToolbar(),
          const SizedBox(height: 12),

          // Editor
          Expanded(
            child: Theme(
              data: ThemeData.dark().copyWith(
                textTheme: TextTheme(
                  bodyLarge: GoogleFonts.workSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: VedaColors.white,
                    height: 1.8,
                  ),
                ),
              ),
              child: quill.QuillEditor.basic(
                controller: _quillController,
                focusNode: _focusNode,
                scrollController: _scrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: VedaColors.zinc800, width: 0.5),
      ),
      child: Row(
        children: [
          // Bold
          _buildToolbarButton(
            icon: Icons.format_bold,
            onPressed: () => _quillController.formatSelection(quill.Attribute.bold),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('bold'),
          ),

          // Italic
          _buildToolbarButton(
            icon: Icons.format_italic,
            onPressed: () => _quillController.formatSelection(quill.Attribute.italic),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('italic'),
          ),

          // Underline
          _buildToolbarButton(
            icon: Icons.format_underline,
            onPressed: () => _quillController.formatSelection(quill.Attribute.underline),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('underline'),
          ),

          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: VedaColors.zinc800),
          const SizedBox(width: 12),

          // Normal paragraph (reset heading)
          _buildToolbarButton(
            icon: Icons.text_fields,
            label: 'P',
            onPressed: () {
              // Clear heading formatting
              _quillController.formatSelection(
                quill.Attribute.clone(quill.Attribute.h1, null),
              );
              _quillController.formatSelection(
                quill.Attribute.clone(quill.Attribute.h2, null),
              );
              _quillController.formatSelection(
                quill.Attribute.clone(quill.Attribute.h3, null),
              );
            },
            isActive: !_quillController.getSelectionStyle().attributes.containsKey('header'),
          ),

          // Heading 1
          _buildToolbarButton(
            icon: Icons.format_size,
            label: 'H1',
            onPressed: () => _quillController.formatSelection(quill.Attribute.h1),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('header') &&
                _quillController.getSelectionStyle().attributes['header']?.value == 1,
          ),

          // Heading 2
          _buildToolbarButton(
            icon: Icons.format_size,
            label: 'H2',
            onPressed: () => _quillController.formatSelection(quill.Attribute.h2),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('header') &&
                _quillController.getSelectionStyle().attributes['header']?.value == 2,
          ),

          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: VedaColors.zinc800),
          const SizedBox(width: 12),

          // Bullet list
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            onPressed: () => _quillController.formatSelection(quill.Attribute.ul),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('list') &&
                _quillController.getSelectionStyle().attributes['list']?.value == 'bullet',
          ),

          // Numbered list
          _buildToolbarButton(
            icon: Icons.format_list_numbered,
            onPressed: () => _quillController.formatSelection(quill.Attribute.ol),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('list') &&
                _quillController.getSelectionStyle().attributes['list']?.value == 'ordered',
          ),

          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: VedaColors.zinc800),
          const SizedBox(width: 12),

          // Quote
          _buildToolbarButton(
            icon: Icons.format_quote,
            onPressed: () => _quillController.formatSelection(quill.Attribute.blockQuote),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('blockquote'),
          ),

          // Code block
          _buildToolbarButton(
            icon: Icons.code,
            onPressed: () => _quillController.formatSelection(quill.Attribute.codeBlock),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('code-block'),
          ),

          const Spacer(),

          // Clear formatting
          _buildToolbarButton(
            icon: Icons.format_clear,
            onPressed: () {
              // Clear all inline formatting
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.bold, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.italic, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.underline, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.strikeThrough, null));
              // Clear block formatting
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.h1, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.h2, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.h3, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.ul, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.ol, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.blockQuote, null));
              _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.codeBlock, null));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    String? label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isActive ? VedaColors.accent.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isActive ? VedaColors.accent : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: label != null
            ? Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive ? VedaColors.accent : VedaColors.white,
                ),
              )
            : Icon(
                icon,
                size: 18,
                color: isActive ? VedaColors.accent : VedaColors.white,
              ),
      ),
    );
  }

  Widget _buildPromptArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: VedaColors.zinc800, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: VedaColors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Prompt AI to generate content...',
                hintStyle: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: VedaColors.zinc800,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: VedaColors.zinc800, width: 0.5),
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: VedaColors.zinc800, width: 0.5),
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: VedaColors.accent, width: 0.5),
                  borderRadius: BorderRadius.zero,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 3,
              onSubmitted: (_) => _generateContent(),
            ),
          ),

          const SizedBox(width: 12),

          // Microphone button for STT
          IconButton(
            onPressed: _isGenerating
                ? null
                : (_isListening ? _stopListening : _startListening),
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : VedaColors.white,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: _isListening ? Colors.red : VedaColors.zinc800,
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(width: 8),

          // Generate button
          IconButton(
            onPressed: _isGenerating ? null : _generateContent,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(VedaColors.accent),
                    ),
                  )
                : const Icon(Icons.arrow_upward, color: VedaColors.accent, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: VedaColors.zinc800, width: 0.5),
              ),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
