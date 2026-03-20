import 'card_enums.dart';

class CardModel {
  final int? id;
  final int binderId;
  final String name;
  final String imagePath;

  final CardLanguage cardLanguage;
  final CardType type;
  final CardStage stage;
  final CardRarity rarity;
  final CardVariant variant;

  final bool legendary;
  final bool forSale;
  final double? price;

  final int pageNumber; // 1-based
  final int row; // 1-3
  final int column; // 1-3

  CardModel({
    this.id,
    required this.binderId,
    required this.name,
    required this.imagePath,
    required this.cardLanguage,
    required this.type,
    required this.stage,
    required this.rarity,
    required this.variant,
    required this.legendary,
    required this.forSale,
    this.price,
    required this.pageNumber,
    required this.row,
    required this.column,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'binderId': binderId,
      'name': name,
      'imagePath': imagePath,
      'cardLanguage': cardLanguage.index,
      'type': type.index,
      'stage': stage.index,
      'rarity': rarity.index,
      'variant': variant.index,
      'legendary': legendary ? 1 : 0,
      'forSale': forSale ? 1 : 0,
      'price': price,
      'pageNumber': pageNumber,
      'row': row,
      'column': column,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as int?,
      binderId: map['binderId'] as int,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
      cardLanguage: CardLanguage.values[map['cardLanguage'] as int],
      type: CardType.values[map['type'] as int],
      stage: CardStage.values[map['stage'] as int],
      rarity: CardRarity.values[map['rarity'] as int],
      variant: CardVariant.values[map['variant'] as int],
      legendary: (map['legendary'] as int) == 1,
      forSale: (map['forSale'] as int) == 1,
      price: map['price'] == null ? null : (map['price'] as num).toDouble(),
      pageNumber: map['pageNumber'] as int,
      row: map['row'] as int,
      column: map['column'] as int,
    );
  }
}
