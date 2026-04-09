import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PokemonHelpPage extends StatelessWidget {
  const PokemonHelpPage({super.key});

  void _openSection(
    BuildContext context, {
    required String title,
    required String intro,
    required List<HelpBullet> items,
    String? note,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PokemonHelpSectionPage(
          title: title,
          intro: intro,
          items: items,
          note: note,
        ),
      ),
    );
  }

  void _openLinks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PokemonHelpLinksPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Card categories'),
              subtitle: const Text(
                'Learn how to tell Pokémon, Trainer, Item/Stadium, and Energy cards apart.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Card categories',
                intro:
                    'Use the card front to identify which category it belongs to.',
                items: const [
                  HelpBullet(
                    heading: 'Pokémon card',
                    body: 'A Pokémon appears on the front of the card.',
                  ),
                  HelpBullet(
                    heading: 'Trainer card',
                    body:
                        'The word "Trainer" appears near the top of the card.',
                  ),
                  HelpBullet(
                    heading: 'Item/Stadium card',
                    body:
                        'The word "Item" or "Stadium" appears near the top-left.',
                  ),
                  HelpBullet(
                    heading: 'Energy card',
                    body:
                        'The word "Energy" appears near the top area of the card.',
                  ),
                  HelpBullet(
                    heading: 'ACE SPEC',
                    body:
                        'ACE SPEC cards should be entered under "Item/Stadium" and then marked as "Item".',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.search_outlined),
              title: const Text('Pokémon card info locations'),
              subtitle: const Text(
                'Find where name, rarity, type, stage, and variant appear on a card.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSection(
                context,
                title: 'Pokémon card info locations',
                intro:
                    'These are the main spots to check when adding a Pokémon card.',
                items: const [
                  HelpBullet(
                    heading: 'Name',
                    body:
                        'Top-left area of the card, usually in bold black text.',
                  ),
                  HelpBullet(
                    heading: 'Rarity',
                    body: 'Bottom-left area, often next to the card number.',
                  ),
                  HelpBullet(
                    heading: 'Type',
                    body: 'Top-right area, shown with a symbol.',
                  ),
                  HelpBullet(
                    heading: 'Stage',
                    body:
                        'Top-left area, usually just to the left of the name.',
                  ),
                  HelpBullet(
                    heading: 'Variant',
                    body:
                        'Often near the upper-middle or right side of the card name area when applicable.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Useful links'),
              subtitle: const Text(
                'Open external references for the Pokémon TCG, rarity help, and legendary lists.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openLinks(context),
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonHelpSectionPage extends StatelessWidget {
  final String title;
  final String intro;
  final List<HelpBullet> items;
  final String? note;

  const PokemonHelpSectionPage({
    super.key,
    required this.title,
    required this.intro,
    required this.items,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(intro),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  item.heading,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(item.body),
                ),
              ),
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(note!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PokemonHelpLinksPage extends StatelessWidget {
  const PokemonHelpLinksPage({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Useful Links')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Pokémon TCG website'),
              subtitle: const Text(
                'Official Pokémon Trading Card Game website',
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink('https://www.pokemon.com/us/pokemon-tcg'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.stars_outlined),
              title: const Text('Checking Pokémon card rarity'),
              subtitle: const Text('Guide for identifying Pokémon card rarity'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink(
                'https://www.tcgplayer.com/content/article/How-to-Tell-the-Rarity-of-a-Pok%C3%A9mon-Card/3bc6c211-f4ce-4c4d-b823-74f3790ebaeb/',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Is your card a legendary?'),
              subtitle: const Text('Legendary and mythical Pokémon reference'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openLink(
                'https://www.wargamer.com/pokemon-trading-card-game/legendary-pokemon',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpBullet {
  final String heading;
  final String body;

  const HelpBullet({required this.heading, required this.body});
}
