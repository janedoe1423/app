import 'package:flutter/material.dart';
import 'teacher/assessment_management.dart';
import 'teacher/performance_analysis.dart';
import 'teacher/class_management.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth > 600 
                            ? (constraints.maxWidth - 48) / 2 
                            : constraints.maxWidth - 32,
                        child: _buildStatCard(
                          'Active Assessments',
                          '5',
                          Icons.assignment,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth > 600 
                            ? (constraints.maxWidth - 48) / 2 
                            : constraints.maxWidth - 32,
                        child: _buildStatCard(
                          'Total Students',
                          '120',
                          Icons.people,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: _calculateChildAspectRatio(constraints.maxWidth),
                        children: [
                          _buildFeatureCard(
                            context,
                            'Assessments',
                            Icons.assignment,
                            'Create and manage all assessments',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AssessmentManagement(),
                              ),
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Performance Analysis',
                            Icons.analytics,
                            'View student performance and analytics',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PerformanceAnalysis(),
                              ),
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Class Management',
                            Icons.class_,
                            'Manage classes and students',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ClassManagement(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _calculateChildAspectRatio(double width) {
    if (width > 900) return 1.4;
    if (width > 600) return 1.2;
    if (width > 400) return 1.0;
    return 0.85;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                size: 40,
                color: Theme.of(context).primaryColor
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 