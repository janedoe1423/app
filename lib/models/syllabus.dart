class Syllabus {
  final String className;
  final String section;
  final String subject;
  final List<Chapter> chapters;
  final DateTime createdAt;
  final DateTime updatedAt;

  Syllabus({
    required this.className,
    required this.section,
    required this.subject,
    required this.chapters,
    required this.createdAt,
    required this.updatedAt,
  });

  // Add a method to convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'section': section,
      'subject': subject,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Add a factory constructor to create from Map
  factory Syllabus.fromMap(Map<String, dynamic> map) {
    return Syllabus(
      className: map['className'],
      section: map['section'],
      subject: map['subject'],
      chapters: (map['chapters'] as List)
          .map((chapter) => Chapter.fromMap(chapter))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

class Chapter {
  final String name;
  final List<Topic> topics;
  final int weightage; // Percentage weightage in exams

  Chapter({
    required this.name,
    required this.topics,
    this.weightage = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'topics': topics.map((topic) => topic.toMap()).toList(),
      'weightage': weightage,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      name: map['name'],
      topics: (map['topics'] as List)
          .map((topic) => Topic.fromMap(topic))
          .toList(),
      weightage: map['weightage'] ?? 0,
    );
  }
}

class Topic {
  final String name;
  final String description;
  final int weightage; // Percentage weightage within chapter

  Topic({
    required this.name,
    this.description = '',
    this.weightage = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'weightage': weightage,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      name: map['name'],
      description: map['description'] ?? '',
      weightage: map['weightage'] ?? 0,
    );
  }
} 