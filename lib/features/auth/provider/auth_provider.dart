import 'package:flutter/foundation.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  error
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  UserModel? _user;
  AuthStatus _status = AuthStatus.initial;
  bool _isLoading = false;
  String? _error;
  
  AuthProvider({
    required AuthService authService,
  }) : _authService = authService {
    _checkAuthStatus();
  }
  
  // Getters
  UserModel? get currentUser => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  // Login with email and password
  Future<bool> login(String email, String password, {bool isAdminLogin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = await _authService.login(email, password, isAdminLogin: isAdminLogin);
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      
      _user = user;
      _status = AuthStatus.authenticated;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    if (_user == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedUser = await _authService.updateUserProfile(
        userId: _user!.id,
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
      );
      
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}