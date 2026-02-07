import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/attendance_model.dart';
import '../models/exam_model.dart';

class AttendanceService {
  final ApiClient _client;

  AttendanceService(this._client);

  Future<ApiResponse<AttendanceFilterOptions>> getFilterOptions() async {
    final response = await _client.dio.get(AppConstants.attendanceFiltersEndpoint);
    return ApiResponse.fromJson(
      response.data,
      (data) => AttendanceFilterOptions.fromJson(data),
    );
  }

  Future<ApiResponse<List<AttendanceGroup>>> getGroups({
    required int teacherId,
    required int level,
    required int subjectId,
  }) async {
    final response = await _client.dio.get(
      AppConstants.attendanceGroupsEndpoint,
      queryParameters: {
        'teacherId': teacherId,
        'level': level,
        'subjectId': subjectId,
      },
    );
    return ApiResponse.fromJson(
      response.data,
      (data) =>
          (data as List).map((e) => AttendanceGroup.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<List<AttendanceSubject>>> getSubjectsByTeacher(
      int teacherId) async {
    final response = await _client.dio.get(
      '${AppConstants.attendanceSubjectsEndpoint}/$teacherId',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) =>
          (data as List).map((e) => AttendanceSubject.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<List<AttendanceDay>>> getGroupHistory(int groupId) async {
    final response = await _client.dio.get(
      '${AppConstants.attendanceGroupHistoryEndpoint}/$groupId/history',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) =>
          (data as List).map((e) => AttendanceDay.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<AttendanceDayDetails>> startAttendanceDay({
    required int groupId,
    required String date,
    int? examId,
  }) async {
    final params = <String, dynamic>{'date': date};
    if (examId != null) params['examId'] = examId;

    final response = await _client.dio.post(
      '${AppConstants.attendanceStartEndpoint}/$groupId',
      queryParameters: params,
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => AttendanceDayDetails.fromJson(data),
    );
  }

  Future<ApiResponse<AttendanceDayDetails>> getAttendanceDayDetails(
      int attendanceDayId) async {
    final response = await _client.dio.get(
      '${AppConstants.attendanceDayEndpoint}/$attendanceDayId',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => AttendanceDayDetails.fromJson(data),
    );
  }

  Future<ApiResponse<AttendanceSummary>> getAttendanceSummary(
      int attendanceDayId) async {
    final response = await _client.dio.get(
      '${AppConstants.attendanceSummaryEndpoint}/$attendanceDayId',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => AttendanceSummary.fromJson(data),
    );
  }

  Future<ApiResponse> markAttendance(MarkAttendanceRequest request) async {
    final response = await _client.dio.post(
      AppConstants.attendanceMarkEndpoint,
      data: request.toJson(),
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse<PaymentOptions>> getPaymentOptions({
    required int groupStudentId,
    required int attendanceDayId,
  }) async {
    final response = await _client.dio.get(
      '${AppConstants.attendancePaymentOptionsEndpoint}/$groupStudentId',
      queryParameters: {'attendanceDayId': attendanceDayId},
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => PaymentOptions.fromJson(data),
    );
  }

  Future<ApiResponse<List<StudentAttendanceHistory>>> getStudentHistory(
      int groupStudentId) async {
    final response = await _client.dio.get(
      '${AppConstants.attendanceStudentHistoryEndpoint}/$groupStudentId',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List)
          .map((e) => StudentAttendanceHistory.fromJson(e))
          .toList(),
    );
  }

  Future<ApiResponse> setExamForDay({
    required int attendanceDayId,
    int? examId,
  }) async {
    final response = await _client.dio.post(
      AppConstants.attendanceExamEndpoint,
      data: {'attendanceDayId': attendanceDayId, 'examId': examId},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> saveExamMarks({
    required int attendanceDayId,
    required List<ExamMark> marks,
  }) async {
    final response = await _client.dio.post(
      AppConstants.attendanceExamMarksEndpoint,
      data: {
        'attendanceDayId': attendanceDayId,
        'marks': marks.map((e) => e.toJson()).toList(),
      },
    );
    return ApiResponse.fromJson(response.data, null);
  }
}
