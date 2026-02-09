import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/password_entity.dart';
import '../../data/repositories/password_repository_impl.dart';

class PasswordViewModel extends ChangeNotifier {
  final PasswordRepositoryImpl _repository;

  List<PasswordEntity> _passwords = [];
  List<PasswordEntity> _filteredPasswords = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<PasswordEntity> get passwords => _filteredPasswords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  PasswordViewModel(this._repository);

  // Load all passwords
  Future<void> loadPasswords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _passwords = await _repository.getAllPasswords();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load passwords: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new password
  Future<bool> addPassword({
    required String title,
    required String username,
    required String password,
    String? url,
    String? category,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      const uuid = Uuid();
      final now = DateTime.now();
      final passwordEntity = PasswordEntity(
        id: uuid.v4(),
        title: title,
        username: username,
        password: password,
        url: url,
        category: category,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addPassword(passwordEntity);
      await loadPasswords(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add password: ${e.toString()}';
      debugPrint(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword({
    required String id,
    required String title,
    required String username,
    required String password,
    String? url,
    String? category,
    String? notes,
    required DateTime createdAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final passwordEntity = PasswordEntity(
        id: id,
        title: title,
        username: username,
        password: password,
        url: url,
        category: category,
        notes: notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.updatePassword(passwordEntity);
      await loadPasswords(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update password: ${e.toString()}';
      debugPrint(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete password
  Future<bool> deletePassword(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deletePassword(id);
      await loadPasswords(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete password: ${e.toString()}';
      debugPrint(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search passwords
  void searchPasswords(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters (search + category)
  void _applyFilters() {
    _filteredPasswords = _passwords;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredPasswords = _filteredPasswords.where((password) {
        final titleMatch = password.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final usernameMatch = password.username.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final urlMatch =
            password.url?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
            false;
        return titleMatch || usernameMatch || urlMatch;
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      _filteredPasswords = _filteredPasswords.where((password) {
        // Map category names
        final categoryMap = {
          'Social': 'Social Media',
          'Work': 'Work',
          'Finance': 'Banking',
        };
        final targetCategory = categoryMap[_selectedCategory] ?? _selectedCategory;
        return password.category == targetCategory;
      }).toList();
    }
  }

  // Get password by ID
  Future<PasswordEntity?> getPasswordById(String id) async {
    try {
      return await _repository.getPasswordById(id);
    } catch (e) {
      _errorMessage = 'Failed to get password: ${e.toString()}';
      debugPrint(_errorMessage);
      return null;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
