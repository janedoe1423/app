import 'package:flutter/foundation.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  bool _isLoading = false;
  String? _error;
  
  AuthProvider({
    required AuthService authService,
  }) : _authService = authService {
    _checkCurrentUser();
  }
  
  // Getters
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  // Login with email and password
  Future<bool> login(String email, String password, {bool isAdminLogin = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email, 
        password,
        isAdminLogin: isAdminLogin,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Register a new user
  Future<bool> register(
    String email,
    String password,
    String displayName,
    UserRole role,
    {String? adminCode}
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Add your registration logic here
      // For now, just simulate a delay
      await Future.delayed(const Duration(seconds: 2));

      if (role == UserRole.admin && (adminCode != 'ADMIN123')) {
        throw Exception('Invalid admin code');
      }

      final user = await _authService.createUserWithEmailAndPassword(
        email,
        password,
        displayName,
        role,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
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
      await _authService.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Check if user is already logged in
  Future<void> _checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    }
    
    _isLoading = false;
    notifyListeners();
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
    if (_currentUser == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedUser = await _authService.updateUserProfile(
        userId: _currentUser!.id,
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
      );
      
      _currentUser = updatedUser;
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