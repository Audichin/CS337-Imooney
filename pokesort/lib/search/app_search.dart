import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../pages/binder_page.dart';
import '../pages/card_detail_page.dart';

import '../utils/page_mapping.dart';

String _normalizeSearchText(String value) {
  const replacements = {
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
  };

  var normalized = value.toLowerCase();
  replacements.forEach((key, replacement) {
    normalized = normalized.replaceAll(key, replacement);
  });
  return normalized;
}

class _SearchFilters {
  final String textQuery;
  final int? virtualPage;
  final int? sheetNumber;
  final BinderSide? side;
  final double? minPrice;
  final double? maxPrice;
  final bool hasIncompleteFilter;

  const _SearchFilters({
    required this.textQuery,
    this.virtualPage,
    this.sheetNumber,
    this.side,
    this.minPrice,
    this.maxPrice,
    this.hasIncompleteFilter = false,
  });
}

double? _parsePriceValue(String value) {
  final normalized = value.startsWith('.') ? '0$value' : value;
  final parsed = double.tryParse(normalized);
  if (parsed == null) return null;
  return double.parse(parsed.toStringAsFixed(2));
}

double? _roundCardPrice(double? value) {
  if (value == null) return null;
  return double.parse(value.toStringAsFixed(2));
}

_SearchFilters _parseSearchFilters(String query) {
  var remaining = _normalizeSearchText(query.trim());

  int? virtualPage;
  int? sheetNumber;
  BinderSide? side;
  double? minPrice;
  double? maxPrice;
  var hasIncompleteFilter = false;
  const pricePattern = r'(?:\d+(?:\.\d+)?|\.\d+)';

  final virtualPageMatch = RegExp(
    r'\bpage\s*:\s*(\d+)\b',
  ).firstMatch(remaining);
  if (virtualPageMatch != null) {
    virtualPage = int.tryParse(virtualPageMatch.group(1)!);
    remaining = remaining.replaceFirst(virtualPageMatch.group(0)!, ' ');
  }

  final sheetMatch = RegExp(r'\bsheet\s*:\s*(\d+)\b').firstMatch(remaining);
  if (sheetMatch != null) {
    sheetNumber = int.tryParse(sheetMatch.group(1)!);
    remaining = remaining.replaceFirst(sheetMatch.group(0)!, ' ');
  }

  final sideMatch = RegExp(r'\b(front|back)\b').firstMatch(remaining);
  if (sideMatch != null) {
    side = sideMatch.group(1) == 'front' ? BinderSide.front : BinderSide.back;
    remaining = remaining.replaceFirst(sideMatch.group(0)!, ' ');
  }

  final rangeMatch = RegExp(
    '\\bprice\\s*:\\s*($pricePattern)\\s*-\\s*($pricePattern)\\b',
  ).firstMatch(remaining);
  if (rangeMatch != null) {
    minPrice = _parsePriceValue(rangeMatch.group(1)!);
    maxPrice = _parsePriceValue(rangeMatch.group(2)!);
    remaining = remaining.replaceFirst(rangeMatch.group(0)!, ' ');
  }

  final plusMatch = RegExp(
    '\\bprice\\s*:\\s*($pricePattern)\\+\\b',
  ).firstMatch(remaining);
  if (plusMatch != null) {
    minPrice = _parsePriceValue(plusMatch.group(1)!);
    remaining = remaining.replaceFirst(plusMatch.group(0)!, ' ');
  }

  final comparisonMatch = RegExp(
    '\\bprice\\s*:?\\s*(<=|>=|<|>)\\s*($pricePattern)\\b',
  ).firstMatch(remaining);
  if (comparisonMatch != null) {
    final value = _parsePriceValue(comparisonMatch.group(2)!);
    final operator = comparisonMatch.group(1);
    if (operator == '<' || operator == '<=') {
      maxPrice = value;
    } else if (operator == '>' || operator == '>=') {
      minPrice = value;
    }
    remaining = remaining.replaceFirst(comparisonMatch.group(0)!, ' ');
  }

  final incompletePriceMatch = RegExp(
    r'\bprice\s*:?\s*(?:(?:<=|>=|<|>)\s*)?(?:(?:\d+(?:\.\d*)?|\.\d*)?(?:\s*-\s*(?:\d+(?:\.\d*)?|\.\d*)?)?\+?)?\s*$',
  ).firstMatch(remaining);
  if (incompletePriceMatch != null) {
    final matchedText = incompletePriceMatch.group(0) ?? '';
    if (matchedText.trim().isNotEmpty) {
      remaining = remaining.replaceFirst(matchedText, ' ');
      hasIncompleteFilter = true;
    }
  }

  remaining = remaining.replaceAll(RegExp(r'\s+'), ' ').trim();

  return _SearchFilters(
    textQuery: remaining,
    virtualPage: virtualPage,
    sheetNumber: sheetNumber,
    side: side,
    minPrice: minPrice,
    maxPrice: maxPrice,
    hasIncompleteFilter: hasIncompleteFilter,
  );
}

