import 'dart:convert';
import 'question_model.dart';

enum AssessmentType {
  quiz,
  test,
  exam,
  homework,
  practice,
}

enum AssessmentStatus {
  draft,
  published,
  scheduled,
  active,
  completed,
  archived,
}

class AssessmentModel {
  final String id;
  final String title;
  final String? description;
  final AssessmentType type;
  final AssessmentStatus status;
  final String createdById;
  final List<QuestionModel> questions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final Duration? duration;
  final int? maxAttempts;
  final double? passingScore;
  final bool? shuffleQuestions;
  final bool? showCorrectAnswers;
  final String? accessCode;
  
  AssessmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.createdById,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.endDate,
    this.duration,
    this.maxAttempts,
    this.passingScore,
    this.shuffleQuestions,
    this.showCorrectAnswers,
    this.accessCode,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'status': status.toString(),
      'createdById': createdById,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'duration': duration?.inMinutes,
      'maxAttempts': maxAttempts,
      'passingScore': passingScore,
      'shuffleQuestions': shuffleQuestions,
      'showCorrectAnswers': showCorrectAnswers,
      'accessCode': accessCode,
    };
  }
  
  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: _parseAssessmentType(json['type'] as String),
      status: _parseAssessmentStatus(json['status'] as String),
      createdById: json['createdById'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : null,
      maxAttempts: json['maxAttempts'] as int?,
      passingScore: json['passingScore'] as double?,
      shuffleQuestions: json['shuffleQuestions'] as bool?,
      showCorrectAnswers: json['showCorrectAnswers'] as bool?,
      accessCode: json['accessCode'] as String?,
    );
  }
  
  static AssessmentType _parseAssessmentType(String typeStr) {
    switch (typeStr.split('.').last) {
      case 'quiz':
        return AssessmentType.quiz;
      case 'test':
        return AssessmentType.test;
      case 'exam':
        return AssessmentType.exam;
      case 'homework':
        return AssessmentType.homework;
      case 'practice':
        return AssessmentType.practice;
      default:
        return AssessmentType.quiz;
    }
  }
  
  static AssessmentStatus _parseAssessmentStatus(String statusStr) {
    switch (statusStr.split('.').last) {
      case 'draft':
        return AssessmentStatus.draft;
      case 'published':
        return AssessmentStatus.published;
      case 'scheduled':
        return AssessmentStatus.scheduled;
      case 'active':
        return AssessmentStatus.active;
      case 'completed':
        return AssessmentStatus.completed;
      case 'archived':
        return AssessmentStatus.archived;
      default:
        return AssessmentStatus.draft;
    }
  }
  
  // Get the total marks for this assessment
  int get totalMarks {
    return questions.fold(0, (sum, question) => sum + question.marks);
  }
  
  // Get the time remaining in minutes if assessment has a duration and start date
  int? get timeRemainingMinutes {
    if (duration == null || startDate == null) return null;
    
    final now = DateTime.now();
    if (now.isBefore(startDate!)) return duration!.inMinutes;
    
    final endTime = startDate!.add(duration!);
    if (now.isAfter(endTime)) return 0;
    
    return endTime.difference(now).inMinutes;
  }
  
  // Check if the assessment is currently active
  bool get isActive {
    if (status != AssessmentStatus.published && 
        status != AssessmentStatus.active) {
      return false;
    }
    
    final now = DateTime.now();
    
    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }
    
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }
    
    return true;
  }
}