import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart'; // gives authUserId extension
import '../gemini/gemini_service.dart';
import '../generated/protocol.dart';

/// LMS Endpoint - handles course management operations
class LmsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  // ---------------------------------------------------------------------------
  // Course Management
  // ---------------------------------------------------------------------------

  /// Creates a new course with default draft visibility
  Future<Course> createCourse(Session session, Course course) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    course.creatorId = authInfo.authUserId;
    course.createdAt = DateTime.now();
    course.updatedAt = DateTime.now();
    return await Course.db.insertRow(session, course);
  }

  /// Updates an existing course
  Future<Course> updateCourse(Session session, Course course) async {
    course.updatedAt = DateTime.now();
    return await Course.db.updateRow(session, course);
  }

  /// Deletes a course by ID
  Future<bool> deleteCourse(Session session, int id) async {
    final deleted = await Course.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
    return deleted.isNotEmpty;
  }

  /// Gets a course by ID with all related data
  Future<Course?> getCourseById(Session session, int id) async {
    return await Course.db.findById(
      session,
      id,
      include: Course.include(
        modules: Module.includeList(
          orderBy: (t) => t.sortOrder,
        ),
        knowledgeFiles: KnowledgeFile.includeList(),
        courseIndices: CourseIndex.includeList(),
      ),
    );
  }

  /// Lists courses with optional keyword and visibility filters
  Future<List<Course>> listCourses(
    Session session, {
    String? keyword,
    CourseVisibility? visibility,
  }) async {
    return await Course.db.find(
      session,
      where: (t) {
        Expression whereExpr = Constant.bool(true);

        if (keyword != null && keyword.isNotEmpty) {
          whereExpr = whereExpr & t.title.ilike('%$keyword%');
        }

        if (visibility != null) {
          whereExpr = whereExpr & t.visibility.equals(visibility);
        }

        return whereExpr;
      },
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Lists courses created by the authenticated user
  Future<List<Course>> listMyCourses(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final creatorId = authInfo.authUserId;

    return await Course.db.find(
      session,
      where: (t) => t.creatorId.equals(creatorId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Lists all courses created by a specific creator.
  /// Public endpoint - does not require authentication.
  Future<List<Course>> getCoursesByCreator(
    Session session,
    UuidValue creatorId,
  ) async {
    return await Course.db.find(
      session,
      where: (t) => t.creatorId.equals(creatorId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Knowledge File Management
  // ---------------------------------------------------------------------------

  /// Adds a knowledge file to a course
  /// Adds a knowledge file to a course and generates embedding
  Future<KnowledgeFile> addFileToCourse(
    Session session,
    KnowledgeFile file,
  ) async {
    file.uploadedAt = DateTime.now();
    final insertedFile = await KnowledgeFile.db.insertRow(session, file);

    // Automatically generate embedding for the file
    // Process synchronously to ensure session is still open
    try {
      await _processFileEmbedding(session, insertedFile);
      session.log('✅ [Embedding] Successfully generated embedding for ${insertedFile.fileName}');
    } catch (error) {
      session.log('❌ [Embedding] Failed to generate embedding for ${insertedFile.fileName}: $error',
        level: LogLevel.error);
      // Don't throw - allow file to be added even if embedding fails
    }

    // Return updated file with embedding
    return (await KnowledgeFile.db.findById(session, insertedFile.id!))!;
  }

  /// Process a knowledge file and generate its embedding
  /// This runs asynchronously after file upload
  Future<void> _processFileEmbedding(Session session, KnowledgeFile file) async {
    try {
      session.log('🔄 [Embedding] Processing file: ${file.fileName}');

      // Read file content
      final content = await _readFileContent(session, file);
      if (content.isEmpty) {
        session.log('⚠️ [Embedding] File has no content, skipping: ${file.fileName}');
        return;
      }

      session.log('📄 [Embedding] Read ${content.length} characters from ${file.fileName}');

      // For now, use the full content as one chunk
      // TODO: Implement chunking for large files
      const maxChunkSize = 10000;
      final textToEmbed = content.length > maxChunkSize
          ? content.substring(0, maxChunkSize)
          : content;

      // Generate embedding
      final apiKey = session.passwords['geminiApiKey'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key not configured');
      }

      final gemini = GeminiService(apiKey: apiKey);
      session.log('🤖 [Embedding] Generating embedding with Gemini (${textToEmbed.length} chars)');

      final embedding = await gemini.generateEmbedding(textToEmbed);
      session.log('✅ [Embedding] Generated ${embedding.length}-dimensional vector');

      // Update the file with embedding and text content
      final updatedFile = file.copyWith(
        embedding: Vector(embedding),
        textContent: content, // Store full content for display
      );

      await KnowledgeFile.db.updateRow(session, updatedFile);
      session.log('💾 [Embedding] Saved embedding to database for ${file.fileName}');

    } catch (e, stackTrace) {
      session.log('❌ [Embedding] Error processing file ${file.fileName}: $e',
        level: LogLevel.error);
      session.log('Stack trace: $stackTrace', level: LogLevel.debug);
      rethrow;
    }
  }

  /// Manually process embeddings for a specific file (for re-processing)
  Future<KnowledgeFile> processFileEmbedding(
    Session session,
    int fileId,
  ) async {
    final file = await KnowledgeFile.db.findById(session, fileId);
    if (file == null) {
      throw Exception('File not found');
    }

    await _processFileEmbedding(session, file);

    // Return the updated file
    return (await KnowledgeFile.db.findById(session, fileId))!;
  }

  /// Process embeddings for all files in a course (batch processing)
  Future<List<KnowledgeFile>> processAllFileEmbeddings(
    Session session,
    int courseId,
  ) async {
    session.log('🔄 [Embedding] Processing all files for course $courseId');

    final files = await KnowledgeFile.db.find(
      session,
      where: (t) => t.courseId.equals(courseId),
    );

    session.log('📚 [Embedding] Found ${files.length} files to process');

    for (final file in files) {
      try {
        await _processFileEmbedding(session, file);
      } catch (e) {
        session.log('❌ [Embedding] Failed to process ${file.fileName}: $e',
          level: LogLevel.warning);
        // Continue with other files even if one fails
      }
    }

    session.log('✅ [Embedding] Finished processing ${files.length} files');

    // Return updated files
    return await KnowledgeFile.db.find(
      session,
      where: (t) => t.courseId.equals(courseId),
    );
  }

  /// Gets all knowledge files for a course
  Future<List<KnowledgeFile>> getFilesForCourse(
    Session session,
    int courseId,
  ) async {
    return await KnowledgeFile.db.find(
      session,
      where: (t) => t.courseId.equals(courseId),
    );
  }

  /// Deletes a knowledge file
  Future<bool> deleteFile(Session session, int fileId) async {
    final result = await KnowledgeFile.db.deleteWhere(
      session,
      where: (t) => t.id.equals(fileId),
    );
    return result.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // File Creation Draft Management
  // ---------------------------------------------------------------------------

  /// Create or update a file creation draft
  Future<FileCreationDraft> saveDraft(
    Session session,
    FileCreationDraft draft,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    // Always set creator from authenticated user
    draft.creatorId = authInfo.authUserId;
    draft.updatedAt = DateTime.now();

    if (draft.id == null) {
      // New draft
      draft.createdAt = DateTime.now();
      return await FileCreationDraft.db.insertRow(session, draft);
    } else {
      // Update existing draft
      return await FileCreationDraft.db.updateRow(session, draft);
    }
  }

  /// Get all drafts for the authenticated user
  Future<List<FileCreationDraft>> getMyDrafts(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    return await FileCreationDraft.db.find(
      session,
      where: (t) => t.creatorId.equals(authInfo.authUserId),
      orderBy: (t) => t.updatedAt,
      orderDescending: true,
    );
  }

  /// Get drafts for a specific course
  Future<List<FileCreationDraft>> getDraftsForCourse(
    Session session,
    int courseId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    return await FileCreationDraft.db.find(
      session,
      where: (t) =>
          t.creatorId.equals(authInfo.authUserId) &
          t.courseId.equals(courseId),
      orderBy: (t) => t.updatedAt,
      orderDescending: true,
    );
  }

  /// Get a specific draft by ID
  Future<FileCreationDraft?> getDraft(Session session, int draftId) async {
    return await FileCreationDraft.db.findById(session, draftId);
  }

  /// Delete a draft
  Future<bool> deleteDraft(Session session, int draftId) async {
    final result = await FileCreationDraft.db.deleteWhere(
      session,
      where: (t) => t.id.equals(draftId),
    );
    return result.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Module Management
  // ---------------------------------------------------------------------------

  /// Gets all modules for a course with items and topics
  Future<List<Module>> getModules(Session session, int courseId) async {
    session.log(
      '📋 [getModules] Fetching modules for course $courseId',
      level: LogLevel.info,
    );

    // Fetch modules without trying to include items (because the relation uses wrong foreign key)
    final modules = await Module.db.find(
      session,
      where: (t) => t.courseId.equals(courseId),
      orderBy: (t) => t.sortOrder,
    );

    session.log(
      '📋 [getModules] Found ${modules.length} modules',
      level: LogLevel.info,
    );

    // Manually load module items using the correct moduleId foreign key
    int totalTopicsLoaded = 0;
    for (final module in modules) {
      // Find all ModuleItems for this module using moduleId
      final items = await ModuleItem.db.find(
        session,
        where: (t) => t.moduleId.equals(module.id!),
        orderBy: (t) => t.sortOrder,
      );

      session.log(
        '  📦 [getModules] Module "${module.title}" (ID: ${module.id}): Found ${items.length} items',
        level: LogLevel.debug,
      );

      // Load topic for each item
      for (final item in items) {
        item.topic = await Topic.db.findById(session, item.topicId);
        if (item.topic != null) {
          totalTopicsLoaded++;
          session.log(
            '    ✅ [getModules] Loaded topic: "${item.topic!.title}" (ID: ${item.topic!.id})',
            level: LogLevel.debug,
          );
        } else {
          session.log(
            '    ❌ [getModules] Failed to load topic with ID: ${item.topicId}',
            level: LogLevel.warning,
          );
        }
      }

      // Set the items on the module
      module.items = items;
    }

    session.log(
      '✅ [getModules] Returning ${modules.length} modules with $totalTopicsLoaded topics total',
      level: LogLevel.info,
    );

    return modules;
  }

  /// Creates a new module
  Future<Module> createModule(Session session, Module module) async {
    return await Module.db.insertRow(session, module);
  }

  /// Updates an existing module
  Future<Module> updateModule(Session session, Module module) async {
    return await Module.db.updateRow(session, module);
  }

  /// Deletes a module by ID
  Future<bool> deleteModule(Session session, int moduleId) async {
    final result = await Module.db.deleteWhere(
      session,
      where: (t) => t.id.equals(moduleId),
    );
    return result.isNotEmpty;
  }

  /// Deletes all modules for a course
  Future<void> deleteAllModules(Session session, int courseId) async {
    await Module.db.deleteWhere(
      session,
      where: (t) => t.courseId.equals(courseId),
    );
  }

  // ---------------------------------------------------------------------------
  // Topic Management
  // ---------------------------------------------------------------------------

  /// Creates a new topic
  Future<Topic> createTopic(Session session, Topic topic) async {
    topic.createdAt = DateTime.now();
    topic.updatedAt = DateTime.now();
    return await Topic.db.insertRow(session, topic);
  }

  /// Updates an existing topic
  Future<Topic> updateTopic(Session session, Topic topic) async {
    topic.updatedAt = DateTime.now();
    return await Topic.db.updateRow(session, topic);
  }

  /// Gets a topic by ID
  Future<Topic?> getTopicById(Session session, int id) async {
    return await Topic.db.findById(session, id);
  }

  /// Searches topics by keyword (case-insensitive partial match on title)
  Future<List<Topic>> searchTopics(
    Session session, {
    required String keyword,
  }) async {
    return await Topic.db.find(
      session,
      where: (t) => t.title.ilike('%$keyword%'),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Finds the Course that contains a given Topic (via ModuleItem → Module → Course)
  Future<Course?> getCourseByTopicId(Session session, int topicId) async {
    // Step 1: Find a ModuleItem that references this topic
    final moduleItem = await ModuleItem.db.findFirstRow(
      session,
      where: (mi) => mi.topicId.equals(topicId),
    );
    if (moduleItem == null) return null;

    // Step 2: Get the Module to find courseId
    final module = await Module.db.findById(session, moduleItem.moduleId);
    if (module == null) return null;

    // Step 3: Get the Course
    return await Course.db.findById(session, module.courseId);
  }

  // ---------------------------------------------------------------------------
  // Module Item Management
  // ---------------------------------------------------------------------------

  /// Creates a module item (links topic to module)
  Future<ModuleItem> createModuleItem(
    Session session,
    ModuleItem moduleItem,
  ) async {
    return await ModuleItem.db.insertRow(session, moduleItem);
  }

  /// Updates a module item
  Future<ModuleItem> updateModuleItem(
    Session session,
    ModuleItem moduleItem,
  ) async {
    return await ModuleItem.db.updateRow(session, moduleItem);
  }

  /// Deletes a module item
  Future<bool> deleteModuleItem(Session session, int moduleItemId) async {
    final result = await ModuleItem.db.deleteWhere(
      session,
      where: (t) => t.id.equals(moduleItemId),
    );
    return result.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Enrollment Management
  // ---------------------------------------------------------------------------

  /// Enrolls the authenticated user in a course.
  /// Returns the created Enrollment record.
  /// Throws if the user is already enrolled.
  Future<Enrollment> enrollInCourse(Session session, int courseId) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final userId = authInfo.authUserId;

    // Check if already enrolled
    final existing = await Enrollment.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.courseId.equals(courseId),
    );
    if (existing != null) {
      throw Exception('Already enrolled in this course');
    }

    // Verify course exists
    final course = await Course.db.findById(session, courseId);
    if (course == null) {
      throw Exception('Course not found');
    }

    final enrollment = Enrollment(
      userId: userId,
      courseId: courseId,
      enrolledAt: DateTime.now(),
    );

    return await Enrollment.db.insertRow(session, enrollment);
  }

  /// Unenrolls the authenticated user from a course.
  Future<bool> unenrollFromCourse(Session session, int courseId) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final userId = authInfo.authUserId;

    final result = await Enrollment.db.deleteWhere(
      session,
      where: (t) => t.userId.equals(userId) & t.courseId.equals(courseId),
    );

    return result.isNotEmpty;
  }

  /// Checks if the authenticated user is enrolled in a specific course.
  Future<bool> isEnrolled(Session session, int courseId) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final userId = authInfo.authUserId;

    final enrollment = await Enrollment.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.courseId.equals(courseId),
    );

    return enrollment != null;
  }

  /// Lists all courses the authenticated user is enrolled in.
  /// Returns enrollments with course data included.
  Future<List<Enrollment>> getMyEnrollments(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final userId = authInfo.authUserId;

    final enrollments = await Enrollment.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.enrolledAt,
      orderDescending: true,
    );

    // Manually load course for each enrollment
    for (final enrollment in enrollments) {
      enrollment.course = await Course.db.findById(session, enrollment.courseId);
    }

    return enrollments;
  }

  /// Gets the number of students enrolled in a course.
  Future<int> getEnrollmentCount(Session session, int courseId) async {
    final enrollments = await Enrollment.db.find(
      session,
      where: (t) => t.courseId.equals(courseId),
    );
    return enrollments.length;
  }

  // ---------------------------------------------------------------------------
  // Module Progress Tracking
  // ---------------------------------------------------------------------------

  /// Marks a module as completed for the authenticated user.
  /// Creates progress record if it doesn't exist, or updates it.
  Future<ModuleProgress> markModuleComplete(
    Session session,
    int courseId,
    int moduleId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final userId = authInfo.authUserId;

    // Check if progress record already exists
    final existing = await ModuleProgress.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.moduleId.equals(moduleId),
    );

    if (existing != null) {
      existing.completed = true;
      existing.completedAt = DateTime.now();
      return await ModuleProgress.db.updateRow(session, existing);
    }

    // Create new progress record
    final progress = ModuleProgress(
      userId: userId,
      moduleId: moduleId,
      courseId: courseId,
      completed: true,
      completedAt: DateTime.now(),
      startedAt: DateTime.now(),
    );

    return await ModuleProgress.db.insertRow(session, progress);
  }

  /// Gets all module progress records for a specific course.
  Future<List<ModuleProgress>> getMyProgress(
    Session session,
    int courseId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final userId = authInfo.authUserId;

    return await ModuleProgress.db.find(
      session,
      where: (t) => t.userId.equals(userId) & t.courseId.equals(courseId),
    );
  }

  /// Gets the course progress percentage (completed modules / total modules).
  Future<double> getCourseProgress(
    Session session,
    int courseId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User not authenticated');
    }

    final userId = authInfo.authUserId;

    // Count total modules in the course
    final totalModules = await Module.db.count(
      session,
      where: (t) => t.courseId.equals(courseId),
    );

    if (totalModules == 0) return 0.0;

    // Count completed modules
    final completedModules = await ModuleProgress.db.count(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.courseId.equals(courseId) &
          t.completed.equals(true),
    );

    return completedModules / totalModules;
  }

  // ---------------------------------------------------------------------------
  // File Content Reading
  // ---------------------------------------------------------------------------

  /// Read file content from S3 public URL
  /// Currently supports TXT files, returns placeholder for others
  Future<String> _readFileContent(
    Session session,
    KnowledgeFile file,
  ) async {
    try {
      session.log(
        '📄 [FILE] Reading file: ${file.fileName}',
        level: LogLevel.info,
      );
      session.log(
        '📄 [FILE] File URL: ${file.fileUrl}',
        level: LogLevel.debug,
      );
      session.log(
        '📄 [FILE] File type: ${file.fileType}',
        level: LogLevel.debug,
      );

      // Fetch file content from public URL
      final response = await http.get(Uri.parse(file.fileUrl));

      session.log(
        '📄 [FILE] HTTP response: ${response.statusCode}',
        level: LogLevel.debug,
      );

      if (response.statusCode != 200) {
        session.log(
          '❌ Failed to fetch file ${file.fileName}: HTTP ${response.statusCode}',
          level: LogLevel.warning,
        );
        session.log(
          '❌ Response body: ${response.body}',
          level: LogLevel.debug,
        );
        return '[Unable to read file: ${file.fileName}]';
      }

      // Handle text files
      if (file.fileType?.toLowerCase() == 'txt') {
        final content = utf8.decode(response.bodyBytes);
        session.log(
          '✅ [FILE] Successfully read TXT file: ${content.length} chars',
          level: LogLevel.info,
        );
        session.log(
          '📝 [FILE] Content preview (first 300 chars):\n${content.length > 300 ? content.substring(0, 300) : content}',
          level: LogLevel.debug,
        );
        return content;
      }

      // For PDF/DOCX, return placeholder for now
      // Can be enhanced with pdf/docx parsing packages
      if (file.fileType?.toLowerCase() == 'pdf') {
        session.log(
          '⚠️ [FILE] PDF file detected - text extraction not implemented',
          level: LogLevel.warning,
        );
        return '[PDF file: ${file.fileName} - text extraction not yet implemented. Please convert to TXT for now.]';
      }

      if (file.fileType?.toLowerCase() == 'docx' ||
          file.fileType?.toLowerCase() == 'doc') {
        session.log(
          '⚠️ [FILE] Word document detected - text extraction not implemented',
          level: LogLevel.warning,
        );
        return '[Word document: ${file.fileName} - text extraction not yet implemented. Please convert to TXT for now.]';
      }

      // Unknown file type
      session.log(
        '⚠️ [FILE] Unknown file type: ${file.fileType}',
        level: LogLevel.warning,
      );
      return '[File type ${file.fileType}: ${file.fileName} - please use TXT files]';
    } catch (e, stackTrace) {
      session.log(
        '❌ Error reading file ${file.fileName}: $e',
        level: LogLevel.error,
      );
      session.log('Stack trace: $stackTrace', level: LogLevel.debug);
      return '[Error reading file: ${file.fileName} - $e]';
    }
  }

  // ---------------------------------------------------------------------------
  // Generate Course Table of Contents (Modules + Topics via AI)
  // ---------------------------------------------------------------------------

  /// Generates a full course table of contents using Gemini AI.
  /// Creates Modules with Topics (via ModuleItems) based on course info
  /// and uploaded knowledge files. Deletes existing modules first.
  ///
  /// [customPrompt] - Optional custom instructions for structuring the TOC
  Future<List<Module>> generateCourseTableOfContents(
    Session session,
    int courseId, {
    String? customPrompt,
  }) async {
    // Fetch course with knowledge files
    final course = await Course.db.findById(
      session,
      courseId,
      include: Course.include(
        knowledgeFiles: KnowledgeFile.includeList(),
      ),
    );

    if (course == null) {
      throw Exception('Course not found');
    }

    final apiKey = session.passwords['geminiApiKey'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    // Debug: Check if files exist separately
    final allFiles = await KnowledgeFile.db.find(
      session,
      where: (t) => t.courseId.equals(courseId),
    );
    session.log(
      '🔍 [DEBUG] Direct query found ${allFiles.length} knowledge files for courseId $courseId',
      level: LogLevel.info,
    );
    for (final file in allFiles) {
      session.log(
        '  📄 File: ${file.fileName} (courseId: ${file.courseId})',
        level: LogLevel.debug,
      );
    }

    // If include didn't work, manually assign files
    if (course.knowledgeFiles == null || course.knowledgeFiles!.isEmpty) {
      if (allFiles.isNotEmpty) {
        session.log(
          '⚠️ [DEBUG] Include failed! Manually assigning ${allFiles.length} files to course',
          level: LogLevel.warning,
        );
        course.knowledgeFiles = allFiles;
      }
    }

    // Use RAG to get relevant knowledge for TOC generation
    session.log(
      '🔍 [TOC RAG] Using semantic search for course: ${course.title}',
      level: LogLevel.info,
    );
    session.log(
      '🔍 [TOC RAG] Knowledge files count: ${allFiles.length}',
      level: LogLevel.info,
    );

    // Build query for RAG based on course context
    final ragQuery = '''
Generate a comprehensive table of contents for course: ${course.title}
${course.description != null ? 'Description: ${course.description}' : ''}
${course.systemPrompt != null ? 'Focus: ${course.systemPrompt}' : ''}
${customPrompt != null ? 'Requirements: $customPrompt' : ''}
''';

    session.log('🔍 [TOC RAG] Query: $ragQuery');

    // Use RAG to retrieve most relevant knowledge chunks
    final relevantKnowledge = await findRelevantKnowledge(
      session,
      ragQuery,
      courseId,
      limit: 10, // Get more chunks for comprehensive TOC
    );

    session.log('✅ [TOC RAG] Retrieved ${relevantKnowledge.length} relevant chunks');

    // Build knowledge content from RAG results
    final fileContents = <String>[];
    if (relevantKnowledge.isNotEmpty) {
      for (final file in relevantKnowledge) {
        session.log('📄 [TOC RAG] Including: ${file.fileName}');
        fileContents.add('''
File: ${file.fileName}
Type: ${file.fileType ?? 'unknown'}
---
${file.textContent ?? '[No content]'}
---
''');
      }
    } else {
      session.log(
        '⚠️ [TOC RAG] No relevant knowledge found - embeddings may not be generated yet',
        level: LogLevel.warning,
      );

      // Fallback: Read all files if no embeddings exist
      session.log('📚 [TOC RAG] Falling back to reading all files...');
      for (final file in allFiles) {
        final content = await _readFileContent(session, file);
        if (content.isNotEmpty) {
          final truncated = content.length > 10000
              ? '${content.substring(0, 10000)}\n[... truncated ...]'
              : content;
          fileContents.add('''
File: ${file.fileName}
---
$truncated
---
''');
        }
      }
    }

    final knowledgeContent = fileContents.isEmpty
        ? 'No knowledge files uploaded. Generate a generic course structure.'
        : fileContents.join('\n\n');

    session.log(
      '📝 [TOC] Total knowledge content length: ${knowledgeContent.length} chars',
      level: LogLevel.info,
    );
    session.log(
      '📝 [TOC] Custom prompt: ${customPrompt ?? "none"}',
      level: LogLevel.info,
    );

    final prompt = '''
Analyze this course and generate a comprehensive, detailed table of contents / syllabus.

Course Title: ${course.title}
Course Description: ${course.description ?? 'No description'}
System Prompt / Topic: ${course.systemPrompt ?? 'No topic specified'}

${customPrompt != null ? 'Custom Instructions: $customPrompt\n' : ''}

RELEVANT KNOWLEDGE (Retrieved via semantic search):
$knowledgeContent

IMPORTANT: Generate a complete, detailed course structure with modules and topics based on the course information and relevant knowledge above.
The knowledge content has been intelligently selected based on relevance to this course topic.

Generate a JSON array of modules, each containing multiple topics. Return ONLY valid JSON with no markdown code fences or additional text.

Required JSON Format:
[
  {
    "title": "Module title (e.g., Introduction to Machine Learning)",
    "description": "Detailed 2-3 sentence description of what this module covers, including key concepts and learning outcomes",
    "topics": [
      {
        "title": "Topic/Lesson title (e.g., What is Machine Learning?)",
        "description": "Detailed 1-2 sentence description explaining what students will learn in this specific lesson"
      },
      {
        "title": "Second topic in this module",
        "description": "Detailed description of the second topic with specific learning points"
      }
    ]
  }
]

CRITICAL JSON FORMATTING RULES:
- All descriptions MUST be on a single line (no newlines or line breaks)
- All quotes inside strings MUST be escaped with backslash: \\"
- Do NOT include any text before or after the JSON array
- Do NOT use markdown code fences
- Ensure all strings are properly terminated with quotes
- Keep descriptions concise but informative (max 200 characters each)

Guidelines:
- Generate 4-8 modules that form a logical learning progression
- EACH module MUST have 3-6 topics (lessons)
- Topics should be specific, actionable learning units
- Use the retrieved knowledge content to inform module and topic structure with accurate details
- Module and topic descriptions should be detailed and informative (not generic)
- Reference specific concepts, techniques, or examples from the knowledge base
- Start with foundational concepts and progress to advanced topics
- Module titles should be concise (2-5 words) but descriptive
- Topic titles should be specific and actionable
- Topic descriptions should be 1-2 sentences explaining the content
- Base the structure on the course topic and uploaded files
''';

    session.log(
      '🤖 [TOC] Sending prompt to Gemini (${prompt.length} chars)',
      level: LogLevel.info,
    );
    session.log(
      '🤖 [TOC] Prompt preview (first 500 chars):\n${prompt.substring(0, prompt.length > 500 ? 500 : prompt.length)}',
      level: LogLevel.debug,
    );

    final gemini = GeminiService(apiKey: apiKey);
    final response = await gemini.chat(
      message: prompt,
      enableTools: false,
      maxOutputTokens: 8192,
      responseMimeType: 'application/json',
    );

    session.log(
      '✅ [TOC] Received response from Gemini (${response.length} chars)',
      level: LogLevel.info,
    );
    session.log(
      '📋 [TOC] Full Gemini response:\n$response',
      level: LogLevel.debug,
    );

    // Parse the JSON response
    try {
      // Extract JSON from the response (handle possible markdown wrapping)
      var jsonStr = response.trim();

      // Remove BOM if present
      if (jsonStr.startsWith('\uFEFF')) {
        jsonStr = jsonStr.substring(1);
      }

      // Remove markdown code fences if present
      if (jsonStr.startsWith('```')) {
        session.log('🔧 [TOC] Stripping markdown code fence', level: LogLevel.debug);
        jsonStr = jsonStr.replaceFirst(RegExp(r'^```\w*\n?'), '');
        jsonStr = jsonStr.replaceFirst(RegExp(r'\n?```$'), '');
        jsonStr = jsonStr.trim();
      }

      // Remove trailing commas before closing brackets/braces (common LLM mistake)
      jsonStr = jsonStr.replaceAll(RegExp(r',\s*([\]\}])'), r'$1');

      // Remove control characters that can break JSON parsing
      jsonStr = jsonStr.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

      // Try to parse the JSON directly first
      dynamic parsed;
      try {
        parsed = jsonDecode(jsonStr);
        session.log(
          '✅ [TOC] Successfully parsed JSON directly (${jsonStr.length} chars)',
          level: LogLevel.debug,
        );
      } catch (e) {
        // If direct parsing fails, try to extract JSON array boundaries
        session.log(
          '⚠️ [TOC] Direct JSON parsing failed: $e. Attempting to extract JSON boundaries...',
          level: LogLevel.warning,
        );

        // Find the first '[' and last ']'
        final firstBracket = jsonStr.indexOf('[');
        final lastBracket = jsonStr.lastIndexOf(']');

        if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {
          final extracted = jsonStr.substring(firstBracket, lastBracket + 1);
          session.log(
            '🔧 [TOC] Extracted JSON array boundaries (${extracted.length} chars)',
            level: LogLevel.debug,
          );
          parsed = jsonDecode(extracted);
          session.log(
            '✅ [TOC] Successfully parsed extracted JSON',
            level: LogLevel.debug,
          );
        } else {
          session.log(
            '❌ [TOC] Could not find valid JSON array boundaries',
            level: LogLevel.error,
          );
          rethrow;
        }
      }

      // Validate it's a list
      if (parsed is! List) {
        session.log(
          '❌ [TOC] Gemini response is not a JSON array! Got: ${parsed.runtimeType}',
          level: LogLevel.error,
        );
        throw Exception('Expected JSON array of modules, got ${parsed.runtimeType}');
      }

      if (parsed.isEmpty) {
        session.log(
          '⚠️ [TOC] Gemini returned an empty array!',
          level: LogLevel.warning,
        );
        return [];
      }

      session.log(
        '✅ [TOC] Parsed ${parsed.length} modules from JSON',
        level: LogLevel.info,
      );

      // Delete existing modules (cascade deletes module_items too)
      session.log(
        '🗑️ [TOC] Deleting existing modules for course',
        level: LogLevel.info,
      );
      final deletedModules = await Module.db.deleteWhere(
        session,
        where: (t) => t.courseId.equals(courseId),
      );
      session.log(
        '🗑️ [TOC] Deleted ${deletedModules.length} existing modules',
        level: LogLevel.info,
      );

      // Create modules with their topics
      session.log(
        '🏗️ [TOC] Creating ${parsed.length} modules with topics',
        level: LogLevel.info,
      );

      for (var i = 0; i < parsed.length; i++) {
        final entry = parsed[i] as Map<String, dynamic>;

        // Validate module has topics
        final topics = entry['topics'] as List<dynamic>? ?? [];
        if (topics.isEmpty) {
          session.log(
            '⚠️ [TOC] Module "${entry['title']}" has no topics! Skipping...',
            level: LogLevel.warning,
          );
          continue;
        }

        // Create the module
        final module = Module(
          title: entry['title'] as String? ?? 'Untitled Module',
          description: entry['description'] as String?,
          sortOrder: i + 1,
          courseId: courseId,
        );
        final createdModule = await Module.db.insertRow(session, module);
        session.log(
          '📦 [TOC] Created module ${i + 1}: "${module.title}" (ID: ${createdModule.id})',
          level: LogLevel.info,
        );

        // Create topics and link them via ModuleItems
        session.log(
          '  📝 [TOC] Module has ${topics.length} topics',
          level: LogLevel.debug,
        );

        for (var j = 0; j < topics.length; j++) {
          final topicEntry = topics[j] as Map<String, dynamic>;

          // Create the topic
          final topic = Topic(
            title: topicEntry['title'] as String? ?? 'Untitled Topic',
            description: topicEntry['description'] as String?,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          final createdTopic = await Topic.db.insertRow(session, topic);

          session.log(
            '    📄 [TOC] Created topic ${j + 1}: "${topic.title}" (ID: ${createdTopic.id})',
            level: LogLevel.debug,
          );

          // Link topic to module via ModuleItem
          final moduleItem = ModuleItem(
            sortOrder: j + 1,
            contextualDescription: topicEntry['description'] as String?,
            moduleId: createdModule.id!,
            topicId: createdTopic.id!,
          );
          final createdItem = await ModuleItem.db.insertRow(session, moduleItem);

          session.log(
            '    🔗 [TOC] Linked topic to module via ModuleItem (ID: ${createdItem.id})',
            level: LogLevel.debug,
          );
        }
      }

      session.log(
        '✅ [TOC] Successfully created all modules and topics',
        level: LogLevel.info,
      );

      // Query modules without items first
      final modules = await Module.db.find(
        session,
        where: (t) => t.courseId.equals(courseId),
        orderBy: (t) => t.sortOrder,
      );

      session.log(
        '🔄 [TOC] Fetching module items and topics for ${modules.length} modules',
        level: LogLevel.debug,
      );

      // Manually load ModuleItems for each module
      int totalTopicsLoaded = 0;
      for (final module in modules) {
        // Find all ModuleItems for this module
        final items = await ModuleItem.db.find(
          session,
          where: (t) => t.moduleId.equals(module.id!),
          orderBy: (t) => t.sortOrder,
        );

        session.log(
          '  📦 [TOC] Module "${module.title}" (ID: ${module.id}): Found ${items.length} items',
          level: LogLevel.debug,
        );

        // Load topic for each item
        for (final item in items) {
          item.topic = await Topic.db.findById(session, item.topicId);
          if (item.topic != null) {
            session.log(
              '    ✅ [TOC] Loaded topic: "${item.topic!.title}" (ID: ${item.topic!.id})',
              level: LogLevel.debug,
            );
          } else {
            session.log(
              '    ❌ [TOC] Failed to load topic with ID: ${item.topicId}',
              level: LogLevel.warning,
            );
          }
        }

        module.items = items;
        totalTopicsLoaded += items.length;
      }

      session.log(
        '🎉 [TOC] Generation complete! Created ${modules.length} modules with $totalTopicsLoaded topics total',
        level: LogLevel.info,
      );

      for (final module in modules) {
        session.log(
          '  📦 Module: "${module.title}" (${module.items?.length ?? 0} topics)',
          level: LogLevel.info,
        );
      }

      return modules;
    } catch (e, stackTrace) {
      session.log('❌ [TOC] Failed to parse TOC response: $e', level: LogLevel.error);
      session.log('❌ [TOC] Stack trace: $stackTrace', level: LogLevel.error);

      // Log the problematic response for debugging
      if (response.length < 5000) {
        session.log('❌ [TOC] Full response:\n$response', level: LogLevel.error);
      } else {
        session.log('❌ [TOC] Response preview (first 2000 chars):\n${response.substring(0, 2000)}', level: LogLevel.error);
        session.log('❌ [TOC] Response preview (last 2000 chars):\n${response.substring(response.length - 2000)}', level: LogLevel.error);
      }

      throw Exception('Failed to generate course table of contents. The AI response contained invalid JSON. Please try again or contact support if the issue persists.');
    }
  }

  // ---------------------------------------------------------------------------
  // File Upload (S3 Cloud Storage)
  // ---------------------------------------------------------------------------

  /// Returns a signed upload description for direct client-to-S3 upload
  Future<String?> getUploadDescription(Session session, String path) async {
    session.log('📤 [LmsEndpoint] getUploadDescription called');
    session.log('📤 [LmsEndpoint] Path: $path');

    try {
      final description = await session.storage.createDirectFileUploadDescription(
        storageId: 'public',
        path: path,
      );
      session.log('✅ [LmsEndpoint] Got upload description: ${description != null ? "OK (${description.length} chars)" : "NULL"}');
      return description;
    } catch (e, stackTrace) {
      session.log('❌ [LmsEndpoint] getUploadDescription error: $e');
      session.log('❌ [LmsEndpoint] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Verifies that a direct file upload completed successfully
  Future<bool> verifyUpload(Session session, String path) async {
    session.log('🔍 [LmsEndpoint] verifyUpload called');
    session.log('🔍 [LmsEndpoint] Path: $path');

    try {
      final verified = await session.storage.verifyDirectFileUpload(
        storageId: 'public',
        path: path,
      );
      session.log('${verified ? "✅" : "❌"} [LmsEndpoint] Verification result: $verified');
      return verified;
    } catch (e, stackTrace) {
      session.log('❌ [LmsEndpoint] verifyUpload error: $e');
      session.log('❌ [LmsEndpoint] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Returns the public URL for an uploaded file
  Future<String?> getPublicUrl(Session session, String path) async {
    session.log('🔗 [LmsEndpoint] getPublicUrl called');
    session.log('🔗 [LmsEndpoint] Path: $path');

    try {
      final uri = await session.storage.getPublicUrl(
        storageId: 'public',
        path: path,
      );
      session.log('✅ [LmsEndpoint] Public URL: $uri');
      return uri?.toString();
    } catch (e, stackTrace) {
      session.log('❌ [LmsEndpoint] getPublicUrl error: $e');
      session.log('❌ [LmsEndpoint] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // RAG - Semantic Search on Knowledge Files
  // ---------------------------------------------------------------------------

  /// Find relevant knowledge file chunks using semantic search
  /// Returns top-k most similar documents based on cosine similarity
  Future<List<KnowledgeFile>> findRelevantKnowledge(
    Session session,
    String query,
    int courseId, {
    int limit = 5,
    double similarityThreshold = 0.3,
  }) async {
    session.log('🔍 [RAG] Searching knowledge for query: "$query"');
    session.log('🔍 [RAG] Course ID: $courseId, Limit: $limit');

    try {
      // Generate embedding for the query
      final apiKey = session.passwords['geminiApiKey'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key not configured');
      }

      final gemini = GeminiService(apiKey: apiKey);
      final queryEmbedding = await gemini.generateEmbedding(query);

      session.log('✅ [RAG] Generated query embedding: ${queryEmbedding.length} dimensions');

      // Convert List<double> to Vector for Serverpod
      final queryVector = Vector(queryEmbedding);

      // Find similar documents using vector search
      // First filter by courseId, then order by similarity
      final results = await KnowledgeFile.db.find(
        session,
        where: (t) => t.courseId.equals(courseId),
        orderBy: (t) => t.embedding.distanceCosine(queryVector),
        limit: limit,
      );

      session.log('✅ [RAG] Found ${results.length} relevant knowledge chunks');

      for (var i = 0; i < results.length; i++) {
        session.log('  ${i + 1}. ${results[i].fileName} (${results[i].textContent?.length ?? 0} chars)');
      }

      return results;
    } catch (e, stackTrace) {
      session.log('❌ [RAG] Error during knowledge search: $e');
      session.log('Stack trace: $stackTrace');
      return []; // Return empty list on error
    }
  }
}
