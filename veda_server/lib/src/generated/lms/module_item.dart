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
import '../lms/module.dart' as _i2;
import '../lms/topic.dart' as _i3;
import 'package:veda_server/src/generated/protocol.dart' as _i4;

/// ModuleItem - junction table linking modules to topics with context
abstract class ModuleItem
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ModuleItem._({
    this.id,
    required this.sortOrder,
    this.contextualDescription,
    required this.moduleId,
    this.module,
    required this.topicId,
    this.topic,
  });

  factory ModuleItem({
    int? id,
    required int sortOrder,
    String? contextualDescription,
    required int moduleId,
    _i2.Module? module,
    required int topicId,
    _i3.Topic? topic,
  }) = _ModuleItemImpl;

  factory ModuleItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModuleItem(
      id: jsonSerialization['id'] as int?,
      sortOrder: jsonSerialization['sortOrder'] as int,
      contextualDescription:
          jsonSerialization['contextualDescription'] as String?,
      moduleId: jsonSerialization['moduleId'] as int,
      module: jsonSerialization['module'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.Module>(jsonSerialization['module']),
      topicId: jsonSerialization['topicId'] as int,
      topic: jsonSerialization['topic'] == null
          ? null
          : _i4.Protocol().deserialize<_i3.Topic>(jsonSerialization['topic']),
    );
  }

  static final t = ModuleItemTable();

  static const db = ModuleItemRepository._();

  @override
  int? id;

  /// Sort order within the module
  int sortOrder;

  /// Contextual description specific to this topic in this course
  String? contextualDescription;

  /// Foreign key to parent module
  int moduleId;

  /// Parent module reference
  _i2.Module? module;

  /// Foreign key to topic
  int topicId;

  /// Topic reference
  _i3.Topic? topic;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ModuleItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ModuleItem copyWith({
    int? id,
    int? sortOrder,
    String? contextualDescription,
    int? moduleId,
    _i2.Module? module,
    int? topicId,
    _i3.Topic? topic,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ModuleItem',
      if (id != null) 'id': id,
      'sortOrder': sortOrder,
      if (contextualDescription != null)
        'contextualDescription': contextualDescription,
      'moduleId': moduleId,
      if (module != null) 'module': module?.toJson(),
      'topicId': topicId,
      if (topic != null) 'topic': topic?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ModuleItem',
      if (id != null) 'id': id,
      'sortOrder': sortOrder,
      if (contextualDescription != null)
        'contextualDescription': contextualDescription,
      'moduleId': moduleId,
      if (module != null) 'module': module?.toJsonForProtocol(),
      'topicId': topicId,
      if (topic != null) 'topic': topic?.toJsonForProtocol(),
    };
  }

  static ModuleItemInclude include() {
    return ModuleItemInclude._();
  }

  static ModuleItemIncludeList includeList({
    _i1.WhereExpressionBuilder<ModuleItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleItemTable>? orderByList,
    ModuleItemInclude? include,
  }) {
    return ModuleItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModuleItem.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ModuleItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ModuleItemImpl extends ModuleItem {
  _ModuleItemImpl({
    int? id,
    required int sortOrder,
    String? contextualDescription,
    required int moduleId,
    _i2.Module? module,
    required int topicId,
    _i3.Topic? topic,
  }) : super._(
         id: id,
         sortOrder: sortOrder,
         contextualDescription: contextualDescription,
         moduleId: moduleId,
         module: module,
         topicId: topicId,
         topic: topic,
       );

  /// Returns a shallow copy of this [ModuleItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ModuleItem copyWith({
    Object? id = _Undefined,
    int? sortOrder,
    Object? contextualDescription = _Undefined,
    int? moduleId,
    Object? module = _Undefined,
    int? topicId,
    Object? topic = _Undefined,
  }) {
    return ModuleItem(
      id: id is int? ? id : this.id,
      sortOrder: sortOrder ?? this.sortOrder,
      contextualDescription: contextualDescription is String?
          ? contextualDescription
          : this.contextualDescription,
      moduleId: moduleId ?? this.moduleId,
      module: module is _i2.Module? ? module : this.module?.copyWith(),
      topicId: topicId ?? this.topicId,
      topic: topic is _i3.Topic? ? topic : this.topic?.copyWith(),
    );
  }
}

class ModuleItemUpdateTable extends _i1.UpdateTable<ModuleItemTable> {
  ModuleItemUpdateTable(super.table);

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<String, String> contextualDescription(String? value) =>
      _i1.ColumnValue(
        table.contextualDescription,
        value,
      );

  _i1.ColumnValue<int, int> moduleId(int value) => _i1.ColumnValue(
    table.moduleId,
    value,
  );

  _i1.ColumnValue<_i2.Module, _i2.Module> module(_i2.Module? value) =>
      _i1.ColumnValue(
        table.module,
        value,
      );

