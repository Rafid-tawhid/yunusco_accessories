import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../riverpod/data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class DashboardHelper {

  static String reviewStatus="Review";
  static String modifyStatus="Modify";
  static String confirmStatus="Confirm";

  static saveString(String key,String value) async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    pref.setString(key, value);
  }
  static Future<String?> getString(String key) async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    return pref.getString(key);
  }



  static Future<bool> hasAnyColorInFile(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return false;

    int colorPixels = 0;
    final totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        final rg = (r - g).abs();
        final rb = (r - b).abs();
        final gb = (g - b).abs();

        if (rg > 15 || rb > 15 || gb > 15) {
          colorPixels++;
        }
      }
    }

    final colorRatio = colorPixels / totalPixels;

    debugPrint(
      '🎨 Color pixel ratio: ${(colorRatio * 100).toStringAsFixed(2)}%',
    );

    return colorRatio > 0.003; // 0.3%
  }


  static Future<File?> compressImage(File file, {int quality = 85}) async {
    try {
      final filePath = file.absolute.path;

      // Get image extension
      final extension = filePath.split('.').last.toLowerCase();

      // Create output file path
      final lastSeparator = filePath.lastIndexOf(Platform.pathSeparator);
      final newPath = '${filePath.substring(0, lastSeparator + 1)}compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Compress based on image type
      XFile? result;
      if (extension == 'png') {
        result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          newPath,
          quality: quality,
          format: CompressFormat.png,
        );
      } else {
        result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          newPath,
          quality: quality,
          format: CompressFormat.jpeg,
        );
      }

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Image compression error: $e');
      return file; // Return original if compression fails
    }
  }





}