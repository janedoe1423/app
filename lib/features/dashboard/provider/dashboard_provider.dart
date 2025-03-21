import 'package:flutter/foundation.dart';
import '../../../core/models/assessment_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  // This would be injected in a real app
  // final ApiService _apiService;
  
  bool _isLoading = false;
  String? _error;
  List<dynamic>? _upcomingAssessments;
  List<dynamic>? _recentActivities;
  Map<String, dynamic>? _performanceMetrics;
  List<dynamic>? _classrooms;
  
  // For now, use mock data since we don't have an API service
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic>? get upcomingAssessments => _upcomingAssessments;
  List<dynamic>? get recentActivities => _recentActivities;
  Map<String, dynamic>? get performanceMetrics => _performanceMetrics;
  List<dynamic>? get classrooms => _classrooms;
  
  // Load dashboard data for a specific user
  Future<void> loadDashboardDataForUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // In a real app, we would call an API to get this data
      // For demo purposes, we'll create mock data based on the user
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (user.isTeacher) {
        _loadTeacherDashboard(user);
      } else {
        _loadStudentDashboard(user);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load generic dashboard data (when user is not specified)
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // In a real app, we would call an API to get this data
      // For demo purposes, we'll create mock data
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock empty state for now
      _upcomingAssessments = [];
      _recentActivities = [];
      _performanceMetrics = {};
      _classrooms = [];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load dashboard data for a teacher
  void _loadTeacherDashboard(UserModel teacher) {
    // Mock data for teacher dashboard
    _upcomingAssessments = [];
    _recentActivities = [];
    _performanceMetrics = {
      'students': 86,
      'classes': 4,
      'assignments': 12,
      'assessments': 8,
    };
    _classrooms = [
      {
        'id': '1',
        'name': 'Mathematics 101',
        'studentCount': 32,
        'grade': '10th Grade',
        'subject': 'Mathematics',
        'color': 'blue',
      },
      {
        'id': '2',
        'name': 'Physics 202',
        'studentCount': 28,
        'grade': '12th Grade',
        'subject': 'Physics',
        'color': 'green',
      },
      {
        'id': '3',
        'name': 'Computer Science',
        'studentCount': 35,
        'grade': '11th Grade',
        'subject': 'Computer Science',
        'color': 'orange',
      },
    ];
  }
  
  // Load dashboard data for a student
  void _loadStudentDashboard(UserModel student) {
    // Mock data for student dashboard
    _upcomingAssessments = [];
    _recentActivities = [];
    _performanceMetrics = {
      'overall': 95,
      'quizzes': 87,
      'assignments': 92,
      'attendance': 98,
    };
    _classrooms = [
      {
        'id': '1',
        'name': 'Mathematics 101',
        'teacher': 'Dr. Sarah Johnson',
        'grade': '10th Grade',
        'subject': 'Mathematics',
        'color': 'blue',
      },
      {
        'id': '2',
        'name': 'Physics 202',
        'teacher': 'Prof. Michael Chen',
        'grade': '10th Grade',
        'subject': 'Physics',
        'color': 'green',
      },
      {
        'id': '3',
        'name': 'Computer Science',
        'teacher': 'Ms. Emily Rodriguez',
        'grade': '10th Grade',
        'subject': 'Computer Science',
        'color': 'orange',
      },
    ];
  }
  
  // Clear dashboard data
  void clearDashboardData() {
    _upcomingAssessments = null;
    _recentActivities = null;
    _performanceMetrics = null;
    _classrooms = null;
    notifyListeners();
  }
  
  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}