import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/binder.dart';
import '../models/card_model.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE binders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        coverImage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        binderId INTEGER NOT NULL,
        name TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        cardLanguage INTEGER NOT NULL,
        type INTEGER NOT NULL,
        stage INTEGER NOT NULL,
        rarity INTEGER NOT NULL,
        variant INTEGER NOT NULL,
        legendary INTEGER NOT NULL,
        forSale INTEGER NOT NULL,
        price REAL,
        FOREIGN KEY (binderId) REFERENCES binders(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS cards');
      await db.execute('DROP TABLE IF EXISTS binders');
      await _createDB(db, newVersion);
    }
  }

  Future<int> insertBinder(Binder binder) async {
    final db = await database;
    return db.insert('binders', binder.toMap());
  }

  Future<List<Binder>> getBinders() async {
    final db = await database;
    final maps = await db.query('binders', orderBy: 'name ASC');
    return maps.map((map) => Binder.fromMap(map)).toList();
  }

  Future<int> insertCard(CardModel card) async {
    final db = await database;
    return db.insert('cards', card.toMap());
  }

  Future<List<CardModel>> getCardsByBinder(int binderId) async {
    final db = await database;
    final maps = await db.query(
      'cards',
      where: 'binderId = ?',
      whereArgs: [binderId],
      orderBy: 'id ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }
}