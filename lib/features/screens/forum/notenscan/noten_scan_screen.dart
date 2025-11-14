import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
// TFLite vorübergehend deaktiviert
// import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:notekey_app/features/themes/colors.dart';

const String kModelPath = 'assets/tflite/noten_model.tflite';
const String kLabelsPath = 'assets/tflite/labels.txt';

class NotenScanScreen extends StatefulWidget {
  const NotenScanScreen({super.key});

  @override
  State<NotenScanScreen> createState() => _NotenScanScreenState();
}

class _NotenScanScreenState extends State<NotenScanScreen> {
  final ImagePicker _picker = ImagePicker();

  // Interpreter? _interpreter; // Deaktiviert
  late List<String> _labels;

  bool _loading = false;
  String? _error;
  File? _image;

  final int _inputWidth = 224;
  final int _inputHeight = 224;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Labels laden (oder Fallback)
      try {
        final raw = await rootBundle.loadString(kLabelsPath);
        _labels = raw
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } catch (_) {
        _labels = const ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
      }
    } catch (e) {
      _error = 'Labels konnten nicht geladen werden: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final x = await _picker.pickImage(source: source, maxWidth: 2048);
      if (x == null) return;

      final file = File(x.path);
      setState(() => _image = file);

      await _analyzeImage(file);
    } catch (e) {
      setState(() => _error = 'Bild konnte nicht geladen werden: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Temporäre Demo-Analyse ohne TFLite
  Future<void> _analyzeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        setState(() => _error = 'Bild-Decoder fehlgeschlagen.');
        return;
      }

      final resized = img.copyResize(
        original,
        width: _inputWidth,
        height: _inputHeight,
        interpolation: img.Interpolation.linear,
      );

      double sum = 0;
      int count = 0;
      for (int y = 0; y < _inputHeight; y++) {
        for (int x = 0; x < _inputWidth; x++) {
          final px = resized.getPixel(x, y);
          final lum = 0.299 * px.r + 0.587 * px.g + 0.114 * px.b;
          sum += lum;
          count++;
        }
      }

      final avg = (count == 0) ? 0.0 : sum / count;
      final int idx =
          (avg / 256.0 * _labels.length).floor().clamp(0, _labels.length - 1);

      final List<(int, double)> top = [];
      top.add((idx, 0.92));
      if (_labels.length > 1) top.add(((idx + 1) % _labels.length, 0.31));
      if (_labels.length > 2) top.add(((idx + 2) % _labels.length, 0.18));

      if (mounted) {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.hellbeige,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ergebnis (Demo ohne TFLite)',
                  style: TextStyle(
                    color: AppColors.dunkelbraun,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final e in top)
                  ListTile(
                    dense: true,
                    title: Text(
                      _labels[e.$1],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text('${(e.$2 * 100).toStringAsFixed(1)} %'),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Hinweis: TFLite ist momentan deaktiviert. '
                  'Die echte Erkennung wird später wieder aktiviert.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Analyse fehlgeschlagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        title: const Text(
          'NOTEscan',
          style: TextStyle(color: AppColors.hellbeige),
        ),
        iconTheme: const IconThemeData(color: AppColors.hellbeige),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, width: 320),
                )
              else
                Container(
                  width: 320,
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.hellbeige,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Kein Bild ausgewählt'),
                ),
              const SizedBox(height: 20),
              if (_loading) const CircularProgressIndicator(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ScanActionButton(
                      icon: Icons.photo_camera,
                      label: 'Kamera',
                      onTap: () => _pick(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScanActionButton(
                      icon: Icons.photo_library,
                      label: 'Galerie',
                      onTap: () => _pick(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ScanActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: AppColors.hellbeige),
        label: Text(
          label,
          style: const TextStyle(
            color: AppColors.hellbeige,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldbraun,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1.5,
        ),
      ),
    );
  }
}
