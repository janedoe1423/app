import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/database_provider.dart';
import '../../models/syllabus.dart';
import './view_syllabus_screen.dart';
import '../../services/pdf_extractor.dart';

class SyllabusManagement extends StatelessWidget {
  const SyllabusManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus Management'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose an Option',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildOptionCard(
                context,
                'Add Syllabus',
                Icons.add_circle_outline,
                'Upload new syllabus for any class',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSyllabus(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                'View Syllabus',
                Icons.visibility,
                'View and manage existing syllabi',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewSyllabusScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddSyllabus extends StatefulWidget {
  const AddSyllabus({super.key});

  @override
  State<AddSyllabus> createState() => _AddSyllabusState();
}

class _AddSyllabusState extends State<AddSyllabus> {
  final _formKey = GlobalKey<FormState>();
  String? selectedClass;
  String? selectedSection;
  String? selectedSubject;
  PlatformFile? uploadedFile;
  List<String> extractedTopics = [];
  bool isExtracting = false;

  final List<String> classes = ['Class 10', 'Class 11', 'Class 12'];
  final List<String> sections = ['A', 'B', 'C'];
  final List<String> subjects = ['Mathematics', 'Physics', 'Chemistry'];

  Future<void> _uploadAndExtractPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          uploadedFile = result.files.first;
          isExtracting = true;
          extractedTopics = []; // Clear previous topics
        });

        // Show loading dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing PDF content...'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        // Extract topics from PDF
        final pdfExtractor = PDFExtractor();
        final extractedData = await pdfExtractor.extractFromPDF(result.files.first.bytes!);
        
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        setState(() {
          extractedTopics = extractedData;
          isExtracting = false;
        });
      }
    } catch (e) {
      // Close loading dialog if error occurs
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      setState(() {
        isExtracting = false;
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeTopic(int index) {
    setState(() {
      extractedTopics.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Syllabus'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: const InputDecoration(labelText: 'Select Class'),
                  items: classes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedClass = value),
                  validator: (value) => value == null ? 'Please select a class' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSection,
                  decoration: const InputDecoration(labelText: 'Select Section'),
                  items: sections.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedSection = value),
                  validator: (value) => value == null ? 'Please select a section' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: const InputDecoration(labelText: 'Select Subject'),
                  items: subjects.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedSubject = value),
                  validator: (value) => value == null ? 'Please select a subject' : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _uploadAndExtractPDF,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Syllabus PDF'),
                ),

                if (isExtracting)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Extracting syllabus content...'),
                        ],
                      ),
                    ),
                  ),

                if (uploadedFile != null && extractedTopics.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Extracted Topics:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${extractedTopics.length} topics found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: extractedTopics.length,
                    itemBuilder: (context, index) {
                      final topic = extractedTopics[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(topic),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _removeTopic(index),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 24),
                if (uploadedFile != null)
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && uploadedFile != null) {
                        try {
                          final provider = Provider.of<DatabaseProvider>(context, listen: false);
                          
                          final syllabus = Syllabus(
                            className: selectedClass!,
                            section: selectedSection!,
                            subject: selectedSubject!,
                            fileName: uploadedFile!.name,
                            topics: extractedTopics,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );

                          await provider.addSyllabus(syllabus);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Syllabus added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Submit Syllabus'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ViewSyllabus extends StatelessWidget {
  const ViewSyllabus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Syllabus'),
        centerTitle: true,
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, dbProvider, child) {
          final syllabi = dbProvider.syllabi;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: syllabi.length,
            itemBuilder: (context, index) {
              final syllabus = syllabi[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  title: Text('${syllabus.className} - Section ${syllabus.section}'),
                  subtitle: Text(syllabus.subject),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          // TODO: Implement view syllabus details
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement edit syllabus
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await dbProvider.deleteSyllabus(
                            syllabus.className,
                            syllabus.section,
                            syllabus.subject,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSyllabus(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 