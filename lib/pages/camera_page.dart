import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  XFile? _capturedImage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first; // pode trocar para cameras.last para frontal

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller?.initialize();
    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();

    // Opcional: salvar a foto num diretório temporário
    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, path.basename(image.path));
    final savedImage = await File(image.path).copy(filePath);

    setState(() {
      _capturedImage = XFile(savedImage.path);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Câmera')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capturar Foto'),
            ),
          ),
          if (_capturedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(File(_capturedImage!.path)),
            ),
        ],
      ),
    );
  }
}
