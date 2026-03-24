import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PokemonHelpPage extends StatelessWidget {
  const PokemonHelpPage({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Help')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _sectionTitle(context, 'Need help understanding your card?'),
            const Text('''
Locations for all data for adding a card into Pokesort:

Card cadagories (supported by the app):
Pokemon card --> will have a pokemon on the front
Tainer card --> Will say "Trainer" either on the top left or middle
Item/Stadium card --> Will say "Item" or "Stadium" on top left
Energy card --> Will say "Energy" on top left or middle
ACE SPEC --> Will say "ACE SPEC" on left & right of card

NOTICE: If you have an ACE SPEC card, it is labeled under "Item/Stadium", click on "Item" when prompted
--------------------------------------------------------------------------------------------
Pokemon card information locations:

Name --> Top left of card, in black letters
Rarity --> Bottom left of card, right of (###/###)
Type --> Top Right of card, with symbol
Stage --> Top left of card, left of name
Variant --> Middle right of card, right of name, if applicable
--------------------------------------------------------------------------------------------
'''),
            _sectionTitle(context, 'Useful Links'),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Pokémon TCG website'),
              subtitle: const Text('Official Pokémon TCG website'),
              onTap: () => _openLink('https://www.pokemon.com/us/pokemon-tcg'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Checking pokemon card rarity'),
              subtitle: const Text('Pokémon rarity system'),
              onTap: () => _openLink(
                'https://www.tcgplayer.com/content/article/How-to-Tell-the-Rarity-of-a-Pok%C3%A9mon-Card/3bc6c211-f4ce-4c4d-b823-74f3790ebaeb/',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Is your card a legendary?'),
              subtitle: const Text('All legendary & mythical pokemon'),
              onTap: () => _openLink(
                'https://www.wargamer.com/pokemon-trading-card-game/legendary-pokemon',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
