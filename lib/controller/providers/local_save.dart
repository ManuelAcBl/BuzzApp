import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalSave<T> {
  final String id;
  final T value;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic>? Function(T data) toJson;

  LocalSave({required this.id, required this.value, required this.fromJson, required this.toJson});

  Future<T> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? string = prefs.getString(id);

    if (string == null) return value;

    T element = value;

    try {
      element = fromJson(jsonDecode(string));
    } catch (e) {
      print("LOAD ERROR: $string");
    }

    return element;
  }

  Future<void> save(T? data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (data == null) {
      prefs.remove(id);
      return;
    }

    String string = jsonEncode(toJson(data));

    await prefs.setString(id, string);
  }
}
