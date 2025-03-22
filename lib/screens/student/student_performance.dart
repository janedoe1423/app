import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'available_assessments.dart';

class StudentPerformance extends StatelessWidget {
  const StudentPerformance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Performance'),
        centerTitle: true,
      ),
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, child) {
          final completedAssessments = provider.completedAssessments;
          
          if (completedAssessments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment_outlined, 
                    size: 64, 
                    color: Colors.grey[400]
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No completed assessments yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvailableAssessments(),
                        ),
                      );
                    },
                    child: const Text('Take an Assessment'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallProgress(provider),
                const SizedBox(height: 24),
                _buildSubjectWisePerformance(provider),
                const SizedBox(height: 24),
                _buildRecentAssessments(completedAssessments),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress(AssessmentProvider provider) {
    final progress = provider.getOverallProgress();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: progress,
                      color: Colors.blue,
                      title: '${progress.round()}%',
                      radius: 80,
                    ),
                    PieChartSectionData(
                      value: 100 - progress,
                      color: Colors.grey[300],
                      radius: 80,
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectWisePerformance(AssessmentProvider provider) {
    final subjectScores = provider.getSubjectWisePerformance();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: subjectScores.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key.hashCode,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final subject = subjectScores.keys
                              .firstWhere((k) => k.hashCode == value.toInt());
                          return Text(
                            subject,
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAssessments(List<Assessment> assessments) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Assessments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assessments.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final assessment = assessments[index];
                final score = assessment.results!['score'] as double;
                
                return ListTile(
                  title: Text(assessment.subject),
                  subtitle: Text(assessment.chapter),
                  trailing: CircleAvatar(
                    backgroundColor: _getScoreColor(score),
                    child: Text(
                      '${score.round()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
} 