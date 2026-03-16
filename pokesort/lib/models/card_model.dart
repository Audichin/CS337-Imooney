import 'card_enums.dart';

class CardModel {

  final int? id;
  final int binderId;

  final String name;
  final String imagePath;
  final String language;

  final CardType type;
  final CardStage stage;
  final CardRarity rarity;
  final CardVariant variant;
  final CardLanguage cardLanguage;

  final bool legendary;
  final bool forSale;

  final double? price;

  CardModel({
    this.id,

    required this.binderId,
    required this.name,
    required this.imagePath,
    required this.language,
    required this.type,
    required this.stage,
    required this.rarity,
    required this.variant,
    required this.legendary,
    required this.forSale,
    required this.cardLanguage,

    this.price,
  });

}