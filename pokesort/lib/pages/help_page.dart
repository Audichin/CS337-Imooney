import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use PokeSort')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text('''
- Creating a binder:
  1) Tap the "+" in the "My Binders" Tab
  2) Add the following:
    a) Binder name (make it unique!)
    b) Page count (front & back of each page are seperate)
    c) Take photo of the front of the binder
  3) Click save, your binder will appear to the left
'''),
        ),
      ),
    );
  }
}
