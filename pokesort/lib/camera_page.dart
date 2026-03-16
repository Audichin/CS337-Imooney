import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({super.key, required this.cameras});

  static Future<String?> takePicture(BuildContext context) async {
    final cameras = await availableCameras();

    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraPage(cameras: cameras),
      ),
    );
  }

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> 
{
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState()
  {
    super.initState();

    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() 
  {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _capture() async
  {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      if (!mounted) return;

      Navigator.pop(context, image.path);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Take Picture")),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.done) {

            return Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              ),
            );

          } else {
            return const Center(child: CircularProgressIndicator());
          }

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capture,
        child: const Icon(Icons.camera),
      ),
    );
  }
}