import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/services/dj_api_service.dart';

class DJService {
  // Get all DJs
  static Future<List<DJ>> getAllDJs() async {
    return await DJApiService.getAllDJs();
  }

  // Get DJ by ID
  static Future<DJ?> getDJById(String id) async {
    return await DJApiService.getDJById(id);
  }

  // Search DJs
  static Future<List<DJ>> searchDJs(String query) async {
    return await DJApiService.searchDJsByName(query);
  }

  // Get DJs by genre
  static Future<List<DJ>> getDJsByGenre(String genre) async {
    return await DJApiService.getDJsByGenre(genre);
  }

  // Get current DJ profile
  static Future<DJ?> getCurrentDJProfile() async {
    return await DJApiService.getCurrentDJProfile();
  }
}
