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

/// CourseIndex - searchable metadata/tags for course discovery
abstract class CourseIndex
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CourseIndex._({
    this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.tags,
    required this.sortOrder,
    required this.courseId,
    this.course,
  }) : _coursesCourseindicesCoursesId = null;

  factory CourseIndex({
    int? id,
    required String title,
    String? description,
    String? imageUrl,
    List<String>? tags,
    required int sortOrder,
    required int courseId,
    _i2.Course? course,
  }) = _CourseIndexImpl;

  factory CourseIndex.fromJson(Map<String, dynamic> jsonSerialization) {
    return CourseIndexImplicit._(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      imageUrl: jsonSerialization['imageUrl'] as String?,
      tags: jsonSerialization['tags'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(jsonSerialization['tags']),
      sortOrder: jsonSerialization['sortOrder'] as int,
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Course>(jsonSerialization['course']),
      $_coursesCourseindicesCoursesId:
          jsonSerialization['_coursesCourseindicesCoursesId'] as int?,
    );
  }

  static final t = CourseIndexTable();

  static const db = CourseIndexRepository._();

  @override
  int? id;

  /// Index title/keyword
  String title;

  /// Index description
  String? description;

  /// URL for index image
  String? imageUrl;

  /// List of tags for this index
  List<String>? tags;

  /// Sort order
  int sortOrder;

  /// Foreign key to parent course
  int courseId;

  /// Parent course reference
  _i2.Course? course;

  final int? _coursesCourseindicesCoursesId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CourseIndex]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CourseIndex copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? tags,
    int? sortOrder,
    int? courseId,
    _i2.Course? course,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CourseIndex',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (tags != null) 'tags': tags?.toJson(),
      'sortOrder': sortOrder,
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
      if (_coursesCourseindicesCoursesId != null)
        '_coursesCourseindicesCoursesId': _coursesCourseindicesCoursesId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CourseIndex',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (tags != null) 'tags': tags?.toJson(),
      'sortOrder': sortOrder,
      'courseId': courseId,
      if (course != null) 'course': course?.toJsonForProtocol(),
    };
  }

  static CourseIndexInclude include() {
    return CourseIndexInclude._();
  }

  static CourseIndexIncludeList includeList({
    _i1.WhereExpressionBuilder<CourseIndexTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseIndexTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseIndexTable>? orderByList,
    CourseIndexInclude? include,
  }) {
    return CourseIndexIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CourseIndex.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CourseIndex.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseIndexImpl extends CourseIndex {
  _CourseIndexImpl({
    int? id,
    required String title,
    String? description,
    String? imageUrl,
    List<String>? tags,
    required int sortOrder,
    required int courseId,
    _i2.Course? course,
  }) : super._(
         id: id,
         title: title,
         description: description,
         imageUrl: imageUrl,
         tags: tags,
         sortOrder: sortOrder,
         courseId: courseId,
         course: course,
       );

  /// Returns a shallow copy of this [CourseIndex]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CourseIndex copyWith({
    Object? id = _Undefined,
    String? title,
    Object? description = _Undefined,
    Object? imageUrl = _Undefined,
    Object? tags = _Undefined,
    int? sortOrder,
    int? courseId,
    Object? course = _Undefined,
  }) {
    return CourseIndexImplicit._(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      tags: tags is List<String>? ? tags : this.tags?.map((e0) => e0).toList(),
      sortOrder: sortOrder ?? this.sortOrder,
      courseId: courseId ?? this.courseId,
      course: course is _i2.Course? ? course : this.course?.copyWith(),
      $_coursesCourseindicesCoursesId: this._coursesCourseindicesCoursesId,
    );
  }
}

class CourseIndexImplicit extends _CourseIndexImpl {
  CourseIndexImplicit._({
    int? id,
    required String title,
    String? description,
    String? imageUrl,
    List<String>? tags,
    required int sortOrder,
    required int courseId,
    _i2.Course? course,
    int? $_coursesCourseindicesCoursesId,
  }) : _coursesCourseindicesCoursesId = $_coursesCourseindicesCoursesId,
       super(
         id: id,
         title: title,
         description: description,
         imageUrl: imageUrl,
         tags: tags,
         sortOrder: sortOrder,
         courseId: courseId,
         course: course,
       );

  factory CourseIndexImplicit(
    CourseIndex courseIndex, {
    int? $_coursesCourseindicesCoursesId,
  }) {
    return CourseIndexImplicit._(
      id: courseIndex.id,
      title: courseIndex.title,
      description: courseIndex.description,
      imageUrl: courseIndex.imageUrl,
      tags: courseIndex.tags,
      sortOrder: courseIndex.sortOrder,
      courseId: courseIndex.courseId,
      course: courseIndex.course,
      $_coursesCourseindicesCoursesId: $_coursesCourseindicesCoursesId,
    );
  }

  @override
  final int? _coursesCourseindicesCoursesId;
}

