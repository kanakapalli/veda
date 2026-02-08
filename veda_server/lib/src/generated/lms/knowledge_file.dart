/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../lms/course.dart' as _i2;
import 'package:veda_server/src/generated/protocol.dart' as _i3;

/// KnowledgeFile - source material for AI course generation with RAG support
abstract class KnowledgeFile
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  KnowledgeFile._({
    this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.fileType,
    this.textContent,
    this.embedding,
    DateTime? uploadedAt,
    required this.courseId,
    this.course,
  }) : uploadedAt = uploadedAt ?? DateTime.now(),
       _coursesKnowledgefilesCoursesId = null;

  factory KnowledgeFile({
    int? id,
    required String fileName,
    required String fileUrl,
    required int fileSize,
    String? fileType,
    String? textContent,
    _i1.Vector? embedding,
    DateTime? uploadedAt,
    required int courseId,
    _i2.Course? course,
  }) = _KnowledgeFileImpl;

  factory KnowledgeFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return KnowledgeFileImplicit._(
      id: jsonSerialization['id'] as int?,
      fileName: jsonSerialization['fileName'] as String,
      fileUrl: jsonSerialization['fileUrl'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      fileType: jsonSerialization['fileType'] as String?,
      textContent: jsonSerialization['textContent'] as String?,
      embedding: jsonSerialization['embedding'] == null
          ? null
          : _i1.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
      uploadedAt: jsonSerialization['uploadedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['uploadedAt']),
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Course>(jsonSerialization['course']),
      $_coursesKnowledgefilesCoursesId:
          jsonSerialization['_coursesKnowledgefilesCoursesId'] as int?,
    );
  }

  static final t = KnowledgeFileTable();

  static const db = KnowledgeFileRepository._();

  @override
  int? id;

  /// Original file name
  String fileName;

  /// URL to the stored file
  String fileUrl;

  /// File size in bytes
  int fileSize;

  /// File MIME type or extension
  String? fileType;

  /// Extracted text content for RAG
  String? textContent;

  /// Embedding vector for semantic search (3072 dimensions for gemini-embedding-001)
  _i1.Vector? embedding;

  /// Timestamp when the file was uploaded
  DateTime uploadedAt;

  /// Foreign key to parent course
  int courseId;

  /// Parent course reference
  _i2.Course? course;

  final int? _coursesKnowledgefilesCoursesId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [KnowledgeFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  KnowledgeFile copyWith({
    int? id,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    String? fileType,
    String? textContent,
    _i1.Vector? embedding,
    DateTime? uploadedAt,
    int? courseId,
    _i2.Course? course,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'KnowledgeFile',
      if (id != null) 'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      if (fileType != null) 'fileType': fileType,
      if (textContent != null) 'textContent': textContent,
      if (embedding != null) 'embedding': embedding?.toJson(),
      'uploadedAt': uploadedAt.toJson(),
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
      if (_coursesKnowledgefilesCoursesId != null)
        '_coursesKnowledgefilesCoursesId': _coursesKnowledgefilesCoursesId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'KnowledgeFile',
      if (id != null) 'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      if (fileType != null) 'fileType': fileType,
      if (textContent != null) 'textContent': textContent,
      if (embedding != null) 'embedding': embedding?.toJson(),
      'uploadedAt': uploadedAt.toJson(),
      'courseId': courseId,
      if (course != null) 'course': course?.toJsonForProtocol(),
    };
  }

  static KnowledgeFileInclude include() {
    return KnowledgeFileInclude._();
  }

  static KnowledgeFileIncludeList includeList({
    _i1.WhereExpressionBuilder<KnowledgeFileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<KnowledgeFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<KnowledgeFileTable>? orderByList,
    KnowledgeFileInclude? include,
  }) {
    return KnowledgeFileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(KnowledgeFile.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(KnowledgeFile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _KnowledgeFileImpl extends KnowledgeFile {
  _KnowledgeFileImpl({
    int? id,
    required String fileName,
    required String fileUrl,
    required int fileSize,
    String? fileType,
    String? textContent,
    _i1.Vector? embedding,
    DateTime? uploadedAt,
    required int courseId,
    _i2.Course? course,
  }) : super._(
         id: id,
         fileName: fileName,
         fileUrl: fileUrl,
         fileSize: fileSize,
         fileType: fileType,
         textContent: textContent,
         embedding: embedding,
         uploadedAt: uploadedAt,
         courseId: courseId,
         course: course,
       );

  /// Returns a shallow copy of this [KnowledgeFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  KnowledgeFile copyWith({
    Object? id = _Undefined,
    String? fileName,
    String? fileUrl,
    int? fileSize,
    Object? fileType = _Undefined,
    Object? textContent = _Undefined,
    Object? embedding = _Undefined,
    DateTime? uploadedAt,
    int? courseId,
    Object? course = _Undefined,
  }) {
    return KnowledgeFileImplicit._(
      id: id is int? ? id : this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType is String? ? fileType : this.fileType,
      textContent: textContent is String? ? textContent : this.textContent,
      embedding: embedding is _i1.Vector? ? embedding : this.embedding?.clone(),
      uploadedAt: uploadedAt ?? this.uploadedAt,
      courseId: courseId ?? this.courseId,
      course: course is _i2.Course? ? course : this.course?.copyWith(),
      $_coursesKnowledgefilesCoursesId: this._coursesKnowledgefilesCoursesId,
    );
  }
}

class KnowledgeFileImplicit extends _KnowledgeFileImpl {
  KnowledgeFileImplicit._({
    int? id,
    required String fileName,
    required String fileUrl,
    required int fileSize,
    String? fileType,
    String? textContent,
    _i1.Vector? embedding,
    DateTime? uploadedAt,
    required int courseId,
    _i2.Course? course,
    int? $_coursesKnowledgefilesCoursesId,
  }) : _coursesKnowledgefilesCoursesId = $_coursesKnowledgefilesCoursesId,
       super(
         id: id,
         fileName: fileName,
         fileUrl: fileUrl,
         fileSize: fileSize,
         fileType: fileType,
         textContent: textContent,
         embedding: embedding,
         uploadedAt: uploadedAt,
         courseId: courseId,
         course: course,
       );

  factory KnowledgeFileImplicit(
    KnowledgeFile knowledgeFile, {
    int? $_coursesKnowledgefilesCoursesId,
  }) {
    return KnowledgeFileImplicit._(
      id: knowledgeFile.id,
      fileName: knowledgeFile.fileName,
      fileUrl: knowledgeFile.fileUrl,
      fileSize: knowledgeFile.fileSize,
      fileType: knowledgeFile.fileType,
      textContent: knowledgeFile.textContent,
      embedding: knowledgeFile.embedding,
      uploadedAt: knowledgeFile.uploadedAt,
      courseId: knowledgeFile.courseId,
      course: knowledgeFile.course,
      $_coursesKnowledgefilesCoursesId: $_coursesKnowledgefilesCoursesId,
    );
  }

  @override
  final int? _coursesKnowledgefilesCoursesId;
}

class KnowledgeFileUpdateTable extends _i1.UpdateTable<KnowledgeFileTable> {
  KnowledgeFileUpdateTable(super.table);

  _i1.ColumnValue<String, String> fileName(String value) => _i1.ColumnValue(
    table.fileName,
    value,
  );

  _i1.ColumnValue<String, String> fileUrl(String value) => _i1.ColumnValue(
    table.fileUrl,
    value,
  );

  _i1.ColumnValue<int, int> fileSize(int value) => _i1.ColumnValue(
    table.fileSize,
    value,
  );

  _i1.ColumnValue<String, String> fileType(String? value) => _i1.ColumnValue(
    table.fileType,
    value,
  );

  _i1.ColumnValue<String, String> textContent(String? value) => _i1.ColumnValue(
    table.textContent,
    value,
  );

  _i1.ColumnValue<_i1.Vector, _i1.Vector> embedding(_i1.Vector? value) =>
      _i1.ColumnValue(
        table.embedding,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> uploadedAt(DateTime value) =>
      _i1.ColumnValue(
        table.uploadedAt,
        value,
      );

  _i1.ColumnValue<int, int> courseId(int value) => _i1.ColumnValue(
    table.courseId,
    value,
  );

  _i1.ColumnValue<_i2.Course, _i2.Course> course(_i2.Course? value) =>
      _i1.ColumnValue(
        table.course,
        value,
      );

  _i1.ColumnValue<int, int> $_coursesKnowledgefilesCoursesId(int? value) =>
      _i1.ColumnValue(
        table.$_coursesKnowledgefilesCoursesId,
        value,
      );
}

class KnowledgeFileTable extends _i1.Table<int?> {
  KnowledgeFileTable({super.tableRelation})
    : super(tableName: 'knowledge_files') {
    updateTable = KnowledgeFileUpdateTable(this);
    fileName = _i1.ColumnString(
      'fileName',
      this,
    );
    fileUrl = _i1.ColumnString(
      'fileUrl',
      this,
    );
    fileSize = _i1.ColumnInt(
      'fileSize',
      this,
    );
    fileType = _i1.ColumnString(
      'fileType',
      this,
    );
    textContent = _i1.ColumnString(
      'textContent',
      this,
    );
    embedding = _i1.ColumnVector(
      'embedding',
      this,
      dimension: 3072,
    );
    uploadedAt = _i1.ColumnDateTime(
      'uploadedAt',
      this,
      hasDefault: true,
    );
    courseId = _i1.ColumnInt(
      'courseId',
      this,
    );
    course = _i1.ColumnSerializable<_i2.Course>(
      'course',
      this,
    );
    $_coursesKnowledgefilesCoursesId = _i1.ColumnInt(
      '_coursesKnowledgefilesCoursesId',
      this,
    );
  }

  late final KnowledgeFileUpdateTable updateTable;

  /// Original file name
  late final _i1.ColumnString fileName;

  /// URL to the stored file
  late final _i1.ColumnString fileUrl;

  /// File size in bytes
  late final _i1.ColumnInt fileSize;

  /// File MIME type or extension
  late final _i1.ColumnString fileType;

  /// Extracted text content for RAG
  late final _i1.ColumnString textContent;

  /// Embedding vector for semantic search (3072 dimensions for gemini-embedding-001)
  late final _i1.ColumnVector embedding;

  /// Timestamp when the file was uploaded
  late final _i1.ColumnDateTime uploadedAt;

  /// Foreign key to parent course
  late final _i1.ColumnInt courseId;

  /// Parent course reference
  late final _i1.ColumnSerializable<_i2.Course> course;

  late final _i1.ColumnInt $_coursesKnowledgefilesCoursesId;

  @override
  List<_i1.Column> get columns => [
    id,
    fileName,
    fileUrl,
    fileSize,
    fileType,
    textContent,
    embedding,
    uploadedAt,
    courseId,
    course,
    $_coursesKnowledgefilesCoursesId,
  ];

  @override
  List<_i1.Column> get managedColumns => [
    id,
    fileName,
    fileUrl,
    fileSize,
    fileType,
    textContent,
    embedding,
    uploadedAt,
    courseId,
    course,
  ];
}

class KnowledgeFileInclude extends _i1.IncludeObject {
  KnowledgeFileInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => KnowledgeFile.t;
}

class KnowledgeFileIncludeList extends _i1.IncludeList {
  KnowledgeFileIncludeList._({
    _i1.WhereExpressionBuilder<KnowledgeFileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(KnowledgeFile.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => KnowledgeFile.t;
}

class KnowledgeFileRepository {
  const KnowledgeFileRepository._();

  /// Returns a list of [KnowledgeFile]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<KnowledgeFile>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<KnowledgeFileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<KnowledgeFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<KnowledgeFileTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<KnowledgeFile>(
      where: where?.call(KnowledgeFile.t),
      orderBy: orderBy?.call(KnowledgeFile.t),
      orderByList: orderByList?.call(KnowledgeFile.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [KnowledgeFile] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<KnowledgeFile?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<KnowledgeFileTable>? where,
    int? offset,
    _i1.OrderByBuilder<KnowledgeFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<KnowledgeFileTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<KnowledgeFile>(
      where: where?.call(KnowledgeFile.t),
      orderBy: orderBy?.call(KnowledgeFile.t),
      orderByList: orderByList?.call(KnowledgeFile.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [KnowledgeFile] by its [id] or null if no such row exists.
  Future<KnowledgeFile?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<KnowledgeFile>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [KnowledgeFile]s in the list and returns the inserted rows.
  ///
  /// The returned [KnowledgeFile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<KnowledgeFile>> insert(
    _i1.Session session,
    List<KnowledgeFile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<KnowledgeFile>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [KnowledgeFile] and returns the inserted row.
  ///
  /// The returned [KnowledgeFile] will have its `id` field set.
  Future<KnowledgeFile> insertRow(
    _i1.Session session,
    KnowledgeFile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<KnowledgeFile>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [KnowledgeFile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<KnowledgeFile>> update(
    _i1.Session session,
    List<KnowledgeFile> rows, {
    _i1.ColumnSelections<KnowledgeFileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<KnowledgeFile>(
      rows,
      columns: columns?.call(KnowledgeFile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [KnowledgeFile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<KnowledgeFile> updateRow(
    _i1.Session session,
    KnowledgeFile row, {
    _i1.ColumnSelections<KnowledgeFileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<KnowledgeFile>(
      row,
      columns: columns?.call(KnowledgeFile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [KnowledgeFile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<KnowledgeFile?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<KnowledgeFileUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<KnowledgeFile>(
      id,
      columnValues: columnValues(KnowledgeFile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [KnowledgeFile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<KnowledgeFile>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<KnowledgeFileUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<KnowledgeFileTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<KnowledgeFileTable>? orderBy,
    _i1.OrderByListBuilder<KnowledgeFileTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<KnowledgeFile>(
      columnValues: columnValues(KnowledgeFile.t.updateTable),
      where: where(KnowledgeFile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(KnowledgeFile.t),
      orderByList: orderByList?.call(KnowledgeFile.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [KnowledgeFile]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<KnowledgeFile>> delete(
    _i1.Session session,
    List<KnowledgeFile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<KnowledgeFile>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [KnowledgeFile].
  Future<KnowledgeFile> deleteRow(
    _i1.Session session,
    KnowledgeFile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<KnowledgeFile>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<KnowledgeFile>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<KnowledgeFileTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<KnowledgeFile>(
      where: where(KnowledgeFile.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<KnowledgeFileTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<KnowledgeFile>(
      where: where?.call(KnowledgeFile.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
