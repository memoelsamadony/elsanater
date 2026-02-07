class Student {
  final int id;
  final String name;
  final String? phone;
  final String? codeId;
  final int schoolLevel;
  final String? schoolLevelName;
  final bool gender;
  final String? address;
  final String? parentName;
  final String? parentPhone;

  Student({
    required this.id,
    required this.name,
    this.phone,
    this.codeId,
    required this.schoolLevel,
    this.schoolLevelName,
    required this.gender,
    this.address,
    this.parentName,
    this.parentPhone,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      codeId: json['codeId'],
      schoolLevel: json['schoolLevel'] ?? 0,
      schoolLevelName: json['schoolLevelName'],
      gender: json['gender'] ?? true,
      address: json['address'],
      parentName: json['parentName'],
      parentPhone: json['parentPhone'],
    );
  }
}

class PaginatedStudents {
  final List<Student> students;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  PaginatedStudents({
    required this.students,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedStudents.fromJson(Map<String, dynamic> json) {
    return PaginatedStudents(
      students: (json['students'] as List?)
              ?.map((e) => Student.fromJson(e))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class UpdateStudentRequest {
  final int id;
  final String name;
  final String? phone;
  final int schoolLevel;
  final String? address;
  final bool gender;
  final String? parentName;
  final String? parentPhone;

  UpdateStudentRequest({
    required this.id,
    required this.name,
    this.phone,
    required this.schoolLevel,
    this.address,
    required this.gender,
    this.parentName,
    this.parentPhone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'schoolLevel': schoolLevel,
        'address': address,
        'gender': gender,
        'parentName': parentName,
        'parentPhone': parentPhone,
      };
}

class StudentGroup {
  final int id;
  final String title;
  final String? teacherName;
  final String? subjectName;

  StudentGroup({
    required this.id,
    required this.title,
    this.teacherName,
    this.subjectName,
  });

  factory StudentGroup.fromJson(Map<String, dynamic> json) {
    return StudentGroup(
      id: json['id'],
      title: json['title'] ?? '',
      teacherName: json['teacherName'],
      subjectName: json['subjectName'],
    );
  }
}
