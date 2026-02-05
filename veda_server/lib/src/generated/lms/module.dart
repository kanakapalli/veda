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
import '../lms/course.dart' as _i2;
import '../lms/module_item.dart' as _i3;
import 'package:veda_server/src/generated/protocol.dart' as _i4;

/// Module - hierarchical organization unit within a course
abstract class Module implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Module._({
    this.id,
    required this.title,
    this.description,
    required this.sortOrder,
    this.imageUrl,
    this.bannerImageUrl,
    this.videoUrl,
    required this.courseId,
    this.course,
    this.items,
  }) : _coursesModulesCoursesId = null;

  factory Module({
    int? id,
    required String title,
    String? description,
    required int sortOrder,
    String? imageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required int courseId,
    _i2.Course? course,
    List<_i3.ModuleItem>? items,
  }) = _ModuleImpl;

  factory Module.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModuleImplicit._(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int,
      imageUrl: jsonSerialization['imageUrl'] as String?,
      bannerImageUrl: jsonSerialization['bannerImageUrl'] as String?,
      videoUrl: jsonSerialization['videoUrl'] as String?,
      courseId: jsonSerialization['courseId'] as int,
      course: jsonSerialization['course'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Course>(jsonSerialization['course']),
      items: jsonSerialization['items'] == null
          ? null
          : _i4.Protocol().deserialize<List<_i3.ModuleItem>>(
              jsonSerialization['items'],
            ),
      $_coursesModulesCoursesId:
          jsonSerialization['_coursesModulesCoursesId'] as int?,
    );
  }

  static final t = ModuleTable();

  static const db = ModuleRepository._();

  @override
  int? id;

  /// Module title
  String title;

  /// Module description
  String? description;

  /// Sort order within the course
  int sortOrder;

  /// URL for module image
  String? imageUrl;

  /// URL for module banner image
  String? bannerImageUrl;

  /// URL for module intro video
  String? videoUrl;

  /// Foreign key to parent course
  int courseId;

  /// Parent course reference
  _i2.Course? course;

  /// List of module items (topics) in this module
  List<_i3.ModuleItem>? items;

  final int? _coursesModulesCoursesId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Module]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Module copyWith({
    int? id,
    String? title,
    String? description,
    int? sortOrder,
    String? imageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    int? courseId,
    _i2.Course? course,
    List<_i3.ModuleItem>? items,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Module',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      'sortOrder': sortOrder,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'courseId': courseId,
      if (course != null) 'course': course?.toJson(),
      if (items != null) 'items': items?.toJson(valueToJson: (v) => v.toJson()),
      if (_coursesModulesCoursesId != null)
        '_coursesModulesCoursesId': _coursesModulesCoursesId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Module',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      'sortOrder': sortOrder,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'courseId': courseId,
      if (course != null) 'course': course?.toJsonForProtocol(),
      if (items != null)
        'items': items?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static ModuleInclude include({_i3.ModuleItemIncludeList? items}) {
    return ModuleInclude._(items: items);
  }

  static ModuleIncludeList includeList({
    _i1.WhereExpressionBuilder<ModuleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleTable>? orderByList,
    ModuleInclude? include,
  }) {
    return ModuleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Module.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Module.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ModuleImpl extends Module {
  _ModuleImpl({
    int? id,
    required String title,
    String? description,
    required int sortOrder,
    String? imageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required int courseId,
    _i2.Course? course,
    List<_i3.ModuleItem>? items,
  }) : super._(
         id: id,
         title: title,
         description: description,
         sortOrder: sortOrder,
         imageUrl: imageUrl,
         bannerImageUrl: bannerImageUrl,
         videoUrl: videoUrl,
         courseId: courseId,
         course: course,
         items: items,
       );

  /// Returns a shallow copy of this [Module]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Module copyWith({
    Object? id = _Undefined,
    String? title,
    Object? description = _Undefined,
    int? sortOrder,
    Object? imageUrl = _Undefined,
    Object? bannerImageUrl = _Undefined,
    Object? videoUrl = _Undefined,
    int? courseId,
    Object? course = _Undefined,
    Object? items = _Undefined,
  }) {
    return ModuleImplicit._(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      bannerImageUrl: bannerImageUrl is String?
          ? bannerImageUrl
          : this.bannerImageUrl,
      videoUrl: videoUrl is String? ? videoUrl : this.videoUrl,
      courseId: courseId ?? this.courseId,
      course: course is _i2.Course? ? course : this.course?.copyWith(),
      items: items is List<_i3.ModuleItem>?
          ? items
          : this.items?.map((e0) => e0.copyWith()).toList(),
      $_coursesModulesCoursesId: this._coursesModulesCoursesId,
    );
  }
}

class ModuleImplicit extends _ModuleImpl {
  ModuleImplicit._({
    int? id,
    required String title,
    String? description,
    required int sortOrder,
    String? imageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required int courseId,
    _i2.Course? course,
    List<_i3.ModuleItem>? items,
    int? $_coursesModulesCoursesId,
  }) : _coursesModulesCoursesId = $_coursesModulesCoursesId,
       super(
         id: id,
         title: title,
         description: description,
         sortOrder: sortOrder,
         imageUrl: imageUrl,
         bannerImageUrl: bannerImageUrl,
         videoUrl: videoUrl,
         courseId: courseId,
         course: course,
         items: items,
       );

  factory ModuleImplicit(
    Module module, {
    int? $_coursesModulesCoursesId,
  }) {
    return ModuleImplicit._(
      id: module.id,
      title: module.title,
      description: module.description,
      sortOrder: module.sortOrder,
      imageUrl: module.imageUrl,
      bannerImageUrl: module.bannerImageUrl,
      videoUrl: module.videoUrl,
      courseId: module.courseId,
      course: module.course,
      items: module.items,
      $_coursesModulesCoursesId: $_coursesModulesCoursesId,
    );
  }

  @override
  final int? _coursesModulesCoursesId;
}

class ModuleUpdateTable extends _i1.UpdateTable<ModuleTable> {
  ModuleUpdateTable(super.table);

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<String, String> imageUrl(String? value) => _i1.ColumnValue(
    table.imageUrl,
    value,
  );

  _i1.ColumnValue<String, String> bannerImageUrl(String? value) =>
      _i1.ColumnValue(
        table.bannerImageUrl,
        value,
      );

  _i1.ColumnValue<String, String> videoUrl(String? value) => _i1.ColumnValue(
    table.videoUrl,
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

  _i1.ColumnValue<int, int> $_coursesModulesCoursesId(int? value) =>
      _i1.ColumnValue(
        table.$_coursesModulesCoursesId,
        value,
      );
}

class ModuleTable extends _i1.Table<int?> {
  ModuleTable({super.tableRelation}) : super(tableName: 'modules') {
    updateTable = ModuleUpdateTable(this);
    title = _i1.ColumnString(
      'title',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    imageUrl = _i1.ColumnString(
      'imageUrl',
      this,
    );
    bannerImageUrl = _i1.ColumnString(
      'bannerImageUrl',
      this,
    );
    videoUrl = _i1.ColumnString(
      'videoUrl',
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
    $_coursesModulesCoursesId = _i1.ColumnInt(
      '_coursesModulesCoursesId',
      this,
    );
  }

  late final ModuleUpdateTable updateTable;

  /// Module title
  late final _i1.ColumnString title;

  /// Module description
  late final _i1.ColumnString description;

  /// Sort order within the course
  late final _i1.ColumnInt sortOrder;

  /// URL for module image
  late final _i1.ColumnString imageUrl;

  /// URL for module banner image
  late final _i1.ColumnString bannerImageUrl;

  /// URL for module intro video
  late final _i1.ColumnString videoUrl;

  /// Foreign key to parent course
  late final _i1.ColumnInt courseId;

  /// Parent course reference
  late final _i1.ColumnSerializable<_i2.Course> course;

  /// List of module items (topics) in this module
  _i3.ModuleItemTable? ___items;

  /// List of module items (topics) in this module
  _i1.ManyRelation<_i3.ModuleItemTable>? _items;

  late final _i1.ColumnInt $_coursesModulesCoursesId;

  _i3.ModuleItemTable get __items {
    if (___items != null) return ___items!;
    ___items = _i1.createRelationTable(
      relationFieldName: '__items',
      field: Module.t.id,
      foreignField: _i3.ModuleItem.t.$_modulesItemsModulesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ModuleItemTable(tableRelation: foreignTableRelation),
    );
    return ___items!;
  }

  _i1.ManyRelation<_i3.ModuleItemTable> get items {
    if (_items != null) return _items!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'items',
      field: Module.t.id,
      foreignField: _i3.ModuleItem.t.$_modulesItemsModulesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ModuleItemTable(tableRelation: foreignTableRelation),
    );
    _items = _i1.ManyRelation<_i3.ModuleItemTable>(
      tableWithRelations: relationTable,
      table: _i3.ModuleItemTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _items!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    title,
    description,
    sortOrder,
    imageUrl,
    bannerImageUrl,
    videoUrl,
    courseId,
    course,
    $_coursesModulesCoursesId,
  ];

  @override
  List<_i1.Column> get managedColumns => [
    id,
    title,
    description,
    sortOrder,
    imageUrl,
    bannerImageUrl,
    videoUrl,
    courseId,
    course,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'items') {
      return __items;
    }
    return null;
  }
}

class ModuleInclude extends _i1.IncludeObject {
  ModuleInclude._({_i3.ModuleItemIncludeList? items}) {
    _items = items;
  }

  _i3.ModuleItemIncludeList? _items;

  @override
  Map<String, _i1.Include?> get includes => {'items': _items};

  @override
  _i1.Table<int?> get table => Module.t;
}

class ModuleIncludeList extends _i1.IncludeList {
  ModuleIncludeList._({
    _i1.WhereExpressionBuilder<ModuleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Module.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Module.t;
}

class ModuleRepository {
  const ModuleRepository._();

  final attach = const ModuleAttachRepository._();

  final attachRow = const ModuleAttachRowRepository._();

  final detach = const ModuleDetachRepository._();

  final detachRow = const ModuleDetachRowRepository._();

  /// Returns a list of [Module]s matching the given query parameters.
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
  Future<List<Module>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleTable>? orderByList,
    _i1.Transaction? transaction,
    ModuleInclude? include,
  }) async {
    return session.db.find<Module>(
      where: where?.call(Module.t),
      orderBy: orderBy?.call(Module.t),
      orderByList: orderByList?.call(Module.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Module] matching the given query parameters.
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
  Future<Module?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleTable>? where,
    int? offset,
    _i1.OrderByBuilder<ModuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleTable>? orderByList,
    _i1.Transaction? transaction,
    ModuleInclude? include,
  }) async {
    return session.db.findFirstRow<Module>(
      where: where?.call(Module.t),
      orderBy: orderBy?.call(Module.t),
      orderByList: orderByList?.call(Module.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Module] by its [id] or null if no such row exists.
  Future<Module?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    ModuleInclude? include,
  }) async {
    return session.db.findById<Module>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Module]s in the list and returns the inserted rows.
  ///
  /// The returned [Module]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Module>> insert(
    _i1.Session session,
    List<Module> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Module>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Module] and returns the inserted row.
  ///
  /// The returned [Module] will have its `id` field set.
  Future<Module> insertRow(
    _i1.Session session,
    Module row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Module>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Module]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Module>> update(
    _i1.Session session,
    List<Module> rows, {
    _i1.ColumnSelections<ModuleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Module>(
      rows,
      columns: columns?.call(Module.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Module]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Module> updateRow(
    _i1.Session session,
    Module row, {
    _i1.ColumnSelections<ModuleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Module>(
      row,
      columns: columns?.call(Module.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Module] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Module?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ModuleUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Module>(
      id,
      columnValues: columnValues(Module.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Module]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Module>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ModuleUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ModuleTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleTable>? orderBy,
    _i1.OrderByListBuilder<ModuleTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Module>(
      columnValues: columnValues(Module.t.updateTable),
      where: where(Module.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Module.t),
      orderByList: orderByList?.call(Module.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Module]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Module>> delete(
    _i1.Session session,
    List<Module> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Module>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Module].
  Future<Module> deleteRow(
    _i1.Session session,
    Module row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Module>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Module>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ModuleTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Module>(
      where: where(Module.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Module>(
      where: where?.call(Module.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class ModuleAttachRepository {
  const ModuleAttachRepository._();

  /// Creates a relation between this [Module] and the given [ModuleItem]s
  /// by setting each [ModuleItem]'s foreign key `_modulesItemsModulesId` to refer to this [Module].
  Future<void> items(
    _i1.Session session,
    Module module,
    List<_i3.ModuleItem> moduleItem, {
    _i1.Transaction? transaction,
  }) async {
    if (moduleItem.any((e) => e.id == null)) {
      throw ArgumentError.notNull('moduleItem.id');
    }
    if (module.id == null) {
      throw ArgumentError.notNull('module.id');
    }

    var $moduleItem = moduleItem
        .map(
          (e) => _i3.ModuleItemImplicit(
            e,
            $_modulesItemsModulesId: module.id,
          ),
        )
        .toList();
    await session.db.update<_i3.ModuleItem>(
      $moduleItem,
      columns: [_i3.ModuleItem.t.$_modulesItemsModulesId],
      transaction: transaction,
    );
  }
}

class ModuleAttachRowRepository {
  const ModuleAttachRowRepository._();

  /// Creates a relation between this [Module] and the given [ModuleItem]
  /// by setting the [ModuleItem]'s foreign key `_modulesItemsModulesId` to refer to this [Module].
  Future<void> items(
    _i1.Session session,
    Module module,
    _i3.ModuleItem moduleItem, {
    _i1.Transaction? transaction,
  }) async {
    if (moduleItem.id == null) {
      throw ArgumentError.notNull('moduleItem.id');
    }
    if (module.id == null) {
      throw ArgumentError.notNull('module.id');
    }

    var $moduleItem = _i3.ModuleItemImplicit(
      moduleItem,
      $_modulesItemsModulesId: module.id,
    );
    await session.db.updateRow<_i3.ModuleItem>(
      $moduleItem,
      columns: [_i3.ModuleItem.t.$_modulesItemsModulesId],
      transaction: transaction,
    );
  }
}

class ModuleDetachRepository {
  const ModuleDetachRepository._();

  /// Detaches the relation between this [Module] and the given [ModuleItem]
  /// by setting the [ModuleItem]'s foreign key `_modulesItemsModulesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> items(
    _i1.Session session,
    List<_i3.ModuleItem> moduleItem, {
    _i1.Transaction? transaction,
  }) async {
    if (moduleItem.any((e) => e.id == null)) {
      throw ArgumentError.notNull('moduleItem.id');
    }

    var $moduleItem = moduleItem
        .map(
          (e) => _i3.ModuleItemImplicit(
            e,
            $_modulesItemsModulesId: null,
          ),
        )
        .toList();
    await session.db.update<_i3.ModuleItem>(
      $moduleItem,
      columns: [_i3.ModuleItem.t.$_modulesItemsModulesId],
      transaction: transaction,
    );
  }
}

class ModuleDetachRowRepository {
  const ModuleDetachRowRepository._();

  /// Detaches the relation between this [Module] and the given [ModuleItem]
  /// by setting the [ModuleItem]'s foreign key `_modulesItemsModulesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> items(
    _i1.Session session,
    _i3.ModuleItem moduleItem, {
    _i1.Transaction? transaction,
  }) async {
    if (moduleItem.id == null) {
      throw ArgumentError.notNull('moduleItem.id');
    }

    var $moduleItem = _i3.ModuleItemImplicit(
      moduleItem,
      $_modulesItemsModulesId: null,
    );
    await session.db.updateRow<_i3.ModuleItem>(
      $moduleItem,
      columns: [_i3.ModuleItem.t.$_modulesItemsModulesId],
      transaction: transaction,
    );
  }
}
