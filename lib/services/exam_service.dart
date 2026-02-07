import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/exam_model.dart';

class ExamService {
  final ApiClient _client;

  ExamService(this._client);

  Future<ApiResponse<List<Exam>>> getExams({
    required int level,
    required int teacherId,
    required int subjectId,
  }) async {
    final response = await _client.dio.get(
      AppConstants.examsEndpoint,
      queryParameters: {
        'level': level,
        'teacherId': teacherId,
        'subjectId': subjectId,
      },
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => Exam.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse> addExam(Exam exam) async {
    final response = await _client.dio.post(
      AppConstants.examsEndpoint,
      data: exam.toJson(),
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> editExam(int examId, Exam exam) async {
    final response = await _client.dio.put(
      '${AppConstants.examsEndpoint}/$examId',
      data: exam.toJson(),
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> deleteExam(int examId) async {
    final response = await _client.dio.delete(
      '${AppConstants.examsEndpoint}/$examId',
    );
    return ApiResponse.fromJson(response.data, null);
  }
}
