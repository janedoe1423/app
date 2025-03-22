import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../models/syllabus.dart';

class ViewSyllabusScreen extends StatelessWidget {
  const ViewSyllabusScreen({super.key});

  void _showSyllabusDetails(BuildContext context, Syllabus syllabus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SyllabusDetailScreen(syllabus: syllabus),
      ),
    );
  }

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
          if (syllabi.isEmpty) {
            return const Center(
              child: Text('No syllabi available'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: syllabi.length,
            itemBuilder: (context, index) {
              final syllabus = syllabi[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ExpansionTile(
                  title: Text('${syllabus.className} - Section ${syllabus.section}'),
                  subtitle: Text(syllabus.subject),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('File: ${syllabus.fileName}'),
                          Text('Updated: ${syllabus.updatedAt.toString().split('.')[0]}'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Topics:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${syllabus.topics.length} topics',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: syllabus.topics.length,
                            itemBuilder: (context, topicIndex) {
                              return ListTile(
                                title: Text(syllabus.topics[topicIndex]),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showSyllabusDetails(context, syllabus),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to delete this syllabus?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true && context.mounted) {
                            await dbProvider.deleteSyllabus(
                              syllabus.className,
                              syllabus.section,
                              syllabus.subject,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Syllabus deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
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
          Navigator.pushNamed(context, '/add-syllabus');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SyllabusDetailScreen extends StatefulWidget {
  final Syllabus syllabus;

  const SyllabusDetailScreen({
    super.key,
    required this.syllabus,
  });

  @override
  State<SyllabusDetailScreen> createState() => _SyllabusDetailScreenState();
}

class _SyllabusDetailScreenState extends State<SyllabusDetailScreen> {
  late List<String> topics;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    topics = List.from(widget.syllabus.topics);
  }

  void _editTopic(int index) {
    final TextEditingController controller = TextEditingController(text: topics[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Topic'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Topic Name',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                topics[index] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    try {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      final updatedSyllabus = Syllabus(
        className: widget.syllabus.className,
        section: widget.syllabus.section,
        subject: widget.syllabus.subject,
        fileName: widget.syllabus.fileName,
        topics: topics,
        createdAt: widget.syllabus.createdAt,
        updatedAt: DateTime.now(),
      );

      await provider.updateSyllabus(updatedSyllabus);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Syllabus updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating syllabus: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class: ${widget.syllabus.className}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Section: ${widget.syllabus.section}'),
                    Text('Subject: ${widget.syllabus.subject}'),
                    Text('File: ${widget.syllabus.fileName}'),
                    Text('Created: ${widget.syllabus.createdAt.toString().split('.')[0]}'),
                    Text('Updated: ${widget.syllabus.updatedAt.toString().split('.')[0]}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Topics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${topics.length} topics',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEditing)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return Card(
                    key: Key('$index'),
                    child: ListTile(
                      title: Text(topics[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTopic(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                topics.removeAt(index);
                              });
                            },
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = topics.removeAt(oldIndex);
                    topics.insert(newIndex, item);
                  });
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(topics[index]),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
} 