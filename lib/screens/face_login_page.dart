import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:agrismart/services/face_service.dart';

class FaceLoginPage extends StatefulWidget {
  const FaceLoginPage({super.key});

  @override
  State<FaceLoginPage> createState() => _FaceLoginPageState();
}

class _FaceLoginPageState extends State<FaceLoginPage> {
  final _service = FaceService();
  CameraController? _controller;
  String _message = 'Placez votre visage dans le cadre et souriez';
  bool _occupe = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontale = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        frontale,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _message = 'Caméra indisponible ou permission refusée');
    }
  }

  Future<void> _verifier() async {
    final controller = _controller;
    if (controller == null || _occupe) return;
    setState(() { _occupe = true; _message = 'Analyse...'; });
    try {
      final photo = await controller.takePicture();
      final r = await _service.analyser(photo.path);
      if (!mounted) return;
      if (r.nombreVisages == 0) {
        _message = 'Aucun visage détecté';
      } else if (!r.unSeulVisage) {
        _message = 'Un seul visage, svp';
      } else if (!r.sourit) {
        _message = 'Visage détecté, mais souriez !';
      } else {
        _message = 'Vérification réussie ✅';
      }
    } catch (_) {
      _message = 'Erreur pendant l\'analyse';
    }
    if (mounted) setState(() => _occupe = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion par visage')),
      body: Column(
        children: [
          Expanded(
            child: controller == null || !controller.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(controller),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _occupe ? null : _verifier,
                  icon: const Icon(Icons.face),
                  label: const Text('Vérifier'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}