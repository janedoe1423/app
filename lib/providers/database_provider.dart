import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/syllabus.dart';
import '../models/question.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Syllabus> _syllabi = [];
  List<Question> _questions = [];

  List<Syllabus> get syllabi => _syllabi;
  List<Question> get questions => _questions;

  Future<void> initDatabase() async {
    await _db.init();
    await refreshSyllabi();
    await refreshQuestions();
  }

  Future<void> refreshSyllabi() async {
    _syllabi = await _db.getAllSyllabi();
    notifyListeners();
  }

  Future<void> refreshQuestions() async {
    _questions = await _db.getQuestions();
    notifyListeners();
  }

  Future<void> addSyllabus(Syllabus syllabus) async {
    await _db.addSyllabus(syllabus);
    await refreshSyllabi();
  }

  Future<void> updateSyllabus(Syllabus syllabus) async {
    await _db.updateSyllabus(syllabus);
    await refreshSyllabi();
  }

  Future<void> deleteSyllabus(String className, String section, String subject) async {
    await _db.deleteSyllabus(className, section, subject);
    await refreshSyllabi();
  }

  Future<void> addQuestion(Question question) async {
    await _db.addQuestion(question);
    await refreshQuestions();
  }

  List<Question> getQuestionsForSyllabus(Syllabus syllabus) {
    return _questions.where((q) =>
        q.className == syllabus.className &&
        q.subject == syllabus.subject).toList();
  }
} 