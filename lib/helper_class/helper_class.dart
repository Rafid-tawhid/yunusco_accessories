import '../riverpod/data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

}