import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../models/syllabus.dart';
import '../models/question.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _dbFileName = 'temp_database.json';
  late Map<String, dynamic> _data;

  // Initialize database
  Future<void> init() async {
    if (kIsWeb) {
      // For web, initialize with empty data
      _data = {
        'syllabi': [],
        'questions': [],
      };
      // Add some sample data for testing
      _data['syllabi'].add({
        'className': 'Class 10',
        'section': 'A',
        'subject': 'Mathematics',
        'chapters': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } else {
      // For mobile platforms
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_dbFileName');
      
      if (await file.exists()) {
        final String contents = await file.readAsString();
        _data = json.decode(contents);
      } else {
        _data = {
          'syllabi': [],
          'questions': [],
        };
        await _saveData();
      }
    }
  }

  // Save data to file (only for mobile platforms)
  Future<void> _saveData() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_dbFileName');
      await file.writeAsString(json.encode(_data));
    }
  }

  // Syllabus Methods
  Future<void> addSyllabus(Syllabus syllabus) async {
    _data['syllabi'].add(syllabus.toMap());
    await _saveData();
  }

  Future<List<Syllabus>> getAllSyllabi() async {
    return (_data['syllabi'] as List)
        .map((map) => Syllabus.fromMap(map))
        .toList();
  }

  Future<void> updateSyllabus(Syllabus syllabus) async {
    final index = (_data['syllabi'] as List).indexWhere(
      (s) => s['className'] == syllabus.className && 
             s['section'] == syllabus.section &&
             s['subject'] == syllabus.subject
    );
    
    if (index != -1) {
      _data['syllabi'][index] = syllabus.toMap();
      await _saveData();
    }
  }

  Future<void> deleteSyllabus(String className, String section, String subject) async {
    _data['syllabi'].removeWhere(
      (s) => s['className'] == className && 
             s['section'] == section &&
             s['subject'] == subject
    );
    await _saveData();
  }

  // Question Methods
  Future<void> addQuestion(Question question) async {
    _data['questions'].add(question.toMap());
    await _saveData();
  }

  Future<List<Question>> getQuestions({
    String? className,
    String? subject,
    String? chapter,
  }) async {
    return (_data['questions'] as List)
        .where((q) =>
            (className == null || q['className'] == className) &&
            (subject == null || q['subject'] == subject) &&
            (chapter == null || q['chapterName'] == chapter))
        .map((map) => Question.fromMap(map))
        .toList();
  }
} 