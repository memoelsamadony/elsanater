class Teacher {
  final int id;
  final String name;
  final List<TeacherSubject>? subjects;

  Teacher({
    required this.id,
    required this.name,
    this.subjects,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'] ?? '',
      subjects: json['subjects'] != null
          ? (json['subjects'] as List)
              .map((e) => TeacherSubject.fromJson(e))
              .toList()
          : null,
    );
  }
}

class TeacherSubject {
  final int id;
  final String name;

  TeacherSubject({
    required this.id,
    required this.name,
  });

  factory TeacherSubject.fromJson(Map<String, dynamic> json) {
    return TeacherSubject(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class Group {
  final int id;
  final String title;
  final String? teacherName;
  final String? subjectName;
  final int? level;
  final int? studentCount;

  Group({
    required this.id,
    required this.title,
    this.teacherName,
    this.subjectName,
    this.level,
    this.studentCount,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      title: json['title'] ?? '',
      teacherName: json['teacherName'],
      subjectName: json['subjectName'],
      level: json['level'],
      studentCount: json['studentCount'],
    );
  }
}
