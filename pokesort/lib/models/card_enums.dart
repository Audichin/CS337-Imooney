enum CardCategory { pokemon, trainer, itemOrStadium, energy }

String cardCategoryToString(CardCategory category) {
  switch (category) {
    case CardCategory.pokemon:
      return 'Pokémon';
    case CardCategory.trainer:
      return 'Trainer';
    case CardCategory.itemOrStadium:
      return 'Item/Stadium';
    case CardCategory.energy:
      return 'Energy';
  }
}

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

enum PokemonVariant {
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

String pokemonVariantToString(PokemonVariant variant) {
  switch (variant) {
    case PokemonVariant.amazingRare:
      return 'Amazing Rare';
    case PokemonVariant.breakCard:
      return 'BREAK';
    case PokemonVariant.dark:
      return 'Dark';
    case PokemonVariant.defaultVariant:
      return 'Default';
    case PokemonVariant.deltaSpecies:
      return 'Delta Species';
    case PokemonVariant.ex:
      return 'EX';
    case PokemonVariant.gx:
      return 'GX';
    case PokemonVariant.legend:
      return 'LEGEND';
    case PokemonVariant.lvX:
      return 'LV.X';
    case PokemonVariant.light:
      return 'Light';
    case PokemonVariant.megaEx:
      return 'Mega (M EX)';
    case PokemonVariant.prime:
      return 'Prime';
    case PokemonVariant.radiant:
      return 'Radiant';
    case PokemonVariant.shining:
      return 'Shining';
    case PokemonVariant.tagTeamGx:
      return 'Tag Team GX';
    case PokemonVariant.trainerPokemon:
      return 'Trainer Pokémon';
    case PokemonVariant.v:
      return 'V';
    case PokemonVariant.vmax:
      return 'VMAX';
    case PokemonVariant.vstar:
      return 'VSTAR';
    case PokemonVariant.notInList:
      return 'Not in list';
  }
}

enum TrainerVariant { normal, tagTeam }

String trainerVariantToString(TrainerVariant variant) {
  switch (variant) {
    case TrainerVariant.normal:
      return 'Normal';
    case TrainerVariant.tagTeam:
      return 'Tag Team';
  }
}

enum ItemStadiumKind { item, stadium }

String itemStadiumKindToString(ItemStadiumKind kind) {
  switch (kind) {
    case ItemStadiumKind.item:
      return 'Item';
    case ItemStadiumKind.stadium:
      return 'Stadium';
  }
}

enum ItemStadiumVariant { normal, aceSpec }

String itemStadiumVariantToString(ItemStadiumVariant variant) {
  switch (variant) {
    case ItemStadiumVariant.normal:
      return 'Normal';
    case ItemStadiumVariant.aceSpec:
      return 'Ace Spec';
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
