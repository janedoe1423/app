import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Store non-sensitive data
  Future<bool> setData(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      debugPrint('Error storing data: $e');
      return false;
    }
  }
  
  // Retrieve non-sensitive data
  Future<String?> getData(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      debugPrint('Error retrieving data: $e');
      return null;
    }
  }
  
  // Delete non-sensitive data
  Future<bool> deleteData(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      debugPrint('Error deleting data: $e');
      return false;
    }
  }
  
  // Store sensitive data securely
  Future<void> setSecureData(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error storing secure data: $e');
    }
  }
  
  // Retrieve sensitive data
  Future<String?> getSecureData(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Error retrieving secure data: $e');
      return null;
    }
  }
  
  // Delete sensitive data
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting secure data: $e');
    }
  }
  
  // Store boolean value
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error storing boolean: $e');
      return false;
    }
  }
  
  // Retrieve boolean value
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      debugPrint('Error retrieving boolean: $e');
      return null;
    }
  }
  
  // Store integer value
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      debugPrint('Error storing integer: $e');
      return false;
    }
  }
  
  // Retrieve integer value
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      debugPrint('Error retrieving integer: $e');
      return null;
    }
  }
  
  // Store list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      debugPrint('Error storing string list: $e');
      return false;
    }
  }
  
  // Retrieve list of strings
  Future<List<String>?> getStringList(String key) async {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      debugPrint('Error retrieving string list: $e');
      return null;
    }
  }
  
  // Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      debugPrint('Error checking key existence: $e');
      return false;
    }
  }
  
  // Clear all stored data (excluding secure storage)
  Future<bool> clearAll() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return false;
    }
  }
  
  // Clear all secure stored data
  Future<void> clearAllSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing all secure data: $e');
    }
  }
}
