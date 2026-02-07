class AppConstants {
  AppConstants._();

  // ── Base URL (single source of truth) ──
  static const String baseUrl = 'http://localhost:8819';

  // ── Auth endpoints ──
  static const String loginEndpoint = '/auth/Login';
  static const String validateTokenEndpoint = '/auth/validate';
  static const String logoutEndpoint = '/auth/logout';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String changeEmailEndpoint = '/auth/change-email';
  static const String sendOtpResetPasswordEndpoint = '/auth/SendOTPResetPassword';
  static const String confirmResetPasswordOtpEndpoint = '/auth/ConfirmResetPasswordOTP';
  static const String resetPasswordEndpoint = '/auth/ResetPassword';
  static const String currentUserEndpoint = '/accounts/current';
  static const String updateProfileEndpoint = '/accounts/update-profile';

  // ── General endpoints ──
  static const String governoratesEndpoint = '/governorates';
  static const String teachersEndpoint = '/teachers';
  static const String teacherGroupsEndpoint = '/teacher-groups';

  // ── Student endpoints ──
  static const String studentsEndpoint = '/Students';

  // ── Exam endpoints ──
  static const String examsEndpoint = '/Exams';

  // ── Malzama endpoints ──
  static const String malzamaEndpoint = '/Malzama';
  static const String malzamaMatchingGroupsEndpoint = '/Malzama/matching-groups';
  static const String malzamaMarkReceivedEndpoint = '/Malzama/mark-received';
  static const String malzamaCancelReceiveEndpoint = '/Malzama/cancel-receive';

  // ── Attendance endpoints ──
  static const String attendanceFiltersEndpoint = '/Attendance/filters';
  static const String attendanceGroupsEndpoint = '/Attendance/groups';
  static const String attendanceSubjectsEndpoint = '/Attendance/subjects';
  static const String attendanceStartEndpoint = '/Attendance/start';
  static const String attendanceDayEndpoint = '/Attendance/day';
  static const String attendanceSummaryEndpoint = '/Attendance/summary';
  static const String attendanceMarkEndpoint = '/Attendance/mark';
  static const String attendancePaymentOptionsEndpoint = '/Attendance/payment-options';
  static const String attendanceStudentHistoryEndpoint = '/Attendance/student-history';
  static const String attendanceGroupHistoryEndpoint = '/Attendance/group';
  static const String attendanceExamEndpoint = '/Attendance/exam';
  static const String attendanceExamMarksEndpoint = '/Attendance/exam-marks';

  // ── Storage keys ──
  static const String tokenKey = 'access_token';
  static const String localeKey = 'app_locale';
  static const String themeModeKey = 'theme_mode';

  // ── Pagination defaults ──
  static const int defaultPageSize = 20;

  // ── School levels ──
  static const Map<int, String> schoolLevelsAr = {
    0: 'الصف الأول الابتدائي',
    1: 'الصف الثاني الابتدائي',
    2: 'الصف الثالث الابتدائي',
    3: 'الصف الرابع الابتدائي',
    4: 'الصف الخامس الابتدائي',
    5: 'الصف السادس الابتدائي',
    6: 'الصف الأول الإعدادي',
    7: 'الصف الثاني الإعدادي',
    8: 'الصف الثالث الإعدادي',
    9: 'الصف الأول الثانوي',
    10: 'الصف الثاني الثانوي',
    11: 'الصف الثالث الثانوي',
  };

  static const Map<int, String> schoolLevelsEn = {
    0: 'Primary 1',
    1: 'Primary 2',
    2: 'Primary 3',
    3: 'Primary 4',
    4: 'Primary 5',
    5: 'Primary 6',
    6: 'Preparatory 1',
    7: 'Preparatory 2',
    8: 'Preparatory 3',
    9: 'Secondary 1',
    10: 'Secondary 2',
    11: 'Secondary 3',
  };

  // ── Roles ──
  static const String roleAdmin = 'Admin';
  static const String roleCenterOwner = 'CenterOwner';
  static const String roleViewStudents = 'ViewStudents';
  static const String roleEditStudent = 'EditStudent';
  static const String roleViewMalzamas = 'ViewMalzamas';
  static const String roleAddMalzama = 'AddMalzama';
  static const String roleEditMalzama = 'EditMalzama';
  static const String roleRemoveMalzama = 'RemoveMalzama';
  static const String roleMalzamaDelivery = 'MalzamaDelivery';
  static const String roleViewStudentAttendanceHistory = 'ViewStudentAttendanceHistory';
}

enum PaymentMethod {
  cash(0),
  wallet(1);

  final int value;
  const PaymentMethod(this.value);

  static PaymentMethod fromValue(int value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}
