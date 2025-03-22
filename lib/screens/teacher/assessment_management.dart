import 'package:flutter/material.dart';
import 'assessment_creator.dart';
import 'performance_analysis.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';

class AssessmentManagement extends StatefulWidget {
  const AssessmentManagement({super.key});

  @override
  State<AssessmentManagement> createState() => _AssessmentManagementState();
}

class _AssessmentManagementState extends State<AssessmentManagement> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assessment Management'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAssessmentList('active'),
            _buildAssessmentList('upcoming'),
            _buildAssessmentList('completed'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AssessmentCreator(),
              ),
            );
          },
          label: const Text('Create Assessment'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildAssessmentList(String type) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final assessments = type == 'active' 
            ? provider.activeAssessments
            : type == 'upcoming' 
                ? provider.upcomingAssessments 
                : provider.completedAssessments;

        return ListView.builder(
          itemCount: assessments.length,
          itemBuilder: (context, index) {
            final assessment = assessments[index];
            return _buildAssessmentCard(assessment);
          },
        );
      },
    );
  }

  Widget _buildAssessmentCard(Assessment assessment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assessment ${assessment.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(assessment.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Class: ${assessment.className}th Standard'),
            Text('Subject: ${assessment.subject}'),
            Text('Chapter: Chapter ${assessment.chapter}'),
            const SizedBox(height: 8),
            if (assessment.status == 'active') ...[
              LinearProgressIndicator(
                value: (assessment.id.hashCode % 10) * 0.2,
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 8),
              Text('Students Completed: ${(assessment.id.hashCode % 10) * 10}/40'),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  assessment.status == 'completed'
                      ? 'Completed on March ${15 + assessment.id.hashCode % 10}, 2024'
                      : assessment.status == 'upcoming'
                          ? 'Scheduled for April ${1 + assessment.id.hashCode % 10}, 2024'
                          : 'Time Left: ${60 - (assessment.id.hashCode % 10) * 10} mins',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (assessment.status == 'completed' || assessment.status == 'active')
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PerformanceAnalysis(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('View Results'),
                  ),
                if (assessment.status == 'upcoming')
                  TextButton.icon(
                    onPressed: () {
                      // Edit assessment
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String type) {
    Color color;
    String label;
    switch (type) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'upcoming':
        color = Colors.blue;
        label = 'Upcoming';
        break;
      case 'completed':
        color = Colors.grey;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = '';
    }
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }
} 