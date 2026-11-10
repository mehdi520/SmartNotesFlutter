import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A cached API response and when it was saved.
class CachedJson {
  final Map<String, dynamic> json;
  final DateTime savedAt;
  const CachedJson(this.json, this.savedAt);
}

/// Last successful responses of list screens (notebooks, notes), so the app can
/// show them when there is no internet. Cleared on logout.
class OfflineCache {
  OfflineCache._();

  static const String boxName = 'offline_cache';
  static Box<String>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(boxName);
  }

  static Future<void> save(String key, Map<String, dynamic> json) async {
    final box = _box;
    if (box == null) return;
    try {
      await box.put(key, jsonEncode({'savedAt': DateTime.now().toIso8601String(), 'json': json}));
    } catch (e) {
      debugPrint('OfflineCache.save($key) failed: $e');
    }
  }

  static CachedJson? read(String key) {
    final raw = _box?.get(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CachedJson(
        map['json'] as Map<String, dynamic>,
        DateTime.tryParse(map['savedAt'] as String? ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('OfflineCache.read($key) failed: $e');
      return null;
    }
  }

  static Future<void> clear() async => _box?.clear();
}
