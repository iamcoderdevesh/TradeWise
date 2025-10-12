import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> cacheApiData({required String key, required List<Map<String, dynamic>> data}) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, jsonEncode(data));
}

Future<List<Map<String, dynamic>>> getCachedData({required String key}) async {
  List<Map<String, dynamic>> data = [];
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString(key);
  if (jsonString != null) {
    data = List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  return data;
}