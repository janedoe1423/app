class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int pendingApprovals;
  final int totalResources;
  final int totalCourses;
  final Map<String, int> userTypeDistribution;

  DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.pendingApprovals,
    required this.totalResources,
    required this.totalCourses,
    required this.userTypeDistribution,
  });

  factory DashboardStats.initial() {
    return DashboardStats(
      totalUsers: 0,
      activeUsers: 0,
      pendingApprovals: 0,
      totalResources: 0,
      totalCourses: 0,
      userTypeDistribution: {},
    );
  }

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      pendingApprovals: json['pendingApprovals'] ?? 0,
      totalResources: json['totalResources'] ?? 0,
      totalCourses: json['totalCourses'] ?? 0,
      userTypeDistribution: Map.from(json['userTypeDistribution'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'pendingApprovals': pendingApprovals,
      'totalResources': totalResources,
      'totalCourses': totalCourses,
      'userTypeDistribution': userTypeDistribution,
    };
  }
}