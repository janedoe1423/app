class PerformanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final String grade;
  final Map<String, TopicPerformance> topicPerformances;
  final List<AssessmentPerformance> assessmentPerformances;
  final DateTime lastUpdated;
  
  PerformanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.grade,
    required this.topicPerformances,
    required this.assessmentPerformances,
    required this.lastUpdated,
  });
  
  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    // Parse topic performances map
    Map<String, TopicPerformance> topicPerfs = {};
    json['topic_performances'].forEach((key, value) {
      topicPerfs[key] = TopicPerformance.fromJson(value);
    });
    
    return PerformanceModel(
      id: json['id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      subject: json['subject'],
      grade: json['grade'],
      topicPerformances: topicPerfs,
      assessmentPerformances: List<AssessmentPerformance>.from(
        json['assessment_performances'].map((x) => AssessmentPerformance.fromJson(x)),
      ),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    // Convert topic performances to Map
    Map<String, dynamic> topicPerfs = {};
    topicPerformances.forEach((key, value) {
      topicPerfs[key] = value.toJson();
    });
    
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'subject': subject,
      'grade': grade,
      'topic_performances': topicPerfs,
      'assessment_performances': assessmentPerformances.map((x) => x.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
  
  // Get overall performance score
  double get overallPerformance {
    if (assessmentPerformances.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    for (var assessment in assessmentPerformances) {
      totalScore += assessment.score;
    }
    
    return totalScore / assessmentPerformances.length;
  }
  
  // Get performance grade (A, B, C, etc.)
  String get performanceGrade {
    double score = overallPerformance;
    
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
  
  // Get strengths (topics with highest scores)
  List<String> getStrengths({int limit = 3}) {
    if (topicPerformances.isEmpty) return [];
    
    List<MapEntry<String, TopicPerformance>> sortedTopics = topicPerformances.entries.toList()
      ..sort((a, b) => b.value.averageScore.compareTo(a.value.averageScore));
    
    return sortedTopics
        .take(limit)
        .where((entry) => entry.value.averageScore >= 70)
        .map((entry) => entry.key)
        .toList();
  }
  
  // Get weaknesses (topics with lowest scores)
  List<String> getWeaknesses({int limit = 3}) {
    if (topicPerformances.isEmpty) return [];
    
    List<MapEntry<String, TopicPerformance>> sortedTopics = topicPerformances.entries.toList()
      ..sort((a, b) => a.value.averageScore.compareTo(b.value.averageScore));
    
    return sortedTopics
        .take(limit)
        .where((entry) => entry.value.averageScore < 70)
        .map((entry) => entry.key)
        .toList();
  }
  
  // Get performance trend
  List<Map<String, dynamic>> getPerformanceTrend() {
    if (assessmentPerformances.isEmpty) return [];
    
    // Sort by date
    List<AssessmentPerformance> sortedAssessments = [...assessmentPerformances]
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return sortedAssessments.map((assessment) => {
      'date': assessment.date.toIso8601String().split('T')[0],
      'score': assessment.score,
      'title': assessment.assessmentTitle,
    }).toList();
  }
}

class TopicPerformance {
  final double averageScore;
  final int questionsAttempted;
  final int questionsCorrect;
  final DateTime lastAttempted;
  
  TopicPerformance({
    required this.averageScore,
    required this.questionsAttempted,
    required this.questionsCorrect,
    required this.lastAttempted,
  });
  
  factory TopicPerformance.fromJson(Map<String, dynamic> json) {
    return TopicPerformance(
      averageScore: json['average_score'],
      questionsAttempted: json['questions_attempted'],
      questionsCorrect: json['questions_correct'],
      lastAttempted: DateTime.parse(json['last_attempted']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'average_score': averageScore,
      'questions_attempted': questionsAttempted,
      'questions_correct': questionsCorrect,
      'last_attempted': lastAttempted.toIso8601String(),
    };
  }
  
  // Get performance level description
  String get performanceLevel {
    if (averageScore >= 90) return 'Excellent';
    if (averageScore >= 75) return 'Good';
    if (averageScore >= 60) return 'Satisfactory';
    if (averageScore >= 40) return 'Needs Improvement';
    return 'Poor';
  }
  
  // Get accuracy percentage
  double get accuracy {
    if (questionsAttempted == 0) return 0.0;
    return (questionsCorrect / questionsAttempted) * 100;
  }
}

class AssessmentPerformance {
  final String assessmentId;
  final String assessmentTitle;
  final DateTime date;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpentSeconds;
  
  AssessmentPerformance({
    required this.assessmentId,
    required this.assessmentTitle,
    required this.date,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpentSeconds,
  });
  
  factory AssessmentPerformance.fromJson(Map<String, dynamic> json) {
    return AssessmentPerformance(
      assessmentId: json['assessment_id'],
      assessmentTitle: json['assessment_title'],
      date: DateTime.parse(json['date']),
      score: json['score'],
      totalQuestions: json['total_questions'],
      correctAnswers: json['correct_answers'],
      timeSpentSeconds: json['time_spent_seconds'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'assessment_id': assessmentId,
      'assessment_title': assessmentTitle,
      'date': date.toIso8601String(),
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'time_spent_seconds': timeSpentSeconds,
    };
  }
  
  // Get formatted time spent
  String get formattedTimeSpent {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '$minutes min $seconds sec';
  }
  
  // Get accuracy percentage
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }
  
  // Get average time per question in seconds
  double get averageTimePerQuestion {
    if (totalQuestions == 0) return 0.0;
    return timeSpentSeconds / totalQuestions;
  }
}

// Class performance model (for teachers)
class ClassPerformanceModel {
  final String classId;
  final String className;
  final String subject;
  final String grade;
  final String teacherId;
  final List<StudentPerformanceSummary> studentPerformances;
  final Map<String, TopicPerformanceSummary> topicPerformances;
  final List<AssessmentPerformanceSummary> assessmentPerformances;
  final DateTime lastUpdated;
  
  ClassPerformanceModel({
    required this.classId,
    required this.className,
    required this.subject,
    required this.grade,
    required this.teacherId,
    required this.studentPerformances,
    required this.topicPerformances,
    required this.assessmentPerformances,
    required this.lastUpdated,
  });
  
  factory ClassPerformanceModel.fromJson(Map<String, dynamic> json) {
    // Parse topic performances map
    Map<String, TopicPerformanceSummary> topicPerfs = {};
    json['topic_performances'].forEach((key, value) {
      topicPerfs[key] = TopicPerformanceSummary.fromJson(value);
    });
    
    return ClassPerformanceModel(
      classId: json['class_id'],
      className: json['class_name'],
      subject: json['subject'],
      grade: json['grade'],
      teacherId: json['teacher_id'],
      studentPerformances: List<StudentPerformanceSummary>.from(
        json['student_performances'].map((x) => StudentPerformanceSummary.fromJson(x)),
      ),
      topicPerformances: topicPerfs,
      assessmentPerformances: List<AssessmentPerformanceSummary>.from(
        json['assessment_performances'].map((x) => AssessmentPerformanceSummary.fromJson(x)),
      ),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    // Convert topic performances to Map
    Map<String, dynamic> topicPerfs = {};
    topicPerformances.forEach((key, value) {
      topicPerfs[key] = value.toJson();
    });
    
    return {
      'class_id': classId,
      'class_name': className,
      'subject': subject,
      'grade': grade,
      'teacher_id': teacherId,
      'student_performances': studentPerformances.map((x) => x.toJson()).toList(),
      'topic_performances': topicPerfs,
      'assessment_performances': assessmentPerformances.map((x) => x.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
  
  // Get class average score
  double get classAverageScore {
    if (studentPerformances.isEmpty) return 0.0;
    
    double totalScore = 0.0;
    for (var student in studentPerformances) {
      totalScore += student.averageScore;
    }
    
    return totalScore / studentPerformances.length;
  }
  
  // Get student count
  int get studentCount => studentPerformances.length;
  
  // Get performance distribution
  Map<String, int> getPerformanceDistribution() {
    Map<String, int> distribution = {
      'Excellent': 0, // 90-100
      'Good': 0,      // 75-89
      'Satisfactory': 0, // 60-74
      'NeedsImprovement': 0, // 40-59
      'Poor': 0,      // 0-39
    };
    
    for (var student in studentPerformances) {
      if (student.averageScore >= 90) {
        distribution['Excellent'] = (distribution['Excellent'] ?? 0) + 1;
      } else if (student.averageScore >= 75) {
        distribution['Good'] = (distribution['Good'] ?? 0) + 1;
      } else if (student.averageScore >= 60) {
        distribution['Satisfactory'] = (distribution['Satisfactory'] ?? 0) + 1;
      } else if (student.averageScore >= 40) {
        distribution['NeedsImprovement'] = (distribution['NeedsImprovement'] ?? 0) + 1;
      } else {
        distribution['Poor'] = (distribution['Poor'] ?? 0) + 1;
      }
    }
    
    return distribution;
  }
  
  // Get top performing students
  List<StudentPerformanceSummary> getTopPerformers({int limit = 5}) {
    if (studentPerformances.isEmpty) return [];
    
    List<StudentPerformanceSummary> sortedStudents = [...studentPerformances]
      ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
    
    return sortedStudents.take(limit).toList();
  }
  
  // Get students who need attention
  List<StudentPerformanceSummary> getStudentsNeedingAttention({int limit = 5}) {
    if (studentPerformances.isEmpty) return [];
    
    List<StudentPerformanceSummary> sortedStudents = [...studentPerformances]
      ..sort((a, b) => a.averageScore.compareTo(b.averageScore));
    
    return sortedStudents.take(limit).toList();
  }
  
  // Get difficult topics (topics with lowest average score)
  List<String> getDifficultTopics({int limit = 3}) {
    if (topicPerformances.isEmpty) return [];
    
    List<MapEntry<String, TopicPerformanceSummary>> sortedTopics = topicPerformances.entries.toList()
      ..sort((a, b) => a.value.classAverageScore.compareTo(b.value.classAverageScore));
    
    return sortedTopics.take(limit).map((entry) => entry.key).toList();
  }
}

class StudentPerformanceSummary {
  final String studentId;
  final String studentName;
  final double averageScore;
  final int assessmentsCompleted;
  final int questionsAttempted;
  final int questionsCorrect;
  final DateTime lastAssessmentDate;
  
  StudentPerformanceSummary({
    required this.studentId,
    required this.studentName,
    required this.averageScore,
    required this.assessmentsCompleted,
    required this.questionsAttempted,
    required this.questionsCorrect,
    required this.lastAssessmentDate,
  });
  
  factory StudentPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentPerformanceSummary(
      studentId: json['student_id'],
      studentName: json['student_name'],
      averageScore: json['average_score'],
      assessmentsCompleted: json['assessments_completed'],
      questionsAttempted: json['questions_attempted'],
      questionsCorrect: json['questions_correct'],
      lastAssessmentDate: DateTime.parse(json['last_assessment_date']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'average_score': averageScore,
      'assessments_completed': assessmentsCompleted,
      'questions_attempted': questionsAttempted,
      'questions_correct': questionsCorrect,
      'last_assessment_date': lastAssessmentDate.toIso8601String(),
    };
  }
  
  // Get performance level description
  String get performanceLevel {
    if (averageScore >= 90) return 'Excellent';
    if (averageScore >= 75) return 'Good';
    if (averageScore >= 60) return 'Satisfactory';
    if (averageScore >= 40) return 'Needs Improvement';
    return 'Poor';
  }
  
  // Get accuracy percentage
  double get accuracy {
    if (questionsAttempted == 0) return 0.0;
    return (questionsCorrect / questionsAttempted) * 100;
  }
}

class TopicPerformanceSummary {
  final double classAverageScore;
  final int totalStudents;
  final int studentsStruggling;
  final int studentsMastered;
  
  TopicPerformanceSummary({
    required this.classAverageScore,
    required this.totalStudents,
    required this.studentsStruggling,
    required this.studentsMastered,
  });
  
  factory TopicPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return TopicPerformanceSummary(
      classAverageScore: json['class_average_score'],
      totalStudents: json['total_students'],
      studentsStruggling: json['students_struggling'],
      studentsMastered: json['students_mastered'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'class_average_score': classAverageScore,
      'total_students': totalStudents,
      'students_struggling': studentsStruggling,
      'students_mastered': studentsMastered,
    };
  }
  
  // Get mastery percentage
  double get masteryPercentage {
    if (totalStudents == 0) return 0.0;
    return (studentsMastered / totalStudents) * 100;
  }
  
  // Get struggling percentage
  double get strugglingPercentage {
    if (totalStudents == 0) return 0.0;
    return (studentsStruggling / totalStudents) * 100;
  }
  
  // Get difficulty level
  String get difficultyLevel {
    if (classAverageScore >= 85) return 'Easy';
    if (classAverageScore >= 70) return 'Moderate';
    if (classAverageScore >= 50) return 'Challenging';
    return 'Difficult';
  }
}

class AssessmentPerformanceSummary {
  final String assessmentId;
  final String assessmentTitle;
  final DateTime date;
  final double classAverageScore;
  final int totalStudents;
  final int studentsCompleted;
  final int highestScore;
  final int lowestScore;
  
  AssessmentPerformanceSummary({
    required this.assessmentId,
    required this.assessmentTitle,
    required this.date,
    required this.classAverageScore,
    required this.totalStudents,
    required this.studentsCompleted,
    required this.highestScore,
    required this.lowestScore,
  });
  
  factory AssessmentPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return AssessmentPerformanceSummary(
      assessmentId: json['assessment_id'],
      assessmentTitle: json['assessment_title'],
      date: DateTime.parse(json['date']),
      classAverageScore: json['class_average_score'],
      totalStudents: json['total_students'],
      studentsCompleted: json['students_completed'],
      highestScore: json['highest_score'],
      lowestScore: json['lowest_score'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'assessment_id': assessmentId,
      'assessment_title': assessmentTitle,
      'date': date.toIso8601String(),
      'class_average_score': classAverageScore,
      'total_students': totalStudents,
      'students_completed': studentsCompleted,
      'highest_score': highestScore,
      'lowest_score': lowestScore,
    };
  }
  
  // Get completion percentage
  double get completionPercentage {
    if (totalStudents == 0) return 0.0;
    return (studentsCompleted / totalStudents) * 100;
  }
  
  // Get score range
  int get scoreRange => highestScore - lowestScore;
  
  // Format date
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
