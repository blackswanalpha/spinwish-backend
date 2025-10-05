import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveUserPreferences(List<String> favoriteGenres, List<String> favoriteDJs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_genres', favoriteGenres);
    await prefs.setStringList('favorite_djs', favoriteDJs);
  }

  static Future<Map<String, List<String>>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'favorite_genres': prefs.getStringList('favorite_genres') ?? [],
      'favorite_djs': prefs.getStringList('favorite_djs') ?? [],
    };
  }

  static Future<void> saveUserCredits(double credits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_credits', credits);
  }

  static Future<double> getUserCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('user_credits') ?? 0.0;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}