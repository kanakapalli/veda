import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// LMS Endpoint - handles course management operations
class LmsEndpoint extends Endpoint {
  // ---------------------------------------------------------------------------
  // Course Management
  // ---------------------------------------------------------------------------

  /// Creates a new course with default draft visibility
  Future<Course> createCourse(Session session, Course course) async {
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

  // ---------------------------------------------------------------------------
  // Knowledge File Management
  // ---------------------------------------------------------------------------

  /// Adds a knowledge file to a course
  Future<KnowledgeFile> addFileToCourse(
    Session session,
    KnowledgeFile file,
  ) async {
    file.uploadedAt = DateTime.now();
    return await KnowledgeFile.db.insertRow(session, file);
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
  // Module Management
  // ---------------------------------------------------------------------------

  /// Gets all modules for a course with items and topics
  Future<List<Module>> getModules(Session session, int courseId) async {
    return await Module.db.find(
      session,
      where: (t) => t.courseId.equals(courseId),
      orderBy: (t) => t.sortOrder,
      include: Module.include(
        items: ModuleItem.includeList(
          orderBy: (t) => t.sortOrder,
        ),
      ),
    );
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
}
