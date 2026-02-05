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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../lms/module.dart' as _i2;
import '../lms/topic.dart' as _i3;
import 'package:veda_client/src/protocol/protocol.dart' as _i4;

/// ModuleItem - junction table linking modules to topics with context
abstract class ModuleItem implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
