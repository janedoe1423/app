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
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
    {bool isAdminLogin = false}
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();

    if (isAdminLogin) {
      if (email == "admin@educationguide.com" && password == "admin123") {
        return UserModel(
          id: 'admin_id',
          email: email,
          displayName: 'Admin User',
          role: UserRole.admin,
          createdAt: now,
          updatedAt: now,
        );
      }
      throw Exception('Invalid admin credentials');
    }

    // Mock user login
    return UserModel(
      id: 'user_id',
      email: email,
      displayName: 'Test User',
      role: UserRole.student,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create a new user
  Future<UserModel> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    UserRole role,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final now = DateTime.now();
      
      // Return mock user
      return UserModel(
        id: 'mock_id',
        email: email,
        displayName: displayName,
        role: role,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(key: AppConstants.userTokenKey);

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);

      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return null;
    } catch (e) {
      return null;
    }
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