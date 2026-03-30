import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../pages/binder_page.dart';
import '../pages/card_detail_page.dart';

import '../utils/page_mapping.dart';

String _cardVariantLabel(CardModel card) {
  switch (card.category) {
    case CardCategory.pokemon:
      if (card.pokemonVariant == PokemonVariant.notInList &&
          card.customPokemonVariant != null &&
          card.customPokemonVariant!.isNotEmpty) {
        return card.customPokemonVariant!;
      }
      return card.pokemonVariant == null
          ? ''
          : pokemonVariantToString(card.pokemonVariant!);

    case CardCategory.trainer:
      return card.trainerVariant == null
          ? ''
          : trainerVariantToString(card.trainerVariant!);

    case CardCategory.itemOrStadium:
      if (card.itemStadiumKind == ItemStadiumKind.item &&
          card.itemStadiumVariant != null) {
        return itemStadiumVariantToString(card.itemStadiumVariant!);
      }
      return card.itemStadiumKind == null
          ? ''
          : itemStadiumKindToString(card.itemStadiumKind!);

    case CardCategory.energy:
      return card.type == null ? '' : cardTypeToString(card.type!);
  }
}

class CollectionSearchDelegate extends SearchDelegate<void> {
  final List<Binder> binders;
  final List<CardModel> cards;

  CollectionSearchDelegate({required this.binders, required this.cards});

  Map<int, Binder> get _binderById {
    return {
      for (final binder in binders)
        if (binder.id != null) binder.id!: binder,
    };
  }

  List<Binder> _filteredBinders() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return binders;

    return binders.where((binder) {
      return binder.name.toLowerCase().contains(q) ||
          binder.virtualPageCount.toString().contains(q);
    }).toList();
  }

  List<CardModel> _filteredCards() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return cards;

    return cards.where((card) {
      final binderName = _binderById[card.binderId]?.name.toLowerCase() ?? '';
      final variantText = _cardVariantLabel(card).toLowerCase();
      final typeText = card.type == null
          ? ''
          : cardTypeToString(card.type!).toLowerCase();
      final stageText = card.stage == null
          ? ''
          : stageToString(card.stage!).toLowerCase();
      final kindText = card.itemStadiumKind == null
          ? ''
          : itemStadiumKindToString(card.itemStadiumKind!).toLowerCase();

      return card.name.toLowerCase().contains(q) ||
          binderName.contains(q) ||
          cardCategoryToString(card.category).toLowerCase().contains(q) ||
          languageToString(card.cardLanguage).toLowerCase().contains(q) ||
          rarityToString(card.rarity).toLowerCase().contains(q) ||
          typeText.contains(q) ||
          stageText.contains(q) ||
          variantText.contains(q) ||
          kindText.contains(q) ||
          ((card.legendary ?? false) ? 'legendary' : '').contains(q) ||
          (card.forSale ? 'for sale' : 'not for sale').contains(q) ||
          card.pageNumber.toString() == q ||
          card.row.toString() == q ||
          card.column.toString() == q;
    }).toList();
  }

  @override
  String get searchFieldLabel => 'Search binders and cards';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final binderResults = _filteredBinders();
    final cardResults = _filteredCards();

    if (binderResults.isEmpty && cardResults.isEmpty) {
      return const Center(child: Text('No binders or cards found.'));
    }

    return ListView(
      children: [
        if (binderResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Binders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...binderResults.map((binder) {
            return ListTile(
              leading: binder.coverImage == null
                  ? const CircleAvatar(child: Icon(Icons.book))
                  : CircleAvatar(
                      backgroundImage: FileImage(File(binder.coverImage!)),
                    ),
              title: Text(binder.name),
              subtitle: Text('${binder.virtualPageCount} page(s)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BinderPage(binder: binder)),
                );
              },
            );
          }),
        ],
        if (cardResults.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Cards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...cardResults.map((card) {
            final binder = _binderById[card.binderId];
            final binderName = binder?.name ?? 'Unknown Binder';
            final binderPageCount = binder?.virtualPageCount ?? 1;
            final variantLabel = _cardVariantLabel(card);

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(card.imagePath),
                  width: 48,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 48,
                    height: 64,
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              title: Text(card.name),
              subtitle: Text(
                variantLabel.isEmpty
                    ? '$binderName • ${irlPageLabelFromVirtualPage(card.pageNumber)} • ${rarityToString(card.rarity)}'
                    : '$binderName • Pg ${irlPageLabelFromVirtualPage(card.pageNumber)} • ${rarityToString(card.rarity)} • $variantLabel',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailPage(
                      card: card,
                      binderPageCount: binderPageCount,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

class CardSearchDelegate extends SearchDelegate<void> {
  final Binder binder;
  final List<CardModel> cards;

  CardSearchDelegate({required this.binder, required this.cards});

  List<CardModel> _filteredCards() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return cards;

    return cards.where((card) {
      final variantText = _cardVariantLabel(card).toLowerCase();
      final typeText = card.type == null
          ? ''
          : cardTypeToString(card.type!).toLowerCase();
      final stageText = card.stage == null
          ? ''
          : stageToString(card.stage!).toLowerCase();
      final kindText = card.itemStadiumKind == null
          ? ''
          : itemStadiumKindToString(card.itemStadiumKind!).toLowerCase();

      return card.name.toLowerCase().contains(q) ||
          cardCategoryToString(card.category).toLowerCase().contains(q) ||
          languageToString(card.cardLanguage).toLowerCase().contains(q) ||
          rarityToString(card.rarity).toLowerCase().contains(q) ||
          typeText.contains(q) ||
          stageText.contains(q) ||
          variantText.contains(q) ||
          kindText.contains(q) ||
          ((card.legendary ?? false) ? 'legendary' : '').contains(q) ||
          (card.forSale ? 'for sale' : 'not for sale').contains(q) ||
          card.pageNumber.toString() == q ||
          card.row.toString() == q ||
          card.column.toString() == q;
    }).toList();
  }

  @override
  String get searchFieldLabel => 'Search cards in ${binder.name}';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filteredCards();

    if (results.isEmpty) {
      return const Center(child: Text('No cards found.'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final card = results[index];
        final variantLabel = _cardVariantLabel(card);

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              File(card.imagePath),
              width: 48,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 48,
                height: 64,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
          title: Text(card.name),
          subtitle: Text(
            variantLabel.isEmpty
                ? 'Pg ${irlPageLabelFromVirtualPage(card.pageNumber)} • ${rarityToString(card.rarity)}'
                : 'Pg ${irlPageLabelFromVirtualPage(card.pageNumber)} • ${rarityToString(card.rarity)} • $variantLabel',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardDetailPage(
                  card: card,
                  binderPageCount: binder.virtualPageCount,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
