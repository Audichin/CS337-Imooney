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
--------------------------------------------------------------------------------------------
- Adding a card:
  1) Click into the binder you want to add into
  2) Click the "+ Add Card" button on the bottom
  3) Take photo of front of the card
    a) If prompted for access, click allow for camera, can deny audio if you want
  4) Add data depending on card type and details
  *** See "Pokémon Card Help" page for details! ***

  NOTICE: If you have an ACE SPEC card, it is labeled under "Item/Stadium", click on "Item" when prompted
--------------------------------------------------------------------------------------------
- Viewing card details:
  1) Open any binder to view the cards
  2) Click on any card that has a picture to view its details
--------------------------------------------------------------------------------------------
- Deleting a binder:
  1) Go into the binder
  2) Look at the top right for a trash can
  3) Click "Delete" when prompted are you sure
    a) BE CAREFUL: THIS IS IRREVERSIBLE!
--------------------------------------------------------------------------------------------
-Deleting a card:
  1) Click onto the binder you wish to delete the card from
  2) Click into the card you want to delete (into the detail view)
  3) Look at the top right for a trash can
  4) Click "Delete" when prompeted are you sure
    a) BE CAREFUL: THIS IS IRREVERSIBLE!
'''),
        ),
      ),
    );
  }
}
