import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/student_model.dart';

class StudentService {
  final ApiClient _client;

  StudentService(this._client);

  Future<ApiResponse<PaginatedStudents>> getStudents({
    int pageNumber = 1,
    int pageSize = 20,
    int? level,
    bool? gender,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'PageNumber': pageNumber,
      'PageSize': pageSize,
    };
    if (level != null) params['Level'] = level;
    if (gender != null) params['Gender'] = gender;
    if (search != null && search.isNotEmpty) params['Search'] = search;

    final response = await _client.dio.get(
      AppConstants.studentsEndpoint,
      queryParameters: params,
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => PaginatedStudents.fromJson(data),
    );
  }

  Future<ApiResponse<Student>> getStudentById(int id) async {
    final response = await _client.dio.get(
      '${AppConstants.studentsEndpoint}/$id',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => Student.fromJson(data),
    );
  }

  Future<ApiResponse> updateStudent(int id, UpdateStudentRequest request) async {
    final response = await _client.dio.put(
      '${AppConstants.studentsEndpoint}/$id',
      data: request.toJson(),
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse<List<StudentGroup>>> getStudentGroups(int id) async {
    final response = await _client.dio.get(
      '${AppConstants.studentsEndpoint}/$id/groups',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => StudentGroup.fromJson(e)).toList(),
    );
  }
}
