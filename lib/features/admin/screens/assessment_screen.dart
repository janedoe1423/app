import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  String? _pdfPath;
  bool _isProcessing = false;
  List<Topic> _topics = [];
  final _formKey = GlobalKey<FormState>();
  int _totalQuestions = 0;
  String _unsupportedStates = '';
  bool _showAdvancedOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Generation for Chapters'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Upload Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Chapter PDF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickPDF,
                              icon: const Icon(Icons.upload_file),
                              label: Text(_pdfPath != null 
                                ? 'Change PDF' 
                                : 'Select PDF File'),
                            ),
                          ),
                        ],
                      ),
                      if (_pdfPath != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Selected file: ${_pdfPath!.split('/').last}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        if (_isProcessing) ...[
                          const SizedBox(height: 16),
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Topics Section (shown after PDF processing)
              if (_topics.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Topics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addNewTopic,
                              tooltip: 'Add New Topic',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _topics.length,
                          itemBuilder: (context, index) {
                            return _buildTopicItem(_topics[index], index);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Advanced Options Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Advanced Options',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showAdvancedOptions 
                                  ? Icons.expand_less 
                                  : Icons.expand_more,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showAdvancedOptions = !_showAdvancedOptions;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_showAdvancedOptions) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Total Questions',
                              hintText: 'Enter total number of questions',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter total questions';
                              }
                              final number = int.tryParse(value);
                              if (number == null || number <= 0) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _totalQuestions = int.parse(value!);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Unsupported States (comma-separated)',
                              hintText: 'e.g., California, New York',
                            ),
                            onSaved: (value) {
                              _unsupportedStates = value ?? '';
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generateQuestions,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Generate Questions',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicItem(Topic topic, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: topic.isSelected,
                  onChanged: (value) {
                    setState(() {
                      topic.isSelected = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    topic.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _topics.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            if (topic.isSelected) ...[
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Question Weightage (%)',
                  hintText: 'Enter percentage of questions',
                ),
                keyboardType: TextInputType.number,
                initialValue: '50',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weightage';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number < 0 || number > 100) {
                    return 'Please enter a valid percentage (0-100)';
                  }
                  return null;
                },
                onSaved: (value) {
                  topic.weightage = int.parse(value!);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickPDF() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        withReadStream: true,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pdfPath = result.files.single.path;
        });

        // Show processing indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing PDF...'),
            backgroundColor: Colors.blue,
          ),
        );

        // TODO: Call backend API to process PDF and get topics
        // For now, we'll simulate the API call
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          _topics = [
            Topic(name: 'Topic 1', isSelected: true, weightage: 50),
            Topic(name: 'Topic 2', isSelected: true, weightage: 50),
            Topic(name: 'Topic 3', isSelected: true, weightage: 50),
          ];
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF processed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking PDF file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _addNewTopic() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add New Topic'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Topic Name',
              hintText: 'Enter topic name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _topics.add(Topic(
                      name: controller.text,
                      isSelected: true,
                      weightage: 50,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _generateQuestions() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // TODO: Implement question generation logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating questions...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class Topic {
  String name;
  bool isSelected;
  int weightage;

  Topic({
    required this.name,
    required this.isSelected,
    required this.weightage,
  });
} 