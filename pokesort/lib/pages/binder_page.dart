import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../services/binder_database.dart';
import '../services/image_service.dart';
import 'add_card_page.dart';

class BinderPage extends StatefulWidget {
  final Binder binder;

  const BinderPage({super.key, required this.binder});

  @override
  State<BinderPage> createState() => _BinderPageState();
}

class _BinderPageState extends State<BinderPage> {
  late Future<List<CardModel>> _cardsFuture;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadCards() {
    _cardsFuture = BinderDatabase.instance.getCardsByBinder(widget.binder.id!);
  }

  Future<void> _addCard() async {
    debugPrint('Add card pressed');

    final imagePath = await ImageService.takePicture(context);
    if (imagePath == null) return;
    if (!mounted) return;

    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCardPage(
          binderId: widget.binder.id!,
          binderPageCount: widget.binder.pageCount,
          imagePath: imagePath,
        ),
      ),
    );

    if (added == true) {
      setState(_loadCards);
    }
  }

  CardModel? _findCardForSlot(
    List<CardModel> cards,
    int pageNumber,
    int row,
    int column,
  ) {
    try {
      return cards.firstWhere(
        (card) =>
            card.pageNumber == pageNumber &&
            card.row == row &&
            card.column == column,
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildSlot(CardModel? card) {
    if (card == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              File(card.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
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

  Widget _buildBinderSheet(List<CardModel> cards, int pageNumber) {
    final slots = <Widget>[];

    for (int row = 1; row <= 3; row++) {
      for (int column = 1; column <= 3; column++) {
        final card = _findCardForSlot(cards, pageNumber, row, column);
        slots.add(_buildSlot(card));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.68,
              children: slots,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final int currentPage = _currentPageIndex + 1;
    final int? previousPage = currentPage > 1 ? currentPage - 1 : null;
    final int? nextPage = currentPage < widget.binder.pageCount
        ? currentPage + 1
        : null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.black.withOpacity(0.25),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: _addCard,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Card'),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        color: Colors.white,
                        onPressed: previousPage != null
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          previousPage?.toString() ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 28,
                        child: Text(
                          nextPage?.toString() ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        color: Colors.white,
                        onPressed: nextPage != null
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.binder.name)),
      extendBody: true,
      body: FutureBuilder<List<CardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data ?? [];

          return PageView.builder(
            controller: _pageController,
            itemCount: widget.binder.pageCount,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              return _buildBinderSheet(cards, pageNumber);
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
