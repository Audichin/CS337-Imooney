import 'dart:io';

import 'package:flutter/material.dart';

import '../models/card_enums.dart';
import '../models/card_model.dart';

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
            width: 120,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(card.name)),
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
            style: Theme.of(context).textTheme.headlineSmall,

            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _detailRow(context, 'Language', languageToString(card.cardLanguage)),
          _detailRow(context, 'Type', cardTypeToString(card.type)),
          _detailRow(context, 'Stage', stageToString(card.stage)),
          _detailRow(context, 'Rarity', rarityToString(card.rarity)),
          _detailRow(context, 'Variant', variantToString(card.variant)),
          _detailRow(context, 'Legendary', card.legendary ? 'Yes' : 'No'),
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
