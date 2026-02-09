class PasswordEntity {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PasswordEntity({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  PasswordEntity copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PasswordEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
