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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'gemini/chat_message.dart' as _i5;
import 'gemini/chat_request.dart' as _i6;
import 'gemini/chat_response.dart' as _i7;
import 'gemini/course_chat_request.dart' as _i8;
import 'gemini/course_chat_response.dart' as _i9;
import 'greetings/greeting.dart' as _i10;
import 'lms/course.dart' as _i11;
import 'lms/course_index.dart' as _i12;
import 'lms/course_visibility.dart' as _i13;
import 'lms/file_creation_draft.dart' as _i14;
import 'lms/knowledge_file.dart' as _i15;
import 'lms/module.dart' as _i16;
import 'lms/module_item.dart' as _i17;
import 'lms/topic.dart' as _i18;
import 'profiles/user_profile.dart' as _i19;
import 'profiles/user_profile_with_email.dart' as _i20;
import 'profiles/user_type.dart' as _i21;
import 'package:veda_server/src/generated/lms/course.dart' as _i22;
import 'package:veda_server/src/generated/lms/knowledge_file.dart' as _i23;
import 'package:veda_server/src/generated/lms/file_creation_draft.dart' as _i24;
import 'package:veda_server/src/generated/lms/module.dart' as _i25;
export 'gemini/chat_message.dart';
export 'gemini/chat_request.dart';
export 'gemini/chat_response.dart';
export 'gemini/course_chat_request.dart';
export 'gemini/course_chat_response.dart';
export 'greetings/greeting.dart';
export 'lms/course.dart';
export 'lms/course_index.dart';
export 'lms/course_visibility.dart';
export 'lms/file_creation_draft.dart';
export 'lms/knowledge_file.dart';
export 'lms/module.dart';
export 'lms/module_item.dart';
export 'lms/topic.dart';
export 'profiles/user_profile.dart';
export 'profiles/user_profile_with_email.dart';
export 'profiles/user_type.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'course_indices',
      dartName: 'CourseIndex',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'course_indices_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'imageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'tags',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'courseId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'course',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:Course?',
        ),
        _i2.ColumnDefinition(
          name: '_coursesCourseindicesCoursesId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'course_indices_fk_0',
          columns: ['courseId'],
          referenceTable: 'courses',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'course_indices_fk_1',
          columns: ['_coursesCourseindicesCoursesId'],
          referenceTable: 'courses',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'course_indices_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'course_indices_course_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'courseId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'course_indices_title_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'title',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'courses',
      dartName: 'Course',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'courses_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'creatorId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'courseImageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'bannerImageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'videoUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'visibility',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CourseVisibility',
        ),
        _i2.ColumnDefinition(
          name: 'systemPrompt',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'courses_fk_0',
          columns: ['creatorId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'courses_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'courses_visibility_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'visibility',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'courses_created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'courses_creator_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'creatorId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'file_creation_drafts',
      dartName: 'FileCreationDraft',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'file_creation_drafts_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'creatorId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'courseId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'content',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'chatHistory',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'fileType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'md\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'file_creation_drafts_fk_0',
          columns: ['creatorId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'file_creation_drafts_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'file_creation_drafts_creator_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'creatorId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'file_creation_drafts_course_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'courseId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'file_creation_drafts_updated_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'updatedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'knowledge_files',
      dartName: 'KnowledgeFile',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'knowledge_files_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'fileName',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fileUrl',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fileSize',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'fileType',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'textContent',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'embedding',
          columnType: _i2.ColumnType.vector,
          isNullable: true,
          dartType: 'Vector(3072)?',
          vectorDimension: 3072,
        ),
        _i2.ColumnDefinition(
          name: 'uploadedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'courseId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'course',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:Course?',
        ),
        _i2.ColumnDefinition(
          name: '_coursesKnowledgefilesCoursesId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'knowledge_files_fk_0',
          columns: ['courseId'],
          referenceTable: 'courses',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'knowledge_files_fk_1',
          columns: ['_coursesKnowledgefilesCoursesId'],
          referenceTable: 'courses',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'knowledge_files_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'knowledge_files_course_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'courseId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'module_items',
      dartName: 'ModuleItem',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'module_items_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'contextualDescription',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'moduleId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'module',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:Module?',
        ),
        _i2.ColumnDefinition(
          name: 'topicId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'topic',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:Topic?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'module_items_fk_0',
          columns: ['moduleId'],
          referenceTable: 'modules',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'module_items_fk_1',
          columns: ['topicId'],
          referenceTable: 'topics',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'module_items_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'module_items_module_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'moduleId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'module_items_topic_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'topicId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'module_items_sort_order_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'modules',
      dartName: 'Module',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'modules_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'imageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'bannerImageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'videoUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'courseId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'course',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:Course?',
        ),
        _i2.ColumnDefinition(
          name: 'items',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<protocol:ModuleItem>?',
        ),
        _i2.ColumnDefinition(
          name: '_coursesModulesCoursesId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'modules_fk_0',
          columns: ['courseId'],
          referenceTable: 'courses',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'modules_fk_1',
          columns: ['_coursesModulesCoursesId'],
          referenceTable: 'courses',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'modules_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'modules_course_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'courseId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'modules_sort_order_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sortOrder',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'topics',
      dartName: 'Topic',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'topics_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'videoUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'imageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'bannerImageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'topics_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'topics_title_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'title',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'veda_user_profile',
      dartName: 'VedaUserProfile',
      schema: 'public',
      module: 'veda',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'veda_user_profile_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'userTypes',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:UserType>',
        ),
        _i2.ColumnDefinition(
          name: 'fullName',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'bio',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'interests',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _i2.ColumnDefinition(
          name: 'learningGoal',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'websiteUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'profileImageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'expertise',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'veda_user_profile_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'veda_user_profile_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'veda_user_profile_auth_user_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.ChatMessage) {
      return _i5.ChatMessage.fromJson(data) as T;
    }
    if (t == _i6.ChatRequest) {
      return _i6.ChatRequest.fromJson(data) as T;
    }
    if (t == _i7.ChatResponse) {
      return _i7.ChatResponse.fromJson(data) as T;
    }
    if (t == _i8.CourseChatRequest) {
      return _i8.CourseChatRequest.fromJson(data) as T;
    }
    if (t == _i9.CourseChatResponse) {
      return _i9.CourseChatResponse.fromJson(data) as T;
    }
    if (t == _i10.Greeting) {
      return _i10.Greeting.fromJson(data) as T;
    }
    if (t == _i11.Course) {
      return _i11.Course.fromJson(data) as T;
    }
    if (t == _i12.CourseIndex) {
      return _i12.CourseIndex.fromJson(data) as T;
    }
    if (t == _i13.CourseVisibility) {
      return _i13.CourseVisibility.fromJson(data) as T;
    }
    if (t == _i14.FileCreationDraft) {
      return _i14.FileCreationDraft.fromJson(data) as T;
    }
    if (t == _i15.KnowledgeFile) {
      return _i15.KnowledgeFile.fromJson(data) as T;
    }
    if (t == _i16.Module) {
      return _i16.Module.fromJson(data) as T;
    }
    if (t == _i17.ModuleItem) {
      return _i17.ModuleItem.fromJson(data) as T;
    }
    if (t == _i18.Topic) {
      return _i18.Topic.fromJson(data) as T;
    }
    if (t == _i19.VedaUserProfile) {
      return _i19.VedaUserProfile.fromJson(data) as T;
    }
    if (t == _i20.VedaUserProfileWithEmail) {
      return _i20.VedaUserProfileWithEmail.fromJson(data) as T;
    }
    if (t == _i21.UserType) {
      return _i21.UserType.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.ChatMessage?>()) {
      return (data != null ? _i5.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ChatRequest?>()) {
      return (data != null ? _i6.ChatRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatResponse?>()) {
      return (data != null ? _i7.ChatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CourseChatRequest?>()) {
      return (data != null ? _i8.CourseChatRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CourseChatResponse?>()) {
      return (data != null ? _i9.CourseChatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Greeting?>()) {
      return (data != null ? _i10.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Course?>()) {
      return (data != null ? _i11.Course.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.CourseIndex?>()) {
      return (data != null ? _i12.CourseIndex.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.CourseVisibility?>()) {
      return (data != null ? _i13.CourseVisibility.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.FileCreationDraft?>()) {
      return (data != null ? _i14.FileCreationDraft.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.KnowledgeFile?>()) {
      return (data != null ? _i15.KnowledgeFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.Module?>()) {
      return (data != null ? _i16.Module.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ModuleItem?>()) {
      return (data != null ? _i17.ModuleItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.Topic?>()) {
      return (data != null ? _i18.Topic.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.VedaUserProfile?>()) {
      return (data != null ? _i19.VedaUserProfile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.VedaUserProfileWithEmail?>()) {
      return (data != null
              ? _i20.VedaUserProfileWithEmail.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i21.UserType?>()) {
      return (data != null ? _i21.UserType.fromJson(data) : null) as T;
    }
    if (t == List<_i5.ChatMessage>) {
      return (data as List).map((e) => deserialize<_i5.ChatMessage>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i5.ChatMessage>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i5.ChatMessage>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i16.Module>) {
      return (data as List).map((e) => deserialize<_i16.Module>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i16.Module>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i16.Module>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i12.CourseIndex>) {
      return (data as List)
              .map((e) => deserialize<_i12.CourseIndex>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i12.CourseIndex>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i12.CourseIndex>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i15.KnowledgeFile>) {
      return (data as List)
              .map((e) => deserialize<_i15.KnowledgeFile>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i15.KnowledgeFile>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i15.KnowledgeFile>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i17.ModuleItem>) {
      return (data as List).map((e) => deserialize<_i17.ModuleItem>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i17.ModuleItem>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i17.ModuleItem>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i21.UserType>) {
      return (data as List).map((e) => deserialize<_i21.UserType>(e)).toList()
          as T;
    }
    if (t == List<Map<String, String>>) {
      return (data as List)
              .map((e) => deserialize<Map<String, String>>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _i1.getType<List<Map<String, String>>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<Map<String, String>>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i22.Course>) {
      return (data as List).map((e) => deserialize<_i22.Course>(e)).toList()
          as T;
    }
    if (t == List<_i23.KnowledgeFile>) {
      return (data as List)
              .map((e) => deserialize<_i23.KnowledgeFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.FileCreationDraft>) {
      return (data as List)
              .map((e) => deserialize<_i24.FileCreationDraft>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.Module>) {
      return (data as List).map((e) => deserialize<_i25.Module>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.ChatMessage => 'ChatMessage',
      _i6.ChatRequest => 'ChatRequest',
      _i7.ChatResponse => 'ChatResponse',
      _i8.CourseChatRequest => 'CourseChatRequest',
      _i9.CourseChatResponse => 'CourseChatResponse',
      _i10.Greeting => 'Greeting',
      _i11.Course => 'Course',
      _i12.CourseIndex => 'CourseIndex',
      _i13.CourseVisibility => 'CourseVisibility',
      _i14.FileCreationDraft => 'FileCreationDraft',
      _i15.KnowledgeFile => 'KnowledgeFile',
      _i16.Module => 'Module',
      _i17.ModuleItem => 'ModuleItem',
      _i18.Topic => 'Topic',
      _i19.VedaUserProfile => 'VedaUserProfile',
      _i20.VedaUserProfileWithEmail => 'VedaUserProfileWithEmail',
      _i21.UserType => 'UserType',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('veda.', '');
    }

    switch (data) {
      case _i5.ChatMessage():
        return 'ChatMessage';
      case _i6.ChatRequest():
        return 'ChatRequest';
      case _i7.ChatResponse():
        return 'ChatResponse';
      case _i8.CourseChatRequest():
        return 'CourseChatRequest';
      case _i9.CourseChatResponse():
        return 'CourseChatResponse';
      case _i10.Greeting():
        return 'Greeting';
      case _i11.Course():
        return 'Course';
      case _i12.CourseIndex():
        return 'CourseIndex';
      case _i13.CourseVisibility():
        return 'CourseVisibility';
      case _i14.FileCreationDraft():
        return 'FileCreationDraft';
      case _i15.KnowledgeFile():
        return 'KnowledgeFile';
      case _i16.Module():
        return 'Module';
      case _i17.ModuleItem():
        return 'ModuleItem';
      case _i18.Topic():
        return 'Topic';
      case _i19.VedaUserProfile():
        return 'VedaUserProfile';
      case _i20.VedaUserProfileWithEmail():
        return 'VedaUserProfileWithEmail';
      case _i21.UserType():
        return 'UserType';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i5.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatRequest') {
      return deserialize<_i6.ChatRequest>(data['data']);
    }
    if (dataClassName == 'ChatResponse') {
      return deserialize<_i7.ChatResponse>(data['data']);
    }
    if (dataClassName == 'CourseChatRequest') {
      return deserialize<_i8.CourseChatRequest>(data['data']);
    }
    if (dataClassName == 'CourseChatResponse') {
      return deserialize<_i9.CourseChatResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i10.Greeting>(data['data']);
    }
    if (dataClassName == 'Course') {
      return deserialize<_i11.Course>(data['data']);
    }
    if (dataClassName == 'CourseIndex') {
      return deserialize<_i12.CourseIndex>(data['data']);
    }
    if (dataClassName == 'CourseVisibility') {
      return deserialize<_i13.CourseVisibility>(data['data']);
    }
    if (dataClassName == 'FileCreationDraft') {
      return deserialize<_i14.FileCreationDraft>(data['data']);
    }
    if (dataClassName == 'KnowledgeFile') {
      return deserialize<_i15.KnowledgeFile>(data['data']);
    }
    if (dataClassName == 'Module') {
      return deserialize<_i16.Module>(data['data']);
    }
    if (dataClassName == 'ModuleItem') {
      return deserialize<_i17.ModuleItem>(data['data']);
    }
    if (dataClassName == 'Topic') {
      return deserialize<_i18.Topic>(data['data']);
    }
    if (dataClassName == 'VedaUserProfile') {
      return deserialize<_i19.VedaUserProfile>(data['data']);
    }
    if (dataClassName == 'VedaUserProfileWithEmail') {
      return deserialize<_i20.VedaUserProfileWithEmail>(data['data']);
    }
    if (dataClassName == 'UserType') {
      return deserialize<_i21.UserType>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i11.Course:
        return _i11.Course.t;
      case _i12.CourseIndex:
        return _i12.CourseIndex.t;
      case _i14.FileCreationDraft:
        return _i14.FileCreationDraft.t;
      case _i15.KnowledgeFile:
        return _i15.KnowledgeFile.t;
      case _i16.Module:
        return _i16.Module.t;
      case _i17.ModuleItem:
        return _i17.ModuleItem.t;
      case _i18.Topic:
        return _i18.Topic.t;
      case _i19.VedaUserProfile:
        return _i19.VedaUserProfile.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'veda';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
