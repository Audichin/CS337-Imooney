import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  void _openSection(
    BuildContext context, {
    required String title,
    required List<String> steps,
    String? note,
    List<String> notes = const [],
    List<String> examples = const [],
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HelpSectionPage(
          title: title,
          steps: steps,
          note: note,
          notes: notes,
          examples: examples,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use PokeSort')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.collections_bookmark_outlined),
              title: const Text('Creating a binder'),
              subtitle: const Text(
                'Learn how to make a new binder and set it up correctly.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Creating a binder',
                steps: const [
                  'Tap the "+" button on the "My Binders" page.',
                  'Enter a unique binder name.',
                  'Enter the binder page count.',
                  'Take a photo of the front of the binder.',
                  'Tap save to create the binder.',
                ],
                note:
                    'Each sheet has a front and back, so the app may show more usable pages than the number of physical sheets.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_photo_alternate_outlined),
              title: const Text('Adding a card'),
              subtitle: const Text(
                'See how to capture a card photo and fill in its details.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Adding a card',
                steps: const [
                  'Open the binder where you want to add the card.',
                  'Tap the "+ Add Card" button at the bottom.',
                  'Take a photo of the front of the card.',
                  'Allow camera access if your device prompts you.',
                  'Fill in the card details and save.',
                ],
                note:
                    'If you have an ACE SPEC card, choose "Item/Stadium" and then select "Item". For help identifying card details, open the Pokémon Card Help section.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Viewing card details'),
              subtitle: const Text(
                'Open a card and review all of its saved information.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Viewing card details',
                steps: const [
                  'Open any binder.',
                  'Tap a card that already has a picture.',
                  'Review the detail page for category, rarity, page placement, and other saved data.',
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.search_outlined),
              title: const Text('Searching for binders and cards'),
              subtitle: const Text(
                'Learn how to quickly find specific binders and cards in your collection.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Searching for binders and cards',
                steps: const [
                  'Use the search bar at the top of the main screen.',
                  'Enter keywords related to the binder or card you are looking for.',
                  'Add optional filters for page, side, sheet, or price when you want narrower results.',
                  'Browse the search results to find the desired item.',
                ],
                notes: const [
                  'You can search by card name, type, and/or other attributes you  put into your card.',
                  'Typing "Pokemon" or "Pokémon" will both match the Pokémon category.',
                  'Searching inside a binder view will only return results from that binder.',
                  'Searching from the main screen will search across binders and cards in your entire collection.',
                ],
                examples: const [
                  'pokemon',
                  'trainer price:1-5',
                  'price:>10 rare',
                  'page:3 front',
                  'sheet:2 back',
                  'price:.25-1',
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Deleting a card'),
              subtitle: const Text(
                'Remove a single card from one of your binders.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Deleting a card',
                steps: const [
                  'Open the binder that contains the card.',
                  'Tap the card to open its detail page.',
                  'Tap the trash can in the top-right corner.',
                  'Confirm the deletion when prompted.',
                ],
                notes: const [
                  'Deleting a card is permanent and cannot be undone.',
                  'Only the selected card will be removed from the binder.',
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Deleting a binder'),
              subtitle: const Text(
                'Remove a binder and all cards stored inside it.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Deleting a binder',
                steps: const [
                  'Open the binder you want to delete.',
                  'Tap the trash can in the top-right corner.',
                  'Confirm the deletion when prompted.',
                ],
                notes: const [
                  'Deleting a binder is permanent and cannot be undone.',
                  'Deleting a binder will also remove every card saved inside it.',
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpSectionPage extends StatelessWidget {
  final String title;
  final List<String> steps;
  final String? note;
  final List<String> notes;
  final List<String> examples;

  const HelpSectionPage({
    super.key,
    required this.title,
    required this.steps,
    this.note,
    this.notes = const [],
    this.examples = const [],
  });

  Widget _buildNoteCard(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.priority_high, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(steps[index]),
              ),
            );
          }),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Important Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...notes.map((item) => _buildNoteCard(context, item)),
          ],
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Example Searches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...examples.map(
              (example) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: Text(
                    example,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 8),
            _buildNoteCard(context, note!),
          ],
        ],
      ),
    );
  }
}
