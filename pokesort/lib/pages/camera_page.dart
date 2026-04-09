import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (!mounted || cameras.isEmpty) return;

    _cameras = cameras;
    _selectedCameraIndex = _preferredCameraIndex(cameras);
    await _setActiveCamera(_selectedCameraIndex);
  }

  int _preferredCameraIndex(List<CameraDescription> cameras) {
    final backIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    if (backIndex != -1) return backIndex;

    final frontIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    if (frontIndex != -1) return frontIndex;

    return 0;
  }

  Future<void> _setActiveCamera(int index) async {
    final previousController = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    final initializeFuture = controller.initialize();

    setState(() {
      _selectedCameraIndex = index;
      _controller = controller;
      _initializeControllerFuture = initializeFuture;
    });

    await previousController?.dispose();
    await initializeFuture;

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setActiveCamera(nextIndex);
  }

  String _cameraLabel() {
    if (_cameras.isEmpty) return 'Camera';

    switch (_cameras[_selectedCameraIndex].lensDirection) {
      case CameraLensDirection.front:
        return 'Front Camera';
      case CameraLensDirection.back:
        return 'Back Camera';
      case CameraLensDirection.external:
        return 'External Camera';
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    try {
      if (_controller == null || _initializeControllerFuture == null) return;
      if (_capturing) return;

      setState(() {
        _capturing = true;
      });
      await _initializeControllerFuture!;

      final image = await _controller!.takePicture();

      if (!mounted) return;

      Navigator.pop(context, image.path);
    } catch (e) {
      debugPrint('$e');
      if (mounted) {
        setState(() {
          _capturing = false;
        });
      }
    }
  }

  Widget _buildPreview() {
    final previewSize = _controller!.value.previewSize;
    if (previewSize == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: Colors.black,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Picture'),
        actions: [
          if (_cameras.length > 1)
            IconButton(
              tooltip: 'Switch camera',
              onPressed: _switchCamera,
              icon: const Icon(Icons.flip_camera_android),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return _buildPreview();
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _cameraLabel(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (_cameras.length > 1)
                    OutlinedButton.icon(
                      onPressed: _switchCamera,
                      icon: const Icon(Icons.cameraswitch_outlined),
                      label: const Text('Switch'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _capturing ? null : _capture,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _capturing ? 0.6 : 1,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _capturing
                          ? const Padding(
                              padding: EdgeInsets.all(22),
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
