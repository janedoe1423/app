import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/assessment_model.dart';
import '../../../core/models/question_model.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/connectivity_utils.dart';

enum AiQuestionsStatus {
  initial,
  loading,
  generating,
  generated,
  saving,
  saved,
  error,
}

class AiQuestionsProvider with ChangeNotifier {
  final AiService _aiService;
  final ConnectivityUtils _connectivityUtils = ConnectivityUtils();
  final Uuid _uuid = const Uuid();
  
  bool _isOffline = false;
  AiQuestionsStatus _status = AiQuestionsStatus.initial;
  String? _errorMessage;
  
  // Generation parameters
  String _subject = '';
  String _topic = '';
  String _grade = '';
  String _language = 'English';
  int _numberOfQuestions = 5;
  
  // Generated questions
  List<QuestionModel> _generatedQuestions = [];
  
  // Saved assessments
  List<AssessmentModel> _assessments = [];
  
  // Getters
  bool get isOffline => _isOffline;
  AiQuestionsStatus get status => _status;
  String get errorMessage => _errorMessage ?? 'An error occurred';
  String get subject => _subject;
  String get topic => _topic;
  String get grade => _grade;
  String get language => _language;
  int get numberOfQuestions => _numberOfQuestions;
  List<QuestionModel> get generatedQuestions => _generatedQuestions;
  List<AssessmentModel> get assessments => _assessments;
  
  // Constructor with dependency injection for testing
  AiQuestionsProvider({
    AiService? aiService,
    ApiService? apiService,
  }) : _aiService = aiService ?? AiService();
  
  // Initialize the provider
  Future<void> init() async {
    await checkConnectivity();
    if (!_isOffline) {
      await fetchAssessments();
    }
  }
  
  // Check connectivity
  Future<void> checkConnectivity() async {
    final isConnected = await _connectivityUtils.isConnected();
    _isOffline = !isConnected;
    notifyListeners();
  }
  
  // Set parameters for generation
  void setParameters({
    required String subject,
    required String topic,
    required String grade,
    required String language,
    required int numberOfQuestions,
  }) {
    _subject = subject;
    _topic = topic;
    _grade = grade;
    _language = language;
    _numberOfQuestions = numberOfQuestions;
  }
  
  // Generate questions
  Future<void> generateQuestions() async {
    if (_isOffline) {
      _status = AiQuestionsStatus.error;
      _errorMessage = 'Cannot generate questions while offline';
      notifyListeners();
      return;
    }
    
    try {
      _status = AiQuestionsStatus.generating;
      _errorMessage = null;
      notifyListeners();
      
      final responses = await _aiService.generateMCQs(
        subject: _subject,
        topic: _topic,
        grade: _grade,
        language: _language,
        numberOfQuestions: _numberOfQuestions,
      );
      
      _generatedQuestions = _convertToQuestionModels(responses);
      _status = AiQuestionsStatus.generated;
    } catch (e) {
      _status = AiQuestionsStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error generating questions: $e');
    } finally {
      notifyListeners();
    }
  }
  
  // Convert API responses to QuestionModel objects
  List<QuestionModel> _convertToQuestionModels(List<Map<String, dynamic>> responses) {
    return responses.map((response) {
      final options = <OptionModel>[];
      final optionsMap = response['options'] as Map<String, dynamic>;
      
      // Extract options A, B, C, D
      for (final entry in optionsMap.entries) {
        options.add(OptionModel(
          id: entry.key,
          text: entry.value as String,
        ));
      }
      
      return QuestionModel(
        id: _uuid.v4(),
        text: response['question'] as String,
        type: QuestionType.singleChoice,
        options: options,
        correctAnswer: response['correctAnswer'] as String,
        explanation: response['explanation'] as String?,
        difficulty: _parseDifficulty(response['difficulty'] as String?),
        marks: 1,
      );
    }).toList();
  }
  
  // Parse difficulty level
  DifficultyLevel? _parseDifficulty(String? difficultyStr) {
    if (difficultyStr == null) return null;
    
    switch (difficultyStr.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return null;
    }
  }
  
  // Create assessment from generated questions
  Future<void> createAssessment({
    required String title,
    required String description,
    required AssessmentType type,
    required int durationMinutes,
    DateTime? startDate,
    DateTime? endDate,
    bool isPublished = false,
  }) async {
    if (_generatedQuestions.isEmpty) {
      _status = AiQuestionsStatus.error;
      _errorMessage = 'No questions to create an assessment';
      notifyListeners();
      return;
    }
    
    try {
      _status = AiQuestionsStatus.saving;
      notifyListeners();
      
      // In a real app, this would be a server call
      // For demo, we'll save to local storage
      
      final now = DateTime.now();
      final assessment = AssessmentModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        type: type,
        status: isPublished 
            ? AssessmentStatus.published 
            : AssessmentStatus.draft,
        createdById: 'current-user-id', // Would come from auth service
        questions: _generatedQuestions,
        createdAt: now,
        updatedAt: now,
        startDate: startDate,
        endDate: endDate,
        duration: durationMinutes > 0 
            ? Duration(minutes: durationMinutes) 
            : null,
      );
      
      // Save to local storage (mock API)
      await _saveAssessment(assessment);
      
      _assessments.add(assessment);
      _status = AiQuestionsStatus.saved;
      
      // Clear generated questions
      _generatedQuestions = [];
    } catch (e) {
      _status = AiQuestionsStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error creating assessment: $e');
    } finally {
      notifyListeners();
    }
  }
  
  // Mock save to storage
  Future<void> _saveAssessment(AssessmentModel assessment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = prefs.getStringList('assessments') ?? [];
      
      assessmentsJson.add(assessment.toJson().toString());
      await prefs.setStringList('assessments', assessmentsJson);
    } catch (e) {
      throw Exception('Failed to save assessment: $e');
    }
  }
  
  // Fetch assessments (mock API)
  Future<void> fetchAssessments() async {
    try {
      _status = AiQuestionsStatus.loading;
      notifyListeners();
      
      // In a real app, this would be a server call
      // For demo, we'll load from local storage
      
      final prefs = await SharedPreferences.getInstance();
      final assessmentsJson = prefs.getStringList('assessments') ?? [];
      
      // Would parse JSON in a real implementation
      // For now, return empty list
      _assessments = [];
      _status = AiQuestionsStatus.initial;
    } catch (e) {
      _status = AiQuestionsStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error fetching assessments: $e');
    } finally {
      notifyListeners();
    }
  }
  
  // Search assessments by title or description
  List<AssessmentModel> searchAssessments(String query) {
    if (query.isEmpty) return _assessments;
    
    final lowercaseQuery = query.toLowerCase();
    return _assessments.where((assessment) {
      final title = assessment.title.toLowerCase();
      final description = assessment.description?.toLowerCase() ?? '';
      
      return title.contains(lowercaseQuery) || 
             description.contains(lowercaseQuery);
    }).toList();
  }
  
  // Clear generated questions
  void clearGeneratedQuestions() {
    _generatedQuestions = [];
    _status = AiQuestionsStatus.initial;
    notifyListeners();
  }
  
  // Reset form
  void resetForm() {
    _status = AiQuestionsStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}

// A dropdown field widget based on AppTextField
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  
  const AppDropdownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint),
            isExpanded: true,
            underline: Container(), // Remove default underline
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}