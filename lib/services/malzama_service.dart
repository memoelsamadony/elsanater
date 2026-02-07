import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/malzama_model.dart';
import '../models/teacher_model.dart';

class MalzamaService {
  final ApiClient _client;

  MalzamaService(this._client);

  Future<ApiResponse<PaginatedMalzamas>> getMalzamas({
    int pageNumber = 1,
    int pageSize = 20,
    int? teacherId,
    int? subjectId,
    int? level,
  }) async {
    final params = <String, dynamic>{
      'PageNumber': pageNumber,
      'PageSize': pageSize,
    };
    if (teacherId != null) params['TeacherId'] = teacherId;
    if (subjectId != null) params['SubjectId'] = subjectId;
    if (level != null) params['Level'] = level;

    final response = await _client.dio.get(
      AppConstants.malzamaEndpoint,
      queryParameters: params,
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => PaginatedMalzamas.fromJson(data),
    );
  }

  Future<ApiResponse<Malzama>> getMalzamaById(int id) async {
    final response = await _client.dio.get(
      '${AppConstants.malzamaEndpoint}/$id',
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => Malzama.fromJson(data),
    );
  }

  Future<ApiResponse> createMalzama(Malzama malzama) async {
    final response = await _client.dio.post(
      AppConstants.malzamaEndpoint,
      data: malzama.toJson(),
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> updateMalzama(int id, Malzama malzama) async {
    final response = await _client.dio.put(
      '${AppConstants.malzamaEndpoint}/$id',
      data: malzama.toJson(),
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> deleteMalzama(int id) async {
    final response = await _client.dio.delete(
      '${AppConstants.malzamaEndpoint}/$id',
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse<List<Group>>> getMatchingGroups({
    required int teacherId,
    required int subjectId,
    required int level,
  }) async {
    final response = await _client.dio.get(
      AppConstants.malzamaMatchingGroupsEndpoint,
      queryParameters: {
        'teacherId': teacherId,
        'subjectId': subjectId,
        'level': level,
      },
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => Group.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<PaginatedMalzamaStudents>> getMalzamaStudents(
    int malzamaId, {
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _client.dio.get(
      '${AppConstants.malzamaEndpoint}/$malzamaId/students',
      queryParameters: params,
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => PaginatedMalzamaStudents.fromJson(data),
    );
  }

  Future<ApiResponse> markReceived({
    required int malzamaId,
    required int studentId,
  }) async {
    final response = await _client.dio.post(
      AppConstants.malzamaMarkReceivedEndpoint,
      data: {'malzamaId': malzamaId, 'studentId': studentId},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> cancelReceive({
    required int malzamaId,
    required int studentId,
  }) async {
    final response = await _client.dio.post(
      AppConstants.malzamaCancelReceiveEndpoint,
      data: {'malzamaId': malzamaId, 'studentId': studentId},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> refreshStudents(int malzamaId) async {
    final response = await _client.dio.post(
      '${AppConstants.malzamaEndpoint}/$malzamaId/refresh-students',
    );
    return ApiResponse.fromJson(response.data, null);
  }
}
