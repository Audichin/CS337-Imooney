import 'package:flutter/material.dart';
import 'pages/camera_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openCamera(BuildContext context) async {
    final imagePath = await CameraPage.takePicture(context);

    if (imagePath != null) {
      print("Image saved at: $imagePath");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Picture saved: $imagePath")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Binder Camera Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openCamera(context),
          child: const Text("Take Picture"),
        ),
      ),
    );
  }
}