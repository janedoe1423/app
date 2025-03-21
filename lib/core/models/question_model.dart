import 'dart:convert';

enum QuestionType {
  singleChoice,
  multipleChoice,
  trueFalse,
  shortAnswer,
  longAnswer,
  matching,
  ordering,
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

class OptionModel {
  final String id;
  final String text;
  
  OptionModel({
    required this.id,
    required this.text,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
  
  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }
}

class QuestionModel {
  final String id;
  final String text;
  final QuestionType type;
  final List<OptionModel>? options;
  final String? correctAnswer; // For single choice, could be option ID
  final List<String>? correctAnswers; // For multiple choice, list of option IDs
  final String? explanation;
  final DifficultyLevel? difficulty;
  final int marks;
  final String? imageUrl;
  final String? audioUrl;
  
  QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.correctAnswer,
    this.correctAnswers,
    this.explanation,
    this.difficulty,
    this.marks = 1,
    this.imageUrl,
    this.audioUrl,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString(),
      'options': options?.map((e) => e.toJson()).toList(),
      'correctAnswer': correctAnswer,
      'correctAnswers': correctAnswers,
      'explanation': explanation,
      'difficulty': difficulty?.toString(),
      'marks': marks,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }
  
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      type: _parseQuestionType(json['type'] as String),
      options: json['options'] != null
          ? (json['options'] as List)
              .map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      correctAnswer: json['correctAnswer'] as String?,
      correctAnswers: json['correctAnswers'] != null
          ? List<String>.from(json['correctAnswers'] as List)
          : null,
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] != null
          ? _parseDifficultyLevel(json['difficulty'] as String)
          : null,
      marks: json['marks'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }
  
  static QuestionType _parseQuestionType(String typeStr) {
    switch (typeStr.split('.').last) {
      case 'singleChoice':
        return QuestionType.singleChoice;
      case 'multipleChoice':
        return QuestionType.multipleChoice;
      case 'trueFalse':
        return QuestionType.trueFalse;
      case 'shortAnswer':
        return QuestionType.shortAnswer;
      case 'longAnswer':
        return QuestionType.longAnswer;
      case 'matching':
        return QuestionType.matching;
      case 'ordering':
        return QuestionType.ordering;
      default:
        return QuestionType.singleChoice;
    }
  }
  
  static DifficultyLevel _parseDifficultyLevel(String levelStr) {
    switch (levelStr.split('.').last) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium;
    }
  }
}