import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/password_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Initialize sqflite for desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('passwords.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add notes column for databases created with version 1
      await db.execute('ALTER TABLE passwords ADD COLUMN notes TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
      CREATE TABLE passwords (
        id $idType,
        title $textType,
        username $textType,
        password $textType,
        url $textTypeNullable,
        category $textTypeNullable,
        notes $textTypeNullable,
        created_at $textType,
        updated_at $textType
      )
    ''');
  }

  // Create - Insert password
  Future<PasswordModel> insertPassword(PasswordModel password) async {
    final db = await database;
    await db.insert(
      'passwords',
      password.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return password;
  }

  // Read - Get all passwords
  Future<List<PasswordModel>> getAllPasswords() async {
    final db = await database;
    const orderBy = 'created_at DESC';

    final result = await db.query('passwords', orderBy: orderBy);

    return result.map((json) => PasswordModel.fromJson(json)).toList();
  }

  // Read - Get password by ID
  Future<PasswordModel?> getPasswordById(String id) async {
    final db = await database;

    final maps = await db.query('passwords', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return PasswordModel.fromJson(maps.first);
    }
    return null;
  }

  // Read - Get passwords by category
  Future<List<PasswordModel>> getPasswordsByCategory(String category) async {
    final db = await database;

    final result = await db.query(
      'passwords',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => PasswordModel.fromJson(json)).toList();
  }

  // Read - Search passwords
  Future<List<PasswordModel>> searchPasswords(String query) async {
    final db = await database;

    final result = await db.query(
      'passwords',
      where: 'title LIKE ? OR username LIKE ? OR url LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return result.map((json) => PasswordModel.fromJson(json)).toList();
  }

  // Update - Update password
  Future<int> updatePassword(PasswordModel password) async {
    final db = await database;

    return db.update(
      'passwords',
      password.toJson(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  // Delete - Delete password
  Future<int> deletePassword(String id) async {
    final db = await database;

    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  // Delete - Delete all passwords
  Future<int> deleteAllPasswords() async {
    final db = await database;
    return await db.delete('passwords');
  }

  // Utility - Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
