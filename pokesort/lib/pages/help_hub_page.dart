import 'package:flutter/material.dart';

import 'help_page.dart';
import 'pokemon_help_page.dart';

class HelpHubPage extends StatelessWidget {
  const HelpHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('PokeSort App help'),
              subtitle: const Text(
                'Need help learning the app? \nLearn how to create binders, add cards, and navigate the app.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.catching_pokemon),
              title: const Text('Pokémon Card Help'),
              subtitle: const Text(
                'Need help understanding your card? \nDiscover what you need to add a card into the app, along with links!',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PokemonHelpPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
