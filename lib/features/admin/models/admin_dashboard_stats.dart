class AdminDashboardStats {
  final int totalStudents;
  final int totalTeachers;
  final int pendingApprovals;
  final int activeQuizzes;
  final int pendingQuizApprovals;
  final int totalResources;
  final int resourceRequests;
  final double systemUsage; // Percentage
  final Map<String, dynamic>? additionalMetrics;

  AdminDashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.pendingApprovals,
    required this.activeQuizzes,
    required this.pendingQuizApprovals,
    required this.totalResources,
    required this.resourceRequests,
    required this.systemUsage,
    this.additionalMetrics,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalStudents: json['totalStudents'] as int,
      totalTeachers: json['totalTeachers'] as int,
      pendingApprovals: json['pendingApprovals'] as int,
      activeQuizzes: json['activeQuizzes'] as int,
      pendingQuizApprovals: json['pendingQuizApprovals'] as int,
      totalResources: json['totalResources'] as int,
      resourceRequests: json['resourceRequests'] as int,
      systemUsage: json['systemUsage'] as double,
      additionalMetrics: json['additionalMetrics'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'pendingApprovals': pendingApprovals,
      'activeQuizzes': activeQuizzes,
      'pendingQuizApprovals': pendingQuizApprovals,
      'totalResources': totalResources,
      'resourceRequests': resourceRequests,
      'systemUsage': systemUsage,
      'additionalMetrics': additionalMetrics,
    };
  }

  // Sample for UI development
  factory AdminDashboardStats.sample() {
    return AdminDashboardStats(
      totalStudents: 520,
      totalTeachers: 35,
      pendingApprovals: 12,
      activeQuizzes: 48,
      pendingQuizApprovals: 8,
      totalResources: 156,
      resourceRequests: 4,
      systemUsage: 78.5,
      additionalMetrics: {
        'averageQuizScore': 72.3,
        'activeUsers': 320,
        'weeklyLogins': 1245,
      },
    );
  }
}