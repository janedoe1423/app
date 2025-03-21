import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/attendance_model.dart';
import '../../../core/utils/connectivity_utils.dart';

enum ClassroomStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
}

class ClassroomProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  ClassroomStatus _status = ClassroomStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;
  
  // Data
  List<ClassroomModel> _classrooms = [];
  ClassroomModel? _selectedClassroom;
  List<AttendanceModel> _attendanceRecords = [];
  AttendanceModel? _currentAttendance;
  
  // Filters
  DateTime _selectedDate = DateTime.now();
  
  // Getters
  ClassroomStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  List<ClassroomModel> get classrooms => _classrooms;
  ClassroomModel? get selectedClassroom => _selectedClassroom;
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  AttendanceModel? get currentAttendance => _currentAttendance;
  DateTime get selectedDate => _selectedDate;
  
  // Initialize with user data
  Future<void> init(String userId, String userRole) async {
    _status = ClassroomStatus.loading;
    _isOffline = !(await ConnectivityUtils.isConnected());
    notifyListeners();
    
    try {
      if (userRole == 'teacher') {
        await loadTeacherClassrooms(userId);
      } else if (userRole == 'student') {
        await loadStudentClassrooms(userId);
      }
    } catch (e) {
      _status = ClassroomStatus.error;
      _errorMessage = e.toString();
      debugPrint('Classroom init error: $_errorMessage');
    }
    
    notifyListeners();
  }
  
  // Load classrooms for a teacher
  Future<void> loadTeacherClassrooms(String teacherId) async {
    _status = ClassroomStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Use mock data for offline mode
        _setMockTeacherClassrooms();
        _status = ClassroomStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/teacher/$teacherId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      final List<dynamic> classroomsData = response['classrooms'];
      _classrooms = classroomsData
          .map((data) => ClassroomModel.fromJson(data))
          .toList();
      
      _status = ClassroomStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        _setMockTeacherClassrooms();
        _status = ClassroomStatus.loaded;
      } else {
        _status = ClassroomStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load teacher classrooms error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Load classrooms for a student
  Future<void> loadStudentClassrooms(String studentId) async {
    _status = ClassroomStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Use mock data for offline mode
        _setMockStudentClassrooms();
        _status = ClassroomStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/student/$studentId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      final List<dynamic> classroomsData = response['classrooms'];
      _classrooms = classroomsData
          .map((data) => ClassroomModel.fromJson(data))
          .toList();
      
      _status = ClassroomStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        _setMockStudentClassrooms();
        _status = ClassroomStatus.loaded;
      } else {
        _status = ClassroomStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load student classrooms error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Get classroom details
  Future<void> getClassroomDetails(String classroomId) async {
    _status = ClassroomStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // First check if classroom exists in local state
      final existingClassroom = _classrooms.firstWhere(
        (c) => c.id == classroomId,
        orElse: () => throw Exception('Classroom not found'),
      );
      
      _selectedClassroom = existingClassroom;
      
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        _status = ClassroomStatus.loaded;
        notifyListeners();
        return;
      }
      
      // Get detailed classroom data from API
      final response = await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/$classroomId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      _selectedClassroom = ClassroomModel.fromJson(response);
      
      // Update the classroom in the list
      final index = _classrooms.indexWhere((c) => c.id == classroomId);
      if (index >= 0) {
        _classrooms[index] = _selectedClassroom!;
      }
      
      _status = ClassroomStatus.loaded;
    } catch (e) {
      _status = ClassroomStatus.error;
      _errorMessage = e.toString();
      debugPrint('Get classroom details error: $_errorMessage');
    }
    
    notifyListeners();
  }
  
  // Load attendance records for a classroom
  Future<void> loadAttendanceRecords(String classroomId) async {
    _status = ClassroomStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Use mock data for offline mode
        _setMockAttendanceRecords(classroomId);
        _status = ClassroomStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.attendanceEndpoint}/classroom/$classroomId',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      final List<dynamic> attendanceData = response['attendance_records'];
      _attendanceRecords = attendanceData
          .map((data) => AttendanceModel.fromJson(data))
          .toList();
      
      _status = ClassroomStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        _setMockAttendanceRecords(classroomId);
        _status = ClassroomStatus.loaded;
      } else {
        _status = ClassroomStatus.error;
        _errorMessage = e.toString();
        debugPrint('Load attendance records error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Get attendance for a specific date
  Future<void> getAttendanceForDate(String classroomId, DateTime date) async {
    _selectedDate = date;
    _status = ClassroomStatus.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      // Format date as yyyy-MM-dd
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      if (_isOffline) {
        // Check if we have the attendance record in local state
        _currentAttendance = _attendanceRecords.firstWhere(
          (a) => a.classId == classroomId && 
                 a.date.year == date.year && 
                 a.date.month == date.month && 
                 a.date.day == date.day,
          orElse: () => _createNewAttendanceRecord(classroomId, date),
        );
        
        _status = ClassroomStatus.loaded;
        notifyListeners();
        return;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.attendanceEndpoint}/classroom/$classroomId/date/$formattedDate',
        type: RequestType.get,
        cacheResponse: true,
      );
      
      if (response.containsKey('attendance')) {
        _currentAttendance = AttendanceModel.fromJson(response['attendance']);
      } else {
        // No attendance record exists for this date, create a new one
        _currentAttendance = _createNewAttendanceRecord(classroomId, date);
      }
      
      _status = ClassroomStatus.loaded;
    } catch (e) {
      if (_isOffline) {
        // Create a new attendance record for offline mode
        _currentAttendance = _createNewAttendanceRecord(classroomId, date);
        _status = ClassroomStatus.loaded;
      } else {
        _status = ClassroomStatus.error;
        _errorMessage = e.toString();
        debugPrint('Get attendance for date error: $_errorMessage');
      }
    }
    
    notifyListeners();
  }
  
  // Create a new attendance record
  AttendanceModel _createNewAttendanceRecord(String classroomId, DateTime date) {
    if (_selectedClassroom == null) {
      throw Exception('No classroom selected');
    }
    
    // Create student attendance entries for all students in the class
    final studentAttendances = _selectedClassroom!.students.map((student) {
      return StudentAttendance(
        studentId: student.id,
        studentName: student.name,
        status: AttendanceStatus.absent,
        remarks: '',
      );
    }).toList();
    
    return AttendanceModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      classId: classroomId,
      teacherId: _selectedClassroom!.teacherId,
      date: date,
      studentAttendances: studentAttendances,
      notes: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  // Save attendance record
  Future<bool> saveAttendance(AttendanceModel attendance) async {
    _status = ClassroomStatus.saving;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Store locally for now, will sync later
        // For this MVP, just simulate success
        _status = ClassroomStatus.saved;
        notifyListeners();
        return true;
      }
      
      final isNewRecord = attendance.id.startsWith('temp-');
      final requestType = isNewRecord ? RequestType.post : RequestType.put;
      final endpoint = isNewRecord 
          ? AppConstants.attendanceEndpoint 
          : '${AppConstants.attendanceEndpoint}/${attendance.id}';
      
      final response = await _apiService.request(
        endpoint: endpoint,
        type: requestType,
        data: attendance.toJson(),
      );
      
      final savedAttendance = AttendanceModel.fromJson(response['attendance']);
      
      // Update current attendance
      _currentAttendance = savedAttendance;
      
      // Update or add to attendance records
      final index = _attendanceRecords.indexWhere((a) => a.id == savedAttendance.id);
      if (index >= 0) {
        _attendanceRecords[index] = savedAttendance;
      } else {
        _attendanceRecords.add(savedAttendance);
      }
      
      _status = ClassroomStatus.saved;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ClassroomStatus.error;
      _errorMessage = e.toString();
      debugPrint('Save attendance error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }
  
  // Update attendance status for a student
  void updateStudentAttendance(String studentId, AttendanceStatus status, [String? remarks]) {
    if (_currentAttendance == null) return;
    
    final updatedAttendances = [..._currentAttendance!.studentAttendances];
    final index = updatedAttendances.indexWhere((a) => a.studentId == studentId);
    
    if (index >= 0) {
      updatedAttendances[index] = updatedAttendances[index].copyWith(
        status: status,
        remarks: remarks,
      );
      
      _currentAttendance = _currentAttendance!.copyWith(
        studentAttendances: updatedAttendances,
      );
      
      notifyListeners();
    }
  }
  
  // Update attendance notes
  void updateAttendanceNotes(String notes) {
    if (_currentAttendance == null) return;
    
    _currentAttendance = _currentAttendance!.copyWith(
      notes: notes,
    );
    
    notifyListeners();
  }
  
  // Create a new classroom
  Future<bool> createClassroom(ClassroomModel classroom) async {
    _status = ClassroomStatus.saving;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Store locally for now, will sync later
        // For this MVP, just simulate success
        _status = ClassroomStatus.saved;
        notifyListeners();
        return true;
      }
      
      final response = await _apiService.request(
        endpoint: AppConstants.classroomEndpoint,
        type: RequestType.post,
        data: classroom.toJson(),
      );
      
      final createdClassroom = ClassroomModel.fromJson(response['classroom']);
      
      // Add to classrooms list
      _classrooms.add(createdClassroom);
      
      _status = ClassroomStatus.saved;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ClassroomStatus.error;
      _errorMessage = e.toString();
      debugPrint('Create classroom error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }
  
  // Update classroom details
  Future<bool> updateClassroom(ClassroomModel classroom) async {
    _status = ClassroomStatus.saving;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Store locally for now, will sync later
        // For this MVP, just simulate success
        _status = ClassroomStatus.saved;
        notifyListeners();
        return true;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/${classroom.id}',
        type: RequestType.put,
        data: classroom.toJson(),
      );
      
      final updatedClassroom = ClassroomModel.fromJson(response['classroom']);
      
      // Update classroom in list
      final index = _classrooms.indexWhere((c) => c.id == updatedClassroom.id);
      if (index >= 0) {
        _classrooms[index] = updatedClassroom;
      }
      
      // Update selected classroom if it's the same one
      if (_selectedClassroom?.id == updatedClassroom.id) {
        _selectedClassroom = updatedClassroom;
      }
      
      _status = ClassroomStatus.saved;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ClassroomStatus.error;
      _errorMessage = e.toString();
      debugPrint('Update classroom error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }
  
  // Delete a classroom
  Future<bool> deleteClassroom(String classroomId) async {
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Cannot delete offline
        _errorMessage = 'Cannot delete classroom while offline';
        return false;
      }
      
      await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/$classroomId',
        type: RequestType.delete,
      );
      
      // Remove from classrooms list
      _classrooms.removeWhere((c) => c.id == classroomId);
      
      // Reset selected classroom if it's the same one
      if (_selectedClassroom?.id == classroomId) {
        _selectedClassroom = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Delete classroom error: $_errorMessage');
      return false;
    }
  }
  
  // Add a student to classroom
  Future<bool> addStudentToClassroom(
    String classroomId, 
    ClassroomStudent student
  ) async {
    _status = ClassroomStatus.saving;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Cannot add student offline
        _errorMessage = 'Cannot add student while offline';
        _status = ClassroomStatus.error;
        notifyListeners();
        return false;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/$classroomId/student',
        type: RequestType.post,
        data: student.toJson(),
      );
      
      final updatedClassroom = ClassroomModel.fromJson(response['classroom']);
      
      // Update classroom in list
      final index = _classrooms.indexWhere((c) => c.id == updatedClassroom.id);
      if (index >= 0) {
        _classrooms[index] = updatedClassroom;
      }
      
      // Update selected classroom if it's the same one
      if (_selectedClassroom?.id == updatedClassroom.id) {
        _selectedClassroom = updatedClassroom;
      }
      
      _status = ClassroomStatus.saved;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ClassroomStatus.error;
      _errorMessage = e.toString();
      debugPrint('Add student error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }
  
  // Remove a student from classroom
  Future<bool> removeStudentFromClassroom(
    String classroomId, 
    String studentId
  ) async {
    _status = ClassroomStatus.saving;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Check connectivity
      _isOffline = !(await ConnectivityUtils.isConnected());
      
      if (_isOffline) {
        // Cannot remove student offline
        _errorMessage = 'Cannot remove student while offline';
        _status = ClassroomStatus.error;
        notifyListeners();
        return false;
      }
      
      final response = await _apiService.request(
        endpoint: '${AppConstants.classroomEndpoint}/$classroomId/student/$studentId',
        type: RequestType.delete,
      );
      
      final updatedClassroom = ClassroomModel.fromJson(response['classroom']);
      
      // Update classroom in list
      final index = _classrooms.indexWhere((c) => c.id == updatedClassroom.id);
      if (index >= 0) {
        _classrooms[index] = updatedClassroom;
      }
      
      // Update selected classroom if it's the same one
      if (_selectedClassroom?.id == updatedClassroom.id) {
        _selectedClassroom = updatedClassroom;
      }
      
      _status = ClassroomStatus.saved;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ClassroomStatus.error;
      _errorMessage = e.toString();
      debugPrint('Remove student error: $_errorMessage');
      notifyListeners();
      return false;
    }
  }
  
  // Select a date for attendance
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  // Set selected classroom
  void setSelectedClassroom(ClassroomModel classroom) {
    _selectedClassroom = classroom;
    notifyListeners();
  }
  
  // Clear selected classroom
  void clearSelectedClassroom() {
    _selectedClassroom = null;
    _currentAttendance = null;
    notifyListeners();
  }
  
  // Check connectivity
  Future<void> checkConnectivity() async {
    final wasOffline = _isOffline;
    _isOffline = !(await ConnectivityUtils.isConnected());
    
    if (wasOffline && !_isOffline) {
      // We're back online, refresh data
      if (_selectedClassroom != null) {
        await getClassroomDetails(_selectedClassroom!.id);
      }
    } else if (_isOffline != wasOffline) {
      // Just update offline status
      notifyListeners();
    }
  }
  
  // Generate mock data for offline mode
  void _setMockTeacherClassrooms() {
    _classrooms = [
      ClassroomModel(
        id: 'class-001',
        name: 'Class 8A',
        grade: 'Grade 8',
        section: 'A',
        subject: 'Mathematics',
        teacherId: 'teacher-001',
        teacherName: 'John Smith',
        students: [
          ClassroomStudent(id: 'student-001', name: 'Alice Johnson', rollNumber: '101'),
          ClassroomStudent(id: 'student-002', name: 'Bob Williams', rollNumber: '102'),
          ClassroomStudent(id: 'student-003', name: 'Carol Davis', rollNumber: '103'),
          ClassroomStudent(id: 'student-004', name: 'David Wilson', rollNumber: '104'),
          ClassroomStudent(id: 'student-005', name: 'Eva Brown', rollNumber: '105'),
        ],
        schedules: [
          ClassroomSchedule(id: 'schedule-001', weekday: 1, startTime: '09:00', endTime: '10:00'),
          ClassroomSchedule(id: 'schedule-002', weekday: 3, startTime: '11:00', endTime: '12:00'),
          ClassroomSchedule(id: 'schedule-003', weekday: 5, startTime: '14:00', endTime: '15:00'),
        ],
        roomNumber: '201',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ClassroomModel(
        id: 'class-002',
        name: 'Class 9B',
        grade: 'Grade 9',
        section: 'B',
        subject: 'Science',
        teacherId: 'teacher-001',
        teacherName: 'John Smith',
        students: [
          ClassroomStudent(id: 'student-006', name: 'Frank Miller', rollNumber: '201'),
          ClassroomStudent(id: 'student-007', name: 'Grace Lee', rollNumber: '202'),
          ClassroomStudent(id: 'student-008', name: 'Henry Garcia', rollNumber: '203'),
          ClassroomStudent(id: 'student-009', name: 'Ivy Chen', rollNumber: '204'),
        ],
        schedules: [
          ClassroomSchedule(id: 'schedule-004', weekday: 2, startTime: '09:00', endTime: '10:00'),
          ClassroomSchedule(id: 'schedule-005', weekday: 4, startTime: '11:00', endTime: '12:00'),
        ],
        roomNumber: '203',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
  
  void _setMockStudentClassrooms() {
    _classrooms = [
      ClassroomModel(
        id: 'class-001',
        name: 'Class 8A',
        grade: 'Grade 8',
        section: 'A',
        subject: 'Mathematics',
        teacherId: 'teacher-001',
        teacherName: 'John Smith',
        students: [
          ClassroomStudent(id: 'student-001', name: 'Alice Johnson', rollNumber: '101'),
        ],
        schedules: [
          ClassroomSchedule(id: 'schedule-001', weekday: 1, startTime: '09:00', endTime: '10:00'),
          ClassroomSchedule(id: 'schedule-002', weekday: 3, startTime: '11:00', endTime: '12:00'),
          ClassroomSchedule(id: 'schedule-003', weekday: 5, startTime: '14:00', endTime: '15:00'),
        ],
        roomNumber: '201',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      ClassroomModel(
        id: 'class-003',
        name: 'Class 8A',
        grade: 'Grade 8',
        section: 'A',
        subject: 'Science',
        teacherId: 'teacher-002',
        teacherName: 'Jane Doe',
        students: [
          ClassroomStudent(id: 'student-001', name: 'Alice Johnson', rollNumber: '101'),
        ],
        schedules: [
          ClassroomSchedule(id: 'schedule-006', weekday: 2, startTime: '10:00', endTime: '11:00'),
          ClassroomSchedule(id: 'schedule-007', weekday: 4, startTime: '14:00', endTime: '15:00'),
        ],
        roomNumber: '205',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
  
  void _setMockAttendanceRecords(String classroomId) {
    final classroom = _classrooms.firstWhere(
      (c) => c.id == classroomId,
      orElse: () => throw Exception('Classroom not found'),
    );
    
    _attendanceRecords = List.generate(
      10,
      (index) => AttendanceModel(
        id: 'attendance-${index + 1}',
        classId: classroomId,
        teacherId: classroom.teacherId,
        date: DateTime.now().subtract(Duration(days: index)),
        studentAttendances: classroom.students.map((student) {
          // Randomly assign attendance status
          final random = index % 3;
          AttendanceStatus status;
          
          if (random == 0) {
            status = AttendanceStatus.present;
          } else if (random == 1) {
            status = AttendanceStatus.absent;
          } else {
            status = AttendanceStatus.late;
          }
          
          return StudentAttendance(
            studentId: student.id,
            studentName: student.name,
            status: status,
            remarks: status == AttendanceStatus.absent ? 'Sick leave' : null,
          );
        }).toList(),
        notes: index % 2 == 0 ? 'Regular class day' : null,
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(days: index)),
      ),
    );
    
    // Set current attendance to today's attendance
    _currentAttendance = _attendanceRecords.firstWhere(
      (a) => a.date.year == DateTime.now().year && 
             a.date.month == DateTime.now().month && 
             a.date.day == DateTime.now().day,
      orElse: () => _createNewAttendanceRecord(classroomId, DateTime.now()),
    );
  }
}
