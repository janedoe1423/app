import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/assessment_model.dart';
import '../../../core/models/question_model.dart';
import '../provider/ai_questions_provider.dart';
import '../../auth/provider/auth_provider.dart';

class AiQuestionsScreen extends StatefulWidget {
  const AiQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<AiQuestionsScreen> createState() => _AiQuestionsScreenState();
}

class _AiQuestionsScreenState extends State<AiQuestionsScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _searchController = TextEditingController();
  
  late TabController _tabController;
  String _selectedGrade = 'Grade 8';
  String _selectedLanguage = 'English';
  int _numberOfQuestions = 5;
  
  bool _isCreatingAssessment = false;
  final _assessmentTitleController = TextEditingController();
  final _assessmentDescriptionController = TextEditingController();
  int _assessmentDuration = 30;
  DateTime? _scheduledDate;
  DateTime? _expiryDate;
  bool _isPublished = false;
  
  final List<String> _grades = [
    'Kindergarten',
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5',
    'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10',
    'Grade 11', 'Grade 12',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiQuestionsProvider>(context, listen: false).init();
    });
  }
  
  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _assessmentTitleController.dispose();
    _assessmentDescriptionController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _tabController.index == 0 
          ? null
          : AppBar(
              title: const Text('My Assessments'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _showSearchDialog();
                  },
                ),
              ],
            ),
      body: Consumer<AiQuestionsProvider>(
        builder: (context, provider, _) {
          // Show offline banner if offline
          if (provider.isOffline) {
            return Column(
              children: [
                OfflineBanner(
                  isOffline: true,
                  onRetry: () => provider.checkConnectivity(),
                ),
                Expanded(
                  child: _buildTabsContent(provider),
                ),
              ],
            );
          }
          
          return _buildTabsContent(provider);
        },
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        onTap: (index) {
          setState(() {
            // Reset creation form when switching tabs
            if (index == 0) {
              _isCreatingAssessment = false;
            }
          });
        },
        tabs: const [
          Tab(
            icon: Icon(Icons.create),
            text: 'Generate',
          ),
          Tab(
            icon: Icon(Icons.assignment),
            text: 'Assessments',
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabsContent(AiQuestionsProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Generate Tab
        _buildGenerateTab(provider),
        
        // Assessments Tab
        _buildAssessmentsTab(provider),
      ],
    );
  }
  
  Widget _buildGenerateTab(AiQuestionsProvider provider) {
    // If we're creating an assessment from generated questions
    if (_isCreatingAssessment) {
      return _buildCreateAssessmentForm(provider);
    }
    
    // If questions have been generated
    if (provider.status == AiQuestionsStatus.generated) {
      return _buildGeneratedQuestions(provider);
    }
    
    // Show error message
    if (provider.status == AiQuestionsStatus.error) {
      return AppErrorWidget(
        message: provider.errorMessage,
        onRetry: () => provider.resetForm(),
      );
    }
    
    // Show loading indicator while generating
    if (provider.status == AiQuestionsStatus.generating) {
      return const LoadingIndicator(
        message: 'Generating AI questions...\nThis may take a moment',
      );
    }
    
    // Default: show generation form
    return _buildGenerationForm(provider);
  }
  
  Widget _buildGenerationForm(AiQuestionsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate AI Questions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create relatable MCQs with real-life examples',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            
            // Subject Field
            AppTextField(
              label: 'Subject',
              hintText: 'e.g., Mathematics, Science, English, etc.',
              controller: _subjectController,
              prefixIcon: const Icon(Icons.subject),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Topic Field
            AppTextField(
              label: 'Topic',
              hintText: 'e.g., Fractions, Photosynthesis, etc.',
              controller: _topicController,
              prefixIcon: const Icon(Icons.topic),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a topic';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Grade Dropdown
            AppDropdownField<String>(
              label: 'Grade Level',
              hint: 'Select grade level',
              value: _selectedGrade,
              items: _grades.map((grade) {
                return DropdownMenuItem<String>(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGrade = value ?? _selectedGrade;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Language Dropdown
            AppDropdownField<String>(
              label: 'Language',
              hint: 'Select language',
              value: _selectedLanguage,
              items: AppConstants.supportedLanguages.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value ?? _selectedLanguage;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Number of Questions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number of Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _numberOfQuestions.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: _numberOfQuestions.toString(),
                        onChanged: (value) {
                          setState(() {
                            _numberOfQuestions = value.toInt();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _numberOfQuestions.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Generate Button
            AppButton(
              text: 'Generate Questions',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Set parameters and generate
                  provider.setParameters(
                    subject: _subjectController.text.trim(),
                    topic: _topicController.text.trim(),
                    grade: _selectedGrade,
                    language: _selectedLanguage,
                    numberOfQuestions: _numberOfQuestions,
                  );
                  provider.generateQuestions();
                }
              },
              isFullWidth: true,
            ),
            
            const SizedBox(height: 16),
            
            // Additional note
            Center(
              child: Text(
                'Questions will be generated with relatable real-life examples',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGeneratedQuestions(AiQuestionsProvider provider) {
    final questions = provider.generatedQuestions;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generated Questions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Subject: ${provider.subject}, Topic: ${provider.topic}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Grade: ${provider.grade}, Language: ${provider.language}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: questions.length + 1, // +1 for buttons at bottom
            itemBuilder: (context, index) {
              if (index == questions.length) {
                // Buttons at the bottom
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Create Assessment',
                          onPressed: () {
                            setState(() {
                              _isCreatingAssessment = true;
                              _assessmentTitleController.text = '${provider.subject} - ${provider.topic}';
                              _assessmentDescriptionController.text = 'Assessment on ${provider.topic} for ${provider.grade} students';
                            });
                          },
                          type: AppButtonType.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: 'Generate Again',
                          onPressed: () {
                            provider.clearGeneratedQuestions();
                          },
                          type: AppButtonType.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Question card
              final question = questions[index];
              final options = question.options ?? [];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Question ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    question.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ...options.map((option) {
                            final isCorrect = option.id == question.correctAnswer;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.transparent,
                                      border: Border.all(
                                        color: isCorrect ? Colors.green : Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      option.id,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isCorrect ? Colors.green : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(option.text),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                          if (question.explanation != null) ...[
                            Text(
                              'Explanation:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question.explanation!,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Difficulty: ${question.difficulty}',
                                style: TextStyle(
                                  color: question.difficulty == 'Easy'
                                      ? Colors.green
                                      : question.difficulty == 'Hard'
                                          ? Colors.red
                                          : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Edit question functionality
                                  // Not implemented in this MVP
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Edit question feature coming soon!'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCreateAssessmentForm(AiQuestionsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isCreatingAssessment = false;
                  });
                },
              ),
              Text(
                'Create Assessment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Assessment Title
          AppTextField(
            label: 'Assessment Title',
            hintText: 'Enter assessment title',
            controller: _assessmentTitleController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Assessment Description
          AppTextField(
            label: 'Description',
            hintText: 'Enter assessment description',
            controller: _assessmentDescriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          // Duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duration (minutes)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _assessmentDuration.toDouble(),
                      min: 5,
                      max: 180,
                      divisions: 35,
                      label: '$_assessmentDuration minutes',
                      onChanged: (value) {
                        setState(() {
                          _assessmentDuration = value.toInt();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_assessmentDuration',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Scheduled Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _scheduledDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _scheduledDate == null
                                  ? 'Select Date'
                                  : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _scheduledDate == null
                    ? null
                    : () {
                        setState(() {
                          _scheduledDate = null;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Expiry Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expiry Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _expiryDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              _expiryDate == null
                                  ? 'Select Date'
                                  : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _expiryDate == null
                    ? null
                    : () {
                        setState(() {
                          _expiryDate = null;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Published Status
          Row(
            children: [
              Checkbox(
                value: _isPublished,
                onChanged: (value) {
                  setState(() {
                    _isPublished = value ?? false;
                  });
                },
              ),
              const Text('Publish immediately'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Questions Summary
          Text(
            'Questions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.generatedQuestions.length} Question${provider.generatedQuestions.length > 1 ? 's' : ''} from "${provider.topic}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Subject: ${provider.subject}'),
                Text('Grade: ${provider.grade}'),
                Text('Language: ${provider.language}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Create Button
          AppButton(
            text: 'Create Assessment',
            onPressed: () async {
              // Validate
              if (_assessmentTitleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter an assessment title'),
                  ),
                );
                return;
              }
              
              // Create assessment
              final success = await provider.createAssessment(
                title: _assessmentTitleController.text,
                description: _assessmentDescriptionController.text,
                durationMinutes: _assessmentDuration,
                scheduledDate: _scheduledDate,
                expiryDate: _expiryDate,
                isPublished: _isPublished,
              );
              
              if (success) {
                // Reset and show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assessment created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Switch to assessments tab
                  setState(() {
                    _isCreatingAssessment = false;
                    _tabController.animateTo(1);
                  });
                }
              } else {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create assessment: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            isLoading: provider.status == AiQuestionsStatus.saving,
            isFullWidth: true,
          ),
          const SizedBox(height: 16),
          
          // Cancel Button
          AppButton(
            text: 'Cancel',
            onPressed: () {
              setState(() {
                _isCreatingAssessment = false;
              });
            },
            type: AppButtonType.outline,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssessmentsTab(AiQuestionsProvider provider) {
    if (provider.status == AiQuestionsStatus.loading) {
      return const LoadingIndicator(
        message: 'Loading assessments...',
      );
    }
    
    if (provider.status == AiQuestionsStatus.error) {
      return AppErrorWidget(
        message: provider.errorMessage,
        onRetry: () => provider.loadAssessments(),
      );
    }
    
    final assessments = provider.assessments;
    
    if (assessments.isEmpty) {
      return EmptyStateWidget(
        title: 'No Assessments',
        message: 'Create your first assessment by generating AI questions',
        icon: Icons.assignment,
        actionLabel: 'Create Assessment',
        onAction: () {
          _tabController.animateTo(0);
        },
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.loadAssessments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assessments.length,
        itemBuilder: (context, index) {
          final assessment = assessments[index];
          
          // Determine status color
          final status = assessment.getStatus();
          Color statusColor;
          
          switch (status) {
            case AssessmentStatus.draft:
              statusColor = Colors.grey;
              break;
            case AssessmentStatus.scheduled:
              statusColor = Colors.blue;
              break;
            case AssessmentStatus.active:
              statusColor = Colors.green;
              break;
            case AssessmentStatus.expired:
              statusColor = Colors.red;
              break;
          }
          
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // View assessment details
                provider.getAssessmentDetails(assessment.id);
                _showAssessmentDetailsDialog(assessment);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assessment.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toString().split('.').last,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assessment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          Icons.subject,
                          assessment.subject,
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          Icons.school,
                          assessment.grade,
                          Colors.purple,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          Icons.question_answer,
                          '${assessment.questionCount} Q',
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          Icons.timer,
                          '${assessment.durationMinutes} min',
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status == AssessmentStatus.draft || status == AssessmentStatus.scheduled) ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Edit assessment
                              // Not implemented in this MVP
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit assessment feature coming soon!'),
                                ),
                              );
                            },
                            color: Colors.blue,
                            tooltip: 'Edit',
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            // Share assessment
                            // Not implemented in this MVP
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share assessment feature coming soon!'),
                              ),
                            );
                          },
                          color: Colors.green,
                          tooltip: 'Share',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Confirm delete
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Assessment'),
                                content: const Text('Are you sure you want to delete this assessment?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ?? false;
                            
                            if (confirmed) {
                              // Delete assessment
                              final success = await provider.deleteAssessment(assessment.id);
                              
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Assessment deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete assessment: ${provider.errorMessage}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          color: Colors.red,
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showAssessmentDetailsDialog(AssessmentModel assessment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            assessment.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assessment.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailsRow('Subject', assessment.subject),
                    _buildDetailsRow('Grade', assessment.grade),
                    _buildDetailsRow('Questions', assessment.questionCount.toString()),
                    _buildDetailsRow('Duration', '${assessment.durationMinutes} minutes'),
                    _buildDetailsRow('Status', assessment.getStatus().toString().split('.').last),
                    if (assessment.scheduledDate != null)
                      _buildDetailsRow(
                        'Scheduled Date',
                        '${assessment.scheduledDate!.day}/${assessment.scheduledDate!.month}/${assessment.scheduledDate!.year}',
                      ),
                    if (assessment.expiryDate != null)
                      _buildDetailsRow(
                        'Expiry Date',
                        '${assessment.expiryDate!.day}/${assessment.expiryDate!.month}/${assessment.expiryDate!.year}',
                      ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Questions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: assessment.questions.length,
                      itemBuilder: (context, index) {
                        final question = assessment.questions[index];
                        return ExpansionTile(
                          title: Text(
                            'Question ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            question.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(question.text),
                                  const SizedBox(height: 16),
                                  if (question.options != null) ...[
                                    ...question.options!.map((option) {
                                      final isCorrect = option.id == question.correctAnswer;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.transparent,
                                                border: Border.all(
                                                  color: isCorrect ? Colors.green : Colors.grey.shade400,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                option.id,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isCorrect ? Colors.green : Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(option.text),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  if (question.explanation != null) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      'Explanation:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      question.explanation!,
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.print),
                            label: const Text('Print'),
                            onPressed: () {
                              // Print assessment
                              // Not implemented in this MVP
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Print feature coming soon!'),
                                ),
                              );
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            onPressed: () {
                              // Share assessment
                              // Not implemented in this MVP
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Share feature coming soon!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Assessments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Search',
                hintText: 'Enter title, subject, or topic',
                controller: _searchController,
                prefixIcon: const Icon(Icons.search),
              ),
              const SizedBox(height: 16),
              const Text(
                'Search by title, subject, topic, or grade',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Search functionality
                // Not implemented in this MVP
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search feature coming soon!'),
                  ),
                );
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
