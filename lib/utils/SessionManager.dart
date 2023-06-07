import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final String _sessionIdKey = 'sessionId';
  static final String _accountIdKey = 'accountId';

  static Future<String?> getSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }

  static Future<void> setSessionId(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, sessionId);
  }

  static Future<int?> getAccountId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accountIdKey);
  }

  static Future<void> setAccountId(int accountId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accountIdKey, accountId);
  }
}

