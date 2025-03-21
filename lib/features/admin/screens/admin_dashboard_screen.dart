import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/approval_request_card.dart';
import '../widgets/resource_request_card.dart';
import 'user_approval_screen.dart';
import 'resource_management_screen.dart';
import 'user_management_screen.dart';
import 'system_logs_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'assessment_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard stats when screen loads
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Text(
                'Error: ${adminProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final stats = adminProvider.dashboardStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    StatCard(
                      title: 'Total Users',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Active Users',
                      value: stats.activeUsers.toString(),
                      icon: Icons.person_outline,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Pending Approvals',
                      value: stats.pendingApprovals.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Total Resources',
                      value: stats.totalResources.toString(),
                      icon: Icons.library_books,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'User Distribution',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.userTypeDistribution.length,
                    itemBuilder: (context, index) {
                      final entry = stats.userTypeDistribution.entries
                          .elementAt(index);
                      return ListTile(
                        title: Text(
                          entry.key.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Assessment Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment, size: 32),
                    title: const Text('Question Generation'),
                    subtitle: const Text('Generate questions from chapter PDFs'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssessmentScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 30),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                // TODO: Navigate to user management
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.approval),
              title: const Text('Approval Requests'),
              onTap: () {
                // TODO: Navigate to approval requests
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Resource Management'),
              onTap: () {
                // TODO: Navigate to resource management
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('System Logs'),
              onTap: () {
                // TODO: Navigate to system logs
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}