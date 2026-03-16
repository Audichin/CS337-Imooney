// lib/models/card_enums.dart

enum CardType {
  grass,
  fire,
  water,
  lightning,
  psychic,
  fighting,
  darkness,
  metal,
  fairy,
  dragon,
  colorless
}

String cardTypeToString(CardType type) {
  return type.name[0].toUpperCase() + type.name.substring(1);
}



enum CardStage {
  basic,
  stage1,
  stage2,
  ex,
  gx,
  v,
  vmax,
  vstar
}

String stageToString(CardStage stage) {
  switch (stage) {
    case CardStage.basic:
      return "Basic";
    case CardStage.stage1:
      return "Stage 1";
    case CardStage.stage2:
      return "Stage 2";
    case CardStage.ex:
      return "EX";
    case CardStage.gx:
      return "GX";
    case CardStage.v:
      return "V";
    case CardStage.vmax:
      return "VMAX";
    case CardStage.vstar:
      return "VSTAR";
  }
}



enum CardRarity {
  common,
  uncommon,
  rare,
  holoRare,
  doubleRare,
  ultraRare,
  illustrationRare,
  specialIllustrationRare,
  hyperRare,
  promo
}

String rarityToString(CardRarity rarity) {
  switch (rarity) {
    case CardRarity.common:
      return "Common";
    case CardRarity.uncommon:
      return "Uncommon";
    case CardRarity.rare:
      return "Rare";
    case CardRarity.holoRare:
      return "Holo Rare";
    case CardRarity.doubleRare:
      return "Double Rare";
    case CardRarity.ultraRare:
      return "Ultra Rare";
    case CardRarity.illustrationRare:
      return "Illustration Rare";
    case CardRarity.specialIllustrationRare:
      return "Special Illustration Rare";
    case CardRarity.hyperRare:
      return "Hyper Rare";
    case CardRarity.promo:
      return "Promo";
  }
}

enum CardVariant {
  normal,
  fullArt,
  alternateArt,
  gold,
  rainbow,
  shining,
  radiant,
  trainerGallery,
  illustrationRare,
  specialIllustrationRare
}

String variantToString(CardVariant variant) {
  switch (variant) {
    case CardVariant.normal:
      return "Normal";
    case CardVariant.fullArt:
      return "Full Art";
    case CardVariant.alternateArt:
      return "Alternate Art";
    case CardVariant.gold:
      return "Gold";
    case CardVariant.rainbow:
      return "Rainbow";
    case CardVariant.shining:
      return "Shining";
    case CardVariant.radiant:
      return "Radiant";
    case CardVariant.trainerGallery:
      return "Trainer Gallery";
    case CardVariant.illustrationRare:
      return "Illustration Rare";
    case CardVariant.specialIllustrationRare:
      return "Special Illustration Rare";
  }
}

enum CardLanguage {
  english,
  japanese,
  german,
  french,
  spanish,
  italian,
  korean,
  chinese
}

String languageToString(CardLanguage language) {
  switch (language) {
    case CardLanguage.english:
      return "English";
    case CardLanguage.japanese:
      return "Japanese";
    case CardLanguage.german:
      return "German";
    case CardLanguage.french:
      return "French";
    case CardLanguage.spanish:
      return "Spanish";
    case CardLanguage.italian:
      return "Italian";
    case CardLanguage.korean:
      return "Korean";
    case CardLanguage.chinese:
      return "Chinese";
  }
}