class PasswordEntity {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final DateTime createdAt;

  const PasswordEntity({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    required this.createdAt,
  });
}
