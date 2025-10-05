class Club {
  final String id;
  final String name;
  final String location;
  final String address;
  final String description;
  final String imageUrl;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final int? capacity;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final String? activeSessionId; // For compatibility with existing code

  Club({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.description,
    required this.imageUrl,
    this.phoneNumber,
    this.email,
    this.website,
    this.capacity,
    this.isActive = true,
    this.latitude,
    this.longitude,
    this.activeSessionId,
  });

  // Legacy constructor for backward compatibility
  factory Club.fromJson(Map<String, dynamic> json) => Club(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        location: json['location'] ?? '',
        address: json['address'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['image'] ?? json['imageUrl'] ?? '',
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        website: json['website'],
        capacity: json['capacity'],
        isActive: json['isActive'] ?? true,
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        activeSessionId: json['activeSessionId'],
      );

  // Factory constructor for API response from backend
  factory Club.fromApiResponse(Map<String, dynamic> json) => Club(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        location: json['location'] ?? '',
        address: json['address'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        website: json['website'],
        capacity: json['capacity'],
        isActive: json['isActive'] ?? true,
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'address': address,
        'description': description,
        'imageUrl': imageUrl,
        'phoneNumber': phoneNumber,
        'email': email,
        'website': website,
        'capacity': capacity,
        'isActive': isActive,
        'latitude': latitude,
        'longitude': longitude,
      };

  // Legacy getter for backward compatibility
  String get image => imageUrl;
  List<String> get amenities =>
      []; // Return empty list for backward compatibility
}
