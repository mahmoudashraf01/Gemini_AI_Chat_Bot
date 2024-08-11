  import 'dart:typed_data';
import 'package:image/image.dart' as img;

Future<String> determineImageFormat(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image != null) {
        return 'image/${image.format.name.toLowerCase()}';
      } else {
        return 'image/unknown';
      }
    } catch (e) {
      return 'image/unknown';
    }
  }