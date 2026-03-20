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
              title: const Text('How to Use PokeSort'),
              subtitle: const Text(
                'Learn how to create binders, add cards, and navigate the app.',
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
                'Learn what card fields like rarity, stage, and variant mean.',
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
