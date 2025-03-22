import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';

class PerformanceAnalysis extends StatefulWidget {
  const PerformanceAnalysis({super.key});

  @override
  State<PerformanceAnalysis> createState() => _PerformanceAnalysisState();
}

class _PerformanceAnalysisState extends State<PerformanceAnalysis> {
  String? selectedClass;
  String? selectedSubject;
  String? selectedAssessment;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Performance Analysis'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Assessment Analysis'),
              Tab(text: 'Topic Analysis'),
              Tab(text: 'Student Analysis'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Filter Section
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: ['Class 10', 'Class 11', 'Class 12']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) => setState(() => selectedClass = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: ['Mathematics', 'Physics', 'Chemistry']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) => setState(() => selectedSubject = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOverviewTab(),
                    _buildAssessmentAnalysisTab(),
                    _buildTopicAnalysisTab(),
                    _buildStudentAnalysisTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Performance Overview Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Class Performance Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        // Add sample data
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 3),
                              const FlSpot(1, 4),
                              const FlSpot(2, 3.5),
                              const FlSpot(3, 5),
                              const FlSpot(4, 4),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Average Score', '75%', Icons.score),
              _buildStatCard('Participation', '92%', Icons.people),
              _buildStatCard('Assessments', '15', Icons.assignment),
              _buildStatCard('Improvement', '+8%', Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentAnalysisTab() {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        final completedAssessments = provider.completedAssessments;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Assessment Selection
              DropdownButtonFormField<String>(
                value: selectedAssessment,
                decoration: const InputDecoration(
                  labelText: 'Select Assessment',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Math Test - March 15',
                  'Physics Quiz - March 20',
                  'Chemistry Assessment - March 25',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAssessment = newValue;
                  });
                },
              ),
              const SizedBox(height: 24),

              if (selectedAssessment != null) ...[
                // Assessment Overview Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAssessment!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAssessmentStats(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Performance Distribution
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          // Add chart here
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Topic-wise Performance
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Topic-wise Performance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Topic ${index + 1}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: 0.7 - (index * 0.2),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Average Score: ${70 - (index * 20)}%'),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssessmentStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Average Score', '75%'),
        _buildStatItem('Highest Score', '95%'),
        _buildStatItem('Lowest Score', '45%'),
        _buildStatItem('Completion Rate', '90%'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopicAnalysisTab() {
    return ListView.builder(
      itemCount: 5, // Sample topics
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('Topic ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (index + 1) * 0.2,
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 4),
                Text('Average Score: ${(index + 1) * 20}%'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                // Show detailed topic analysis
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentAnalysisTab() {
    return ListView.builder(
      itemCount: 10, // Sample students
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('S${index + 1}'),
            ),
            title: Text('Student ${index + 1}'),
            subtitle: Text('Average Score: ${70 + index * 2}%'),
            trailing: IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                // Show detailed student analysis
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
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
} 