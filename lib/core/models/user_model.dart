import 'dart:convert';

enum UserRole {
  student,
  teacher,
  admin,
  parent,
}

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final String? fullName;
  final String? schoolId;
  final List<String>? classIds;
  final String? grade;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;
  final String? profileImage;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.fullName,
    this.schoolId,
    this.classIds,
    this.grade,
    this.lastLogin,
    this.preferences,
    this.profileImage,
    this.metadata,
  });

  // Getters for role-based checks
  bool get isStudent => role == UserRole.student;
  bool get isTeacher => role == UserRole.teacher;
  bool get isAdmin => role == UserRole.admin;
  bool get isParent => role == UserRole.parent;

  // User display properties

  // Get user initials for avatar
  String get initials {
    final nameParts = displayName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fullName': fullName,
      'role': role.toString(),
      'schoolId': schoolId,
      'classIds': classIds,
      'grade': grade,
      'lastLogin': lastLogin?.toIso8601String(),
      'preferences': preferences,
      'profileImage': profileImage,
      'metadata': metadata,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: _parseUserRole(json['role'] as String),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      fullName: json['fullName'] as String?,
      schoolId: json['schoolId'] as String?,
      classIds: json['classIds'] != null
          ? List<String>.from(json['classIds'] as List)
          : null,
      grade: json['grade'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
      profileImage: json['profileImage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static UserRole _parseUserRole(String roleStr) {
    switch (roleStr.split('.').last) {
      case 'student':
        return UserRole.student;
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      case 'parent':
        return UserRole.parent;
      default:
        return UserRole.student;
    }
  }

  // Convert user data to JSON string for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create a UserModel from stored JSON string
  static UserModel? fromJsonString(String jsonString) {
    try {
      return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  // Create a copy of this user with updated fields
  UserModel copyWith({
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? fullName,
    String? schoolId,
    List<String>? classIds,
    String? grade,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
    String? profileImage,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      fullName: fullName ?? this.fullName,
      schoolId: schoolId ?? this.schoolId,
      classIds: classIds ?? this.classIds,
      grade: grade ?? this.grade,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
      profileImage: profileImage ?? this.profileImage,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImage': profileImage,
      'metadata': metadata,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == map['role'],
        orElse: () => UserRole.student,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      profileImage: map['profileImage'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}