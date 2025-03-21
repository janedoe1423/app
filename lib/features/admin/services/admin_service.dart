import '../models/dashboard_stats_model.dart';
import '../models/system_log_model.dart';
import '../models/user_approval_request.dart';
import '../../../core/models/user_model.dart';

class AdminService {
  AdminService();

  // Get dashboard stats
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(seconds: 1));
    return DashboardStats(
      totalUsers: 150,
      activeUsers: 120,
      pendingApprovals: 5,
      totalResources: 300,
      totalCourses: 25,
      userTypeDistribution: {
        'Students': 100,
        'Teachers': 30,
        'Parents': 15,
        'Admins': 5,
      },
    );
  }

  // User Management
  Future<List<UserModel>> getUsers({UserRole? role, String? searchQuery}) async {
    await Future.delayed(const Duration(seconds: 1));
    return []; // Mock data
  }

  Future<UserModel> createUser(UserModel user) async {
    await Future.delayed(const Duration(seconds: 1));
    return user; // Mock data
  }

  Future<UserModel> updateUser(UserModel user) async {
    await Future.delayed(const Duration(seconds: 1));
    return user; // Mock data
  }

  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<UserModel?> getUserById(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return null; // Mock data
  }

  // Approval Requests
  Future<List<UserApprovalRequest>> getApprovalRequests({ApprovalStatus? status}) async {
    await Future.delayed(const Duration(seconds: 1));
    return []; // Mock data
  }

  Future<UserApprovalRequest> processUserApproval(
    String requestId,
    bool isApproved,
    {String? notes}
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return UserApprovalRequest(
      id: requestId,
      email: 'test@example.com',
      displayName: 'Test User',
      role: UserRole.teacher,
      status: isApproved ? ApprovalStatus.approved : ApprovalStatus.rejected,
      createdAt: now,
      requestDate: now,
      notes: notes,
    );
  }

  // Resource Requests
  Future<List<dynamic>> getResourceRequests({String? status}) async {
    await Future.delayed(const Duration(seconds: 1));
    return []; // Mock data
  }

  Future<dynamic> createResourceRequest(dynamic request) async {
    await Future.delayed(const Duration(seconds: 1));
    return request; // Mock data
  }

  Future<dynamic> processResourceRequest(
    String requestId,
    bool isApproved,
    {String? notes}
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return null; // Mock data
  }

  // System Logs
  Future<List<SystemLog>> getSystemLogs() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      SystemLog(
        id: '1',
        message: 'New user registered',
        severity: LogSeverity.info,
        timestamp: DateTime.now(),
        userId: 'user123',
        action: 'REGISTER',
      ),
    ];
  }
}