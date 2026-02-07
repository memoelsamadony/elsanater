class Exam {
  final int? id;
  final String title;
  final double fullMark;
  final double successMark;
  final int level;
  final int teacherId;
  final int subjectId;
  final String? note;
  final String? teacherName;
  final String? subjectName;

  Exam({
    this.id,
    required this.title,
    required this.fullMark,
    required this.successMark,
    required this.level,
    required this.teacherId,
    required this.subjectId,
    this.note,
    this.teacherName,
    this.subjectName,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'] ?? '',
      fullMark: (json['fullMark'] ?? 0).toDouble(),
      successMark: (json['successMark'] ?? 0).toDouble(),
      level: json['level'] ?? 0,
      teacherId: json['teacherId'] ?? 0,
      subjectId: json['subjectId'] ?? 0,
      note: json['note'],
      teacherName: json['teacherName'],
      subjectName: json['subjectName'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'fullMark': fullMark,
        'successMark': successMark,
        'level': level,
        'teacherId': teacherId,
        'subjectId': subjectId,
        'note': note,
      };
}

class ExamMark {
  final int groupStudentId;
  final double? examMark;

  ExamMark({
    required this.groupStudentId,
    this.examMark,
  });

  Map<String, dynamic> toJson() => {
        'groupStudentId': groupStudentId,
        'examMark': examMark,
      };
}
