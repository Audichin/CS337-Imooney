import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BinderDatabase {

  static final BinderDatabase instance = BinderDatabase._init();

  static Database? _database;

  BinderDatabase._init();

  Future<Database> get database async {

    if (_database != null) return _database!;

    _database = await _initDB('binder.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {

    await db.execute('''
CREATE TABLE binders(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  coverImage TEXT
)
''');

    await db.execute('''
CREATE TABLE cards(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  binderId INTEGER,
  name TEXT,
  imagePath TEXT
)
''');
  }
}