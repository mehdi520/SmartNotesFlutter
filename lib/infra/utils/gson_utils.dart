import 'dart:convert';

class GsonUtils {
  /// Convert a model object to JSON string
  static String toJson(dynamic model) {
    try {
      return jsonEncode(model);
    } catch (e) {
      throw Exception('Error converting model to JSON: $e');
    }
  }

  /// Convert JSON string to model object
  static T fromJson<T>(String jsonString, T Function(Map<String, dynamic>) fromJson) {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return fromJson(jsonMap);
    } catch (e) {
      throw Exception('Error converting JSON to model: $e');
    }
  }

  /// Convert a list of model objects to JSON string
  static String listToJson<T>(List<T> models, String Function(T) toJson) {
    try {
      final List<String> jsonList = models.map((model) => toJson(model)).toList();
      return jsonEncode(jsonList);
    } catch (e) {
      throw Exception('Error converting list to JSON: $e');
    }
  }

  /// Convert JSON string to list of model objects
  static List<T> listFromJson<T>(String jsonString, T Function(Map<String, dynamic>) fromJson) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error converting JSON to list: $e');
    }
  }

  /// Convert a model object to Map<String, dynamic>
  static Map<String, dynamic> toMap(dynamic model) {
    try {
      return jsonDecode(jsonEncode(model));
    } catch (e) {
      throw Exception('Error converting model to map: $e');
    }
  }

  /// Convert Map<String, dynamic> to model object
  static T fromMap<T>(Map<String, dynamic> map, T Function(Map<String, dynamic>) fromJson) {
    try {
      return fromJson(map);
    } catch (e) {
      throw Exception('Error converting map to model: $e');
    }
  }

  /// Convert a list of model objects to List<Map<String, dynamic>>
  static List<Map<String, dynamic>> listToMap<T>(List<T> models) {
    try {
      return models.map((model) => toMap(model)).toList();
    } catch (e) {
      throw Exception('Error converting list to map: $e');
    }
  }

  /// Convert List<Map<String, dynamic>> to list of model objects
  static List<T> listFromMap<T>(List<Map<String, dynamic>> maps, T Function(Map<String, dynamic>) fromJson) {
    try {
      return maps.map((map) => fromMap(map, fromJson)).toList();
    } catch (e) {
      throw Exception('Error converting map list to model list: $e');
    }
  }
} 