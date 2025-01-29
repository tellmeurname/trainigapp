import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      // Получаем путь к файлу базы данных
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'auth_database.db');

      // Открываем или создаем базу данных
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE,
              password TEXT
            )
          ''');
          print("База данных создана успешно");
        },
      );
    } catch (e) {
      print("Ошибка инициализации базы данных: $e");
      rethrow;
    }
  }

  Future<void> registerUser(String email, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
