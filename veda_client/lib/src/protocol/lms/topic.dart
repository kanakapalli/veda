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

/// Topic - reusable lesson content that can be shared across modules
abstract class Topic implements _i1.SerializableModel {
  Topic._({
    this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.imageUrl,
    this.bannerImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Topic({
    int? id,
    required String title,
    String? description,
    String? videoUrl,
    String? imageUrl,
    String? bannerImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TopicImpl;

  factory Topic.fromJson(Map<String, dynamic> jsonSerialization) {
    return Topic(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      videoUrl: jsonSerialization['videoUrl'] as String?,
      imageUrl: jsonSerialization['imageUrl'] as String?,
      bannerImageUrl: jsonSerialization['bannerImageUrl'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Topic title
  String title;

  /// Topic description / lesson content body
  String? description;

  /// URL for topic video
  String? videoUrl;

  /// URL for topic image
  String? imageUrl;

  /// URL for topic banner image
  String? bannerImageUrl;

  /// Timestamp when the topic was created
  DateTime createdAt;

  /// Timestamp when the topic was last updated
  DateTime updatedAt;

  /// Returns a shallow copy of this [Topic]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Topic copyWith({
    int? id,
    String? title,
    String? description,
    String? videoUrl,
    String? imageUrl,
    String? bannerImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Topic',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (bannerImageUrl != null) 'bannerImageUrl': bannerImageUrl,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TopicImpl extends Topic {
  _TopicImpl({
    int? id,
    required String title,
    String? description,
    String? videoUrl,
    String? imageUrl,
    String? bannerImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         title: title,
         description: description,
         videoUrl: videoUrl,
         imageUrl: imageUrl,
         bannerImageUrl: bannerImageUrl,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Topic]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Topic copyWith({
    Object? id = _Undefined,
    String? title,
    Object? description = _Undefined,
    Object? videoUrl = _Undefined,
    Object? imageUrl = _Undefined,
    Object? bannerImageUrl = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Topic(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      videoUrl: videoUrl is String? ? videoUrl : this.videoUrl,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      bannerImageUrl: bannerImageUrl is String?
          ? bannerImageUrl
          : this.bannerImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