  _i1.ColumnValue<int, int> topicId(int value) => _i1.ColumnValue(
    table.topicId,
    value,
  );

  _i1.ColumnValue<_i3.Topic, _i3.Topic> topic(_i3.Topic? value) =>
      _i1.ColumnValue(
        table.topic,
        value,
      );
}

class ModuleItemTable extends _i1.Table<int?> {
  ModuleItemTable({super.tableRelation}) : super(tableName: 'module_items') {
    updateTable = ModuleItemUpdateTable(this);
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    contextualDescription = _i1.ColumnString(
      'contextualDescription',
      this,
    );
    moduleId = _i1.ColumnInt(
      'moduleId',
      this,
    );
    module = _i1.ColumnSerializable<_i2.Module>(
      'module',
      this,
    );
    topicId = _i1.ColumnInt(
      'topicId',
      this,
    );
    topic = _i1.ColumnSerializable<_i3.Topic>(
      'topic',
      this,
    );
  }

  late final ModuleItemUpdateTable updateTable;

  /// Sort order within the module
  late final _i1.ColumnInt sortOrder;

  /// Contextual description specific to this topic in this course
  late final _i1.ColumnString contextualDescription;

  /// Foreign key to parent module
  late final _i1.ColumnInt moduleId;

  /// Parent module reference
  late final _i1.ColumnSerializable<_i2.Module> module;

  /// Foreign key to topic
  late final _i1.ColumnInt topicId;

  /// Topic reference
  late final _i1.ColumnSerializable<_i3.Topic> topic;

  @override
  List<_i1.Column> get columns => [
    id,
    sortOrder,
    contextualDescription,
    moduleId,
    module,
    topicId,
    topic,
  ];
}

class ModuleItemInclude extends _i1.IncludeObject {
  ModuleItemInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ModuleItem.t;
}

class ModuleItemIncludeList extends _i1.IncludeList {
  ModuleItemIncludeList._({
    _i1.WhereExpressionBuilder<ModuleItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ModuleItem.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ModuleItem.t;
}

class ModuleItemRepository {
  const ModuleItemRepository._();

  /// Returns a list of [ModuleItem]s matching the given query parameters.
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
  Future<List<ModuleItem>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleItemTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ModuleItem>(
      where: where?.call(ModuleItem.t),
      orderBy: orderBy?.call(ModuleItem.t),
      orderByList: orderByList?.call(ModuleItem.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ModuleItem] matching the given query parameters.
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
  Future<ModuleItem?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleItemTable>? where,
    int? offset,
    _i1.OrderByBuilder<ModuleItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ModuleItemTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ModuleItem>(
      where: where?.call(ModuleItem.t),
      orderBy: orderBy?.call(ModuleItem.t),
      orderByList: orderByList?.call(ModuleItem.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ModuleItem] by its [id] or null if no such row exists.
  Future<ModuleItem?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ModuleItem>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ModuleItem]s in the list and returns the inserted rows.
  ///
  /// The returned [ModuleItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ModuleItem>> insert(
    _i1.Session session,
    List<ModuleItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ModuleItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ModuleItem] and returns the inserted row.
  ///
  /// The returned [ModuleItem] will have its `id` field set.
  Future<ModuleItem> insertRow(
    _i1.Session session,
    ModuleItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ModuleItem>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ModuleItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ModuleItem>> update(
    _i1.Session session,
    List<ModuleItem> rows, {
    _i1.ColumnSelections<ModuleItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ModuleItem>(
      rows,
      columns: columns?.call(ModuleItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ModuleItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ModuleItem> updateRow(
    _i1.Session session,
    ModuleItem row, {
    _i1.ColumnSelections<ModuleItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ModuleItem>(
      row,
      columns: columns?.call(ModuleItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ModuleItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ModuleItem?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ModuleItemUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ModuleItem>(
      id,
      columnValues: columnValues(ModuleItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ModuleItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ModuleItem>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ModuleItemUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ModuleItemTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ModuleItemTable>? orderBy,
    _i1.OrderByListBuilder<ModuleItemTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ModuleItem>(
      columnValues: columnValues(ModuleItem.t.updateTable),
      where: where(ModuleItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModuleItem.t),
      orderByList: orderByList?.call(ModuleItem.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ModuleItem]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ModuleItem>> delete(
    _i1.Session session,
    List<ModuleItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ModuleItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ModuleItem].
  Future<ModuleItem> deleteRow(
    _i1.Session session,
    ModuleItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ModuleItem>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ModuleItem>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ModuleItemTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ModuleItem>(
      where: where(ModuleItem.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ModuleItemTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ModuleItem>(
      where: where?.call(ModuleItem.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
