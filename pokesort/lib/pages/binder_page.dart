import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../services/binder_database.dart';
import '../services/image_service.dart';
import 'add_card_page.dart';
import 'card_detail_page.dart';

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

  Future<void> _openCardDetails(CardModel card) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CardDetailPage(
          card: card,
          binderPageCount: widget.binder.pageCount,
        ),
      ),
    );

    if (changed == true) {
      setState(_loadCards);
    }
  }

  Future<void> _deleteBinder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Binder'),
          content: Text(
            'Delete "${widget.binder.name}" and all cards inside it? This cannot be undone.',
          ),
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
    if (widget.binder.id == null) return;

    await BinderDatabase.instance.deleteBinder(widget.binder.id!);

    if (!mounted) return;
    Navigator.pop(context, true);
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

  int _currentPageNumber() => _currentPageIndex + 1;

  int _sheetNumberForPage(int pageNumber) => (pageNumber + 1) ~/ 2;

  bool _isFrontSide(int pageNumber) => pageNumber.isOdd;

  String _pageStatusLabel() {
    final pageNumber = _currentPageNumber();
    final sheetNumber = _sheetNumberForPage(pageNumber);
    final side = _isFrontSide(pageNumber) ? 'Front' : 'Back';

    return 'PokeSort Page $pageNumber • IRL Sheet $sheetNumber • $side';
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
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: Colors.grey,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _openCardDetails(card),
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    card.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _cardVariantLabel(card).isEmpty
                        ? rarityToString(card.rarity)
                        : '${cardCategoryToString(card.category)} card',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 68),
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
        children: slots,
      ),
    );
  }

  Widget _buildBottomBar() {
    final int currentPage = _currentPageNumber();
    final int? previousPage = currentPage > 1 ? currentPage - 1 : null;
    final int? nextPage =
        currentPage < widget.binder.pageCount ? currentPage + 1 : null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.black.withOpacity(0.22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
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
                    width: 24,
                    child: Text(
                      previousPage?.toString() ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _addCard,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Card'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 24,
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.binder.name),
        actions: [
          IconButton(
            tooltip: 'Delete binder',
            onPressed: _deleteBinder,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _pageStatusLabel(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
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