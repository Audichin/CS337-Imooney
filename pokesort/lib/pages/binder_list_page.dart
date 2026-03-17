import 'dart:io';

import 'package:flutter/material.dart';

import '../models/binder.dart';
import '../services/binder_database.dart';
import '../services/image_service.dart';
import 'binder_page.dart';

class BinderListPage extends StatefulWidget {
  const BinderListPage({super.key});

  @override
  State<BinderListPage> createState() => _BinderListPageState();
}

class _BinderListPageState extends State<BinderListPage> {
  late Future<List<Binder>> _bindersFuture;

  @override
  void initState() {
    super.initState();
    _loadBinders();
  }

  void _loadBinders() {
    _bindersFuture = BinderDatabase.instance.getBinders();
  }

  Future<void> _createBinder() async {
    final nameController = TextEditingController();
    final pageCountController = TextEditingController(text: '1');
    String? coverImage;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Binder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Binder Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pageCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of Pages',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (coverImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(coverImage!),
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final imagePath =
                            await ImageService.takePicture(context);
                        if (imagePath != null) {
                          setDialogState(() {
                            coverImage = imagePath;
                          });
                        }
                      },
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Take Cover Photo'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final pageCount =
                        int.tryParse(pageCountController.text.trim());

                    if (name.isEmpty || pageCount == null || pageCount < 1) {
                      return;
                    }

                    await BinderDatabase.instance.insertBinder(
                      Binder(
                        name: name,
                        coverImage: coverImage,
                        pageCount: pageCount,
                      ),
                    );

                    if (!mounted) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    pageCountController.dispose();

    if (created == true) {
      setState(_loadBinders);
    }
  }

  Widget _buildBinderTile(Binder binder) {
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
          MaterialPageRoute(
            builder: (_) => BinderPage(binder: binder),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Binders'),
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
              child: Text('No binders yet. Tap + to create one.'),
            );
          }

          return ListView.separated(
            itemCount: binders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildBinderTile(binders[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBinder,
        child: const Icon(Icons.add),
      ),
    );
  }
}