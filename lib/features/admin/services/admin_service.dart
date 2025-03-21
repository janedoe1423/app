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

  // Get system logs
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
        source: 'System',
        details: 'User registration completed successfully',
      ),
      SystemLog(
        id: '2',
        message: 'Failed login attempt',
        severity: LogSeverity.warning,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        userId: 'user456',
        action: 'LOGIN',
        source: 'Auth Service',
        details: 'Invalid credentials provided',
      ),
    ];
  }

  // Get user approvals
  Future<List<UserApprovalRequest>> getUserApprovals() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      UserApprovalRequest(
        id: '1',
        email: 'teacher@example.com',
        displayName: 'John Doe',
        role: UserRole.teacher,
        status: ApprovalStatus.pending,
        createdAt: DateTime.now(),
      ),
    ];
  }
}