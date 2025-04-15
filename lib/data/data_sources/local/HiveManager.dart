import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_book/domain/models/user/data_model/user_model.dart';
import 'package:note_book/infra/utils/gson_utils.dart';

class HiveManager {
  static const String userBoxName = 'userBox';
  static const String userKey = 'user_json';
  static const String tokenKey = 'jwt_token';

  static late Box _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(userBoxName);
  }

  static Future<void> saveUserJson(UserModel user) async {
    var jsonString = GsonUtils.toJson(user);
    await _userBox.put(userKey, jsonString);
  }

  static UserModel? getUserJson() {
    var jsonString = _userBox.get(userKey);
    if (jsonString == null) return null;
    return GsonUtils.fromJson<UserModel>(jsonString, UserModel.fromJson);
  }

  static Future<void> saveToken(String token) async {
    await _userBox.put(tokenKey, token);
  }

  static String? getToken() {
    return _userBox.get(tokenKey);
  }

  static Future<void> deleteToken() async {
    await _userBox.delete(tokenKey);
  }

  static Future<void> clearUserData() async {
    await _userBox.delete(userKey);
    await _userBox.delete(tokenKey);
  }
}