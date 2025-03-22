import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import 'take_assessment.dart';

class AvailableAssessments extends StatelessWidget {
  const AvailableAssessments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Assessments'),
        centerTitle: true,
      ),
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          final assessments = provider.activeAssessments;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final assessment = assessments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(assessment.subject),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chapter: ${assessment.chapter}'),
                      Text('Duration: 60 minutes'),
                      const LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: Colors.grey,
                      ),
                      Text(
                        'Time Remaining: ${_getRemainingTime(assessment.endTime)}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakeAssessment(
                            assessment: assessment,
                          ),
                        ),
                      );
                    },
                    child: const Text('Start'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getRemainingTime(DateTime endTime) {
    final remaining = endTime.difference(DateTime.now());
    return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
  }
} 