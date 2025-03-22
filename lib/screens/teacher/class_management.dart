import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import 'performance_analysis.dart';

class ClassManagement extends StatefulWidget {
  const ClassManagement({super.key});

  @override
  State<ClassManagement> createState() => _ClassManagementState();
}

class _ClassManagementState extends State<ClassManagement> {
  final List<String> classes = ['Class 10-A', 'Class 11-B', 'Class 12-A'];
  String? selectedClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Class Selection
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
              items: classes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedClass = newValue;
                });
              },
            ),
            const SizedBox(height: 24),

            // Class Info Cards
            if (selectedClass != null) ...[
              _buildInfoCard(
                'Class Details',
                [
                  'Total Students: 40',
                  'Class Teacher: John Doe',
                  'Subjects: 6',
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Recent Activities',
                [
                  'Math Test - 15th March',
                  'Physics Assignment Due - 20th March',
                  'Parent Meeting - 25th March',
                ],
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Students',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Student List
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Sample students
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('S${index + 1}'),
                      ),
                      title: Text('Student ${index + 1}'),
                      subtitle: Text('Roll No: ${1001 + index}'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View Details'),
                          ),
                          PopupMenuItem(
                            value: 'performance',
                            child: Text('View Performance'),
                            onTap: () {
                              final provider = Provider.of<AssessmentProvider>(context, listen: false);
                              final performance = provider.getClassPerformance(selectedClass!);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PerformanceAnalysis(),
                                ),
                              );
                            },
                          ),
                          const PopupMenuItem(
                            value: 'contact',
                            child: Text('Contact Parents'),
                          ),
                        ],
                        onSelected: (value) {
                          // Handle menu item selection
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add new student
          _showAddStudentDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, size: 20),
                      const SizedBox(width: 8),
                      Text(item),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Student Name',
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Roll Number',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Parent Contact',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add student logic here
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
} 