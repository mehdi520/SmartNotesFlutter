import 'package:flutter/material.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';
import 'package:note_book/infra/core/configs/routes/app_routes.dart';
import 'package:note_book/infra/network/api_error.dart';
import 'package:note_book/infra/utils/toast_utils.dart';

/// App-wide session handling: logout and "session expired" (HTTP 401).
class SessionManager {
  SessionManager._();

  /// Given to MaterialApp so we can navigate from outside the widget tree (e.g. an interceptor).
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static bool _expiring = false;

  /// Clears the session and returns to the login screen.
  static Future<void> logout() async {
    await HiveManager.clearUserData();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.loginRoute, (_) => false);
  }

  /// Called when the server rejects our token. Several requests can fail at once,
  /// so only the first one logs out and shows the message.
  static Future<void> sessionExpired() async {
    if (_expiring || !HiveManager.isLoggedIn) return;
    _expiring = true;
    try {
      ToastUtils.showError(ApiError.sessionExpired);
      await logout();
    } finally {
      _expiring = false;
    }
  }
}
