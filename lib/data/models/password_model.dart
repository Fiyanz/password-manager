import '../../../domain/entities/password_entity.dart';

class PasswordModel {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? category;
  final String createdAt;
  final String updatedAt;

  PasswordModel({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  // Serialization - from JSON (database)
  factory PasswordModel.fromJson(Map<String, dynamic> json) {
    return PasswordModel(
      id: json['id'] as String,
      title: json['title'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      url: json['url'] as String?,
      category: json['category'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  // Serialization - to JSON (database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'category': category,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Conversion to Entity (Domain layer)
  PasswordEntity toEntity() {
    return PasswordEntity(
      id: id,
      title: title,
      username: username,
      password: password,
      url: url,
      createdAt: DateTime.parse(createdAt),
    );
  }

  // Conversion from Entity (Domain layer)
  factory PasswordModel.fromEntity(PasswordEntity entity) {
    final now = DateTime.now().toIso8601String();
    return PasswordModel(
      id: entity.id,
      title: entity.title,
      username: entity.username,
      password: entity.password,
      url: entity.url,
      category: null, // Will be added later
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: now,
    );
  }

  // Copy with method for updates
  PasswordModel copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? category,
    String? createdAt,
    String? updatedAt,
  }) {
    return PasswordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
