
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  static const String userBoxName = 'userBox';
  static const String userKey = 'user_json';
  static const String tokenKey = 'jwt_token';

  static late Box _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(userBoxName);
  }

  static Future<void> saveUserJson(String jsonString) async {
    await _userBox.put(userKey, jsonString);
  }

  static String? getUserJson() {
    return _userBox.get(userKey);
  }

  static Future<void> saveToken(String token) async {
    await _userBox.put(tokenKey, token);
  }

  static String? getToken() {
    return _userBox.get(tokenKey);
  }

  static Future<void> clearUserData() async {
    await _userBox.delete(userKey);
    await _userBox.delete(tokenKey);
  }

}