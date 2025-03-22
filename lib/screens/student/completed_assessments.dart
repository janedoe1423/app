import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';

class CompletedAssessments extends StatelessWidget {
  const CompletedAssessments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Assessments'),
        centerTitle: true,
      ),
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          final assessments = provider.completedAssessments;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final assessment = assessments[index];
              final results = assessment.results!;

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
                            assessment.subject,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildScoreChip(results['score'] as double),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Chapter: ${assessment.chapter}'),
                      Text(
                        'Completed on: ${_formatDate(assessment.endTime)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Performance Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPerformanceBreakdown(results['topicWise'] as Map<String, double>),
                      const SizedBox(height: 16),
                      _buildFeedbackSection(results['feedback'] as List<String>),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: View detailed analysis
                          },
                          child: const Text('View Detailed Analysis'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScoreChip(double score) {
    Color color;
    if (score >= 80) {
      color = Colors.green;
    } else if (score >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Chip(
      label: Text(
        '${score.round()}%',
        style: TextStyle(color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildPerformanceBreakdown(Map<String, double> topicWise) {
    return Column(
      children: topicWise.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: entry.value / 100,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackSection(List<String> feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback & Suggestions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...feedback.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 