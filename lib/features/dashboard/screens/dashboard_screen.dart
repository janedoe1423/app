import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/dashboard_provider.dart';
import '../widgets/teacher_dashboard_content.dart';
import '../widgets/admin_dashboard_content.dart';
import '../widgets/student_dashboard_content.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Center(
            child: Text('No user found'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome, ${user.displayName}'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(user.email),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (user.isTeacher)
                  const TeacherDashboardContent()
                else if (user.isAdmin)
                  const AdminDashboardContent()
                else
                  const StudentDashboardContent(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final user = authProvider.currentUser;
    
    return RefreshIndicator(
      onRefresh: () async {
        if (user != null) {
          await dashboardProvider.loadDashboardDataForUser(user);
        } else {
          await dashboardProvider.loadDashboardData();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section
            _buildGreetingSection(context, user),
            const SizedBox(height: 24),
            
            // Quick actions
            _buildQuickActionsSection(context, user),
            const SizedBox(height: 24),
            
            // Upcoming assessments
            _buildUpcomingSection(context, dashboardProvider),
            const SizedBox(height: 24),
            
            // Recent activity
            _buildRecentActivitySection(context),
            const SizedBox(height: 24),
            
            // Performance overview (for students) or Class overview (for teachers)
            if (user?.isStudent ?? true)
              _buildPerformanceSection(context)
            else
              _buildClassOverviewSection(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGreetingSection(BuildContext context, UserModel? user) {
    final greeting = _getGreeting();
    final name = user?.displayName.split(' ').first ?? 'User';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    user?.initials ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, $name!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.isTeacher ?? false
                            ? 'Teacher Account'
                            : 'Student Account',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'What would you like to do today?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionsSection(BuildContext context, UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionButton(
              context,
              icon: Icons.search,
              label: 'Find Resources',
              onTap: () {
                // Navigate to resources search
              },
            ),
            _buildActionButton(
              context,
              icon: user?.isTeacher ?? false ? Icons.assignment : Icons.assignment_turned_in,
              label: user?.isTeacher ?? false ? 'Assignments' : 'My Tasks',
              onTap: () {
                // Navigate to assignments
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.auto_awesome,
              label: 'AI Assist',
              onTap: () {
                // Navigate to AI assistant
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUpcomingSection(BuildContext context, DashboardProvider dashboardProvider) {
    // In a real app, we would use the provider's data
    final hasUpcoming = dashboardProvider.upcomingAssessments?.isNotEmpty ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all upcoming items
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (dashboardProvider.isLoading) ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
        ] else if (!hasUpcoming) ...[
          _buildEmptyUpcoming(),
        ] else ...[
          _buildUpcomingList(dashboardProvider.upcomingAssessments!),
        ],
      ],
    );
  }
  
  Widget _buildEmptyUpcoming() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 8),
            const Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No upcoming deadlines or assignments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUpcomingList(List<dynamic> items) {
    // In a real app, we would iterate over the items and build a list
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text('Upcoming items would be shown here'),
        ),
      ),
    );
  }
  
  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all activity
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.blue.shade300,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No recent activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your recent activity will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to detailed performance
              },
              child: const Text('Details'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Class Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPerformanceMetric('Overall', '95%', Colors.green),
                    _buildPerformanceMetric('Quizzes', '87%', Colors.blue),
                    _buildPerformanceMetric('Assignments', '92%', Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'View Detailed Analytics',
                  onPressed: () {
                    // Navigate to detailed analytics
                  },
                  type: AppButtonType.primary,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildClassOverviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Class Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all classes
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Your Classes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildClassItem('Mathematics 101', '32 Students', Colors.blue.shade200),
                const SizedBox(height: 8),
                _buildClassItem('Physics 202', '28 Students', Colors.green.shade200),
                const SizedBox(height: 8),
                _buildClassItem('Computer Science', '35 Students', Colors.orange.shade200),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Create New Class',
                  onPressed: () {
                    // Navigate to class creation
                  },
                  type: AppButtonType.primary,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceMetric(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildClassItem(String className, String studentCount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Center(
              child: Text(
                className[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.withRed(color.red - 40).withGreen(color.green - 40).withBlue(color.blue - 40),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  studentCount,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}

// Placeholder for Classes Tab
class ClassesTab extends StatelessWidget {
  const ClassesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Classes Tab - Coming Soon'),
    );
  }
}

// Placeholder for Resources Tab
class ResourcesTab extends StatelessWidget {
  const ResourcesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Resources Tab - Coming Soon'),
    );
  }
}

// Placeholder for Profile Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Text(
                authProvider.currentUser?.initials ?? 'U',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.currentUser?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.currentUser?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              authProvider.currentUser?.isTeacher ?? false
                  ? 'Teacher Account'
                  : authProvider.currentUser?.isAdmin ?? false
                      ? 'Admin Account'
                      : 'Student Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Edit Profile',
              onPressed: () {
                // Navigate to profile editing
              },
              type: AppButtonType.primary,
              fullWidth: true,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Log Out',
              onPressed: () async {
                await authProvider.logout();
              },
              type: AppButtonType.outlined,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}