class CourseIndexUpdateTable extends _i1.UpdateTable<CourseIndexTable> {
  CourseIndexUpdateTable(super.table);

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<String, String> imageUrl(String? value) => _i1.ColumnValue(
    table.imageUrl,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> tags(List<String>? value) =>
      _i1.ColumnValue(
        table.tags,
        value,
      );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
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

  _i1.ColumnValue<int, int> $_coursesCourseindicesCoursesId(int? value) =>
      _i1.ColumnValue(
        table.$_coursesCourseindicesCoursesId,
        value,
      );
}

class CourseIndexTable extends _i1.Table<int?> {
  CourseIndexTable({super.tableRelation}) : super(tableName: 'course_indices') {
    updateTable = CourseIndexUpdateTable(this);
    title = _i1.ColumnString(
      'title',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    imageUrl = _i1.ColumnString(
      'imageUrl',
      this,
    );
    tags = _i1.ColumnSerializable<List<String>>(
      'tags',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    courseId = _i1.ColumnInt(
      'courseId',
      this,
    );
    course = _i1.ColumnSerializable<_i2.Course>(
      'course',
      this,
    );
    $_coursesCourseindicesCoursesId = _i1.ColumnInt(
      '_coursesCourseindicesCoursesId',
      this,
    );
  }

  late final CourseIndexUpdateTable updateTable;

  /// Index title/keyword
  late final _i1.ColumnString title;

  /// Index description
  late final _i1.ColumnString description;

  /// URL for index image
  late final _i1.ColumnString imageUrl;

  /// List of tags for this index
  late final _i1.ColumnSerializable<List<String>> tags;

  /// Sort order
  late final _i1.ColumnInt sortOrder;

  /// Foreign key to parent course
  late final _i1.ColumnInt courseId;

  /// Parent course reference
  late final _i1.ColumnSerializable<_i2.Course> course;

  late final _i1.ColumnInt $_coursesCourseindicesCoursesId;

  @override
  List<_i1.Column> get columns => [
    id,
    title,
    description,
    imageUrl,
    tags,
    sortOrder,
    courseId,
    course,
    $_coursesCourseindicesCoursesId,
  ];

  @override
  List<_i1.Column> get managedColumns => [
    id,
    title,
    description,
    imageUrl,
    tags,
    sortOrder,
    courseId,
    course,
  ];
}

class CourseIndexInclude extends _i1.IncludeObject {
  CourseIndexInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CourseIndex.t;
}

class CourseIndexIncludeList extends _i1.IncludeList {
  CourseIndexIncludeList._({
    _i1.WhereExpressionBuilder<CourseIndexTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CourseIndex.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CourseIndex.t;
}

class CourseIndexRepository {
  const CourseIndexRepository._();

  /// Returns a list of [CourseIndex]s matching the given query parameters.
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
  Future<List<CourseIndex>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CourseIndexTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseIndexTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseIndexTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<CourseIndex>(
      where: where?.call(CourseIndex.t),
      orderBy: orderBy?.call(CourseIndex.t),
      orderByList: orderByList?.call(CourseIndex.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [CourseIndex] matching the given query parameters.
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
  Future<CourseIndex?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CourseIndexTable>? where,
    int? offset,
    _i1.OrderByBuilder<CourseIndexTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseIndexTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<CourseIndex>(
      where: where?.call(CourseIndex.t),
      orderBy: orderBy?.call(CourseIndex.t),
      orderByList: orderByList?.call(CourseIndex.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [CourseIndex] by its [id] or null if no such row exists.
  Future<CourseIndex?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<CourseIndex>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [CourseIndex]s in the list and returns the inserted rows.
  ///
  /// The returned [CourseIndex]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<CourseIndex>> insert(
    _i1.Session session,
    List<CourseIndex> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<CourseIndex>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [CourseIndex] and returns the inserted row.
  ///
  /// The returned [CourseIndex] will have its `id` field set.
  Future<CourseIndex> insertRow(
    _i1.Session session,
    CourseIndex row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CourseIndex>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CourseIndex]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CourseIndex>> update(
    _i1.Session session,
    List<CourseIndex> rows, {
    _i1.ColumnSelections<CourseIndexTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CourseIndex>(
      rows,
      columns: columns?.call(CourseIndex.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CourseIndex]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CourseIndex> updateRow(
    _i1.Session session,
    CourseIndex row, {
    _i1.ColumnSelections<CourseIndexTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CourseIndex>(
      row,
      columns: columns?.call(CourseIndex.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CourseIndex] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CourseIndex?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<CourseIndexUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CourseIndex>(
      id,
      columnValues: columnValues(CourseIndex.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CourseIndex]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CourseIndex>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<CourseIndexUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CourseIndexTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseIndexTable>? orderBy,
    _i1.OrderByListBuilder<CourseIndexTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CourseIndex>(
      columnValues: columnValues(CourseIndex.t.updateTable),
      where: where(CourseIndex.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CourseIndex.t),
      orderByList: orderByList?.call(CourseIndex.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CourseIndex]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CourseIndex>> delete(
    _i1.Session session,
    List<CourseIndex> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CourseIndex>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CourseIndex].
  Future<CourseIndex> deleteRow(
    _i1.Session session,
    CourseIndex row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CourseIndex>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CourseIndex>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CourseIndexTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CourseIndex>(
      where: where(CourseIndex.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CourseIndexTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CourseIndex>(
      where: where?.call(CourseIndex.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
