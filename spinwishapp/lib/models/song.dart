class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final int duration; // in seconds
  final String artworkUrl;
  final double baseRequestPrice;
  final int popularity;
  final bool isExplicit;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.artworkUrl,
    required this.baseRequestPrice,
    required this.popularity,
    required this.isExplicit,
  });

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        genre: json['genre'],
        duration: json['duration'],
        artworkUrl: json['artworkUrl'],
        baseRequestPrice: json['baseRequestPrice'].toDouble(),
        popularity: json['popularity'],
        isExplicit: json['isExplicit'],
      );

  // Factory constructor for API response from backend
  factory Song.fromApiResponse(Map<String, dynamic> json) => Song(
        id: json['id']?.toString() ?? '',
        title: json['name'] ?? json['title'] ?? '',
        artist: json['artistName'] ?? json['artist'] ?? '',
        album: json['album'] ?? '',
        genre: json['genre'] ?? '',
        duration: json['duration'] ?? 0,
        artworkUrl: json['artworkUrl'] ?? json['artwork_url'] ?? '',
        baseRequestPrice:
            (json['baseRequestPrice'] ?? json['base_request_price'] ?? 0.0)
                .toDouble(),
        popularity: json['popularity'] ?? 0,
        isExplicit: json['isExplicit'] ?? json['is_explicit'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'genre': genre,
        'duration': duration,
        'artworkUrl': artworkUrl,
        'baseRequestPrice': baseRequestPrice,
        'popularity': popularity,
        'isExplicit': isExplicit,
      };
}
