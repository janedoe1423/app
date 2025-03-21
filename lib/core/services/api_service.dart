import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'auth_service.dart';

class ApiService {
  final http.Client _httpClient = http.Client();
  final AuthService _authService;
  
  ApiService({required AuthService authService}) : _authService = authService;
  
  // Base headers for all requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Helper for GET requests
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse('${AppConstants.baseUrl}/$endpoint'),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }
  
  // Helper for POST requests
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('${AppConstants.baseUrl}/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }
  
  // Helper for PUT requests
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.put(
        Uri.parse('${AppConstants.baseUrl}/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform PUT request: $e');
    }
  }
  
  // Helper for DELETE requests
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.delete(
        Uri.parse('${AppConstants.baseUrl}/$endpoint'),
        headers: headers,
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform DELETE request: $e');
    }
  }
  
  // Handle the HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception(AppConstants.authErrorMessage);
    } else if (response.statusCode == 403) {
      throw Exception(AppConstants.permissionErrorMessage);
    } else if (response.statusCode == 404) {
      throw Exception(AppConstants.resourceNotFoundMessage);
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
  
  // Clean up resources
  void dispose() {
    _httpClient.close();
  }
}