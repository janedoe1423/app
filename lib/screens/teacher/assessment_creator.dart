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
  Set<String> selectedSubtopics = {};

  // Enhanced data structure with hierarchical mapping
  final Map<String, List<String>> sections = {
    'Class 10': ['Section A', 'Section B', 'Section C'],
    'Class 11': ['Section A', 'Section B'],
    'Class 12': ['Section A', 'Section B', 'Section C'],
  };

  final Map<String, List<String>> subjects = {
    'Section A': ['Mathematics', 'Physics', 'Chemistry'],
    'Section B': ['Mathematics', 'Biology', 'Chemistry'],
    'Section C': ['Mathematics', 'Computer Science', 'Physics'],
  };

  final Map<String, List<String>> chapters = {
    'Mathematics': ['Algebra', 'Geometry', 'Calculus', 'Statistics'],
    'Physics': ['Mechanics', 'Thermodynamics', 'Electromagnetism', 'Optics'],
    'Chemistry': ['Atomic Structure', 'Chemical Bonding', 'Thermodynamics', 'Organic Chemistry'],
  };

  final Map<String, List<String>> subtopics = {
    'Algebra': ['Linear Equations', 'Quadratic Equations', 'Polynomials'],
    'Geometry': ['Triangles', 'Circles', 'Polygons'],
    'Calculus': ['Limits', 'Derivatives', 'Integration'],
    // Add more subtopics as needed
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Assessment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClassSelection(),
              const SizedBox(height: 16),
              if (selectedClass != null) _buildSectionSelection(),
              if (selectedSubject != null) _buildSubjectSelection(),
              if (selectedChapter != null) _buildChapterSelection(),
              const SizedBox(height: 24),
              _buildAssessmentConfig(),
              const SizedBox(height: 24),
              _buildSchedule(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Class',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: sections.keys.map((className) {
                return ChoiceChip(
                  label: Text(className),
                  selected: selectedClass == className,
                  onSelected: (selected) {
                    setState(() {
                      selectedClass = selected ? className : null;
                      // Reset dependent selections
                      selectedSubject = null;
                      selectedChapter = null;
                      selectedSubtopics.clear();
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Section',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: sections[selectedClass]?.map((section) {
                return ChoiceChip(
                  label: Text(section),
                  selected: selectedSubject == section,
                  onSelected: (selected) {
                    setState(() {
                      selectedSubject = selected ? section : null;
                      selectedChapter = null;
                      selectedSubtopics.clear();
                    });
                  },
                );
              }).toList() ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Subject',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: subjects[selectedSubject]?.map((subject) {
                return ChoiceChip(
                  label: Text(subject),
                  selected: selectedChapter == subject,
                  onSelected: (selected) {
                    setState(() {
                      selectedChapter = selected ? subject : null;
                      selectedSubtopics.clear();
                    });
                  },
                );
              }).toList() ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Topics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: chapters[selectedChapter]?.map((topic) {
                return FilterChip(
                  label: Text(topic),
                  selected: selectedSubtopics.contains(topic),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedSubtopics.add(topic);
                      } else {
                        selectedSubtopics.remove(topic);
                      }
                    });
                  },
                );
              }).toList() ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assessment Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Your existing configuration widgets
            // (question count, duration sliders)
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(startTime?.toString() ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(isStartTime: true),
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(endTime?.toString() ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(isStartTime: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _canSubmit() ? _submitAssessment : null,
        icon: const Icon(Icons.check_circle),
        label: const Text('Create Assessment'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return selectedClass != null &&
           selectedSubject != null &&
           selectedChapter != null &&
           startTime != null &&
           endTime != null &&
           selectedSubtopics.isNotEmpty;
  }

  Future<void> _selectDateTime({required bool isStartTime}) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStartTime) {
        startTime = dateTime;
      } else {
        endTime = dateTime;
      }
    });
  }

  Future<void> _submitAssessment() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AssessmentProvider>(context, listen: false);
    
    try {
      await provider.createAssessment(
        className: selectedClass!,
        subject: selectedSubject!,
        chapter: selectedChapter!,
        startTime: startTime!,
        endTime: endTime!,
        selectedSubtopics: selectedSubtopics.toList(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Assessment created successfully'),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating assessment: $e')),
      );
    }
  }
} 