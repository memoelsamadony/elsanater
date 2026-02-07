class Malzama {
  final int? id;
  final String title;
  final double price;
  final int teacherId;
  final int subjectId;
  final int level;
  final String? teacherName;
  final String? subjectName;
  final String? levelName;
  final int? totalStudents;
  final int? receivedCount;
  final List<int>? groupIds;

  Malzama({
    this.id,
    required this.title,
    required this.price,
    required this.teacherId,
    required this.subjectId,
    required this.level,
    this.teacherName,
    this.subjectName,
    this.levelName,
    this.totalStudents,
    this.receivedCount,
    this.groupIds,
  });

  factory Malzama.fromJson(Map<String, dynamic> json) {
    return Malzama(
      id: json['id'],
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      teacherId: json['teacherId'] ?? 0,
      subjectId: json['subjectId'] ?? 0,
      level: json['level'] ?? 0,
      teacherName: json['teacherName'],
      subjectName: json['subjectName'],
      levelName: json['levelName'],
      totalStudents: json['totalStudents'],
      receivedCount: json['receivedCount'],
      groupIds:
          json['groupIds'] != null ? List<int>.from(json['groupIds']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'price': price,
        'teacherId': teacherId,
        'subjectId': subjectId,
        'level': level,
        'groupIds': groupIds ?? [],
      };
}

class PaginatedMalzamas {
  final List<Malzama> malzamas;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  PaginatedMalzamas({
    required this.malzamas,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedMalzamas.fromJson(Map<String, dynamic> json) {
    final list = json['malzamas'] ?? json['items'] ?? [];
    return PaginatedMalzamas(
      malzamas: (list as List).map((e) => Malzama.fromJson(e)).toList(),
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class MalzamaStudent {
  final int studentId;
  final String studentName;
  final String? studentPhone;
  final String? studentCode;
  final bool isReceived;
  final String? receivedAt;
  final String? receivedBy;

  MalzamaStudent({
    required this.studentId,
    required this.studentName,
    this.studentPhone,
    this.studentCode,
    required this.isReceived,
    this.receivedAt,
    this.receivedBy,
  });

  factory MalzamaStudent.fromJson(Map<String, dynamic> json) {
    return MalzamaStudent(
      studentId: json['studentId'],
      studentName: json['studentName'] ?? '',
      studentPhone: json['studentPhone'],
      studentCode: json['studentCode'],
      isReceived: json['isReceived'] ?? false,
      receivedAt: json['receivedAt'],
      receivedBy: json['receivedBy'],
    );
  }
}

class PaginatedMalzamaStudents {
  final List<MalzamaStudent> students;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  PaginatedMalzamaStudents({
    required this.students,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedMalzamaStudents.fromJson(Map<String, dynamic> json) {
    final list = json['students'] ?? json['items'] ?? [];
    return PaginatedMalzamaStudents(
      students:
          (list as List).map((e) => MalzamaStudent.fromJson(e)).toList(),
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
