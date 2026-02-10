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
import '../lms/module.dart' as _i3;
import '../lms/course.dart' as _i4;
import 'package:veda_server/src/generated/protocol.dart' as _i5;

/// ModuleProgress - tracks user progress through course modules
abstract class ModuleProgress
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ModuleProgress._({
    this.id,
    required this.userId,
    this.user,
    required this.moduleId,
    this.module,
    required this.courseId,
    this.course,
    bool? completed,
    this.completedAt,
    DateTime? startedAt,
  }) : completed = completed ?? false,
       startedAt = startedAt ?? DateTime.now();

  factory ModuleProgress({
    int? id,
    required _i1.UuidValue userId,
    _i2.AuthUser? user,
    required int moduleId,
    _i3.Module? module,
    required int courseId,
    _i4.Course? course,
    bool? completed,
    DateTime? completedAt,
    DateTime? startedAt,
  }) = _ModuleProgressImpl;

  factory ModuleProgress.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModuleProgress(
      id: jsonSerialization['id'] as int?,
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      user: jsonSerialization['user'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.AuthUser>(jsonSerialization['user']),
      moduleId: jsonSerialization['moduleId'] as int,
      module: jsonSerialization['module'] == null
          ? null
          : _i5.Protocol().deserialize<_i3.Module>(jsonSerialization['module']),
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i5.Protocol().deserialize<_i4.Course>(jsonSerialization['course']),
      completed: jsonSerialization['completed'] as bool?,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
    );
  }

  static final t = ModuleProgressTable();

  static const db = ModuleProgressRepository._();

  @override
  int? id;

  _i1.UuidValue userId;

  /// Link to the authenticated user
  _i2.AuthUser? user;

  /// Foreign key to the module
  int moduleId;

  /// Parent module reference
  _i3.Module? module;

  /// Foreign key to the course (denormalized for quick lookups)
  int courseId;

  /// Parent course reference
  _i4.Course? course;

  /// Whether the module has been completed
  bool completed;

  /// Timestamp when the module was completed
  DateTime? completedAt;

  /// Timestamp when the user started this module
  DateTime startedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ModuleProgress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ModuleProgress copyWith({
    int? id,
    _i1.UuidValue? userId,
    _i2.AuthUser? user,
    int? moduleId,
    _i3.Module? module,
    int? courseId,
    _i4.Course? course,
    bool? completed,
    DateTime? completedAt,
    DateTime? startedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ModuleProgress',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      if (user != null) 'user': user?.toJson(),
      'moduleId': moduleId,
      if (module != null) 'module': module?.toJson(),
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'startedAt': startedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ModuleProgress',
      if (id != null) 'id': id,
      'userId': userId.toJson(),
      if (user != null) 'user': user?.toJsonForProtocol(),
      'moduleId': moduleId,
      if (module != null) 'module': module?.toJsonForProtocol(),
      'courseId': courseId,
      if (course != null) 'course': course?.toJsonForProtocol(),
      'completed': completed,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'startedAt': startedAt.toJson(),
    };
  }

  static ModuleProgressInclude include({_i2.AuthUserInclude? user}) {
    return ModuleProgressInclude._(user: user);
  }

  static ModuleProgressIncludeList includeList({
    _i1.WhereExpressionBuilder<ModuleProgressTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleProgressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleProgressTable>? orderByList,
    ModuleProgressInclude? include,
  }) {
    return ModuleProgressIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModuleProgress.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ModuleProgress.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ModuleProgressImpl extends ModuleProgress {
  _ModuleProgressImpl({
    int? id,
    required _i1.UuidValue userId,
    _i2.AuthUser? user,
    required int moduleId,
    _i3.Module? module,
    required int courseId,
    _i4.Course? course,
    bool? completed,
    DateTime? completedAt,
    DateTime? startedAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         moduleId: moduleId,
         module: module,
         courseId: courseId,
         course: course,
         completed: completed,
         completedAt: completedAt,
         startedAt: startedAt,
       );

  /// Returns a shallow copy of this [ModuleProgress]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ModuleProgress copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? userId,
    Object? user = _Undefined,
    int? moduleId,
    Object? module = _Undefined,
    int? courseId,
    Object? course = _Undefined,
    bool? completed,
    Object? completedAt = _Undefined,
    DateTime? startedAt,
  }) {
    return ModuleProgress(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.AuthUser? ? user : this.user?.copyWith(),
      moduleId: moduleId ?? this.moduleId,
      module: module is _i3.Module? ? module : this.module?.copyWith(),
      courseId: courseId ?? this.courseId,
      course: course is _i4.Course? ? course : this.course?.copyWith(),
      completed: completed ?? this.completed,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

class ModuleProgressUpdateTable extends _i1.UpdateTable<ModuleProgressTable> {
  ModuleProgressUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> userId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.userId,
        value,
      );

  _i1.ColumnValue<int, int> moduleId(int value) => _i1.ColumnValue(
    table.moduleId,
    value,
  );

  _i1.ColumnValue<_i3.Module, _i3.Module> module(_i3.Module? value) =>
      _i1.ColumnValue(
        table.module,
        value,
      );

  _i1.ColumnValue<int, int> courseId(int value) => _i1.ColumnValue(
    table.courseId,
    value,
  );

  _i1.ColumnValue<_i4.Course, _i4.Course> course(_i4.Course? value) =>
      _i1.ColumnValue(
        table.course,
        value,
      );

  _i1.ColumnValue<bool, bool> completed(bool value) => _i1.ColumnValue(
    table.completed,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.completedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> startedAt(DateTime value) =>
      _i1.ColumnValue(
        table.startedAt,
        value,
      );
}

class ModuleProgressTable extends _i1.Table<int?> {
  ModuleProgressTable({super.tableRelation})
    : super(tableName: 'module_progress') {
    updateTable = ModuleProgressUpdateTable(this);
    userId = _i1.ColumnUuid(
      'userId',
      this,
    );
    moduleId = _i1.ColumnInt(
      'moduleId',
      this,
    );
    module = _i1.ColumnSerializable<_i3.Module>(
      'module',
      this,
    );
    courseId = _i1.ColumnInt(
      'courseId',
      this,
    );
    course = _i1.ColumnSerializable<_i4.Course>(
      'course',
      this,
    );
    completed = _i1.ColumnBool(
      'completed',
      this,
      hasDefault: true,
    );
    completedAt = _i1.ColumnDateTime(
      'completedAt',
      this,
    );
    startedAt = _i1.ColumnDateTime(
      'startedAt',
      this,
      hasDefault: true,
    );
  }

  late final ModuleProgressUpdateTable updateTable;

  late final _i1.ColumnUuid userId;

  /// Link to the authenticated user
  _i2.AuthUserTable? _user;

  /// Foreign key to the module
  late final _i1.ColumnInt moduleId;

  /// Parent module reference
  late final _i1.ColumnSerializable<_i3.Module> module;

  /// Foreign key to the course (denormalized for quick lookups)
  late final _i1.ColumnInt courseId;

  /// Parent course reference
  late final _i1.ColumnSerializable<_i4.Course> course;

  /// Whether the module has been completed
  late final _i1.ColumnBool completed;

  /// Timestamp when the module was completed
  late final _i1.ColumnDateTime completedAt;

  /// Timestamp when the user started this module
  late final _i1.ColumnDateTime startedAt;

  _i2.AuthUserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: ModuleProgress.t.userId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    moduleId,
    module,
    courseId,
    course,
    completed,
    completedAt,
    startedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'user') {
      return user;
    }
    return null;
  }
}

class ModuleProgressInclude extends _i1.IncludeObject {
  ModuleProgressInclude._({_i2.AuthUserInclude? user}) {
    _user = user;
  }

  _i2.AuthUserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {'user': _user};

  @override
  _i1.Table<int?> get table => ModuleProgress.t;
}

class ModuleProgressIncludeList extends _i1.IncludeList {
  ModuleProgressIncludeList._({
    _i1.WhereExpressionBuilder<ModuleProgressTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ModuleProgress.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ModuleProgress.t;
}

class ModuleProgressRepository {
  const ModuleProgressRepository._();

  final attachRow = const ModuleProgressAttachRowRepository._();

  /// Returns a list of [ModuleProgress]s matching the given query parameters.
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
  Future<List<ModuleProgress>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleProgressTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleProgressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleProgressTable>? orderByList,
    _i1.Transaction? transaction,
    ModuleProgressInclude? include,
  }) async {
    return session.db.find<ModuleProgress>(
      where: where?.call(ModuleProgress.t),
      orderBy: orderBy?.call(ModuleProgress.t),
      orderByList: orderByList?.call(ModuleProgress.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [ModuleProgress] matching the given query parameters.
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
  Future<ModuleProgress?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleProgressTable>? where,
    int? offset,
    _i1.OrderByBuilder<ModuleProgressTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleProgressTable>? orderByList,
    _i1.Transaction? transaction,
    ModuleProgressInclude? include,
  }) async {
    return session.db.findFirstRow<ModuleProgress>(
      where: where?.call(ModuleProgress.t),
      orderBy: orderBy?.call(ModuleProgress.t),
      orderByList: orderByList?.call(ModuleProgress.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [ModuleProgress] by its [id] or null if no such row exists.
  Future<ModuleProgress?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    ModuleProgressInclude? include,
  }) async {
    return session.db.findById<ModuleProgress>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [ModuleProgress]s in the list and returns the inserted rows.
  ///
  /// The returned [ModuleProgress]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ModuleProgress>> insert(
    _i1.Session session,
    List<ModuleProgress> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ModuleProgress>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ModuleProgress] and returns the inserted row.
  ///
  /// The returned [ModuleProgress] will have its `id` field set.
  Future<ModuleProgress> insertRow(
    _i1.Session session,
    ModuleProgress row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ModuleProgress>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ModuleProgress]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ModuleProgress>> update(
    _i1.Session session,
    List<ModuleProgress> rows, {
    _i1.ColumnSelections<ModuleProgressTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ModuleProgress>(
      rows,
      columns: columns?.call(ModuleProgress.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ModuleProgress]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ModuleProgress> updateRow(
    _i1.Session session,
    ModuleProgress row, {
    _i1.ColumnSelections<ModuleProgressTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ModuleProgress>(
      row,
      columns: columns?.call(ModuleProgress.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ModuleProgress] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ModuleProgress?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ModuleProgressUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ModuleProgress>(
      id,
      columnValues: columnValues(ModuleProgress.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ModuleProgress]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ModuleProgress>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ModuleProgressUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ModuleProgressTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleProgressTable>? orderBy,
    _i1.OrderByListBuilder<ModuleProgressTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ModuleProgress>(
      columnValues: columnValues(ModuleProgress.t.updateTable),
      where: where(ModuleProgress.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModuleProgress.t),
      orderByList: orderByList?.call(ModuleProgress.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ModuleProgress]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ModuleProgress>> delete(
    _i1.Session session,
    List<ModuleProgress> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ModuleProgress>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ModuleProgress].
  Future<ModuleProgress> deleteRow(
    _i1.Session session,
    ModuleProgress row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ModuleProgress>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ModuleProgress>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ModuleProgressTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ModuleProgress>(
      where: where(ModuleProgress.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleProgressTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ModuleProgress>(
      where: where?.call(ModuleProgress.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class ModuleProgressAttachRowRepository {
  const ModuleProgressAttachRowRepository._();

  /// Creates a relation between the given [ModuleProgress] and [AuthUser]
  /// by setting the [ModuleProgress]'s foreign key `userId` to refer to the [AuthUser].
  Future<void> user(
    _i1.Session session,
    ModuleProgress moduleProgress,
    _i2.AuthUser user, {
    _i1.Transaction? transaction,
  }) async {
    if (moduleProgress.id == null) {
      throw ArgumentError.notNull('moduleProgress.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $moduleProgress = moduleProgress.copyWith(userId: user.id);
    await session.db.updateRow<ModuleProgress>(
      $moduleProgress,
      columns: [ModuleProgress.t.userId],
      transaction: transaction,
    );
  }
}
