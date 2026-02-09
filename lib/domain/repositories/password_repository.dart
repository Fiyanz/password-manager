import '../entities/password_entity.dart';

abstract class PasswordRepository {
  Future<List<PasswordEntity>> getAllPasswords();
  Future<PasswordEntity?> getPasswordById(String id);
  Future<void> addPassword(PasswordEntity password);
  Future<void> updatePassword(PasswordEntity password);
  Future<void> deletePassword(String id);
}
