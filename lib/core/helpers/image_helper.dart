import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

class ImageHelper {
  static Future<bool> hasAnyColorInFile(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return false;

    var colorPixels = 0;
    final totalPixels = image.width * image.height;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final rg = (pixel.r - pixel.g).abs();
        final rb = (pixel.r - pixel.b).abs();
        final gb = (pixel.g - pixel.b).abs();
        if (rg > 15 || rb > 15 || gb > 15) colorPixels++;
      }
    }

    final colorRatio = colorPixels / totalPixels;
    debugPrint(
      '🎨 Color pixel ratio: ${(colorRatio * 100).toStringAsFixed(2)}%',
    );
    return colorRatio > 0.003;
  }

  static Future<File?> compressImage(File file, {int quality = 85}) async {
    try {
      final filePath = file.absolute.path;
      final extension = filePath.split('.').last.toLowerCase();
      final lastSeparator = filePath.lastIndexOf(Platform.pathSeparator);
      final newPath =
          '${filePath.substring(0, lastSeparator + 1)}compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        newPath,
        quality: quality,
        format: extension == 'png' ? CompressFormat.png : CompressFormat.jpeg,
      );

      return result == null ? null : File(result.path);
    } catch (error) {
      debugPrint('Image compression error: $error');
      return file;
    }
  }
}
