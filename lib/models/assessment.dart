class Assessment {
  final String id;
  final String className;
  final String subject;
  final String chapter;
  final List<String> selectedSubtopics;  // Changed to match the variable name in AssessmentCreator
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  Assessment({
    required this.id,
    required this.className,
    required this.subject,
    required this.chapter,
    required this.selectedSubtopics,  // Changed to match
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  // Optional: Add a factory constructor for JSON
  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      className: json['className'],
      subject: json['subject'],
      chapter: json['chapter'],
      selectedSubtopics: List<String>.from(json['selectedSubtopics']),  // Changed to match
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: json['status'],
    );
  }
} 