bool _matchesTextQuery(String textQuery, List<String> fields) {
  if (textQuery.isEmpty) return true;
  return fields.any((field) => _normalizeSearchText(field).contains(textQuery));
}

bool _matchesCardFilters(CardModel card, _SearchFilters filters) {
  if (filters.virtualPage != null && card.pageNumber != filters.virtualPage) {
    return false;
  }

  if (filters.sheetNumber != null &&
      sheetFromVirtualPage(card.pageNumber) != filters.sheetNumber) {
    return false;
  }

  if (filters.side != null &&
      sideFromVirtualPage(card.pageNumber) != filters.side) {
    return false;
  }

  final price = _roundCardPrice(card.price);
  if (filters.minPrice != null &&
      (price == null || price < filters.minPrice!)) {
    return false;
  }
  if (filters.maxPrice != null &&
      (price == null || price > filters.maxPrice!)) {
    return false;
  }

  return true;
}

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

Color _searchBackIconColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;
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
    final filters = _parseSearchFilters(query);
    if (filters.textQuery.isEmpty) return binders;

    return binders.where((binder) {
      return _matchesTextQuery(filters.textQuery, [
        binder.name,
        binder.virtualPageCount.toString(),
        binder.sheetCount.toString(),
      ]);
    }).toList();
  }

  List<CardModel> _filteredCards() {
    final filters = _parseSearchFilters(query);
    if (filters.textQuery.isEmpty &&
        filters.virtualPage == null &&
        filters.sheetNumber == null &&
        filters.side == null &&
        filters.minPrice == null &&
        filters.maxPrice == null) {
      return cards;
    }

    return cards.where((card) {
      final binderName = _binderById[card.binderId]?.name ?? '';
      final variantText = _cardVariantLabel(card);
      final typeText = card.type == null ? '' : cardTypeToString(card.type!);
      final stageText = card.stage == null ? '' : stageToString(card.stage!);
      final kindText = card.itemStadiumKind == null
          ? ''
          : itemStadiumKindToString(card.itemStadiumKind!);

      return _matchesCardFilters(card, filters) &&
          _matchesTextQuery(filters.textQuery, [
            card.name,
            binderName,
            cardCategoryToString(card.category),
            languageToString(card.cardLanguage),
            rarityToString(card.rarity),
            typeText,
            stageText,
            variantText,
            kindText,
            (card.legendary ?? false) ? 'legendary' : '',
            card.forSale ? 'for sale' : 'not for sale',
            card.pageNumber.toString(),
            sheetFromVirtualPage(card.pageNumber).toString(),
            binderSideToString(sideFromVirtualPage(card.pageNumber)),
            card.row.toString(),
            card.column.toString(),
          ]);
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
      icon: Icon(Icons.arrow_back, color: _searchBackIconColor(context)),
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
            final binderSheetCount = binder?.sheetCount ?? 1;
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
                      binderSheetCount: binderSheetCount,
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
    final filters = _parseSearchFilters(query);
    if (filters.textQuery.isEmpty &&
        filters.virtualPage == null &&
        filters.sheetNumber == null &&
        filters.side == null &&
        filters.minPrice == null &&
        filters.maxPrice == null) {
      return cards;
    }

    return cards.where((card) {
      final variantText = _cardVariantLabel(card);
      final typeText = card.type == null ? '' : cardTypeToString(card.type!);
      final stageText = card.stage == null ? '' : stageToString(card.stage!);
      final kindText = card.itemStadiumKind == null
          ? ''
          : itemStadiumKindToString(card.itemStadiumKind!);

      return _matchesCardFilters(card, filters) &&
          _matchesTextQuery(filters.textQuery, [
            card.name,
            cardCategoryToString(card.category),
            languageToString(card.cardLanguage),
            rarityToString(card.rarity),
            typeText,
            stageText,
            variantText,
            kindText,
            (card.legendary ?? false) ? 'legendary' : '',
            card.forSale ? 'for sale' : 'not for sale',
            card.pageNumber.toString(),
            sheetFromVirtualPage(card.pageNumber).toString(),
            binderSideToString(sideFromVirtualPage(card.pageNumber)),
            card.row.toString(),
            card.column.toString(),
          ]);
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
      icon: Icon(Icons.arrow_back, color: _searchBackIconColor(context)),
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
                  binderSheetCount: binder.sheetCount,
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
