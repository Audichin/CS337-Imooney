import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../pages/binder_page.dart';
import '../pages/card_detail_page.dart';

class BinderSearchDelegate extends SearchDelegate<void> {
  final List<Binder> binders;

  BinderSearchDelegate({required this.binders});

  List<Binder> _filteredBinders() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return binders;

    return binders.where((binder) {
      return binder.name.toLowerCase().contains(q) ||
          binder.pageCount.toString().contains(q);
    }).toList();
  }

  @override
  String get searchFieldLabel => 'Search binders';

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
    final results = _filteredBinders();

    if (results.isEmpty) {
      return const Center(child: Text('No binders found.'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final binder = results[index];

        return ListTile(
          leading: binder.coverImage == null
              ? const CircleAvatar(child: Icon(Icons.book))
              : CircleAvatar(
                  backgroundImage: FileImage(File(binder.coverImage!)),
                ),
          title: Text(binder.name),
          subtitle: Text('${binder.pageCount} page(s)'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BinderPage(binder: binder)),
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

class CardSearchDelegate extends SearchDelegate<void> {
  final Binder binder;
  final List<CardModel> cards;

  CardSearchDelegate({required this.binder, required this.cards});

  List<CardModel> _filteredCards() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return cards;

    return cards.where((card) {
      return card.name.toLowerCase().contains(q) ||
          languageToString(card.cardLanguage).toLowerCase().contains(q) ||
          cardTypeToString(card.type).toLowerCase().contains(q) ||
          stageToString(card.stage).toLowerCase().contains(q) ||
          rarityToString(card.rarity).toLowerCase().contains(q) ||
          variantToString(card.variant).toLowerCase().contains(q) ||
          (card.legendary ? 'legendary' : '').contains(q) ||
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
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final card = results[index];

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              File(card.imagePath),
              width: 48,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 48,
                height: 64,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
          title: Text(card.name),
          subtitle: Text(
            'Pg ${card.pageNumber} • ${rarityToString(card.rarity)} • ${variantToString(card.variant)}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CardDetailPage(card: card)),
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
