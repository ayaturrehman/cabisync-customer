class User {
  final int id;
  final String name;
  final String? phone; // Made optional for email-based auth
  final String email; // Made required for email-based auth
  final String? profilePicture;
  final double? rating;
  final int? totalRides;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    this.phone, // Now optional
    required this.email, // Now required
    this.profilePicture,
    this.rating,
    this.totalRides,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String? ?? '', // Provide default if null
      profilePicture: json['profile_picture'] as String?,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalRides: json['total_rides'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profile_picture': profilePicture,
      'rating': rating,
      'total_rides': totalRides,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? profilePicture,
    double? rating,
    int? totalRides,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
