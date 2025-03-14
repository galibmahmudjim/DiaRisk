import 'package:shared_preferences/shared_preferences.dart';

class sharedPref {
  static var prefs;

  static init() async {
    var prefs1 = await SharedPreferences.getInstance();
    prefs = prefs1;
  }

  static setID(String id) async {
    if (prefs == null) await init();
    await prefs.setString("_id", id);
  }

  static Future<String?> getID() async {
    if (prefs == null) await init();
    return await prefs.getString("_id");
  }

  static setEmail(String email) async {
    if (prefs == null) await init();
    await prefs.setString("Email", email);
  }

  static Future<String?> getEmail() async {
    if (prefs == null) await init();
    return await prefs.getString("Email");
  }

  static setName(String name) async {
    if (prefs == null) await init();
    await prefs.setString("Name", name);
  }

  static Future<String?> getName() async {
    if (prefs == null) await init();
    return await prefs.getString("Name");
  }

  static setToken(String token) async {
    if (prefs == null) await init();
    await prefs.setString("Token", token);
  }

  static Future<String?> getToken() async {
    if (prefs == null) await init();
    return await prefs.getString("Token");
  }

  static clear() async {
    if (prefs == null) await init();
    await prefs.clear();
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('Token');
  }
}
