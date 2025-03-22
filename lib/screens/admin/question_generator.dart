import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';

class QuestionGenerator extends StatefulWidget {
  const QuestionGenerator({super.key});

  @override
  State<QuestionGenerator> createState() => _QuestionGeneratorState();
}

class _QuestionGeneratorState extends State<QuestionGenerator> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSubject;
  String? selectedChapter;
  bool isGenerating = false;
  List<String>? generatedQuestions;

  final Map<String, List<String>> subjectChapters = {
    'Mathematics': ['Algebra', 'Calculus', 'Geometry'],
    'Physics': ['Mechanics', 'Thermodynamics', 'Optics'],
    'Chemistry': ['Organic', 'Inorganic', 'Physical'],
  };

  final Map<String, Map<String, List<String>>> sampleQuestions = {
    'Mathematics': {
      'Algebra': [
        'Solve the quadratic equation: x² + 5x + 6 = 0',
        'Factorize the expression: 4x² - 16',
        'Find the value of x: 2x + 7 = 15',
        'Solve the system of equations: 3x + y = 7, x - 2y = 1',
        'Simplify: (x² + 2x + 1) - (x² - 2x + 1)',
      ],
      'Calculus': [
        'Find the derivative of f(x) = 3x² + 2x - 1',
        'Evaluate the integral: ∫(2x + 3)dx from 0 to 4',
        'Find the local maxima of f(x) = x³ - 3x² + 1',
        'Calculate the area under the curve y = x² from x = 0 to x = 2',
        'Find the derivative of g(x) = sin(x)cos(x)',
      ],
      'Geometry': [
        'Calculate the area of a circle with radius 7 units',
        'Find the volume of a sphere with radius 5 units',
        'Calculate the surface area of a cube with side length 4 units',
        'Find the perimeter of a rectangle with length 8 units and width 5 units',
        'Calculate the area of a triangle with base 6 units and height 8 units',
      ],
    },
    'Physics': {
      'Mechanics': [
        'A car accelerates from 0 to 60 km/h in 5 seconds. Calculate its acceleration.',
        'Calculate the force needed to lift a 10 kg mass vertically.',
        'A ball is thrown vertically upward with velocity 20 m/s. Find its maximum height.',
        'Calculate the momentum of a 5 kg object moving at 4 m/s.',
        'Find the kinetic energy of a 2 kg mass moving at 5 m/s.',
      ],
      'Thermodynamics': [
        'Calculate the heat required to raise the temperature of 2 kg of water by 10°C.',
        'Define the First Law of Thermodynamics with an example.',
        'Explain the concept of entropy in a closed system.',
        'Calculate the work done by a gas that expands from 2L to 5L at constant pressure of 2 atm.',
        'What is the efficiency of a heat engine operating between 400K and 300K?',
      ],
    },
    'Chemistry': {
      'Organic': [
        'Draw the structure of ethanol and identify functional groups.',
        'Write the balanced equation for the combustion of methane.',
        'Explain the difference between addition and substitution reactions.',
        'Name the following compound: CH3-CH2-CH2-OH',
        'Write the mechanism for the chlorination of methane.',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                ),
                items: subjectChapters.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSubject = newValue;
                    selectedChapter = null;
                    generatedQuestions = null;
                  });
                },
                validator: (value) => value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 16),
              if (selectedSubject != null)
                DropdownButtonFormField<String>(
                  value: selectedChapter,
                  decoration: const InputDecoration(
                    labelText: 'Select Chapter',
                    border: OutlineInputBorder(),
                  ),
                  items: subjectChapters[selectedSubject]?.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedChapter = newValue;
                      generatedQuestions = null;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a chapter' : null,
                ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isGenerating = true;
                      });
                      
                      // Simulate API delay
                      await Future.delayed(const Duration(seconds: 2));
                      
                      final questions = await generateQuestionsWithAI();
                      
                      setState(() {
                        generatedQuestions = questions;
                        isGenerating = false;
                      });

                      // Add to question bank
                      if (!mounted) return;
                      final provider = Provider.of<AssessmentProvider>(context, listen: false);
                      await provider.addQuestionsToBank(
                        '$selectedSubject-$selectedChapter',
                        questions,
                      );
                    }
                  },
                  icon: isGenerating 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                  label: Text(isGenerating ? 'Generating...' : 'Generate Questions'),
                ),
              ),
              if (generatedQuestions != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Generated Questions:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...generatedQuestions!.asMap().entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${entry.key + 1}'),
                      ),
                      title: Text(entry.value),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> generateQuestionsWithAI() async {
    // Return sample questions based on selected subject and chapter
    return sampleQuestions[selectedSubject]?[selectedChapter] ?? [
      'Sample question 1 for $selectedSubject - $selectedChapter',
      'Sample question 2 for $selectedSubject - $selectedChapter',
      'Sample question 3 for $selectedSubject - $selectedChapter',
      'Sample question 4 for $selectedSubject - $selectedChapter',
      'Sample question 5 for $selectedSubject - $selectedChapter',
    ];
  }
} 