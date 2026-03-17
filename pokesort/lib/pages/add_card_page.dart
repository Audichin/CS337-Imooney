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

  DropdownButtonFormField<T> _enumDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map((v) => DropdownMenuItem<T>(
                value: v,
                child: Text(labelBuilder(v)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final pageNumber = int.parse(_pageController.text.trim());
    final row = int.parse(_rowController.text.trim());
    final column = int.parse(_columnController.text.trim());

    setState(() => _saving = true);

    // Prevent two cards in the same slot
    final slotTaken = await BinderDatabase.instance.cardSlotExists(
      binderId: widget.binderId,
      pageNumber: pageNumber,
      row: row,
      column: column,
    );

    if (slotTaken) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That slot already has a card.')),
      );
      return;
    }

    final price = (_forSale && _priceController.text.trim().isNotEmpty)
        ? double.tryParse(_priceController.text.trim())
        : null;

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
      price: price,
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
      appBar: AppBar(title: const Text('Add Card')),
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
                      height: 220,
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
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),
                  _enumDropdown<CardLanguage>(
                    label: 'Language',
                    value: _selectedLanguage,
                    values: CardLanguage.values,
                    labelBuilder: languageToString,
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),

                  const SizedBox(height: 16),
                  _enumDropdown<CardType>(
                    label: 'Type',
                    value: _selectedType,
                    values: CardType.values,
                    labelBuilder: cardTypeToString,
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),

                  const SizedBox(height: 16),
                  _enumDropdown<CardStage>(
                    label: 'Stage',
                    value: _selectedStage,
                    values: CardStage.values,
                    labelBuilder: stageToString,
                    onChanged: (v) => setState(() => _selectedStage = v!),
                  ),

                  const SizedBox(height: 16),
                  _enumDropdown<CardRarity>(
                    label: 'Rarity',
                    value: _selectedRarity,
                    values: CardRarity.values,
                    labelBuilder: rarityToString,
                    onChanged: (v) => setState(() => _selectedRarity = v!),
                  ),

                  const SizedBox(height: 16),
                  _enumDropdown<CardVariant>(
                    label: 'Variant',
                    value: _selectedVariant,
                    values: CardVariant.values,
                    labelBuilder: variantToString,
                    onChanged: (v) => setState(() => _selectedVariant = v!),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Page (1-${widget.binderPageCount})',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null) return 'Enter a number';
                      if (n < 1 || n > widget.binderPageCount) {
                        return 'Must be 1-${widget.binderPageCount}';
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
                          validator: (v) {
                            final n = int.tryParse(v?.trim() ?? '');
                            if (n == null) return 'Required';
                            if (n < 1 || n > 3) return '1-3 only';
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
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final n = int.tryParse(v?.trim() ?? '');
                            if (n == null) return 'Required';
                            if (n < 1 || n > 3) return '1-3 only';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _legendary,
                    onChanged: (v) => setState(() => _legendary = v),
                    title: const Text('Legendary'),
                  ),

                  SwitchListTile(
                    value: _forSale,
                    onChanged: (v) => setState(() => _forSale = v),
                    title: const Text('For Sale'),
                  ),

                  if (_forSale) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      validator: (v) {
                        if (!_forSale) return null;
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save Card'),
                  ),
                ],
              ),
            ),
    );
  }
}