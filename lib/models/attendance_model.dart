class AttendanceFilterOptions {
  final List<AttendanceTeacher> teachers;

  AttendanceFilterOptions({required this.teachers});

  factory AttendanceFilterOptions.fromJson(Map<String, dynamic> json) {
    return AttendanceFilterOptions(
      teachers: (json['teachers'] as List?)
              ?.map((e) => AttendanceTeacher.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AttendanceTeacher {
  final int id;
  final String name;
  final List<AttendanceSubject>? subjects;

  AttendanceTeacher({
    required this.id,
    required this.name,
    this.subjects,
  });

  factory AttendanceTeacher.fromJson(Map<String, dynamic> json) {
    return AttendanceTeacher(
      id: json['id'],
      name: json['name'] ?? '',
      subjects: json['subjects'] != null
          ? (json['subjects'] as List)
              .map((e) => AttendanceSubject.fromJson(e))
              .toList()
          : null,
    );
  }
}

class AttendanceSubject {
  final int id;
  final String name;

  AttendanceSubject({required this.id, required this.name});

  factory AttendanceSubject.fromJson(Map<String, dynamic> json) {
    return AttendanceSubject(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class AttendanceGroup {
  final int id;
  final String title;
  final int? studentCount;

  AttendanceGroup({
    required this.id,
    required this.title,
    this.studentCount,
  });

  factory AttendanceGroup.fromJson(Map<String, dynamic> json) {
    return AttendanceGroup(
      id: json['id'],
      title: json['title'] ?? '',
      studentCount: json['studentCount'],
    );
  }
}

class AttendanceDay {
  final int id;
  final int groupId;
  final String? groupTitle;
  final String? teacherName;
  final String? subjectName;
  final String attendanceDate;
  final int? examId;
  final String? examTitle;
  final int? presentCount;
  final int? absentCount;
  final int? totalStudents;

  AttendanceDay({
    required this.id,
    required this.groupId,
    this.groupTitle,
    this.teacherName,
    this.subjectName,
    required this.attendanceDate,
    this.examId,
    this.examTitle,
    this.presentCount,
    this.absentCount,
    this.totalStudents,
  });

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    return AttendanceDay(
      id: json['id'],
      groupId: json['groupId'],
      groupTitle: json['groupTitle'],
      teacherName: json['teacherName'],
      subjectName: json['subjectName'],
      attendanceDate: json['attendanceDate'] ?? '',
      examId: json['examId'],
      examTitle: json['examTitle'],
      presentCount: json['presentCount'],
      absentCount: json['absentCount'],
      totalStudents: json['totalStudents'],
    );
  }
}

class AttendanceDayDetails {
  final int id;
  final int groupId;
  final String? groupTitle;
  final String? teacherName;
  final String? subjectName;
  final String attendanceDate;
  final int? examId;
  final String? examTitle;
  final List<AttendanceStudent> students;
  final List<dynamic>? availableExams;

  AttendanceDayDetails({
    required this.id,
    required this.groupId,
    this.groupTitle,
    this.teacherName,
    this.subjectName,
    required this.attendanceDate,
    this.examId,
    this.examTitle,
    required this.students,
    this.availableExams,
  });

  factory AttendanceDayDetails.fromJson(Map<String, dynamic> json) {
    return AttendanceDayDetails(
      id: json['id'],
      groupId: json['groupId'],
      groupTitle: json['groupTitle'],
      teacherName: json['teacherName'],
      subjectName: json['subjectName'],
      attendanceDate: json['attendanceDate'] ?? '',
      examId: json['examId'],
      examTitle: json['examTitle'],
      students: (json['students'] as List?)
              ?.map((e) => AttendanceStudent.fromJson(e))
              .toList() ??
          [],
      availableExams: json['availableExams'] as List?,
    );
  }
}

class AttendanceStudent {
  final int groupStudentId;
  final int studentId;
  final String studentName;
  final String? studentPhone;
  final bool isPresent;
  final double? paidAmount;
  final double? originalAmount;
  final double? discountAmount;
  final bool? hasTransaction;
  final String? paymentMethod;
  final double? walletBalance;
  final bool? hasWallet;
  final String? note;
  final double? examMark;

  AttendanceStudent({
    required this.groupStudentId,
    required this.studentId,
    required this.studentName,
    this.studentPhone,
    required this.isPresent,
    this.paidAmount,
    this.originalAmount,
    this.discountAmount,
    this.hasTransaction,
    this.paymentMethod,
    this.walletBalance,
    this.hasWallet,
    this.note,
    this.examMark,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    return AttendanceStudent(
      groupStudentId: json['groupStudentId'],
      studentId: json['studentId'],
      studentName: json['studentName'] ?? '',
      studentPhone: json['studentPhone'],
      isPresent: json['isPresent'] ?? false,
      paidAmount: json['paidAmount']?.toDouble(),
      originalAmount: json['originalAmount']?.toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      hasTransaction: json['hasTransaction'],
      paymentMethod: json['paymentMethod'],
      walletBalance: json['walletBalance']?.toDouble(),
      hasWallet: json['hasWallet'],
      note: json['note'],
      examMark: json['examMark']?.toDouble(),
    );
  }
}

class MarkAttendanceRequest {
  final int attendanceDayId;
  final int groupStudentId;
  final bool isPresent;
  final String? note;
  final int? paymentMethod;

  MarkAttendanceRequest({
    required this.attendanceDayId,
    required this.groupStudentId,
    required this.isPresent,
    this.note,
    this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'attendanceDayId': attendanceDayId,
        'groupStudentId': groupStudentId,
        'isPresent': isPresent,
        'note': note,
        'paymentMethod': paymentMethod ?? 0,
      };
}

class AttendanceSummary {
  final int? totalStudents;
  final int? presentCount;
  final int? absentCount;
  final double? totalCollected;
  final double? totalDiscounts;
  final double? cashAmount;
  final double? walletAmount;

  AttendanceSummary({
    this.totalStudents,
    this.presentCount,
    this.absentCount,
    this.totalCollected,
    this.totalDiscounts,
    this.cashAmount,
    this.walletAmount,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      totalStudents: json['totalStudents'],
      presentCount: json['presentCount'],
      absentCount: json['absentCount'],
      totalCollected: json['totalCollected']?.toDouble(),
      totalDiscounts: json['totalDiscounts']?.toDouble(),
      cashAmount: json['cashAmount']?.toDouble(),
      walletAmount: json['walletAmount']?.toDouble(),
    );
  }
}

class StudentAttendanceHistory {
  final String? date;
  final bool? isPresent;
  final double? paidAmount;
  final String? paymentMethod;
  final String? note;

  StudentAttendanceHistory({
    this.date,
    this.isPresent,
    this.paidAmount,
    this.paymentMethod,
    this.note,
  });

  factory StudentAttendanceHistory.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceHistory(
      date: json['date'] ?? json['attendanceDate'],
      isPresent: json['isPresent'],
      paidAmount: json['paidAmount']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      note: json['note'],
    );
  }
}

class PaymentOptions {
  final double? amount;
  final double? walletBalance;
  final int? preferredMethod;

  PaymentOptions({this.amount, this.walletBalance, this.preferredMethod});

  factory PaymentOptions.fromJson(Map<String, dynamic> json) {
    return PaymentOptions(
      amount: json['amount']?.toDouble(),
      walletBalance: json['walletBalance']?.toDouble(),
      preferredMethod: json['preferredMethod'],
    );
  }
}
