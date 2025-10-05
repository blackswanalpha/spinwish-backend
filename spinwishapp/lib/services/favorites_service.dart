import 'dart:convert';
import 'package:spinwishapp/models/dj.dart';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/services/api_service.dart';

enum FavoriteType { dj, song, genre, artist }

class FavoriteItem {
  final String id;
  final FavoriteType favoriteType;
  final String favoriteId;
  final String favoriteName;
  final DateTime createdAt;

  FavoriteItem({
    required this.id,
    required this.favoriteType,
    required this.favoriteId,
    required this.favoriteName,
    required this.createdAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      favoriteType: FavoriteType.values.firstWhere(
        (e) => e.toString().split('.').last == json['favoriteType'],
      ),
      favoriteId: json['favoriteId'],
      favoriteName: json['favoriteName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favoriteType': favoriteType.toString().split('.').last,
      'favoriteId': favoriteId,
      'favoriteName': favoriteName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AddFavoriteRequest {
  final FavoriteType favoriteType;
  final String favoriteId;
  final String? favoriteName;

  AddFavoriteRequest({
    required this.favoriteType,
    required this.favoriteId,
    this.favoriteName,
  });

  Map<String, dynamic> toJson() {
    return {
      'favoriteType': favoriteType.toString().split('.').last,
      'favoriteId': favoriteId,
      'favoriteName': favoriteName,
    };
  }
}

class FavoritesService {
  static const String _baseEndpoint = '/favorites';

  /// Add item to favorites
  static Future<FavoriteItem> addFavorite(AddFavoriteRequest request) async {
    try {
      final response = await ApiService.postJson(
        _baseEndpoint,
        request.toJson(),
        includeAuth: true,
      );
      return FavoriteItem.fromJson(response);
    } catch (e) {
      throw ApiException('Failed to add favorite: ${e.toString()}');
    }
  }

  /// Remove item from favorites
  static Future<void> removeFavorite(
      FavoriteType favoriteType, String favoriteId) async {
    try {
      await ApiService.delete(
        '$_baseEndpoint/${favoriteType.toString().split('.').last}/$favoriteId',
        includeAuth: true,
      );
    } catch (e) {
      throw ApiException('Failed to remove favorite: ${e.toString()}');
    }
  }

  /// Get all user favorites
  static Future<List<FavoriteItem>> getAllFavorites() async {
    try {
      final response =
          await ApiService.getJson(_baseEndpoint, includeAuth: true);
      if (response['data'] is List) {
        final List<dynamic> data = response['data'];
        return data
            .map((item) => FavoriteItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch favorites: ${e.toString()}');
    }
  }

  /// Get favorites by type
  static Future<List<FavoriteItem>> getFavoritesByType(
      FavoriteType favoriteType) async {
    try {
      final response = await ApiService.getJson(
        '$_baseEndpoint/${favoriteType.toString().split('.').last}',
        includeAuth: true,
      );
      if (response['data'] is List) {
        final List<dynamic> data = response['data'];
        return data
            .map((item) => FavoriteItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch favorites by type: ${e.toString()}');
    }
  }

  /// Check if item is favorite
  static Future<bool> isFavorite(
      FavoriteType favoriteType, String favoriteId) async {
    try {
      final response = await ApiService.getJson(
        '$_baseEndpoint/check/${favoriteType.toString().split('.').last}/$favoriteId',
        includeAuth: true,
      );
      return response as bool? ?? false;
    } catch (e) {
      // If there's an error, assume it's not a favorite
      return false;
    }
  }

  /// Get favorite IDs by type
  static Future<List<String>> getFavoriteIds(FavoriteType favoriteType) async {
    try {
      final response = await ApiService.getJson(
        '$_baseEndpoint/ids/${favoriteType.toString().split('.').last}',
        includeAuth: true,
      );
      if (response['data'] is List) {
        final List<dynamic> data = response['data'];
        return data.map((id) => id.toString()).toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch favorite IDs: ${e.toString()}');
    }
  }

  /// Add DJ to favorites
  static Future<FavoriteItem> addFavoriteDJ(DJ dj) async {
    return addFavorite(AddFavoriteRequest(
      favoriteType: FavoriteType.dj,
      favoriteId: dj.id,
      favoriteName: dj.name,
    ));
  }

  /// Remove DJ from favorites
  static Future<void> removeFavoriteDJ(String djId) async {
    return removeFavorite(FavoriteType.dj, djId);
  }

  /// Add song to favorites
  static Future<FavoriteItem> addFavoriteSong(Song song) async {
    return addFavorite(AddFavoriteRequest(
      favoriteType: FavoriteType.song,
      favoriteId: song.id,
      favoriteName: '${song.title} - ${song.artist}',
    ));
  }

  /// Remove song from favorites
  static Future<void> removeFavoriteSong(String songId) async {
    return removeFavorite(FavoriteType.song, songId);
  }

  /// Add genre to favorites
  static Future<FavoriteItem> addFavoriteGenre(String genre) async {
    return addFavorite(AddFavoriteRequest(
      favoriteType: FavoriteType.genre,
      favoriteId: genre.toLowerCase().replaceAll(' ', '_'),
      favoriteName: genre,
    ));
  }

  /// Remove genre from favorites
  static Future<void> removeFavoriteGenre(String genre) async {
    return removeFavorite(
        FavoriteType.genre, genre.toLowerCase().replaceAll(' ', '_'));
  }

  /// Get favorite DJs
  static Future<List<FavoriteItem>> getFavoriteDJs() async {
    return getFavoritesByType(FavoriteType.dj);
  }

  /// Get favorite songs
  static Future<List<FavoriteItem>> getFavoriteSongs() async {
    return getFavoritesByType(FavoriteType.song);
  }

  /// Get favorite genres
  static Future<List<FavoriteItem>> getFavoriteGenres() async {
    return getFavoritesByType(FavoriteType.genre);
  }

  /// Check if DJ is favorite
  static Future<bool> isDJFavorite(String djId) async {
    return isFavorite(FavoriteType.dj, djId);
  }

  /// Check if song is favorite
  static Future<bool> isSongFavorite(String songId) async {
    return isFavorite(FavoriteType.song, songId);
  }

  /// Check if genre is favorite
  static Future<bool> isGenreFavorite(String genre) async {
    return isFavorite(
        FavoriteType.genre, genre.toLowerCase().replaceAll(' ', '_'));
  }

  /// Get favorite DJ IDs
  static Future<List<String>> getFavoriteDJIds() async {
    return getFavoriteIds(FavoriteType.dj);
  }

  /// Get favorite song IDs
  static Future<List<String>> getFavoriteSongIds() async {
    return getFavoriteIds(FavoriteType.song);
  }

  /// Get favorite genre names
  static Future<List<String>> getFavoriteGenreNames() async {
    final favorites = await getFavoriteGenres();
    return favorites.map((f) => f.favoriteName).toList();
  }

  /// Toggle favorite status for DJ
  static Future<bool> toggleDJFavorite(DJ dj) async {
    final isFav = await isDJFavorite(dj.id);
    if (isFav) {
      await removeFavoriteDJ(dj.id);
      return false;
    } else {
      await addFavoriteDJ(dj);
      return true;
    }
  }

  /// Toggle favorite status for song
  static Future<bool> toggleSongFavorite(Song song) async {
    final isFav = await isSongFavorite(song.id);
    if (isFav) {
      await removeFavoriteSong(song.id);
      return false;
    } else {
      await addFavoriteSong(song);
      return true;
    }
  }

  /// Toggle favorite status for genre
  static Future<bool> toggleGenreFavorite(String genre) async {
    final isFav = await isGenreFavorite(genre);
    if (isFav) {
      await removeFavoriteGenre(genre);
      return false;
    } else {
      await addFavoriteGenre(genre);
      return true;
    }
  }
}
