import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/teacher_model.dart';

class TeacherService {
  final ApiClient _client;

  TeacherService(this._client);

  Future<ApiResponse<List<Teacher>>> getTeachers() async {
    final response = await _client.dio.get(AppConstants.teachersEndpoint);
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => Teacher.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<List<Group>>> getTeacherGroups({
    required int teacherId,
    int? level,
    int? subjectId,
  }) async {
    final params = <String, dynamic>{'TeacherId': teacherId};
    if (level != null) params['Level'] = level;
    if (subjectId != null) params['SubjectId'] = subjectId;

    final response = await _client.dio.get(
      AppConstants.teacherGroupsEndpoint,
      queryParameters: params,
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => Group.fromJson(e)).toList(),
    );
  }
}
