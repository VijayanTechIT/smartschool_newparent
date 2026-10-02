import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'siblings.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE siblings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId TEXT NOT NULL,
            name TEXT NOT NULL,
            relationship TEXT NOT NULL,
            dob TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> addSibling(String name,String studentId, String relationship,String dob) async {
    final db = await database;
    return await db.insert('siblings', {
      'studentId': studentId,
      'relationship': relationship,
      'name':name,
      'dob':dob
    });
  }

  Future<List<Map<String, dynamic>>> getSiblings() async {
    final db = await database;
    return await db.query('siblings');
  }

  Future<int> deleteSibling(int id) async {
    final db = await database;
    return await db.delete('siblings', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllSiblings() async {
    final db = await database;
    return await db.delete('siblings');
  }


  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
