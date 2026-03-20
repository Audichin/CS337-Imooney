import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/binder.dart';
import '../models/card_model.dart';

class BinderDatabase {
  static final BinderDatabase instance = BinderDatabase._init();
  static Database? _database;

  BinderDatabase._init();

  Future<List<CardModel>> getAllCards() async {
    final db = await database;
    final maps = await db.query('cards', orderBy: 'name COLLATE NOCASE ASC');

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE binders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        coverImage TEXT,
        pageCount INTEGER NOT NULL
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
        pageNumber INTEGER NOT NULL,
        row INTEGER NOT NULL,
        column INTEGER NOT NULL,
        FOREIGN KEY (binderId) REFERENCES binders(id) ON DELETE CASCADE,
        UNIQUE(binderId, pageNumber, row, column)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
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
    return db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<CardModel>> getCardsByBinder(int binderId) async {
    final db = await database;
    final maps = await db.query(
      'cards',
      where: 'binderId = ?',
      whereArgs: [binderId],
      orderBy: 'pageNumber ASC, row ASC, column ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  Future<bool> cardSlotExists({
    required int binderId,
    required int pageNumber,
    required int row,
    required int column,
  }) async {
    final db = await database;
    final maps = await db.query(
      'cards',
      where: 'binderId = ? AND pageNumber = ? AND row = ? AND column = ?',
      whereArgs: [binderId, pageNumber, row, column],
      limit: 1,
    );

    return maps.isNotEmpty;
  }
}
