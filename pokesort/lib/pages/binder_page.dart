import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../models/card_model.dart';
import '../services/binder_database.dart';
import '../services/image_service.dart';
import 'add_card_page.dart';

class BinderPage extends StatefulWidget {
  final Binder binder;

  const BinderPage({
    super.key,
    required this.binder,
  });

  @override
  State<BinderPage> createState() => _BinderPageState();
}

class _BinderPageState extends State<BinderPage> {
  late Future<List<CardModel>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    _cardsFuture = BinderDatabase.instance.getCardsByBinder(widget.binder.id!);
  }

  Future<void> _addCard() async {
    final imagePath = await ImageService.takePicture(context);
    if (imagePath == null) return;

    if (!mounted) return;

    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCardPage(
          binderId: widget.binder.id!,
          imagePath: imagePath,
        ),
      ),
    );

    if (added == true) {
      setState(_loadCards);
    }
  }

  Widget _buildCardTile(CardModel card) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              File(card.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${rarityToString(card.rarity)} • ${variantToString(card.variant)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.binder.name),
      ),
      body: FutureBuilder<List<CardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data ?? [];

          if (cards.isEmpty) {
            return const Center(
              child: Text('No cards yet. Add your first card.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              return _buildCardTile(cards[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}