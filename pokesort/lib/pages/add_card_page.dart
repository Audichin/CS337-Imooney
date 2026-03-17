import 'dart:io';

import 'package:flutter/material.dart';

import '../models/card_enums.dart';
import '../models/card_model.dart';
import '../services/binder_database.dart';

class AddCardPage extends StatefulWidget {
  final int binderId;
  final int binderPageCount;
  final String imagePath;

  const AddCardPage({
    super.key,
    required this.binderId,
    required this.binderPageCount,
    required this.imagePath,
  });

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _pageController = TextEditingController(text: '1');
  final _rowController = TextEditingController(text: '1');
  final _columnController = TextEditingController(text: '1');

  CardLanguage _selectedLanguage = CardLanguage.english;
  CardType _selectedType = CardType.grass;
  CardStage _selectedStage = CardStage.basic;
  CardRarity _selectedRarity = CardRarity.common;
  CardVariant _selectedVariant = CardVariant.normal;

  bool _legendary = false;
  bool _forSale = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pageController.dispose();
    _rowController.dispose();
    _columnController.dispose();
    super.dispose();
  }

  DropdownButtonFormField<T> _buildEnumDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: values.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(labelBuilder(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final pageNumber = int.parse(_pageController.text.trim());
    final row = int.parse(_rowController.text.trim());
    final column = int.parse(_columnController.text.trim());

    setState(() {
      _saving = true;
    });

    final slotExists = await BinderDatabase.instance.cardSlotExists(
      binderId: widget.binderId,
      pageNumber: pageNumber,
      row: row,
      column: column,
    );

    if (slotExists) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That page/row/column slot already has a card.'),
        ),
      );
      return;
    }

    final card = CardModel(
      binderId: widget.binderId,
      name: _nameController.text.trim(),
      imagePath: widget.imagePath,
      cardLanguage: _selectedLanguage,
      type: _selectedType,
      stage: _selectedStage,
      rarity: _selectedRarity,
      variant: _selectedVariant,
      legendary: _legendary,
      forSale: _forSale,
      price: _forSale && _priceController.text.trim().isNotEmpty
          ? double.tryParse(_priceController.text.trim())
          : null,
      pageNumber: pageNumber,
      row: row,
      column: column,
    );

    await BinderDatabase.instance.insertCard(card);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Card Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter the card name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEnumDropdown<CardLanguage>(
                    label: 'Language',
                    value: _selectedLanguage,
                    values: CardLanguage.values,
                    labelBuilder: languageToString,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEnumDropdown<CardType>(
                    label: 'Type',
                    value: _selectedType,
                    values: CardType.values,
                    labelBuilder: cardTypeToString,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEnumDropdown<CardStage>(
                    label: 'Stage',
                    value: _selectedStage,
                    values: CardStage.values,
                    labelBuilder: stageToString,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStage = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEnumDropdown<CardRarity>(
                    label: 'Rarity',
                    value: _selectedRarity,
                    values: CardRarity.values,
                    labelBuilder: rarityToString,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRarity = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildEnumDropdown<CardVariant>(
                    label: 'Variant',
                    value: _selectedVariant,
                    values: CardVariant.values,
                    labelBuilder: variantToString,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedVariant = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Page Number (1-${widget.binderPageCount})',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final page = int.tryParse(value?.trim() ?? '');
                      if (page == null) return 'Enter a valid page number';
                      if (page < 1 || page > widget.binderPageCount) {
                        return 'Page must be between 1 and ${widget.binderPageCount}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _rowController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Row (1-3)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final row = int.tryParse(value?.trim() ?? '');
                            if (row == null) return 'Required';
                            if (row < 1 || row > 3) return '1-3 only';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _columnController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Column (1-3)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final column = int.tryParse(value?.trim() ?? '');
                            if (column == null) return 'Required';
                            if (column < 1 || column > 3) return '1-3 only';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _legendary,
                    onChanged: (value) {
                      setState(() => _legendary = value);
                    },
                    title: const Text('Legendary'),
                  ),
                  SwitchListTile(
                    value: _forSale,
                    onChanged: (value) {
                      setState(() => _forSale = value);
                    },
                    title: const Text('For Sale'),
                  ),
                  if (_forSale) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      validator: (value) {
                        if (!_forSale) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a price';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saveCard,
                    child: const Text('Save Card'),
                  ),
                ],
              ),
            ),
    );
  }
}