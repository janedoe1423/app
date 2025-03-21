import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/connectivity_utils.dart';

enum ReportType {
  questionPaper,
  reportCard,
  performanceReport,
  attendanceReport,
}

enum ReportStatus {
  initial,
  loading,
  generating,
  generated,
  error,
}

class ReportsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AiService _aiService = AiService();
  
  ReportStatus _status = ReportStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;
  
  // Reports data
  Map<String, dynamic>? _generatedReport;
  List<Map<String, dynamic>> _savedReports = [];
  
  // Filters
  String? _selectedClass;
  String? _selectedSubject;
  String? _selectedGrade;
  String? _selectedStudent;
  ReportType _selectedReportType = ReportType.questionPaper;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Getters
  ReportStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  Map<String, dynamic>? get generatedReport => _generatedReport;
  List<Map<String, dynamic>> get savedReports => _savedReports;
  
  String? get selectedClass => _selectedClass;
  String? get selectedSubject => _selectedSubject;
  String? get selectedGrade => _selectedGrade;
  String? get selectedStudent => _selectedStudent;
  ReportType get selectedReportType => _selectedReportType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  
  // Initialize with user data
  Future<void> init(String userId, String userRole) async {
    _status = ReportStatus.loading;
    _isOffline = !(await ConnectivityUtils.isConnected());
    notifyListeners();
    
    try {
      if (!_isOffline) {
        await loadSavedReports(userId);
      } else {
        _setMockSavedReports(userRole);
        _status = ReportStatus.initial;
      }
    } catch (e) {
      _status = ReportStatus.error;
      _errorMessage = e.toString();
      debugPrint('Reports init error: $_errorMessage');
    }
    
    notifyListeners();
  }
  
  // Load saved reports
  Future<void> loadSavedReports(String userId) async {
    _status = ReportStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        _setMockSavedReports('teacher');
        _status = ReportStatus.initial;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.reportsEndpoint}/user/$userId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      final List<dynamic> reportsData = response['reports'];
      _savedReports = List<Map<String, dynamic>>.from(reportsData);
      
      _status = ReportStatus.initial;
    } catch (e) {
      if (_isOffline) {
        _setMockSavedReports('teacher');
        _status = ReportStatus.initial;
      } else {
        _status = ReportStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load saved reports error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Generate a report based on report type
  Future<void> generateReport({
    required String userId,
    required String userRole,
    required ReportType reportType,
    required Map<String, dynamic> parameters,
  }) async {
    _status = ReportStatus.generating;
    _errorMessage = '';
    _generatedReport = null;
    _selectedReportType = reportType;
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        throw Exception('Cannot generate reports while offline');
      }
      
      switch (reportType) {
        case ReportType.questionPaper:
          await _generateQuestionPaper(parameters);
          break;
        case ReportType.reportCard:
          await _generateReportCard(parameters);
          break;
        case ReportType.performanceReport:
          await _generatePerformanceReport(parameters);
          break;
        case ReportType.attendanceReport:
          await _generateAttendanceReport(parameters);
          break;
      }
      
      _status = ReportStatus.generated;
    } catch (e) {
      _status = ReportStatus.error;
      _errorMessage = e.toString();
      debugPrint('Generate report error: $_errorMessage');
    }
    
    notifyListeners();
  }
  
  // Generate question paper
  Future<void> _generateQuestionPaper(Map<String, dynamic> parameters) async {
    try {
      final questionPaper = await _aiService.generateQuestionPaper(
        subject: parameters['subject'],
        topics: List<String>.from(parameters['topics']),
        grade: parameters['grade'],
        language: parameters['language'] ?? 'English',
        totalMarks: parameters['totalMarks'] ?? 100,
        duration: parameters['duration'] ?? 60,
      );
      
      _generatedReport = {
        'type': 'question_paper',
        'data': questionPaper,
        'metadata': {
          'subject': parameters['subject'],
          'grade': parameters['grade'],
          'topics': parameters['topics'],
          'total_marks': parameters['totalMarks'] ?? 100,
          'duration': parameters['duration'] ?? 60,
          'language': parameters['language'] ?? 'English',
          'generated_at': DateTime.now().toIso8601String(),
        }
      };
    } catch (e) {
      rethrow;
    }
  }
  
  // Generate report card
  Future<void> _generateReportCard(Map<String, dynamic> parameters) async {
    try {
      final response = await _apiService.request(
        endpoint: '${AppConstants.reportsEndpoint}/report-card',
        type: RequestType.post,
        data: parameters,
      );
      
      _generatedReport = {
        'type': 'report_card',
        'data': response,
        'metadata': {
          'student_id': parameters['studentId'],
          'student_name': parameters['studentName'],
          'grade': parameters['grade'],
          'term': parameters['term'],
          'academic_year': parameters['academicYear'],
          'generated_at': DateTime.now().toIso8601String(),
        }
      };
    } catch (e) {
      rethrow;
    }
  }
  
  // Generate performance report
  Future<void> _generatePerformanceReport(Map<String, dynamic> parameters) async {
    try {
      final response = await _apiService.request(
        endpoint: '${AppConstants.reportsEndpoint}/performance',
        type: RequestType.post,
        data: parameters,
      );
      
      _generatedReport = {
        'type': 'performance_report',
        'data': response,
        'metadata': {
          'class_id': parameters['classId'],
          'class_name': parameters['className'],
          'subject': parameters['subject'],
          'start_date': parameters['startDate'],
          'end_date': parameters['endDate'],
          'generated_at': DateTime.now().toIso8601String(),
        }
      };
    } catch (e) {
      rethrow;
    }
  }
  
  // Generate attendance report
  Future<void> _generateAttendanceReport(Map<String, dynamic> parameters) async {
    try {
      final response = await _apiService.request(
        endpoint: '${AppConstants.reportsEndpoint}/attendance',
        type: RequestType.post,
        data: parameters,
      );
      
      _generatedReport = {
        'type': 'attendance_report',
        'data': response,
        'metadata': {
          'class_id': parameters['classId'],
          'class_name': parameters['className'],
          'start_date': parameters['startDate'],
          'end_date': parameters['endDate'],
          'generated_at': DateTime.now().toIso8601String(),
        }
      };
    } catch (e) {
      rethrow;
    }
  }
  
  // Save a generated report
  Future<bool> saveReport(String userId) async {
    if (_generatedReport == null) {
      _errorMessage = 'No report to save';
      return false;
    }
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        throw Exception('Cannot save reports while offline');
      }
      
      final reportData = {
        'user_id': userId,
        'report_type': _reportTypeToString(_selectedReportType),
        'report_data': _generatedReport!['data'],
        'metadata': _generatedReport!['metadata'],
      };
      
      final response = await _apiService.request(
        endpoint: AppConstants.reportsEndpoint,
        type: RequestType.post,
        data: reportData,
      );
      
      // Add to saved reports
      _savedReports.insert(0, response['report']);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Save report error: $_errorMessage');
      return false;
    }
  }
  
  // Delete a saved report
  Future<bool> deleteReport(String reportId) async {
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        throw Exception('Cannot delete reports while offline');
      }
      
      await _apiService.request(
        endpoint: '${AppConstants.reportsEndpoint}/$reportId',
        type: RequestType.delete,
      );
      
      // Remove from saved reports
      _savedReports.removeWhere((report) => report['id'] == reportId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Delete report error: $_errorMessage');
      return false;
    }
  }
  
  // Share a report
  Future<bool> shareReport(String reportId, List<String> recipientIds) async {
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        throw Exception('Cannot share reports while offline');
      }
      
      await _apiService.request(
        endpoint: '${AppConstants.reportsEndpoint}/$reportId/share',
        type: RequestType.post,
        data: {
          'recipient_ids': recipientIds,
        },
      );
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Share report error: $_errorMessage');
      return false;
    }
  }
  
  // Set filters for reports
  void setFilters({
    String? classId,
    String? className,
    String? subject,
    String? grade,
    String? studentId,
    String? studentName,
    ReportType? reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    bool shouldUpdate = false;
    
    if (classId != null && _selectedClass != classId) {
      _selectedClass = classId;
      shouldUpdate = true;
    }
    
    if (subject != null && _selectedSubject != subject) {
      _selectedSubject = subject;
      shouldUpdate = true;
    }
    
    if (grade != null && _selectedGrade != grade) {
      _selectedGrade = grade;
      shouldUpdate = true;
    }
    
    if (studentId != null && _selectedStudent != studentId) {
      _selectedStudent = studentId;
      shouldUpdate = true;
    }
    
    if (reportType != null && _selectedReportType != reportType) {
      _selectedReportType = reportType;
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
    _selectedClass = null;
    _selectedSubject = null;
    _selectedGrade = null;
    _selectedStudent = null;
    _selectedReportType = ReportType.questionPaper;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }
  
  // Clear generated report
  void clearGeneratedReport() {
    _generatedReport = null;
    _status = ReportStatus.initial;
    notifyListeners();
  }
  
  // Check connectivity
  Future<void> checkConnectivity() async {
    final wasOffline = _isOffline;
    _isOffline = !(await ConnectivityUtils.isConnected());
    
    if (wasOffline && !_isOffline) {
      // We're back online, might want to reload data
      // This would depend on what the user was doing
    } else if (_isOffline != wasOffline) {
      // Just update offline status
      notifyListeners();
    }
  }
  
  // Helper Functions
  String _reportTypeToString(ReportType type) {
    switch (type) {
      case ReportType.questionPaper:
        return 'question_paper';
      case ReportType.reportCard:
        return 'report_card';
      case ReportType.performanceReport:
        return 'performance_report';
      case ReportType.attendanceReport:
        return 'attendance_report';
    }
  }
  
  ReportType _stringToReportType(String typeString) {
    switch (typeString) {
      case 'question_paper':
        return ReportType.questionPaper;
      case 'report_card':
        return ReportType.reportCard;
      case 'performance_report':
        return ReportType.performanceReport;
      case 'attendance_report':
        return ReportType.attendanceReport;
      default:
        return ReportType.questionPaper;
    }
  }
  
  // Generate mock data for offline mode
  void _setMockSavedReports(String userRole) {
    final now = DateTime.now();
    
    _savedReports = [
      {
        'id': 'report-001',
        'user_id': 'user-001',
        'report_type': 'question_paper',
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'metadata': {
          'subject': 'Mathematics',
          'grade': 'Grade 8',
          'topics': ['Algebra', 'Geometry'],
          'total_marks': 100,
          'duration': 60,
          'language': 'English',
          'generated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        }
      },
      {
        'id': 'report-002',
        'user_id': 'user-001',
        'report_type': 'attendance_report',
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'metadata': {
          'class_id': 'class-001',
          'class_name': 'Class 8A',
          'start_date': now.subtract(const Duration(days: 30)).toIso8601String(),
          'end_date': now.subtract(const Duration(days: 5)).toIso8601String(),
          'generated_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        }
      },
      {
        'id': 'report-003',
        'user_id': 'user-001',
        'report_type': 'performance_report',
        'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        'metadata': {
          'class_id': 'class-001',
          'class_name': 'Class 8A',
          'subject': 'Science',
          'start_date': now.subtract(const Duration(days: 60)).toIso8601String(),
          'end_date': now.subtract(const Duration(days: 7)).toIso8601String(),
          'generated_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        }
      },
    ];
    
    if (userRole == 'teacher') {
      _savedReports.add({
        'id': 'report-004',
        'user_id': 'user-001',
        'report_type': 'report_card',
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        'metadata': {
          'student_id': 'student-001',
          'student_name': 'Alice Johnson',
          'grade': 'Grade 8',
          'term': 'Term 1',
          'academic_year': '2023-2024',
          'generated_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        }
      });
    }
  }
}
