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
import '../lms/course_visibility.dart' as _i3;
import '../lms/module.dart' as _i4;
import '../lms/course_index.dart' as _i5;
import '../lms/knowledge_file.dart' as _i6;
import 'package:veda_server/src/generated/protocol.dart' as _i7;

/// Course container - defines high-level course settings and AI parameters
abstract class Course implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Course._({
    this.id,
    required this.creatorId,
    this.creator,
    required this.title,
    this.description,
    this.courseImageUrl,
    this.bannerImageUrl,
    this.videoUrl,
    required this.visibility,
    this.systemPrompt,
    this.courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.modules,
    this.courseIndices,
    this.knowledgeFiles,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Course({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    required String title,
    String? description,
    String? courseImageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required _i3.CourseVisibility visibility,
    String? systemPrompt,
    List<String>? courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i4.Module>? modules,
    List<_i5.CourseIndex>? courseIndices,
    List<_i6.KnowledgeFile>? knowledgeFiles,
  }) = _CourseImpl;

  factory Course.fromJson(Map<String, dynamic> jsonSerialization) {
    return Course(
      id: jsonSerialization['id'] as int?,
      creatorId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['creatorId'],
      ),
      creator: jsonSerialization['creator'] == null
          ? null
          : _i7.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['creator'],
            ),
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      courseImageUrl: jsonSerialization['courseImageUrl'] as String?,
      bannerImageUrl: jsonSerialization['bannerImageUrl'] as String?,
      videoUrl: jsonSerialization['videoUrl'] as String?,
      visibility: _i3.CourseVisibility.fromJson(
        (jsonSerialization['visibility'] as String),
      ),
      systemPrompt: jsonSerialization['systemPrompt'] as String?,
      courseTopics: jsonSerialization['courseTopics'] == null
          ? null
          : _i7.Protocol().deserialize<List<String>>(
              jsonSerialization['courseTopics'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      modules: jsonSerialization['modules'] == null
          ? null
          : _i7.Protocol().deserialize<List<_i4.Module>>(
              jsonSerialization['modules'],
            ),
      courseIndices: jsonSerialization['courseIndices'] == null
          ? null
          : _i7.Protocol().deserialize<List<_i5.CourseIndex>>(
              jsonSerialization['courseIndices'],
            ),
      knowledgeFiles: jsonSerialization['knowledgeFiles'] == null
          ? null
          : _i7.Protocol().deserialize<List<_i6.KnowledgeFile>>(
              jsonSerialization['knowledgeFiles'],
            ),
    );
  }

  static final t = CourseTable();

  static const db = CourseRepository._();

  @override
  int? id;

  _i1.UuidValue creatorId;

  /// Link to the authenticated user who created this course (nullable, set by server)
  _i2.AuthUser? creator;

  /// Course title
  String title;

  /// Course description
  String? description;

  /// URL for course thumbnail image
  String? courseImageUrl;

  /// URL for course banner image
  String? bannerImageUrl;

  /// URL for course intro video
  String? videoUrl;

  /// Course visibility status (draft, public, private)
  _i3.CourseVisibility visibility;

  /// System prompt for AI course generation
  String? systemPrompt;

  /// Course topics/tags for categorization and search
  List<String>? courseTopics;

  /// Timestamp when the course was created
  DateTime createdAt;

  /// Timestamp when the course was last updated
  DateTime updatedAt;

  /// List of modules in this course
  List<_i4.Module>? modules;

  /// List of course indices (searchable tags/keywords)
  List<_i5.CourseIndex>? courseIndices;

  /// List of knowledge files for AI generation
  List<_i6.KnowledgeFile>? knowledgeFiles;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Course]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Course copyWith({
    int? id,
    _i1.UuidValue? creatorId,
    _i2.AuthUser? creator,
    String? title,
    String? description,
    String? courseImageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    _i3.CourseVisibility? visibility,
    String? systemPrompt,
    List<String>? courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i4.Module>? modules,
    List<_i5.CourseIndex>? courseIndices,
    List<_i6.KnowledgeFile>? knowledgeFiles,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Course',
      if (id != null) 'id': id,
      'creatorId': creatorId.toJson(),
      if (creator != null) 'creator': creator?.toJson(),
      'title': title,
      if (description != null) 'description': description,
      if (courseImageUrl != null) 'courseImageUrl': courseImageUrl,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'visibility': visibility.toJson(),
      if (systemPrompt != null) 'systemPrompt': systemPrompt,
      if (courseTopics != null) 'courseTopics': courseTopics?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (modules != null)
        'modules': modules?.toJson(valueToJson: (v) => v.toJson()),
      if (courseIndices != null)
        'courseIndices': courseIndices?.toJson(valueToJson: (v) => v.toJson()),
      if (knowledgeFiles != null)
        'knowledgeFiles': knowledgeFiles?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Course',
      if (id != null) 'id': id,
      'creatorId': creatorId.toJson(),
      if (creator != null) 'creator': creator?.toJsonForProtocol(),
      'title': title,
      if (description != null) 'description': description,
      if (courseImageUrl != null) 'courseImageUrl': courseImageUrl,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'visibility': visibility.toJson(),
      if (systemPrompt != null) 'systemPrompt': systemPrompt,
      if (courseTopics != null) 'courseTopics': courseTopics?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (modules != null)
        'modules': modules?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (courseIndices != null)
        'courseIndices': courseIndices?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (knowledgeFiles != null)
        'knowledgeFiles': knowledgeFiles?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  static CourseInclude include({
    _i2.AuthUserInclude? creator,
    _i4.ModuleIncludeList? modules,
    _i5.CourseIndexIncludeList? courseIndices,
    _i6.KnowledgeFileIncludeList? knowledgeFiles,
  }) {
    return CourseInclude._(
      creator: creator,
      modules: modules,
      courseIndices: courseIndices,
      knowledgeFiles: knowledgeFiles,
    );
  }

  static CourseIncludeList includeList({
    _i1.WhereExpressionBuilder<CourseTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseTable>? orderByList,
    CourseInclude? include,
  }) {
    return CourseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Course.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Course.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CourseImpl extends Course {
  _CourseImpl({
    int? id,
    required _i1.UuidValue creatorId,
    _i2.AuthUser? creator,
    required String title,
    String? description,
    String? courseImageUrl,
    String? bannerImageUrl,
    String? videoUrl,
    required _i3.CourseVisibility visibility,
    String? systemPrompt,
    List<String>? courseTopics,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<_i4.Module>? modules,
    List<_i5.CourseIndex>? courseIndices,
    List<_i6.KnowledgeFile>? knowledgeFiles,
  }) : super._(
         id: id,
         creatorId: creatorId,
         creator: creator,
         title: title,
         description: description,
         courseImageUrl: courseImageUrl,
         bannerImageUrl: bannerImageUrl,
         videoUrl: videoUrl,
         visibility: visibility,
         systemPrompt: systemPrompt,
         courseTopics: courseTopics,
         createdAt: createdAt,
         updatedAt: updatedAt,
         modules: modules,
         courseIndices: courseIndices,
         knowledgeFiles: knowledgeFiles,
       );

  /// Returns a shallow copy of this [Course]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Course copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? creatorId,
    Object? creator = _Undefined,
    String? title,
    Object? description = _Undefined,
    Object? courseImageUrl = _Undefined,
    Object? bannerImageUrl = _Undefined,
    Object? videoUrl = _Undefined,
    _i3.CourseVisibility? visibility,
    Object? systemPrompt = _Undefined,
    Object? courseTopics = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? modules = _Undefined,
    Object? courseIndices = _Undefined,
    Object? knowledgeFiles = _Undefined,
  }) {
    return Course(
      id: id is int? ? id : this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator is _i2.AuthUser? ? creator : this.creator?.copyWith(),
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      courseImageUrl: courseImageUrl is String?
          ? courseImageUrl
          : this.courseImageUrl,
      bannerImageUrl: bannerImageUrl is String?
          ? bannerImageUrl
          : this.bannerImageUrl,
      videoUrl: videoUrl is String? ? videoUrl : this.videoUrl,
      visibility: visibility ?? this.visibility,
      systemPrompt: systemPrompt is String? ? systemPrompt : this.systemPrompt,
      courseTopics: courseTopics is List<String>?
          ? courseTopics
          : this.courseTopics?.map((e0) => e0).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      modules: modules is List<_i4.Module>?
          ? modules
          : this.modules?.map((e0) => e0.copyWith()).toList(),
      courseIndices: courseIndices is List<_i5.CourseIndex>?
          ? courseIndices
          : this.courseIndices?.map((e0) => e0.copyWith()).toList(),
      knowledgeFiles: knowledgeFiles is List<_i6.KnowledgeFile>?
          ? knowledgeFiles
          : this.knowledgeFiles?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class CourseUpdateTable extends _i1.UpdateTable<CourseTable> {
  CourseUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> creatorId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.creatorId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<String, String> courseImageUrl(String? value) =>
      _i1.ColumnValue(
        table.courseImageUrl,
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

  _i1.ColumnValue<_i3.CourseVisibility, _i3.CourseVisibility> visibility(
    _i3.CourseVisibility value,
  ) => _i1.ColumnValue(
    table.visibility,
    value,
  );

  _i1.ColumnValue<String, String> systemPrompt(String? value) =>
      _i1.ColumnValue(
        table.systemPrompt,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> courseTopics(
    List<String>? value,
  ) => _i1.ColumnValue(
    table.courseTopics,
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

class CourseTable extends _i1.Table<int?> {
  CourseTable({super.tableRelation}) : super(tableName: 'courses') {
    updateTable = CourseUpdateTable(this);
    creatorId = _i1.ColumnUuid(
      'creatorId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    courseImageUrl = _i1.ColumnString(
      'courseImageUrl',
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
    visibility = _i1.ColumnEnum(
      'visibility',
      this,
      _i1.EnumSerialization.byName,
    );
    systemPrompt = _i1.ColumnString(
      'systemPrompt',
      this,
    );
    courseTopics = _i1.ColumnSerializable<List<String>>(
      'courseTopics',
      this,
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

  late final CourseUpdateTable updateTable;

  late final _i1.ColumnUuid creatorId;

  /// Link to the authenticated user who created this course (nullable, set by server)
  _i2.AuthUserTable? _creator;

  /// Course title
  late final _i1.ColumnString title;

  /// Course description
  late final _i1.ColumnString description;

  /// URL for course thumbnail image
  late final _i1.ColumnString courseImageUrl;

  /// URL for course banner image
  late final _i1.ColumnString bannerImageUrl;

  /// URL for course intro video
  late final _i1.ColumnString videoUrl;

  /// Course visibility status (draft, public, private)
  late final _i1.ColumnEnum<_i3.CourseVisibility> visibility;

  /// System prompt for AI course generation
  late final _i1.ColumnString systemPrompt;

  /// Course topics/tags for categorization and search
  late final _i1.ColumnSerializable<List<String>> courseTopics;

  /// Timestamp when the course was created
  late final _i1.ColumnDateTime createdAt;

  /// Timestamp when the course was last updated
  late final _i1.ColumnDateTime updatedAt;

  /// List of modules in this course
  _i4.ModuleTable? ___modules;

  /// List of modules in this course
  _i1.ManyRelation<_i4.ModuleTable>? _modules;

  /// List of course indices (searchable tags/keywords)
  _i5.CourseIndexTable? ___courseIndices;

  /// List of course indices (searchable tags/keywords)
  _i1.ManyRelation<_i5.CourseIndexTable>? _courseIndices;

  /// List of knowledge files for AI generation
  _i6.KnowledgeFileTable? ___knowledgeFiles;

  /// List of knowledge files for AI generation
  _i1.ManyRelation<_i6.KnowledgeFileTable>? _knowledgeFiles;

  _i2.AuthUserTable get creator {
    if (_creator != null) return _creator!;
    _creator = _i1.createRelationTable(
      relationFieldName: 'creator',
      field: Course.t.creatorId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _creator!;
  }

  _i4.ModuleTable get __modules {
    if (___modules != null) return ___modules!;
    ___modules = _i1.createRelationTable(
      relationFieldName: '__modules',
      field: Course.t.id,
      foreignField: _i4.Module.t.$_coursesModulesCoursesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i4.ModuleTable(tableRelation: foreignTableRelation),
    );
    return ___modules!;
  }

  _i5.CourseIndexTable get __courseIndices {
    if (___courseIndices != null) return ___courseIndices!;
    ___courseIndices = _i1.createRelationTable(
      relationFieldName: '__courseIndices',
      field: Course.t.id,
      foreignField: _i5.CourseIndex.t.$_coursesCourseindicesCoursesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i5.CourseIndexTable(tableRelation: foreignTableRelation),
    );
    return ___courseIndices!;
  }

  _i6.KnowledgeFileTable get __knowledgeFiles {
    if (___knowledgeFiles != null) return ___knowledgeFiles!;
    ___knowledgeFiles = _i1.createRelationTable(
      relationFieldName: '__knowledgeFiles',
      field: Course.t.id,
      foreignField: _i6.KnowledgeFile.t.$_coursesKnowledgefilesCoursesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i6.KnowledgeFileTable(tableRelation: foreignTableRelation),
    );
    return ___knowledgeFiles!;
  }

  _i1.ManyRelation<_i4.ModuleTable> get modules {
    if (_modules != null) return _modules!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'modules',
      field: Course.t.id,
      foreignField: _i4.Module.t.$_coursesModulesCoursesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i4.ModuleTable(tableRelation: foreignTableRelation),
    );
    _modules = _i1.ManyRelation<_i4.ModuleTable>(
      tableWithRelations: relationTable,
      table: _i4.ModuleTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _modules!;
  }

  _i1.ManyRelation<_i5.CourseIndexTable> get courseIndices {
    if (_courseIndices != null) return _courseIndices!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'courseIndices',
      field: Course.t.id,
      foreignField: _i5.CourseIndex.t.$_coursesCourseindicesCoursesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i5.CourseIndexTable(tableRelation: foreignTableRelation),
    );
    _courseIndices = _i1.ManyRelation<_i5.CourseIndexTable>(
      tableWithRelations: relationTable,
      table: _i5.CourseIndexTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _courseIndices!;
  }

  _i1.ManyRelation<_i6.KnowledgeFileTable> get knowledgeFiles {
    if (_knowledgeFiles != null) return _knowledgeFiles!;
    var relationTable = _i1.createRelationTable(
      relationFieldName: 'knowledgeFiles',
      field: Course.t.id,
      foreignField: _i6.KnowledgeFile.t.$_coursesKnowledgefilesCoursesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i6.KnowledgeFileTable(tableRelation: foreignTableRelation),
    );
    _knowledgeFiles = _i1.ManyRelation<_i6.KnowledgeFileTable>(
      tableWithRelations: relationTable,
      table: _i6.KnowledgeFileTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _knowledgeFiles!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    creatorId,
    title,
    description,
    courseImageUrl,
    bannerImageUrl,
    videoUrl,
    visibility,
    systemPrompt,
    courseTopics,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'creator') {
      return creator;
    }
    if (relationField == 'modules') {
      return __modules;
    }
    if (relationField == 'courseIndices') {
      return __courseIndices;
    }
    if (relationField == 'knowledgeFiles') {
      return __knowledgeFiles;
    }
    return null;
  }
}

class CourseInclude extends _i1.IncludeObject {
  CourseInclude._({
    _i2.AuthUserInclude? creator,
    _i4.ModuleIncludeList? modules,
    _i5.CourseIndexIncludeList? courseIndices,
    _i6.KnowledgeFileIncludeList? knowledgeFiles,
  }) {
    _creator = creator;
    _modules = modules;
    _courseIndices = courseIndices;
    _knowledgeFiles = knowledgeFiles;
  }

  _i2.AuthUserInclude? _creator;

  _i4.ModuleIncludeList? _modules;

  _i5.CourseIndexIncludeList? _courseIndices;

  _i6.KnowledgeFileIncludeList? _knowledgeFiles;

  @override
  Map<String, _i1.Include?> get includes => {
    'creator': _creator,
    'modules': _modules,
    'courseIndices': _courseIndices,
    'knowledgeFiles': _knowledgeFiles,
  };

  @override
  _i1.Table<int?> get table => Course.t;
}

class CourseIncludeList extends _i1.IncludeList {
  CourseIncludeList._({
    _i1.WhereExpressionBuilder<CourseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Course.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Course.t;
}

class CourseRepository {
  const CourseRepository._();

  final attach = const CourseAttachRepository._();

  final attachRow = const CourseAttachRowRepository._();

  final detach = const CourseDetachRepository._();

  final detachRow = const CourseDetachRowRepository._();

  /// Returns a list of [Course]s matching the given query parameters.
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
  Future<List<Course>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CourseTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseTable>? orderByList,
    _i1.Transaction? transaction,
    CourseInclude? include,
  }) async {
    return session.db.find<Course>(
      where: where?.call(Course.t),
      orderBy: orderBy?.call(Course.t),
      orderByList: orderByList?.call(Course.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Course] matching the given query parameters.
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
  Future<Course?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CourseTable>? where,
    int? offset,
    _i1.OrderByBuilder<CourseTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CourseTable>? orderByList,
    _i1.Transaction? transaction,
    CourseInclude? include,
  }) async {
    return session.db.findFirstRow<Course>(
      where: where?.call(Course.t),
      orderBy: orderBy?.call(Course.t),
      orderByList: orderByList?.call(Course.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Course] by its [id] or null if no such row exists.
  Future<Course?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    CourseInclude? include,
  }) async {
    return session.db.findById<Course>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Course]s in the list and returns the inserted rows.
  ///
  /// The returned [Course]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Course>> insert(
    _i1.Session session,
    List<Course> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Course>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Course] and returns the inserted row.
  ///
  /// The returned [Course] will have its `id` field set.
  Future<Course> insertRow(
    _i1.Session session,
    Course row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Course>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Course]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Course>> update(
    _i1.Session session,
    List<Course> rows, {
    _i1.ColumnSelections<CourseTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Course>(
      rows,
      columns: columns?.call(Course.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Course]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Course> updateRow(
    _i1.Session session,
    Course row, {
    _i1.ColumnSelections<CourseTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Course>(
      row,
      columns: columns?.call(Course.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Course] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Course?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<CourseUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Course>(
      id,
      columnValues: columnValues(Course.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Course]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Course>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<CourseUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CourseTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CourseTable>? orderBy,
    _i1.OrderByListBuilder<CourseTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Course>(
      columnValues: columnValues(Course.t.updateTable),
      where: where(Course.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Course.t),
      orderByList: orderByList?.call(Course.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Course]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Course>> delete(
    _i1.Session session,
    List<Course> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Course>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Course].
  Future<Course> deleteRow(
    _i1.Session session,
    Course row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Course>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Course>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CourseTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Course>(
      where: where(Course.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CourseTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Course>(
      where: where?.call(Course.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class CourseAttachRepository {
  const CourseAttachRepository._();

  /// Creates a relation between this [Course] and the given [Module]s
  /// by setting each [Module]'s foreign key `_coursesModulesCoursesId` to refer to this [Course].
  Future<void> modules(
    _i1.Session session,
    Course course,
    List<_i4.Module> module, {
    _i1.Transaction? transaction,
  }) async {
    if (module.any((e) => e.id == null)) {
      throw ArgumentError.notNull('module.id');
    }
    if (course.id == null) {
      throw ArgumentError.notNull('course.id');
    }

    var $module = module
        .map(
          (e) => _i4.ModuleImplicit(
            e,
            $_coursesModulesCoursesId: course.id,
          ),
        )
        .toList();
    await session.db.update<_i4.Module>(
      $module,
      columns: [_i4.Module.t.$_coursesModulesCoursesId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Course] and the given [CourseIndex]s
  /// by setting each [CourseIndex]'s foreign key `_coursesCourseindicesCoursesId` to refer to this [Course].
  Future<void> courseIndices(
    _i1.Session session,
    Course course,
    List<_i5.CourseIndex> courseIndex, {
    _i1.Transaction? transaction,
  }) async {
    if (courseIndex.any((e) => e.id == null)) {
      throw ArgumentError.notNull('courseIndex.id');
    }
    if (course.id == null) {
      throw ArgumentError.notNull('course.id');
    }

    var $courseIndex = courseIndex
        .map(
          (e) => _i5.CourseIndexImplicit(
            e,
            $_coursesCourseindicesCoursesId: course.id,
          ),
        )
        .toList();
    await session.db.update<_i5.CourseIndex>(
      $courseIndex,
      columns: [_i5.CourseIndex.t.$_coursesCourseindicesCoursesId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Course] and the given [KnowledgeFile]s
  /// by setting each [KnowledgeFile]'s foreign key `_coursesKnowledgefilesCoursesId` to refer to this [Course].
  Future<void> knowledgeFiles(
    _i1.Session session,
    Course course,
    List<_i6.KnowledgeFile> knowledgeFile, {
    _i1.Transaction? transaction,
  }) async {
    if (knowledgeFile.any((e) => e.id == null)) {
      throw ArgumentError.notNull('knowledgeFile.id');
    }
    if (course.id == null) {
      throw ArgumentError.notNull('course.id');
    }

    var $knowledgeFile = knowledgeFile
        .map(
          (e) => _i6.KnowledgeFileImplicit(
            e,
            $_coursesKnowledgefilesCoursesId: course.id,
          ),
        )
        .toList();
    await session.db.update<_i6.KnowledgeFile>(
      $knowledgeFile,
      columns: [_i6.KnowledgeFile.t.$_coursesKnowledgefilesCoursesId],
      transaction: transaction,
    );
  }
}

class CourseAttachRowRepository {
  const CourseAttachRowRepository._();

  /// Creates a relation between the given [Course] and [AuthUser]
  /// by setting the [Course]'s foreign key `creatorId` to refer to the [AuthUser].
  Future<void> creator(
    _i1.Session session,
    Course course,
    _i2.AuthUser creator, {
    _i1.Transaction? transaction,
  }) async {
    if (course.id == null) {
      throw ArgumentError.notNull('course.id');
    }
    if (creator.id == null) {
      throw ArgumentError.notNull('creator.id');
    }

    var $course = course.copyWith(creatorId: creator.id);
    await session.db.updateRow<Course>(
      $course,
      columns: [Course.t.creatorId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Course] and the given [Module]
  /// by setting the [Module]'s foreign key `_coursesModulesCoursesId` to refer to this [Course].
  Future<void> modules(
    _i1.Session session,
    Course course,
    _i4.Module module, {
    _i1.Transaction? transaction,
  }) async {
    if (module.id == null) {
      throw ArgumentError.notNull('module.id');
    }
    if (course.id == null) {
      throw ArgumentError.notNull('course.id');
    }

    var $module = _i4.ModuleImplicit(
      module,
      $_coursesModulesCoursesId: course.id,
    );
    await session.db.updateRow<_i4.Module>(
      $module,
      columns: [_i4.Module.t.$_coursesModulesCoursesId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Course] and the given [CourseIndex]
  /// by setting the [CourseIndex]'s foreign key `_coursesCourseindicesCoursesId` to refer to this [Course].
  Future<void> courseIndices(
    _i1.Session session,
    Course course,
    _i5.CourseIndex courseIndex, {
    _i1.Transaction? transaction,
  }) async {
    if (courseIndex.id == null) {
      throw ArgumentError.notNull('courseIndex.id');
    }
    if (course.id == null) {
      throw ArgumentError.notNull('course.id');
    }

    var $courseIndex = _i5.CourseIndexImplicit(
      courseIndex,
      $_coursesCourseindicesCoursesId: course.id,
    );
    await session.db.updateRow<_i5.CourseIndex>(
      $courseIndex,
      columns: [_i5.CourseIndex.t.$_coursesCourseindicesCoursesId],
      transaction: transaction,
    );
  }

  /// Creates a relation between this [Course] and the given [KnowledgeFile]
  /// by setting the [KnowledgeFile]'s foreign key `_coursesKnowledgefilesCoursesId` to refer to this [Course].
  Future<void> knowledgeFiles(
    _i1.Session session,
    Course course,
    _i6.KnowledgeFile knowledgeFile, {
    _i1.Transaction? transaction,
  }) async {
    if (knowledgeFile.id == null) {
      throw ArgumentError.notNull('knowledgeFile.id');
    }
    if (course.id == null) {
      throw ArgumentError.notNull('course.id');
    }

    var $knowledgeFile = _i6.KnowledgeFileImplicit(
      knowledgeFile,
      $_coursesKnowledgefilesCoursesId: course.id,
    );
    await session.db.updateRow<_i6.KnowledgeFile>(
      $knowledgeFile,
      columns: [_i6.KnowledgeFile.t.$_coursesKnowledgefilesCoursesId],
      transaction: transaction,
    );
  }
}

class CourseDetachRepository {
  const CourseDetachRepository._();

  /// Detaches the relation between this [Course] and the given [Module]
  /// by setting the [Module]'s foreign key `_coursesModulesCoursesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> modules(
    _i1.Session session,
    List<_i4.Module> module, {
    _i1.Transaction? transaction,
  }) async {
    if (module.any((e) => e.id == null)) {
      throw ArgumentError.notNull('module.id');
    }

    var $module = module
        .map(
          (e) => _i4.ModuleImplicit(
            e,
            $_coursesModulesCoursesId: null,
          ),
        )
        .toList();
    await session.db.update<_i4.Module>(
      $module,
      columns: [_i4.Module.t.$_coursesModulesCoursesId],
      transaction: transaction,
    );
  }

  /// Detaches the relation between this [Course] and the given [CourseIndex]
  /// by setting the [CourseIndex]'s foreign key `_coursesCourseindicesCoursesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> courseIndices(
    _i1.Session session,
    List<_i5.CourseIndex> courseIndex, {
    _i1.Transaction? transaction,
  }) async {
    if (courseIndex.any((e) => e.id == null)) {
      throw ArgumentError.notNull('courseIndex.id');
    }

    var $courseIndex = courseIndex
        .map(
          (e) => _i5.CourseIndexImplicit(
            e,
            $_coursesCourseindicesCoursesId: null,
          ),
        )
        .toList();
    await session.db.update<_i5.CourseIndex>(
      $courseIndex,
      columns: [_i5.CourseIndex.t.$_coursesCourseindicesCoursesId],
      transaction: transaction,
    );
  }

  /// Detaches the relation between this [Course] and the given [KnowledgeFile]
  /// by setting the [KnowledgeFile]'s foreign key `_coursesKnowledgefilesCoursesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> knowledgeFiles(
    _i1.Session session,
    List<_i6.KnowledgeFile> knowledgeFile, {
    _i1.Transaction? transaction,
  }) async {
    if (knowledgeFile.any((e) => e.id == null)) {
      throw ArgumentError.notNull('knowledgeFile.id');
    }

    var $knowledgeFile = knowledgeFile
        .map(
          (e) => _i6.KnowledgeFileImplicit(
            e,
            $_coursesKnowledgefilesCoursesId: null,
          ),
        )
        .toList();
    await session.db.update<_i6.KnowledgeFile>(
      $knowledgeFile,
      columns: [_i6.KnowledgeFile.t.$_coursesKnowledgefilesCoursesId],
      transaction: transaction,
    );
  }
}

class CourseDetachRowRepository {
  const CourseDetachRowRepository._();

  /// Detaches the relation between this [Course] and the given [Module]
  /// by setting the [Module]'s foreign key `_coursesModulesCoursesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> modules(
    _i1.Session session,
    _i4.Module module, {
    _i1.Transaction? transaction,
  }) async {
    if (module.id == null) {
      throw ArgumentError.notNull('module.id');
    }

    var $module = _i4.ModuleImplicit(
      module,
      $_coursesModulesCoursesId: null,
    );
    await session.db.updateRow<_i4.Module>(
      $module,
      columns: [_i4.Module.t.$_coursesModulesCoursesId],
      transaction: transaction,
    );
  }

  /// Detaches the relation between this [Course] and the given [CourseIndex]
  /// by setting the [CourseIndex]'s foreign key `_coursesCourseindicesCoursesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> courseIndices(
    _i1.Session session,
    _i5.CourseIndex courseIndex, {
    _i1.Transaction? transaction,
  }) async {
    if (courseIndex.id == null) {
      throw ArgumentError.notNull('courseIndex.id');
    }

    var $courseIndex = _i5.CourseIndexImplicit(
      courseIndex,
      $_coursesCourseindicesCoursesId: null,
    );
    await session.db.updateRow<_i5.CourseIndex>(
      $courseIndex,
      columns: [_i5.CourseIndex.t.$_coursesCourseindicesCoursesId],
      transaction: transaction,
    );
  }

  /// Detaches the relation between this [Course] and the given [KnowledgeFile]
  /// by setting the [KnowledgeFile]'s foreign key `_coursesKnowledgefilesCoursesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> knowledgeFiles(
    _i1.Session session,
    _i6.KnowledgeFile knowledgeFile, {
    _i1.Transaction? transaction,
  }) async {
    if (knowledgeFile.id == null) {
      throw ArgumentError.notNull('knowledgeFile.id');
    }

    var $knowledgeFile = _i6.KnowledgeFileImplicit(
      knowledgeFile,
      $_coursesKnowledgefilesCoursesId: null,
    );
    await session.db.updateRow<_i6.KnowledgeFile>(
      $knowledgeFile,
      columns: [_i6.KnowledgeFile.t.$_coursesKnowledgefilesCoursesId],
      transaction: transaction,
    );
  }
}
