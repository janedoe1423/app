import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AdminInitializer {
  static const String adminEmail = 'admin@educationguide.com';
  static const String adminPassword = 'admin123';
  static const String adminDisplayName = 'System Administrator';

  /// Initialize admin account if it doesn't exist
  static Future<void> ensureAdminExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '{}';
      final users = jsonDecode(usersJson) as Map<String, dynamic>;

      // Check if admin already exists
      if (users.containsKey(adminEmail)) {
        print('Admin account already exists');
        return;
      }

      // Create admin user
      final now = DateTime.now();
      final adminUser = UserModel(
        id: 'admin-user-id',
        email: adminEmail,
        displayName: adminDisplayName,
        role: UserRole.admin,
        fullName: 'System Administrator',
        createdAt: now,
        updatedAt: now,
      );

      // Store admin with password
      final adminWithPassword = {
        ...adminUser.toJson(),
        'password': adminPassword,
      };

      // Add admin to users
      users[adminEmail] = jsonEncode(adminWithPassword);
      await prefs.setString('users', jsonEncode(users));

      print('Admin account created successfully');
    } catch (e) {
      print('Error ensuring admin exists: $e');
    }
  }

  /// Get admin credentials for display
  static Map<String, String> getAdminCredentials() {
    return {
      'email': adminEmail,
      'password': adminPassword,
    };
  }
}