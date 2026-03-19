import 'package:flutter/material.dart';

import '../pages/help_page.dart';
import '../pages/pokemon_help_page.dart';
import '../services/app_settings.dart';

class AppMenuSheet extends StatelessWidget {
  final AppSettings settings;

  const AppMenuSheet({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (value) {
                  settings.setDarkMode(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('How to Use PokeSort'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.catching_pokemon),
              title: const Text('Pokémon Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PokemonHelpPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}