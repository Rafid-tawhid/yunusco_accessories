import '../riverpod/role_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextHelper {
  static void changeText(WidgetRef ref, String newText) {
    ref.read(textProvider.notifier).state = newText;
  }

  static void clearText(WidgetRef ref) {
    ref.read(textProvider.notifier).state = '';
  }
}