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
  List<bool> questionSelections = []; // Track selections for each question
  String? selectedClass; // New field for Class
  double numberOfQuestions = 20; // Default number of questions as double for slider
  double questionTypePercentage = 50.0; // Default percentage as double for slider
  bool includeRegionalConversion = false; // New field for regional conversion

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Class Selection
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Class 1', 'Class 2', 'Class 3'] // Example classes
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClass = newValue;
                      selectedSubject = null; // Reset subject and chapter
                      selectedChapter = null;
                      generatedQuestions = null;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a class' : null,
                ),
                const SizedBox(height: 16),

                // Subject Selection
                if (selectedClass != null) // Only show if class is selected
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
                        selectedChapter = null; // Reset chapter
                        generatedQuestions = null;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a subject' : null,
                  ),
                const SizedBox(height: 16),

                // Chapter Selection
                if (selectedSubject != null) // Only show if subject is selected
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
                        generatedQuestions = null; // Reset questions
                      });
                    },
                    validator: (value) => value == null ? 'Please select a chapter' : null,
                  ),
                const SizedBox(height: 16),

                // Number of Questions Slider
                if (selectedChapter != null) // Only show if chapter is selected
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Number of Questions:'),
                      Slider(
                        value: numberOfQuestions,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        label: numberOfQuestions.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            numberOfQuestions = value;
                          });
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Percentage of Question Types Slider
                if (numberOfQuestions > 0) // Only show if number of questions is set
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Percentage of Question Types (0-100):'),
                      Slider(
                        value: questionTypePercentage,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: questionTypePercentage.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            questionTypePercentage = value;
                          });
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Regional Conversion Checkbox
                if (numberOfQuestions > 0) // Only show if number of questions is set
                  Row(
                    children: [
                      Checkbox(
                        value: includeRegionalConversion,
                        onChanged: (bool? value) {
                          setState(() {
                            includeRegionalConversion = value ?? false;
                          });
                        },
                      ),
                      const Text('Include Regional Conversion'),
                    ],
                  ),
                const SizedBox(height: 24),

                // Generate Questions Button
                Center(
                  child: ElevatedButton(
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
                          questionSelections = List<bool>.filled(questions.length, true); // Default to selected
                          isGenerating = false;
                        });
                      }
                    },
                    child: const Text('Generate Questions'),
                  ),
                ),
                const SizedBox(height: 24),

                // Display Generated Questions
                if (generatedQuestions != null) ...[
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: generatedQuestions!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(generatedQuestions![index]),
                            trailing: Checkbox(
                              value: questionSelections[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  questionSelections[index] = value ?? false;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Row for Regenerate and Submit Buttons
                  Center(
                    child: Wrap(  // Using Wrap instead of Row
                      spacing: 8.0,  // Horizontal spacing between buttons
                      runSpacing: 8.0,  // Vertical spacing between rows
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Regenerate questions logic
                            final questions = await generateQuestionsWithAI();
                            setState(() {
                              generatedQuestions = questions;
                              questionSelections = List<bool>.filled(questions.length, true);
                            });
                          },
                          child: const Text('Regenerate Questions'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // Submit selected questions logic
                            final selectedQuestions = generatedQuestions!.asMap().entries
                                .where((entry) => questionSelections[entry.key])
                                .map((entry) => entry.value)
                                .toList();
                            
                            if (selectedQuestions.isNotEmpty) {
                              final provider = Provider.of<AssessmentProvider>(context, listen: false);
                              await provider.addQuestionsToBank(
                                '$selectedSubject-$selectedChapter',
                                selectedQuestions,
                              );

                              // Show success dialog
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Submitted'),
                                      content: const Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Questions submitted successfully!'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          child: const Text('Submit Selected Questions'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
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