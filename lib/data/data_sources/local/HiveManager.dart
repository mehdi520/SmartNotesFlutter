import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_book/data/data_sources/local/offline_cache.dart';
import 'package:note_book/domain/models/user/data_model/user_model.dart';
import 'package:note_book/infra/utils/gson_utils.dart';

/// Local storage.
/// - The login token lives in secure storage (iOS Keychain / Android Keystore / WebCrypto on web)
///   and is kept in memory so it can be read synchronously.
/// - The user profile (not secret) lives in a Hive box.
class HiveManager {
  static const String userBoxName = 'userBox';
  static const String userKey = 'user_json';
  static const String tokenKey = 'jwt_token';
  static const String _installedKey = 'installed';

  static late Box _userBox;
  static const FlutterSecureStorage _secure = FlutterSecureStorage();
  static String? _token;

  static Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(userBoxName);
    await OfflineCache.init();
    await _loadToken();
  }

  static Future<void> _loadToken() async {
    try {
      // The iOS Keychain survives uninstall: on a fresh install, forget any old token.
      if (_userBox.get(_installedKey) != true) {
        await _secure.delete(key: tokenKey);
        await _userBox.put(_installedKey, true);
      }
      // Move a token saved by older versions (plain Hive) into secure storage.
      final legacy = _userBox.get(tokenKey);
      if (legacy is String && legacy.isNotEmpty) {
        await _secure.write(key: tokenKey, value: legacy);
        await _userBox.delete(tokenKey);
      }
      _token = await _secure.read(key: tokenKey);
    } catch (e) {
      // Secure storage can fail (e.g. Android keys reset after a backup restore): log in again.
      debugPrint('Secure storage unavailable, signing out: $e');
      _token = null;
      try {
        await _secure.delete(key: tokenKey);
      } catch (_) {}
    }
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
    _token = token;
    await _secure.write(key: tokenKey, value: token);
  }

  static String? getToken() => _token;

  static bool get isLoggedIn => (_token ?? '').isNotEmpty;

  static Future<void> deleteToken() async {
    _token = null;
    try {
      await _secure.delete(key: tokenKey);
    } catch (e) {
      debugPrint('Could not delete token: $e');
    }
  }

  /// Logout / session expired: token, profile and cached notes.
  static Future<void> clearUserData() async {
    await deleteToken();
    await _userBox.delete(userKey);
    await OfflineCache.clear();
  }
}
