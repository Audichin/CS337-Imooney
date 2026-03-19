import 'package:flutter/material.dart';

import 'pages/binder_list_page.dart';
import 'services/app_settings.dart';

void main() {
  runApp(PokeSortApp(settings: AppSettings()));
}

class PokeSortApp extends StatelessWidget {
  final AppSettings settings;

  const PokeSortApp({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'PokeSort',
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: BinderListPage(settings: settings),
        );
      },
    );
  }
}