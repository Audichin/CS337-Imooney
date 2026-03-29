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
      version: 5,
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
        category INTEGER NOT NULL,
        cardLanguage INTEGER NOT NULL,
        rarity INTEGER NOT NULL,
        type INTEGER,
        stage INTEGER,
        pokemonVariant INTEGER,
        customPokemonVariant TEXT,
        trainerVariant INTEGER,
        itemStadiumKind INTEGER,
        itemStadiumVariant INTEGER,
        legendary INTEGER,
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
    if (oldVersion < 5) {
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

  Future<int> deleteBinder(int binderId) async {
    final db = await database;

    await db.delete(
      'cards',
      where: 'binderId = ?',
      whereArgs: [binderId],
    );

    return db.delete(
      'binders',
      where: 'id = ?',
      whereArgs: [binderId],
    );
  }

  Future<int> insertCard(CardModel card) async {
    final db = await database;
    return db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> updateCard(CardModel card) async {
    final db = await database;
    if (card.id == null) {
      throw ArgumentError('Cannot update a card with no id.');
    }

    return db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> deleteCard(int cardId) async {
    final db = await database;
    return db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [cardId],
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

  Future<List<CardModel>> getAllCards() async {
    final db = await database;
    final maps = await db.query(
      'cards',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return maps.map((map) => CardModel.fromMap(map)).toList();
  }

  Future<bool> cardSlotExists({
    required int binderId,
    required int pageNumber,
    required int row,
    required int column,
    int? excludeCardId,
  }) async {
    final db = await database;

    String where =
        'binderId = ? AND pageNumber = ? AND row = ? AND column = ?';
    final whereArgs = <Object?>[binderId, pageNumber, row, column];

    if (excludeCardId != null) {
      where += ' AND id != ?';
      whereArgs.add(excludeCardId);
    }

    final maps = await db.query(
      'cards',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }
}