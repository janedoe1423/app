import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';

class AssessmentCreator extends StatefulWidget {
  const AssessmentCreator({super.key});

  @override
  State<AssessmentCreator> createState() => _AssessmentCreatorState();
}

class _AssessmentCreatorState extends State<AssessmentCreator> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClass;
  String? selectedSubject;
  String? selectedChapter;
  DateTime? startTime;
  DateTime? endTime;
  Map<String, double> subtopicWeightage = {
    'Basic Concepts': 30,
    'Problem Solving': 40,
    'Advanced Applications': 30,
  };
  int questionCount = 10;
  int duration = 60; // in minutes

  final List<String> classes = ['Class 10-A', 'Class 11-B', 'Class 12-A'];
  final List<String> subjects = ['Mathematics', 'Physics', 'Chemistry'];
  final Map<String, List<String>> chapters = {
    'Mathematics': ['Algebra', 'Calculus', 'Geometry'],
    'Physics': ['Mechanics', 'Thermodynamics', 'Optics'],
    'Chemistry': ['Organic', 'Inorganic', 'Physical'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Assessment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                validator: (value) => value == null ? 'Please select a class' : null,
              ),
              const SizedBox(height: 16),

              // Subject Selection
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                ),
                items: subjects.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSubject = newValue;
                    selectedChapter = null; // Reset chapter when subject changes
                  });
                },
                validator: (value) => value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 16),

              // Chapter Selection
              if (selectedSubject != null)
                DropdownButtonFormField<String>(
                  value: selectedChapter,
                  decoration: const InputDecoration(
                    labelText: 'Select Chapter',
                    border: OutlineInputBorder(),
                  ),
                  items: chapters[selectedSubject]?.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedChapter = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a chapter' : null,
                ),
              const SizedBox(height: 24),

              // Assessment Configuration
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessment Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Number of Questions
                      Row(
                        children: [
                          const Text('Number of Questions: '),
                          Expanded(
                            child: Slider(
                              value: questionCount.toDouble(),
                              min: 5,
                              max: 30,
                              divisions: 25,
                              label: questionCount.toString(),
                              onChanged: (value) {
                                setState(() {
                                  questionCount = value.round();
                                });
                              },
                            ),
                          ),
                          Text(questionCount.toString()),
                        ],
                      ),

                      // Duration
                      Row(
                        children: [
                          const Text('Duration (minutes): '),
                          Expanded(
                            child: Slider(
                              value: duration.toDouble(),
                              min: 15,
                              max: 180,
                              divisions: 165,
                              label: duration.toString(),
                              onChanged: (value) {
                                setState(() {
                                  duration = value.round();
                                });
                              },
                            ),
                          ),
                          Text(duration.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Subtopic Weightage
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subtopic Weightage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...subtopicWeightage.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${entry.key} (${entry.value.round()}%)'),
                            Slider(
                              value: entry.value,
                              min: 0,
                              max: 100,
                              divisions: 20,
                              label: entry.value.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  subtopicWeightage[entry.key] = value;
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Schedule
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Start Time'),
                        subtitle: Text(
                          startTime?.toString() ?? 'Not set',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final time = await showDateTimePicker(context);
                          if (time != null) {
                            setState(() {
                              startTime = time;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('End Time'),
                        subtitle: Text(
                          endTime?.toString() ?? 'Not set',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final time = await showDateTimePicker(context);
                          if (time != null) {
                            setState(() {
                              endTime = time;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create Assessment Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        startTime != null &&
                        endTime != null) {
                      final provider = Provider.of<AssessmentProvider>(context, listen: false);
                      
                      // Create assessment
                      await provider.createAssessment(
                        className: selectedClass!,
                        subject: selectedSubject!,
                        chapter: selectedChapter!,
                        startTime: startTime!,
                        endTime: endTime!,
                        questionCount: questionCount,
                        duration: duration,
                        subtopicWeightage: subtopicWeightage,
                      );

                      if (!mounted) return;
                      
                      // Show success dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Assessment has been created and scheduled successfully.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Return to previous screen
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Create Assessment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
} 