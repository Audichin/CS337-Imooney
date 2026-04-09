import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../services/binder_database.dart';
import '../services/image_service.dart';
import 'binder_page.dart';

import '../services/app_settings.dart';
import '../widgets/app_menu_sheet.dart';

import '../search/app_search.dart';

import 'help_hub_page.dart';

class BinderListPage extends StatefulWidget {
  final AppSettings settings;

  const BinderListPage({super.key, required this.settings});

  @override
  State<BinderListPage> createState() => _BinderListPageState();
}

class _BinderListPageState extends State<BinderListPage> {
  late Future<List<Binder>> _bindersFuture;

  void _openHelpHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpHubPage()),
    );
  }

  Future<void> _openCollectionSearch() async {
    final binders = await BinderDatabase.instance.getBinders();
    final cards = await BinderDatabase.instance.getAllCards();

    if (!mounted) return;

    await showSearch(
      context: context,
      delegate: CollectionSearchDelegate(binders: binders, cards: cards),
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => AppMenuSheet(settings: widget.settings),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBinders();
  }

  void _loadBinders() {
    _bindersFuture = BinderDatabase.instance.getBinders();
  }

  Future<void> _createBinder() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateBinderDialog(),
    );

    if (created == true) {
      setState(_loadBinders);
    }
  }

  Widget _buildBinderTile(Binder binder) {
    return ListTile(
      leading: binder.coverImage == null
          ? const CircleAvatar(child: Icon(Icons.book))
          : CircleAvatar(backgroundImage: FileImage(File(binder.coverImage!))),
      title: Text(binder.name),
      subtitle: Text('${binder.sheetCount} pages(s)'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => BinderPage(binder: binder)),
        );

        if (changed == true) {
          setState(_loadBinders);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Binders'),
        actions: [
          IconButton(
            tooltip: 'Help',
            onPressed: _openHelpHub,
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<Binder>>(
        future: _bindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final binders = snapshot.data ?? [];

          if (binders.isEmpty) {
            return const Center(
              child: Text(
                'You have no binders yet. Tap + to create one! \n      Please take a look at the ? for help!',
              ),
            );
          }

          return ListView.separated(
            itemCount: binders.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildBinderTile(binders[index]),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'binder_list_menu_fab',
            onPressed: _openMenu,
            child: const Icon(Icons.settings),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'binder_list_search_fab',
            onPressed: _openCollectionSearch,
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'binder_list_add_fab',
            onPressed: _createBinder,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _CreateBinderDialog extends StatefulWidget {
  const _CreateBinderDialog();

  @override
  State<_CreateBinderDialog> createState() => _CreateBinderDialogState();
}

class _CreateBinderDialogState extends State<_CreateBinderDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pageCountController = TextEditingController(
    text: '1',
  );
  String? _coverImage;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  Future<void> _takeCoverPhoto() async {
    final imagePath = await ImageService.takePicture(context);
    if (!mounted || imagePath == null) return;

    setState(() {
      _coverImage = imagePath;
    });
  }

  Future<void> _saveBinder() async {
    final name = _nameController.text.trim();
    final pageCount = int.tryParse(_pageCountController.text.trim());

    if (name.isEmpty || pageCount == null || pageCount < 1) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
    });

    await BinderDatabase.instance.insertBinder(
      Binder(name: name, coverImage: _coverImage, sheetCount: pageCount),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Binder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Binder Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pageCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Binder sheets (front/back)',
              ),
            ),
            const SizedBox(height: 12),
            if (_coverImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_coverImage!),
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : _takeCoverPhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take Cover Photo'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _saveBinder,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
