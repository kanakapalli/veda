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

/// Veda user profile data linked to authenticated user.
/// Uses relation to AuthUser as per Serverpod recommended pattern.
abstract class VedaUserProfile
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  VedaUserProfile._({
    this.id,
    required this.authUserId,
    this.authUser,
    this.fullName,
    this.bio,
    this.interests,
    this.learningGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VedaUserProfile({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VedaUserProfileImpl;

  factory VedaUserProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return VedaUserProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      fullName: jsonSerialization['fullName'] as String?,
      bio: jsonSerialization['bio'] as String?,
      interests: jsonSerialization['interests'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['interests'],
            ),
      learningGoal: jsonSerialization['learningGoal'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = VedaUserProfileTable();

  static const db = VedaUserProfileRepository._();

  @override
  int? id;

  _i1.UuidValue authUserId;

  /// Link to the authenticated user (creates authUserId automatically)
  _i2.AuthUser? authUser;

  /// Full name of the user.
  String? fullName;

  /// User biography or context description (max 200 characters).
  String? bio;

  /// List of interest tags selected during onboarding.
  List<String>? interests;

  /// Learning goal: 'career_pivot' or 'academic_depth'.
  String? learningGoal;

  /// Timestamp when the profile was created.
  DateTime createdAt;

  /// Timestamp when the profile was last updated.
  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [VedaUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  VedaUserProfile copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VedaUserProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests?.toJson(),
      if (learningGoal != null) 'learningGoal': learningGoal,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VedaUserProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJsonForProtocol(),
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests?.toJson(),
      if (learningGoal != null) 'learningGoal': learningGoal,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static VedaUserProfileInclude include({_i2.AuthUserInclude? authUser}) {
    return VedaUserProfileInclude._(authUser: authUser);
  }

  static VedaUserProfileIncludeList includeList({
    _i1.WhereExpressionBuilder<VedaUserProfileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VedaUserProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VedaUserProfileTable>? orderByList,
    VedaUserProfileInclude? include,
  }) {
    return VedaUserProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VedaUserProfile.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(VedaUserProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VedaUserProfileImpl extends VedaUserProfile {
  _VedaUserProfileImpl({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    String? fullName,
    String? bio,
    List<String>? interests,
    String? learningGoal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         fullName: fullName,
         bio: bio,
         interests: interests,
         learningGoal: learningGoal,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [VedaUserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  VedaUserProfile copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    Object? fullName = _Undefined,
    Object? bio = _Undefined,
    Object? interests = _Undefined,
    Object? learningGoal = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VedaUserProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      fullName: fullName is String? ? fullName : this.fullName,
      bio: bio is String? ? bio : this.bio,
      interests: interests is List<String>?
          ? interests
          : this.interests?.map((e0) => e0).toList(),
      learningGoal: learningGoal is String? ? learningGoal : this.learningGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VedaUserProfileUpdateTable extends _i1.UpdateTable<VedaUserProfileTable> {
  VedaUserProfileUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<String, String> fullName(String? value) => _i1.ColumnValue(
    table.fullName,
    value,
  );

  _i1.ColumnValue<String, String> bio(String? value) => _i1.ColumnValue(
    table.bio,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> interests(List<String>? value) =>
      _i1.ColumnValue(
        table.interests,
        value,
      );

  _i1.ColumnValue<String, String> learningGoal(String? value) =>
      _i1.ColumnValue(
        table.learningGoal,
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

class VedaUserProfileTable extends _i1.Table<int?> {
  VedaUserProfileTable({super.tableRelation})
    : super(tableName: 'veda_user_profile') {
    updateTable = VedaUserProfileUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    fullName = _i1.ColumnString(
      'fullName',
      this,
    );
    bio = _i1.ColumnString(
      'bio',
      this,
    );
    interests = _i1.ColumnSerializable<List<String>>(
      'interests',
      this,
    );
    learningGoal = _i1.ColumnString(
      'learningGoal',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final VedaUserProfileUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  /// Link to the authenticated user (creates authUserId automatically)
  _i2.AuthUserTable? _authUser;

  /// Full name of the user.
  late final _i1.ColumnString fullName;

  /// User biography or context description (max 200 characters).
  late final _i1.ColumnString bio;

  /// List of interest tags selected during onboarding.
  late final _i1.ColumnSerializable<List<String>> interests;

  /// Learning goal: 'career_pivot' or 'academic_depth'.
  late final _i1.ColumnString learningGoal;

  /// Timestamp when the profile was created.
  late final _i1.ColumnDateTime createdAt;

  /// Timestamp when the profile was last updated.
  late final _i1.ColumnDateTime updatedAt;

  _i2.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _i1.createRelationTable(
      relationFieldName: 'authUser',
      field: VedaUserProfile.t.authUserId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    fullName,
    bio,
    interests,
    learningGoal,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class VedaUserProfileInclude extends _i1.IncludeObject {
  VedaUserProfileInclude._({_i2.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _i2.AuthUserInclude? _authUser;

  @override
  Map<String, _i1.Include?> get includes => {'authUser': _authUser};

  @override
  _i1.Table<int?> get table => VedaUserProfile.t;
}

class VedaUserProfileIncludeList extends _i1.IncludeList {
  VedaUserProfileIncludeList._({
    _i1.WhereExpressionBuilder<VedaUserProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(VedaUserProfile.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => VedaUserProfile.t;
}

class VedaUserProfileRepository {
  const VedaUserProfileRepository._();

  final attachRow = const VedaUserProfileAttachRowRepository._();

  /// Returns a list of [VedaUserProfile]s matching the given query parameters.
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
  Future<List<VedaUserProfile>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<VedaUserProfileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VedaUserProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VedaUserProfileTable>? orderByList,
    _i1.Transaction? transaction,
    VedaUserProfileInclude? include,
  }) async {
    return session.db.find<VedaUserProfile>(
      where: where?.call(VedaUserProfile.t),
      orderBy: orderBy?.call(VedaUserProfile.t),
      orderByList: orderByList?.call(VedaUserProfile.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [VedaUserProfile] matching the given query parameters.
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
  Future<VedaUserProfile?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<VedaUserProfileTable>? where,
    int? offset,
    _i1.OrderByBuilder<VedaUserProfileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<VedaUserProfileTable>? orderByList,
    _i1.Transaction? transaction,
    VedaUserProfileInclude? include,
  }) async {
    return session.db.findFirstRow<VedaUserProfile>(
      where: where?.call(VedaUserProfile.t),
      orderBy: orderBy?.call(VedaUserProfile.t),
      orderByList: orderByList?.call(VedaUserProfile.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [VedaUserProfile] by its [id] or null if no such row exists.
  Future<VedaUserProfile?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    VedaUserProfileInclude? include,
  }) async {
    return session.db.findById<VedaUserProfile>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [VedaUserProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [VedaUserProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<VedaUserProfile>> insert(
    _i1.Session session,
    List<VedaUserProfile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<VedaUserProfile>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [VedaUserProfile] and returns the inserted row.
  ///
  /// The returned [VedaUserProfile] will have its `id` field set.
  Future<VedaUserProfile> insertRow(
    _i1.Session session,
    VedaUserProfile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<VedaUserProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [VedaUserProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<VedaUserProfile>> update(
    _i1.Session session,
    List<VedaUserProfile> rows, {
    _i1.ColumnSelections<VedaUserProfileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<VedaUserProfile>(
      rows,
      columns: columns?.call(VedaUserProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VedaUserProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<VedaUserProfile> updateRow(
    _i1.Session session,
    VedaUserProfile row, {
    _i1.ColumnSelections<VedaUserProfileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<VedaUserProfile>(
      row,
      columns: columns?.call(VedaUserProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [VedaUserProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<VedaUserProfile?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<VedaUserProfileUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<VedaUserProfile>(
      id,
      columnValues: columnValues(VedaUserProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [VedaUserProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<VedaUserProfile>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<VedaUserProfileUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<VedaUserProfileTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<VedaUserProfileTable>? orderBy,
    _i1.OrderByListBuilder<VedaUserProfileTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<VedaUserProfile>(
      columnValues: columnValues(VedaUserProfile.t.updateTable),
      where: where(VedaUserProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(VedaUserProfile.t),
      orderByList: orderByList?.call(VedaUserProfile.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [VedaUserProfile]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<VedaUserProfile>> delete(
    _i1.Session session,
    List<VedaUserProfile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<VedaUserProfile>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [VedaUserProfile].
  Future<VedaUserProfile> deleteRow(
    _i1.Session session,
    VedaUserProfile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<VedaUserProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<VedaUserProfile>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<VedaUserProfileTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<VedaUserProfile>(
      where: where(VedaUserProfile.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<VedaUserProfileTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<VedaUserProfile>(
      where: where?.call(VedaUserProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class VedaUserProfileAttachRowRepository {
  const VedaUserProfileAttachRowRepository._();

  /// Creates a relation between the given [VedaUserProfile] and [AuthUser]
  /// by setting the [VedaUserProfile]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _i1.Session session,
    VedaUserProfile vedaUserProfile,
    _i2.AuthUser authUser, {
    _i1.Transaction? transaction,
  }) async {
    if (vedaUserProfile.id == null) {
      throw ArgumentError.notNull('vedaUserProfile.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $vedaUserProfile = vedaUserProfile.copyWith(authUserId: authUser.id);
    await session.db.updateRow<VedaUserProfile>(
      $vedaUserProfile,
      columns: [VedaUserProfile.t.authUserId],
      transaction: transaction,
    );
  }
}
