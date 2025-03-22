class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String className;
  final String subject;
  final String chapterName;
  final String topicName;
  final String difficulty;
  final int marks;
  final DateTime createdAt;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.className,
    required this.subject,
    required this.chapterName,
    required this.topicName,
    required this.difficulty,
    required this.marks,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'className': className,
      'subject': subject,
      'chapterName': chapterName,
      'topicName': topicName,
      'difficulty': difficulty,
      'marks': marks,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'],
      options: List<String>.from(map['options']),
      correctAnswer: map['correctAnswer'],
      className: map['className'],
      subject: map['subject'],
      chapterName: map['chapterName'],
      topicName: map['topicName'],
      difficulty: map['difficulty'],
      marks: map['marks'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

enum QuestionDifficulty {
  easy,
  medium,
  hard
} 