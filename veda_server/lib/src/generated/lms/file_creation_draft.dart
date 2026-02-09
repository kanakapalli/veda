/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i2;
import 'package:veda_server/src/generated/protocol.dart' as _i3;

/// File Creation Draft - stores user's in-progress notes/files created with AI assistance
abstract class FileCreationDraft
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  FileCreationDraft._({
    this.id,
    required this.creatorId,
    this.creator,
    this.courseId,
    required this.title,
    required this.content,
    this.chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : fileType = fileType ?? 'md',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory FileCreationDraft({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    int? courseId,
    required String title,
    required String content,
    String? chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FileCreationDraftImpl;

  factory FileCreationDraft.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileCreationDraft(
      id: jsonSerialization['id'] as int?,
      creatorId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorId'],
      ),
      creator: jsonSerialization['creator'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['creator'],
            ),
      courseId: jsonSerialization['courseId'] as int?,
      title: jsonSerialization['title'] as String,
      content: jsonSerialization['content'] as String,
      chatHistory: jsonSerialization['chatHistory'] as String?,
      fileType: jsonSerialization['fileType'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = FileCreationDraftTable();

  static const db = FileCreationDraftRepository._();

  @override
  int? id;

  _i1.UuidValue creatorId;

  /// Link to the user who created this draft
  _i2.AuthUser? creator;

  /// Link to the course this draft belongs to
  int? courseId;

  /// Title of the file/note
  String title;

  /// Content in markdown format
  String content;

  /// AI chat history for this draft (JSON string)
  String? chatHistory;

  /// File type (txt, md, pdf)
  String fileType;

  /// Creation timestamp
  DateTime createdAt;

  /// Last update timestamp
  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [FileCreationDraft]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FileCreationDraft copyWith({
    int? id,
    _i1.UuidValue? creatorId,
    _i2.AuthUser? creator,
    int? courseId,
    String? title,
    String? content,
    String? chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileCreationDraft',
      if (id != null) 'id': id,
      'creatorId': creatorId.toJson(),
      if (creator != null) 'creator': creator?.toJson(),
      if (courseId != null) 'courseId': courseId,
      'title': title,
      'content': content,
      if (chatHistory != null) 'chatHistory': chatHistory,
      'fileType': fileType,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileCreationDraft',
      if (id != null) 'id': id,
      'creatorId': creatorId.toJson(),
      if (creator != null) 'creator': creator?.toJsonForProtocol(),
      if (courseId != null) 'courseId': courseId,
      'title': title,
      'content': content,
      if (chatHistory != null) 'chatHistory': chatHistory,
      'fileType': fileType,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static FileCreationDraftInclude include({_i2.AuthUserInclude? creator}) {
    return FileCreationDraftInclude._(creator: creator);
  }

  static FileCreationDraftIncludeList includeList({
    _i1.WhereExpressionBuilder<FileCreationDraftTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FileCreationDraftTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FileCreationDraftTable>? orderByList,
    FileCreationDraftInclude? include,
  }) {
    return FileCreationDraftIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileCreationDraft.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FileCreationDraft.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileCreationDraftImpl extends FileCreationDraft {
  _FileCreationDraftImpl({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    int? courseId,
    required String title,
    required String content,
    String? chatHistory,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         creatorId: creatorId,
         creator: creator,
         courseId: courseId,
         title: title,
         content: content,
         chatHistory: chatHistory,
         fileType: fileType,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FileCreationDraft]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FileCreationDraft copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? creatorId,
    Object? creator = _Undefined,
    Object? courseId = _Undefined,
    String? title,
    String? content,
    Object? chatHistory = _Undefined,
    String? fileType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileCreationDraft(
      id: id is int? ? id : this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator is _i2.AuthUser? ? creator : this.creator?.copyWith(),
      courseId: courseId is int? ? courseId : this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      chatHistory: chatHistory is String? ? chatHistory : this.chatHistory,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FileCreationDraftUpdateTable
    extends _i1.UpdateTable<FileCreationDraftTable> {
  FileCreationDraftUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> creatorId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.creatorId,
    value,
  );

  _i1.ColumnValue<int, int> courseId(int? value) => _i1.ColumnValue(
    table.courseId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> content(String value) => _i1.ColumnValue(
    table.content,
    value,
  );

  _i1.ColumnValue<String, String> chatHistory(String? value) => _i1.ColumnValue(
    table.chatHistory,
    value,
  );

  _i1.ColumnValue<String, String> fileType(String value) => _i1.ColumnValue(
    table.fileType,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class FileCreationDraftTable extends _i1.Table<int?> {
  FileCreationDraftTable({super.tableRelation})
    : super(tableName: 'file_creation_drafts') {
    updateTable = FileCreationDraftUpdateTable(this);
    creatorId = _i1.ColumnUuid(
      'creatorId',
      this,
    );
    courseId = _i1.ColumnInt(
      'courseId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    chatHistory = _i1.ColumnString(
      'chatHistory',
      this,
    );
    fileType = _i1.ColumnString(
      'fileType',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final FileCreationDraftUpdateTable updateTable;

  late final _i1.ColumnUuid creatorId;

  /// Link to the user who created this draft
  _i2.AuthUserTable? _creator;

  /// Link to the course this draft belongs to
  late final _i1.ColumnInt courseId;

  /// Title of the file/note
  late final _i1.ColumnString title;

  /// Content in markdown format
  late final _i1.ColumnString content;

  /// AI chat history for this draft (JSON string)
  late final _i1.ColumnString chatHistory;

  /// File type (txt, md, pdf)
  late final _i1.ColumnString fileType;

  /// Creation timestamp
  late final _i1.ColumnDateTime createdAt;

  /// Last update timestamp
  late final _i1.ColumnDateTime updatedAt;

  _i2.AuthUserTable get creator {
    if (_creator != null) return _creator!;
    _creator = _i1.createRelationTable(
      relationFieldName: 'creator',
      field: FileCreationDraft.t.creatorId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _creator!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    creatorId,
    courseId,
    title,
    content,
    chatHistory,
    fileType,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'creator') {
      return creator;
    }
    return null;
  }
}

class FileCreationDraftInclude extends _i1.IncludeObject {
  FileCreationDraftInclude._({_i2.AuthUserInclude? creator}) {
    _creator = creator;
  }

  _i2.AuthUserInclude? _creator;

  @override
  Map<String, _i1.Include?> get includes => {'creator': _creator};

  @override
  _i1.Table<int?> get table => FileCreationDraft.t;
}

class FileCreationDraftIncludeList extends _i1.IncludeList {
  FileCreationDraftIncludeList._({
    _i1.WhereExpressionBuilder<FileCreationDraftTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FileCreationDraft.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => FileCreationDraft.t;
}

class FileCreationDraftRepository {
  const FileCreationDraftRepository._();

  final attachRow = const FileCreationDraftAttachRowRepository._();

  /// Returns a list of [FileCreationDraft]s matching the given query parameters.
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
  Future<List<FileCreationDraft>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FileCreationDraftTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FileCreationDraftTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FileCreationDraftTable>? orderByList,
    _i1.Transaction? transaction,
    FileCreationDraftInclude? include,
  }) async {
    return session.db.find<FileCreationDraft>(
      where: where?.call(FileCreationDraft.t),
      orderBy: orderBy?.call(FileCreationDraft.t),
      orderByList: orderByList?.call(FileCreationDraft.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [FileCreationDraft] matching the given query parameters.
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
  Future<FileCreationDraft?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FileCreationDraftTable>? where,
    int? offset,
    _i1.OrderByBuilder<FileCreationDraftTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FileCreationDraftTable>? orderByList,
    _i1.Transaction? transaction,
    FileCreationDraftInclude? include,
  }) async {
    return session.db.findFirstRow<FileCreationDraft>(
      where: where?.call(FileCreationDraft.t),
      orderBy: orderBy?.call(FileCreationDraft.t),
      orderByList: orderByList?.call(FileCreationDraft.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [FileCreationDraft] by its [id] or null if no such row exists.
  Future<FileCreationDraft?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    FileCreationDraftInclude? include,
  }) async {
    return session.db.findById<FileCreationDraft>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [FileCreationDraft]s in the list and returns the inserted rows.
  ///
  /// The returned [FileCreationDraft]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<FileCreationDraft>> insert(
    _i1.Session session,
    List<FileCreationDraft> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<FileCreationDraft>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [FileCreationDraft] and returns the inserted row.
  ///
  /// The returned [FileCreationDraft] will have its `id` field set.
  Future<FileCreationDraft> insertRow(
    _i1.Session session,
    FileCreationDraft row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FileCreationDraft>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FileCreationDraft]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FileCreationDraft>> update(
    _i1.Session session,
    List<FileCreationDraft> rows, {
    _i1.ColumnSelections<FileCreationDraftTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FileCreationDraft>(
      rows,
      columns: columns?.call(FileCreationDraft.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FileCreationDraft]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FileCreationDraft> updateRow(
    _i1.Session session,
    FileCreationDraft row, {
    _i1.ColumnSelections<FileCreationDraftTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FileCreationDraft>(
      row,
      columns: columns?.call(FileCreationDraft.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FileCreationDraft] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FileCreationDraft?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<FileCreationDraftUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<FileCreationDraft>(
      id,
      columnValues: columnValues(FileCreationDraft.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FileCreationDraft]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<FileCreationDraft>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<FileCreationDraftUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<FileCreationDraftTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FileCreationDraftTable>? orderBy,
    _i1.OrderByListBuilder<FileCreationDraftTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<FileCreationDraft>(
      columnValues: columnValues(FileCreationDraft.t.updateTable),
      where: where(FileCreationDraft.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileCreationDraft.t),
      orderByList: orderByList?.call(FileCreationDraft.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [FileCreationDraft]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FileCreationDraft>> delete(
    _i1.Session session,
    List<FileCreationDraft> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FileCreationDraft>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FileCreationDraft].
  Future<FileCreationDraft> deleteRow(
    _i1.Session session,
    FileCreationDraft row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FileCreationDraft>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FileCreationDraft>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FileCreationDraftTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FileCreationDraft>(
      where: where(FileCreationDraft.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FileCreationDraftTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FileCreationDraft>(
      where: where?.call(FileCreationDraft.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class FileCreationDraftAttachRowRepository {
  const FileCreationDraftAttachRowRepository._();

  /// Creates a relation between the given [FileCreationDraft] and [AuthUser]
  /// by setting the [FileCreationDraft]'s foreign key `creatorId` to refer to the [AuthUser].
  Future<void> creator(
    _i1.Session session,
    FileCreationDraft fileCreationDraft,
    _i2.AuthUser creator, {
    _i1.Transaction? transaction,
  }) async {
    if (fileCreationDraft.id == null) {
      throw ArgumentError.notNull('fileCreationDraft.id');
    }
    if (creator.id == null) {
      throw ArgumentError.notNull('creator.id');
    }

    var $fileCreationDraft = fileCreationDraft.copyWith(creatorId: creator.id);
    await session.db.updateRow<FileCreationDraft>(
      $fileCreationDraft,
      columns: [FileCreationDraft.t.creatorId],
      transaction: transaction,
    );
  }
}
