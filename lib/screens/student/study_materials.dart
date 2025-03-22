import 'package:flutter/material.dart';

class StudyMaterials extends StatelessWidget {
  const StudyMaterials({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSubjectSection(
            'Mathematics',
            [
              'Algebra Basics',
              'Trigonometry',
              'Calculus Introduction',
            ],
          ),
          _buildSubjectSection(
            'Physics',
            [
              'Mechanics',
              'Thermodynamics',
              'Optics',
            ],
          ),
          _buildSubjectSection(
            'Chemistry',
            [
              'Organic Chemistry',
              'Inorganic Chemistry',
              'Physical Chemistry',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSection(String subject, List<String> topics) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          subject,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: topics.map((topic) {
          return ListTile(
            title: Text(topic),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () {
                    // TODO: Implement video playback
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () {
                    // TODO: Implement PDF download
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
} 