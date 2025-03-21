import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/performance_model.dart';
import '../../../core/utils/connectivity_utils.dart';

enum AnalyticsStatus {
  initial,
  loading,
  loaded,
  error,
}

class AnalyticsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AnalyticsStatus _status = AnalyticsStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;
  
  // Performance data
  PerformanceModel? _studentPerformance;
  ClassPerformanceModel? _classPerformance;
  
  // Selected filters
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedGrade;
  String? _selectedStudent;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Getters
  AnalyticsStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  PerformanceModel? get studentPerformance => _studentPerformance;
  ClassPerformanceModel? get classPerformance => _classPerformance;
  
  String? get selectedSubject => _selectedSubject;
  String? get selectedClass => _selectedClass;
  String? get selectedGrade => _selectedGrade;
  String? get selectedStudent => _selectedStudent;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  
  // Initialize with user data
  Future<void> init(String userId, String userRole) async {
    _status = AnalyticsStatus.loading;
    _isOffline = !(await ConnectivityUtils.isConnected());
    notifyListeners();
    
    try {
      if (userRole == 'teacher') {
        // Default: get all classes for this teacher
        if (_selectedClass == null) {
          await loadTeacherClasses(userId);
        } else {
          await loadClassPerformance(userId, _selectedClass!);
        }
      } else if (userRole == 'student') {
        await loadStudentPerformance(userId);
      }
    } catch (e) {
      _status = AnalyticsStatus.error;
      _errorMessage = e.toString();
      debugPrint('Analytics init error: $_errorMessage');
    }
    
    notifyListeners();
  }
  
  // Load student performance data
  Future<void> loadStudentPerformance(String studentId, {String? subject}) async {
    _status = AnalyticsStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      // Build endpoint with optional subject filter
      final endpoint = subject != null 
          ? '${AppConstants.performanceEndpoint}/student/$studentId?subject=$subject'
          : '${AppConstants.performanceEndpoint}/student/$studentId';
      
      if (_isOffline) {
        // Use mock data for offline mode
        _setMockStudentPerformance(studentId);
        _status = AnalyticsStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: endpoint,
        type: RequestType.get,
        cacheResponse: true,
      );
      
      _studentPerformance = PerformanceModel.fromJson(response);
      _selectedSubject = subject ?? _studentPerformance?.subject;
      
      _status = AnalyticsStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        _setMockStudentPerformance(studentId);
        _status = AnalyticsStatus.loaded;
      } else {
        _status = AnalyticsStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load student performance error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Load teacher's classes
  Future<void> loadTeacherClasses(String teacherId) async {
    _status = AnalyticsStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Use mock data for offline mode
        _setMockTeacherClasses();
        _status = AnalyticsStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/teacher/$teacherId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      // The response should contain a list of classes
      // For now, we'll just set status to loaded
      _status = AnalyticsStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        _setMockTeacherClasses();
        _status = AnalyticsStatus.loaded;
      } else {
        _status = AnalyticsStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load teacher classes error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Load class performance data
  Future<void> loadClassPerformance(String teacherId, String classId) async {
    _status = AnalyticsStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Use mock data for offline mode
        _setMockClassPerformance(classId);
        _status = AnalyticsStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.performanceEndpoint}/class/$classId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      _classPerformance = ClassPerformanceModel.fromJson(response);
      _selectedClass = classId;
      
      _status = AnalyticsStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        _setMockClassPerformance(classId);
        _status = AnalyticsStatus.loaded;
      } else {
        _status = AnalyticsStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load class performance error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Load student details for teacher view
  Future<void> loadStudentDetailsForTeacher(String studentId, String classId) async {
    _status = AnalyticsStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Use mock data for offline mode
        _setMockStudentPerformance(studentId);
        _status = AnalyticsStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.performanceEndpoint}/student/$studentId/class/$classId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      _studentPerformance = PerformanceModel.fromJson(response);
      _selectedStudent = studentId;
      
      _status = AnalyticsStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        _setMockStudentPerformance(studentId);
        _status = AnalyticsStatus.loaded;
      } else {
        _status = AnalyticsStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load student details error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Set filters for analytics data
  void setFilters({
    String? subject,
    String? classId,
    String? grade,
    String? student,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    bool shouldUpdate = false;
    
    if (subject != null && _selectedSubject != subject) {
      _selectedSubject = subject;
      shouldUpdate = true;
    }
    
    if (classId != null && _selectedClass != classId) {
      _selectedClass = classId;
      shouldUpdate = true;
    }
    
    if (grade != null && _selectedGrade != grade) {
      _selectedGrade = grade;
      shouldUpdate = true;
    }
    
    if (student != null && _selectedStudent != student) {
      _selectedStudent = student;
      shouldUpdate = true;
    }
    
    if (startDate != null && _startDate != startDate) {
      _startDate = startDate;
      shouldUpdate = true;
    }
    
    if (endDate != null && _endDate != endDate) {
      _endDate = endDate;
      shouldUpdate = true;
    }
    
    if (shouldUpdate) {
      notifyListeners();
    }
  }
  
  // Clear filters
  void clearFilters() {
    _selectedSubject = null;
    _selectedClass = null;
    _selectedGrade = null;
    _selectedStudent = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }
  
  // Refresh data based on current selections
  Future<void> refreshData(String userId, String userRole) async {
    await init(userId, userRole);
  }
  
  // Check connectivity
  Future<void> checkConnectivity() async {
    final wasOffline = _isOffline;
    _isOffline = !(await ConnectivityUtils.isConnected());
    
    if (wasOffline && !_isOffline) {
      // We're back online, refresh data
      if (_studentPerformance != null) {
        await loadStudentPerformance(_studentPerformance!.studentId, subject: _selectedSubject);
      } else if (_classPerformance != null) {
        await loadClassPerformance(_classPerformance!.teacherId, _classPerformance!.classId);
      }
    } else if (_isOffline != wasOffline) {
      // Just update offline status
      notifyListeners();
    }
  }
  
  // Mock data methods for offline mode
  void _setMockStudentPerformance(String studentId) {
    _studentPerformance = PerformanceModel(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: 'John Doe',
      subject: 'Mathematics',
      grade: 'Grade 8',
      topicPerformances: {
        'Algebra': TopicPerformance(
          averageScore: 85.5,
          questionsAttempted: 20,
          questionsCorrect: 17,
          lastAttempted: DateTime.now().subtract(const Duration(days: 5)),
        ),
        'Geometry': TopicPerformance(
          averageScore: 92.0,
          questionsAttempted: 15,
          questionsCorrect: 14,
          lastAttempted: DateTime.now().subtract(const Duration(days: 2)),
        ),
        'Statistics': TopicPerformance(
          averageScore: 65.0,
          questionsAttempted: 10,
          questionsCorrect: 6,
          lastAttempted: DateTime.now().subtract(const Duration(days: 10)),
        ),
        'Calculus': TopicPerformance(
          averageScore: 78.0,
          questionsAttempted: 18,
          questionsCorrect: 14,
          lastAttempted: DateTime.now().subtract(const Duration(days: 7)),
        ),
      },
      assessmentPerformances: [
        AssessmentPerformance(
          assessmentId: 'a1',
          assessmentTitle: 'Mid-term Assessment',
          date: DateTime.now().subtract(const Duration(days: 30)),
          score: 82.0,
          totalQuestions: 20,
          correctAnswers: 16,
          timeSpentSeconds: 1800,
        ),
        AssessmentPerformance(
          assessmentId: 'a2',
          assessmentTitle: 'Linear Equations Quiz',
          date: DateTime.now().subtract(const Duration(days: 15)),
          score: 90.0,
          totalQuestions: 10,
          correctAnswers: 9,
          timeSpentSeconds: 900,
        ),
        AssessmentPerformance(
          assessmentId: 'a3',
          assessmentTitle: 'Geometry Test',
          date: DateTime.now().subtract(const Duration(days: 5)),
          score: 85.0,
          totalQuestions: 15,
          correctAnswers: 13,
          timeSpentSeconds: 1200,
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }
  
  void _setMockClassPerformance(String classId) {
    _classPerformance = ClassPerformanceModel(
      classId: classId,
      className: 'Class 8A',
      subject: 'Mathematics',
      grade: 'Grade 8',
      teacherId: 'teacher-001',
      studentPerformances: [
        StudentPerformanceSummary(
          studentId: 'student-001',
          studentName: 'Alice Johnson',
          averageScore: 92.5,
          assessmentsCompleted: 10,
          questionsAttempted: 150,
          questionsCorrect: 138,
          lastAssessmentDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        StudentPerformanceSummary(
          studentId: 'student-002',
          studentName: 'Bob Smith',
          averageScore: 78.0,
          assessmentsCompleted: 9,
          questionsAttempted: 135,
          questionsCorrect: 105,
          lastAssessmentDate: DateTime.now().subtract(const Duration(days: 3)),
        ),
        StudentPerformanceSummary(
          studentId: 'student-003',
          studentName: 'Carol Williams',
          averageScore: 85.5,
          assessmentsCompleted: 10,
          questionsAttempted: 150,
          questionsCorrect: 128,
          lastAssessmentDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        StudentPerformanceSummary(
          studentId: 'student-004',
          studentName: 'Dave Brown',
          averageScore: 65.0,
          assessmentsCompleted: 8,
          questionsAttempted: 120,
          questionsCorrect: 78,
          lastAssessmentDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        StudentPerformanceSummary(
          studentId: 'student-005',
          studentName: 'Eva Martinez',
          averageScore: 88.0,
          assessmentsCompleted: 10,
          questionsAttempted: 150,
          questionsCorrect: 132,
          lastAssessmentDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      topicPerformances: {
        'Algebra': TopicPerformanceSummary(
          classAverageScore: 82.0,
          totalStudents: 25,
          studentsStruggling: 5,
          studentsMastered: 15,
        ),
        'Geometry': TopicPerformanceSummary(
          classAverageScore: 88.0,
          totalStudents: 25,
          studentsStruggling: 3,
          studentsMastered: 18,
        ),
        'Statistics': TopicPerformanceSummary(
          classAverageScore: 72.0,
          totalStudents: 25,
          studentsStruggling: 8,
          studentsMastered: 10,
        ),
        'Calculus': TopicPerformanceSummary(
          classAverageScore: 68.0,
          totalStudents: 25,
          studentsStruggling: 10,
          studentsMastered: 8,
        ),
      },
      assessmentPerformances: [
        AssessmentPerformanceSummary(
          assessmentId: 'a1',
          assessmentTitle: 'Mid-term Assessment',
          date: DateTime.now().subtract(const Duration(days: 30)),
          classAverageScore: 78.5,
          totalStudents: 25,
          studentsCompleted: 25,
          highestScore: 98,
          lowestScore: 55,
        ),
        AssessmentPerformanceSummary(
          assessmentId: 'a2',
          assessmentTitle: 'Linear Equations Quiz',
          date: DateTime.now().subtract(const Duration(days: 15)),
          classAverageScore: 82.0,
          totalStudents: 25,
          studentsCompleted: 24,
          highestScore: 100,
          lowestScore: 60,
        ),
        AssessmentPerformanceSummary(
          assessmentId: 'a3',
          assessmentTitle: 'Geometry Test',
          date: DateTime.now().subtract(const Duration(days: 5)),
          classAverageScore: 85.0,
          totalStudents: 25,
          studentsCompleted: 25,
          highestScore: 100,
          lowestScore: 65,
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }
  
  void _setMockTeacherClasses() {
    // No implementation needed yet, as we don't have a model for the list of classes
    // This would populate a list of classes for the teacher
  }
}
