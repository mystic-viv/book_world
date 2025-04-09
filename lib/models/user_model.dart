class UserModel {
  final String id; // UUID
  final String customId; // Auto-generated by trigger (e.g., USR-001)
  final String email;
  final String username;
  final String name;
  final String? mobile;
  final DateTime? dateOfBirth;
  final String? localAddress;
  final String? permanentAddress;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.customId,
    required this.email,
    required this.username,
    required this.name,
    this.mobile,
    this.dateOfBirth,
    this.localAddress,
    this.permanentAddress,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from JSON (from Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      customId: json['custom_id'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      mobile: json['mobile'],
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
      localAddress: json['local_address'],
      permanentAddress: json['permanent_address'],
      profilePictureUrl: json['profile_picture_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  // Convert to JSON (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'custom_id': customId,
      'email': email,
      'username': username,
      'name': name,
      'mobile': mobile,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'local_address': localAddress,
      'permanent_address': permanentAddress,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? customId,
    String? email,
    String? username,
    String? name,
    String? mobile,
    DateTime? dateOfBirth,
    String? localAddress,
    String? permanentAddress,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      customId: customId ?? this.customId,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      localAddress: localAddress ?? this.localAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get formatted date of birth
  String? get formattedDateOfBirth {
    if (dateOfBirth == null) return null;
    return '${dateOfBirth!.year}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.day.toString().padLeft(2, '0')}';
  }

  // Helper method to get user's display name (username or name)
  String get displayName => name.isNotEmpty ? name : username;
}
