import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/database_provider.dart';
import '../../models/syllabus.dart';
import './view_syllabus_screen.dart';

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

  final List<String> classes = ['Class 1', 'Class 2', 'Class 3'];
  final List<String> sections = ['A', 'B', 'C'];
  final List<String> subjects = ['Mathematics', 'Science', 'English'];

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
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClass = newValue;
                    });
                  },
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
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSection = newValue;
                    });
                  },
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
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubject = newValue;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                        withData: true,
                      );

                      if (result != null) {
                        setState(() {
                          uploadedFile = result.files.first;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Syllabus uploaded successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error uploading file. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Syllabus'),
                ),
                const SizedBox(height: 16),

                if (uploadedFile != null) ...[
                  Text('Uploaded File: ${uploadedFile!.name}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            uploadedFile = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && uploadedFile != null) {
                        try {
                          final provider = Provider.of<DatabaseProvider>(context, listen: false);
                          await provider.addSyllabus(
                            Syllabus(
                              className: selectedClass!,
                              section: selectedSection!,
                              subject: selectedSubject!,
                              fileName: uploadedFile!.name,
                              chapters: [],
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Syllabus submitted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error submitting syllabus. Please try again.'),
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