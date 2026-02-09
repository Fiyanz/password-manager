import '../../domain/entities/password_entity.dart';
import '../../domain/repositories/password_repository.dart';
import '../datasources/database_helper.dart';
import '../models/password_model.dart';

class PasswordRepositoryImpl implements PasswordRepository {
  final DatabaseHelper _databaseHelper;

  PasswordRepositoryImpl(this._databaseHelper);

  @override
  Future<List<PasswordEntity>> getAllPasswords() async {
    final models = await _databaseHelper.getAllPasswords();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PasswordEntity?> getPasswordById(String id) async {
    final model = await _databaseHelper.getPasswordById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addPassword(PasswordEntity password) async {
    final model = PasswordModel.fromEntity(password);
    await _databaseHelper.insertPassword(model);
  }

  @override
  Future<void> updatePassword(PasswordEntity password) async {
    final model = PasswordModel.fromEntity(password);
    await _databaseHelper.updatePassword(model);
  }

  @override
  Future<void> deletePassword(String id) async {
    await _databaseHelper.deletePassword(id);
  }

  // Additional methods
  Future<List<PasswordEntity>> getPasswordsByCategory(String category) async {
    final models = await _databaseHelper.getPasswordsByCategory(category);
    return models.map((model) => model.toEntity()).toList();
  }

  Future<List<PasswordEntity>> searchPasswords(String query) async {
    final models = await _databaseHelper.searchPasswords(query);
    return models.map((model) => model.toEntity()).toList();
  }
}
