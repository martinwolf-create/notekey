import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final _picker = ImagePicker();

/// Bild aus Galerie/Kamera auswählen und dauerhaft speichern.
/// Gibt `null` zurück, wenn der Nutzer abbricht.
Future<String?> pickAndPersistImage({bool fromCamera = false}) async {
  final x = await _picker.pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    imageQuality: 88,
  );
  if (x == null) return null;

  final bytes = await x.readAsBytes();
  final dir = await getApplicationDocumentsDirectory();
  final ext = x.name.split('.').last;
  final file =
      File('${dir.path}/event_${DateTime.now().millisecondsSinceEpoch}.$ext');

  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
