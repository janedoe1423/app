import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final http.Client _httpClient = http.Client();
  final Uuid _uuid = const Uuid();

  // In a real app, we would use an API server for these operations
  // For now, we'll mock these operations with local storage

  AuthService();  // Empty constructor

  // Sign in with email and password
  Future<UserModel?> login(String email, String password, {bool isAdminLogin = false}) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock login logic with admin check
    if (isAdminLogin && email == 'admin@example.com' && password == 'admin123') {
      return UserModel(
        id: '3',
        email: email,
        displayName: 'Admin User',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (email == 'student@example.com' && password == 'password123') {
      return UserModel(
        id: '1',
        email: email,
        displayName: 'Student User',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (email == 'teacher@example.com' && password == 'password123') {
      return UserModel(
        id: '2',
        email: email,
        displayName: 'Teacher User',
        role: UserRole.teacher,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    throw Exception('Invalid credentials');
  }

  // Create a new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock registration
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Sign out
  Future<void> logout() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final now = DateTime.now();
      
      return UserModel(
        id: userId,
        email: 'mock@email.com',
        displayName: displayName ?? 'Mock User',
        role: UserRole.student,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Get current user
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Check current password
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '{}';
      final users = jsonDecode(usersJson) as Map<String, dynamic>;

      if (!users.containsKey(currentUser.email)) {
        throw Exception('User not found');
      }

      final userJson = jsonDecode(users[currentUser.email]) as Map<String, dynamic>;
      if (userJson['password'] != currentPassword) {
        throw Exception('Invalid current password');
      }

      // Update password
      userJson['password'] = newPassword;
      users[currentUser.email] = jsonEncode(userJson);
      await prefs.setString('users', jsonEncode(users));
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Get authentication token
  Future<String?> getToken() async {
    return _secureStorage.read(key: AppConstants.userTokenKey);
  }

  // Check if token is valid
  Future<bool> isTokenValid() async {
    final token = await getToken();
    return token != null;
  }
}