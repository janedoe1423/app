class AttendanceModel {
  final String id;
  final String classId;
  final String teacherId;
  final DateTime date;
  final List<StudentAttendance> studentAttendances;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  AttendanceModel({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.date,
    required this.studentAttendances,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      classId: json['class_id'],
      teacherId: json['teacher_id'],
      date: DateTime.parse(json['date']),
      studentAttendances: List<StudentAttendance>.from(
        json['student_attendances'].map((x) => StudentAttendance.fromJson(x)),
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'teacher_id': teacherId,
      'date': date.toIso8601String().split('T')[0], // Just the date part
      'student_attendances': studentAttendances.map((x) => x.toJson()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Calculate attendance statistics
  Map<String, dynamic> getStats() {
    int present = 0;
    int absent = 0;
    int late = 0;
    
    for (var attendance in studentAttendances) {
      switch (attendance.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.late:
          late++;
          break;
      }
    }
    
    int total = studentAttendances.length;
    
    return {
      'total': total,
      'present': present,
      'absent': absent,
      'late': late,
      'present_percentage': total > 0 ? (present / total * 100).toStringAsFixed(1) : '0.0',
      'absent_percentage': total > 0 ? (absent / total * 100).toStringAsFixed(1) : '0.0',
      'late_percentage': total > 0 ? (late / total * 100).toStringAsFixed(1) : '0.0',
    };
  }
  
  // Create a new instance with updated fields
  AttendanceModel copyWith({
    List<StudentAttendance>? studentAttendances,
    String? notes,
  }) {
    return AttendanceModel(
      id: this.id,
      classId: this.classId,
      teacherId: this.teacherId,
      date: this.date,
      studentAttendances: studentAttendances ?? this.studentAttendances,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class StudentAttendance {
  final String studentId;
  final String studentName;
  final AttendanceStatus status;
  final String? remarks;
  
  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.remarks,
  });
  
  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: json['student_id'],
      studentName: json['student_name'],
      status: _parseStatus(json['status']),
      remarks: json['remarks'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'status': status.toString().split('.').last,
      'remarks': remarks,
    };
  }
  
  // Helper to parse attendance status
  static AttendanceStatus _parseStatus(String status) {
    switch (status) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.absent;
    }
  }
  
  // Create a new instance with updated fields
  StudentAttendance copyWith({
    AttendanceStatus? status,
    String? remarks,
  }) {
    return StudentAttendance(
      studentId: this.studentId,
      studentName: this.studentName,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }
}

// Classroom model
class ClassroomModel {
  final String id;
  final String name;
  final String grade;
  final String section;
  final String? subject;
  final String teacherId;
  final String teacherName;
  final List<ClassroomStudent> students;
  final List<ClassroomSchedule> schedules;
  final String? roomNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  ClassroomModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.section,
    this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.students,
    required this.schedules,
    this.roomNumber,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      section: json['section'],
      subject: json['subject'],
      teacherId: json['teacher_id'],
      teacherName: json['teacher_name'],
      students: List<ClassroomStudent>.from(
        json['students'].map((x) => ClassroomStudent.fromJson(x)),
      ),
      schedules: List<ClassroomSchedule>.from(
        json['schedules'].map((x) => ClassroomSchedule.fromJson(x)),
      ),
      roomNumber: json['room_number'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'section': section,
      'subject': subject,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'students': students.map((x) => x.toJson()).toList(),
      'schedules': schedules.map((x) => x.toJson()).toList(),
      'room_number': roomNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Get student count
  int get studentCount => students.length;
  
  // Get today's schedule
  ClassroomSchedule? getTodaySchedule() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 for Monday, 7 for Sunday
    
    return schedules.firstWhere(
      (schedule) => schedule.weekday == weekday,
      orElse: () => ClassroomSchedule(
        id: 'none',
        weekday: weekday,
        startTime: '00:00',
        endTime: '00:00',
      ),
    );
  }
  
  // Create a new instance with updated fields
  ClassroomModel copyWith({
    String? name,
    String? grade,
    String? section,
    String? subject,
    List<ClassroomStudent>? students,
    List<ClassroomSchedule>? schedules,
    String? roomNumber,
  }) {
    return ClassroomModel(
      id: this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      subject: subject ?? this.subject,
      teacherId: this.teacherId,
      teacherName: this.teacherName,
      students: students ?? this.students,
      schedules: schedules ?? this.schedules,
      roomNumber: roomNumber ?? this.roomNumber,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ClassroomStudent {
  final String id;
  final String name;
  final String? rollNumber;
  
  ClassroomStudent({
    required this.id,
    required this.name,
    this.rollNumber,
  });
  
  factory ClassroomStudent.fromJson(Map<String, dynamic> json) {
    return ClassroomStudent(
      id: json['id'],
      name: json['name'],
      rollNumber: json['roll_number'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
    };
  }
}

class ClassroomSchedule {
  final String id;
  final int weekday; // 1 for Monday, 7 for Sunday
  final String startTime; // Format: "HH:MM"
  final String endTime; // Format: "HH:MM"
  
  ClassroomSchedule({
    required this.id,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });
  
  factory ClassroomSchedule.fromJson(Map<String, dynamic> json) {
    return ClassroomSchedule(
      id: json['id'],
      weekday: json['weekday'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
  
  // Get weekday name
  String get weekdayName {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
  
  // Format time range
  String get timeRange => '$startTime - $endTime';
}

enum AttendanceStatus {
  present,
  absent,
  late,
}
