import 'dart:convert';
import 'package:spinwishapp/models/song.dart';
import 'package:spinwishapp/services/api_service.dart';

class SongApiService {
  // Get all songs
  static Future<List<Song>> getAllSongs() async {
    try {
      final response = await ApiService.get('/songs', includeAuth: true);
      final data = ApiService.handleResponse(response);

      if (data is List) {
        return data
            .map((songData) =>
                Song.fromApiResponse(songData as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw ApiException('Failed to fetch songs: ${e.toString()}');
    }
  }

  // Get song by ID
  static Future<Song?> getSongById(String songId) async {
    try {
      final response =
          await ApiService.get('/songs/$songId', includeAuth: true);
      final data = ApiService.handleResponse(response);
      if (data is Map<String, dynamic>) {
        return Song.fromApiResponse(data);
      }
      throw ApiException(
          'Invalid response format: Expected object, got ${data.runtimeType}');
    } catch (e) {
      if (e.toString().contains('404')) {
        return null;
      }
      throw ApiException('Failed to fetch song: ${e.toString()}');
    }
  }

  // Search songs by title, artist, or genre
  static Future<List<Song>> searchSongs(String query) async {
    try {
      // Since the backend doesn't have a search endpoint, we'll get all songs and filter locally
      // This should be replaced with a proper search endpoint in the backend
      final allSongs = await getAllSongs();

      if (query.isEmpty) return allSongs;

      final lowerQuery = query.toLowerCase();
      return allSongs
          .where((song) =>
              song.title.toLowerCase().contains(lowerQuery) ||
              song.artist.toLowerCase().contains(lowerQuery) ||
              song.genre.toLowerCase().contains(lowerQuery) ||
              song.album.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw ApiException('Failed to search songs: ${e.toString()}');
    }
  }

  // Filter songs by genre
  static Future<List<Song>> getSongsByGenre(String genre) async {
    try {
      final allSongs = await getAllSongs();
      return allSongs.where((song) => song.genre == genre).toList();
    } catch (e) {
      throw ApiException('Failed to fetch songs by genre: ${e.toString()}');
    }
  }

  // Get popular songs (sorted by popularity)
  static Future<List<Song>> getPopularSongs({int limit = 20}) async {
    try {
      final allSongs = await getAllSongs();
      allSongs.sort((a, b) => b.popularity.compareTo(a.popularity));
      return allSongs.take(limit).toList();
    } catch (e) {
      throw ApiException('Failed to fetch popular songs: ${e.toString()}');
    }
  }

  // Get songs sorted by price (low to high)
  static Future<List<Song>> getSongsByPriceLowToHigh() async {
    try {
      final allSongs = await getAllSongs();
      allSongs.sort((a, b) => a.baseRequestPrice.compareTo(b.baseRequestPrice));
      return allSongs;
    } catch (e) {
      throw ApiException('Failed to fetch songs by price: ${e.toString()}');
    }
  }

  // Get songs sorted by price (high to low)
  static Future<List<Song>> getSongsByPriceHighToLow() async {
    try {
      final allSongs = await getAllSongs();
      allSongs.sort((a, b) => b.baseRequestPrice.compareTo(a.baseRequestPrice));
      return allSongs;
    } catch (e) {
      throw ApiException('Failed to fetch songs by price: ${e.toString()}');
    }
  }

  // Get songs sorted alphabetically
  static Future<List<Song>> getSongsAlphabetically() async {
    try {
      final allSongs = await getAllSongs();
      allSongs.sort((a, b) => a.title.compareTo(b.title));
      return allSongs;
    } catch (e) {
      throw ApiException(
          'Failed to fetch songs alphabetically: ${e.toString()}');
    }
  }

  // Get songs sorted by duration
  static Future<List<Song>> getSongsByDuration() async {
    try {
      final allSongs = await getAllSongs();
      allSongs.sort((a, b) => a.duration.compareTo(b.duration));
      return allSongs;
    } catch (e) {
      throw ApiException('Failed to fetch songs by duration: ${e.toString()}');
    }
  }

  // Get available genres
  static Future<List<String>> getAvailableGenres() async {
    try {
      final allSongs = await getAllSongs();
      final genres = allSongs.map((song) => song.genre).toSet().toList();
      genres.sort();
      return genres;
    } catch (e) {
      throw ApiException('Failed to fetch genres: ${e.toString()}');
    }
  }

  // Create a new song (for admin/DJ use)
  static Future<Song> createSong(Map<String, dynamic> songData) async {
    try {
      final response = await ApiService.postJson('/songs', songData);
      return Song.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to create song: ${e.toString()}');
    }
  }

  // Update a song (for admin/DJ use)
  static Future<Song> updateSong(
      String songId, Map<String, dynamic> songData) async {
    try {
      final response = await ApiService.put('/songs/$songId', songData);
      return Song.fromApiResponse(response);
    } catch (e) {
      throw ApiException('Failed to update song: ${e.toString()}');
    }
  }

  // Delete a song (for admin use)
  static Future<void> deleteSong(String songId) async {
    try {
      await ApiService.delete('/songs/$songId');
    } catch (e) {
      throw ApiException('Failed to delete song: ${e.toString()}');
    }
  }

  // Get filtered and sorted songs (comprehensive method)
  static Future<List<Song>> getFilteredAndSortedSongs({
    String? searchQuery,
    String? genre,
    String sortBy =
        'Popularity', // 'Popularity', 'Price: Low to High', 'Price: High to Low', 'A-Z', 'Duration'
  }) async {
    try {
      List<Song> songs = await getAllSongs();

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        songs = songs
            .where((song) =>
                song.title.toLowerCase().contains(lowerQuery) ||
                song.artist.toLowerCase().contains(lowerQuery) ||
                song.genre.toLowerCase().contains(lowerQuery) ||
                song.album.toLowerCase().contains(lowerQuery))
            .toList();
      }

      // Apply genre filter
      if (genre != null && genre != 'All') {
        songs = songs.where((song) => song.genre == genre).toList();
      }

      // Apply sorting
      switch (sortBy) {
        case 'Price: Low to High':
          songs
              .sort((a, b) => a.baseRequestPrice.compareTo(b.baseRequestPrice));
          break;
        case 'Price: High to Low':
          songs
              .sort((a, b) => b.baseRequestPrice.compareTo(a.baseRequestPrice));
          break;
        case 'A-Z':
          songs.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'Duration':
          songs.sort((a, b) => a.duration.compareTo(b.duration));
          break;
        case 'Popularity':
        default:
          songs.sort((a, b) => b.popularity.compareTo(a.popularity));
          break;
      }

      return songs;
    } catch (e) {
      throw ApiException('Failed to fetch filtered songs: ${e.toString()}');
    }
  }
}
