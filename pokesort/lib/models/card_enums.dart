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
  colorless,
}

String cardTypeToString(CardType type) {
  return type.name[0].toUpperCase() + type.name.substring(1);
}

enum CardStage { basic, stage1, stage2 }

String stageToString(CardStage stage) {
  switch (stage) {
    case CardStage.basic:
      return 'Basic';
    case CardStage.stage1:
      return 'Stage 1';
    case CardStage.stage2:
      return 'Stage 2';
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
  promo,
}

String rarityToString(CardRarity rarity) {
  switch (rarity) {
    case CardRarity.common:
      return 'Common';
    case CardRarity.uncommon:
      return 'Uncommon';
    case CardRarity.rare:
      return 'Rare';
    case CardRarity.holoRare:
      return 'Holo Rare';
    case CardRarity.doubleRare:
      return 'Double Rare';
    case CardRarity.ultraRare:
      return 'Ultra Rare';
    case CardRarity.illustrationRare:
      return 'Illustration Rare';
    case CardRarity.specialIllustrationRare:
      return 'Special Illustration Rare';
    case CardRarity.hyperRare:
      return 'Hyper Rare';
    case CardRarity.promo:
      return 'Promo';
  }
}

enum CardVariant {
  amazingRare,
  breakCard,
  dark,
  defaultVariant,
  deltaSpecies,
  ex,
  gx,
  legend,
  lvX,
  light,
  megaEx,
  prime,
  radiant,
  shining,
  tagTeamGx,
  trainerPokemon,
  v,
  vmax,
  vstar,
  notInList,
}

String variantToString(CardVariant variant) {
  switch (variant) {
    case CardVariant.amazingRare:
      return 'Amazing Rare';
    case CardVariant.breakCard:
      return 'BREAK';
    case CardVariant.dark:
      return 'Dark';
    case CardVariant.defaultVariant:
      return 'None';
    case CardVariant.deltaSpecies:
      return 'Delta Species';
    case CardVariant.ex:
      return 'EX';
    case CardVariant.gx:
      return 'GX';
    case CardVariant.legend:
      return 'LEGEND';
    case CardVariant.lvX:
      return 'LV.X';
    case CardVariant.light:
      return 'Light';
    case CardVariant.megaEx:
      return 'Mega (M EX)';
    case CardVariant.prime:
      return 'Prime';
    case CardVariant.radiant:
      return 'Radiant';
    case CardVariant.shining:
      return 'Shining';
    case CardVariant.tagTeamGx:
      return 'Tag Team GX';
    case CardVariant.trainerPokemon:
      return 'Trainer Pokémon';
    case CardVariant.v:
      return 'V';
    case CardVariant.vmax:
      return 'VMAX';
    case CardVariant.vstar:
      return 'VSTAR';
    case CardVariant.notInList:
      return 'Unknown Variant';
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
  chinese,
}

String languageToString(CardLanguage language) {
  switch (language) {
    case CardLanguage.english:
      return 'English';
    case CardLanguage.japanese:
      return 'Japanese';
    case CardLanguage.german:
      return 'German';
    case CardLanguage.french:
      return 'French';
    case CardLanguage.spanish:
      return 'Spanish';
    case CardLanguage.italian:
      return 'Italian';
    case CardLanguage.korean:
      return 'Korean';
    case CardLanguage.chinese:
      return 'Chinese';
  }
}
