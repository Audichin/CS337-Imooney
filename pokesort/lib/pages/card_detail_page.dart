import 'dart:io';

import 'package:flutter/material.dart';

import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../services/binder_database.dart';

class CardDetailPage extends StatelessWidget {
  final CardModel card;

  const CardDetailPage({super.key, required this.card});

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _variantLabel() {
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
        return '';

      case CardCategory.energy:
        return '';
    }
  }

  List<Widget> _buildCategoryFields(BuildContext context) {
    switch (card.category) {
      case CardCategory.pokemon:
        return [
          _detailRow(context, 'Type', cardTypeToString(card.type!)),
          _detailRow(context, 'Stage', stageToString(card.stage!)),
          _detailRow(context, 'Variant', _variantLabel()),
          _detailRow(
            context,
            'Legendary',
            (card.legendary ?? false) ? 'Yes' : 'No',
          ),
        ];

      case CardCategory.trainer:
        return [
          _detailRow(
            context,
            'Variant',
            trainerVariantToString(card.trainerVariant!),
          ),
        ];

      case CardCategory.itemOrStadium:
        return [
          _detailRow(
            context,
            'Kind',
            itemStadiumKindToString(card.itemStadiumKind!),
          ),
          if (card.itemStadiumKind == ItemStadiumKind.item &&
              card.itemStadiumVariant != null)
            _detailRow(
              context,
              'Variant',
              itemStadiumVariantToString(card.itemStadiumVariant!),
            ),
        ];

      case CardCategory.energy:
        return [_detailRow(context, 'Type', cardTypeToString(card.type!))];
    }
  }

  Future<void> _deleteCard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: Text('Delete "${card.name}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (card.id == null) return;

    await BinderDatabase.instance.deleteCard(card.id!);

    if (!context.mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          IconButton(
            tooltip: 'Delete card',
            onPressed: () => _deleteCard(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(card.imagePath),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                height: 300,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            card.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _detailRow(context, 'Category', cardCategoryToString(card.category)),
          _detailRow(context, 'Language', languageToString(card.cardLanguage)),
          _detailRow(context, 'Rarity', rarityToString(card.rarity)),
          ..._buildCategoryFields(context),
          _detailRow(context, 'For Sale', card.forSale ? 'Yes' : 'No'),
          _detailRow(
            context,
            'Price',
            card.price != null ? '\$${card.price!.toStringAsFixed(2)}' : 'N/A',
          ),
          _detailRow(context, 'Page', card.pageNumber.toString()),
          _detailRow(context, 'Row', card.row.toString()),
          _detailRow(context, 'Column', card.column.toString()),
        ],
      ),
    );
  }
}
