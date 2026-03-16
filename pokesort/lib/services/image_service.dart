import 'package:flutter/material.dart';
import '../pages/camera_page.dart';

class ImageService {

  static Future<String?> takePicture(BuildContext context) async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraPage(),
      ),
    );

    return imagePath;
  }

}