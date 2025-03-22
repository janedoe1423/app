import 'package:flutter/foundation.dart';

class Assessment {
  final String id;
  final String className;
  final String subject;
  final String chapter;
  final DateTime startTime;
  final DateTime endTime;
  final int questionCount;
  final int duration;
  final Map<String, double> subtopicWeightage;
  final String status; // 'scheduled', 'active', 'completed'
  final Map<String, dynamic>? results;
  final List<String> selectedSubtopics;

  Assessment({
    required this.id,
    required this.className,
    required this.subject,
    required this.chapter,
    required this.startTime,
    required this.endTime,
    required this.questionCount,
    required this.duration,
    required this.subtopicWeightage,
    this.status = 'scheduled',
    this.results,
    required this.selectedSubtopics,
  });
}

class AssessmentProvider with ChangeNotifier {
  final List<Assessment> _assessments = [];
  final Map<String, List<String>> _questionBank = {};

  // Getters
  List<Assessment> get activeAssessments => _assessments
      .where((a) => a.status == 'active' && 
          a.startTime.isBefore(DateTime.now()) &&
          a.endTime.isAfter(DateTime.now()))
      .toList();

  List<Assessment> get completedAssessments =>
      _assessments.where((a) => a.status == 'completed').toList();

  List<Assessment> getClassAssessments(String className) =>
      _assessments.where((a) => a.className == className).toList();

  List<Assessment> get upcomingAssessments => _assessments
      .where((a) => a.status == 'scheduled' && 
          a.startTime.isAfter(DateTime.now()))
      .toList();

  double getOverallProgress() {
    final completed = completedAssessments;
    if (completed.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    for (var assessment in completed) {
      totalScore += assessment.results?['score'] as double? ?? 0.0;
    }
    return totalScore / completed.length;
  }

  Map<String, double> getSubjectWisePerformance() {
    final completed = completedAssessments;
    if (completed.isEmpty) return {};

    final Map<String, List<double>> subjectScores = {};
    for (var assessment in completed) {
      final score = assessment.results?['score'] as double? ?? 0.0;
      subjectScores.putIfAbsent(assessment.subject, () => []).add(score);
    }

    return Map.fromEntries(
      subjectScores.entries.map(
        (e) => MapEntry(
          e.key,
          e.value.reduce((a, b) => a + b) / e.value.length,
        ),
      ),
    );
  }

  Map<String, double> getClassPerformance(String className) {
    final classAssessments = getClassAssessments(className);
    if (classAssessments.isEmpty) return {};

    final Map<String, List<double>> subjectScores = {};
    for (var assessment in classAssessments) {
      if (assessment.results != null) {
        final score = assessment.results!['score'] as double? ?? 0.0;
        subjectScores.putIfAbsent(assessment.subject, () => []).add(score);
      }
    }

    return Map.fromEntries(
      subjectScores.entries.map(
        (e) => MapEntry(
          e.key,
          e.value.reduce((a, b) => a + b) / e.value.length,
        ),
      ),
    );
  }

  List<String>? getQuestionsForTopic(String topic) {
    return _questionBank[topic];
  }

  // For Teachers: Create assessment from existing question bank
  Future<void> createAssessment({
    required String className,
    required String subject,
    required String chapter,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> selectedSubtopics,
  }) async {
    // Verify questions exist in question bank
    final questionKey = '$subject-$chapter';
    if (!_questionBank.containsKey(questionKey)) {
      throw Exception('No questions available for this topic. Please contact admin.');
    }

    if (_questionBank[questionKey]!.length < selectedSubtopics.length) {
      throw Exception('Not enough questions available. Please reduce question count or contact admin.');
    }

    final assessment = Assessment(
      id: DateTime.now().toString(),
      className: className,
      subject: subject,
      chapter: chapter,
      selectedSubtopics: selectedSubtopics,
      startTime: startTime,
      endTime: endTime,
      questionCount: selectedSubtopics.length,
      duration: 0, // Assuming duration is not provided in the new method
      subtopicWeightage: {},
      status: 'scheduled',
    );

    _assessments.add(assessment);
    notifyListeners();
  }

  // For Admin: Add questions to question bank
  Future<void> addQuestionsToBank(String topic, List<String> questions) async {
    _questionBank[topic] = questions;
    notifyListeners();
  }

  // Get questions for an assessment (used when student takes assessment)
  List<String>? getQuestionsForAssessment(Assessment assessment) {
    final key = '${assessment.subject}-${assessment.chapter}';
    final questions = _questionBank[key];
    if (questions == null) return null;

    // Randomly select questions based on count and weightage
    // TODO: Implement proper question selection algorithm
    return questions.take(assessment.questionCount).toList();
  }

  // Update assessment status and results
  Future<void> updateAssessment(Assessment assessment) async {
    final index = _assessments.indexWhere((a) => a.id == assessment.id);
    if (index != -1) {
      _assessments[index] = assessment;
      notifyListeners();
    }
  }

  // Get performance analytics
  Map<String, double> getStudentPerformance(String studentId) {
    // TODO: Implement actual analytics
    return {
      'Overall': 85.0,
      'Mathematics': 90.0,
      'Physics': 80.0,
      'Chemistry': 85.0,
    };
  }

  // Refresh assessments (e.g., update status based on time)
  Future<void> refreshAssessments() async {
    final now = DateTime.now();
    for (var assessment in _assessments) {
      if (assessment.status != 'completed') {
        if (now.isAfter(assessment.startTime) && now.isBefore(assessment.endTime)) {
          assessment = Assessment(
            id: assessment.id,
            className: assessment.className,
            subject: assessment.subject,
            chapter: assessment.chapter,
            startTime: assessment.startTime,
            endTime: assessment.endTime,
            questionCount: assessment.questionCount,
            duration: assessment.duration,
            subtopicWeightage: assessment.subtopicWeightage,
            status: 'active',
            selectedSubtopics: assessment.selectedSubtopics,
          );
        } else if (now.isAfter(assessment.endTime)) {
          assessment = Assessment(
            id: assessment.id,
            className: assessment.className,
            subject: assessment.subject,
            chapter: assessment.chapter,
            startTime: assessment.startTime,
            endTime: assessment.endTime,
            questionCount: assessment.questionCount,
            duration: assessment.duration,
            subtopicWeightage: assessment.subtopicWeightage,
            status: 'completed',
            selectedSubtopics: assessment.selectedSubtopics,
          );
        }
      }
    }
    notifyListeners();
  }
} 