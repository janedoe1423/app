import 'package:flutter/foundation.dart';
import '../../../core/models/user_model.dart';
import '../services/admin_service.dart';
import '../models/dashboard_stats_model.dart';
import '../models/user_approval_request.dart';
import '../models/resource_request_model.dart';
import '../models/system_log_model.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;
  
  DashboardStats _dashboardStats = DashboardStats.initial();
  List<UserModel> _users = [];
  List<UserApprovalRequest> _approvalRequests = [];
  List<ResourceRequest> _resourceRequests = [];
  List<SystemLog> _systemLogs = [];
  
  bool _isLoading = false;
  String? _error;

  AdminProvider({required AdminService authService}) : _adminService = authService;

  // Getters
  DashboardStats get dashboardStats => _dashboardStats;
  List<UserModel> get users => [..._users];
  List<UserApprovalRequest> get approvalRequests => [..._approvalRequests];
  List<ResourceRequest> get resourceRequests => [..._resourceRequests];
  List<SystemLog> get systemLogs => _systemLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods to fetch dashboard data
  Future<void> fetchDashboardStats() async {
    try {
      _isLoading = true;
      notifyListeners();

      _dashboardStats = await _adminService.getDashboardStats();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to fetch system logs
  Future<void> loadSystemLogs() async {
    try {
      _isLoading = true;
      notifyListeners();

      _systemLogs = await _adminService.getSystemLogs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // User Management Methods
  Future<void> loadUsers({UserRole? role, String? searchQuery}) async {
    _setLoading(true);
    
    try {
      final users = await _adminService.getUsers(role: role, searchQuery: searchQuery);
      _users = users;
      _setLoading(false);
    } catch (e) {
      _handleError('Failed to load users: $e');
    }
  }

  Future<void> createUser(UserModel user) async {
    _setLoading(true);
    
    try {
      final newUser = await _adminService.createUser(user);
      _users.add(newUser);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Failed to create user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    _setLoading(true);
    
    try {
      final updatedUser = await _adminService.updateUser(user);
      
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    
    try {
      await _adminService.deleteUser(userId);
      
      _users.removeWhere((user) => user.id == userId);
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Failed to delete user: $e');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _adminService.getUserById(userId);
    } catch (e) {
      _handleError('Failed to get user: $e', notify: false);
      return null;
    }
  }

  // User Approval Methods
  Future<void> loadApprovalRequests({String? status}) async {
    _setLoading(true);
    
    try {
      final requests = await _adminService.getApprovalRequests(status: status);
      _approvalRequests = requests;
      _setLoading(false);
    } catch (e) {
      _handleError('Failed to load approval requests: $e');
    }
  }

  Future<void> processUserApproval({
    required String requestId,
    required bool approved,
    String? notes,
  }) async {
    _setLoading(true);
    
    try {
      final updatedRequest = await _adminService.processUserApproval(
        requestId: requestId,
        approved: approved,
        notes: notes,
      );
      
      final index = _approvalRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _approvalRequests[index] = updatedRequest;
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Failed to process approval: $e');
    }
  }

  // Resource Management Methods
  Future<void> loadResourceRequests({ResourceRequestStatus? status}) async {
    _setLoading(true);
    
    try {
      final requests = await _adminService.getResourceRequests(status: status);
      _resourceRequests = requests;
      _setLoading(false);
    } catch (e) {
      _handleError('Failed to load resource requests: $e');
    }
  }

  Future<void> createResourceRequest(ResourceRequest request) async {
    _setLoading(true);
    
    try {
      final newRequest = await _adminService.createResourceRequest(request);
      _resourceRequests.add(newRequest);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Failed to create resource request: $e');
    }
  }

  Future<void> processResourceRequest({
    required String requestId,
    required ResourceRequestStatus newStatus,
    String? donorName,
    String? notes,
  }) async {
    _setLoading(true);
    
    try {
      final updatedRequest = await _adminService.processResourceRequest(
        requestId: requestId,
        newStatus: newStatus,
        donorName: donorName,
        notes: notes,
      );
      
      final index = _resourceRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _resourceRequests[index] = updatedRequest;
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _handleError('Failed to process resource request: $e');
    }
  }

  // Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String errorMsg, {bool notify = true}) {
    _error = errorMsg;
    _isLoading = false;
    if (notify) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}