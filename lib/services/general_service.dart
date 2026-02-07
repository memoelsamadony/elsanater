import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/governorate_model.dart';

class GeneralService {
  final ApiClient _client;

  GeneralService(this._client);

  Future<ApiResponse<List<Governorate>>> getGovernorates() async {
    final response = await _client.dio.get(AppConstants.governoratesEndpoint);
    return ApiResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => Governorate.fromJson(e)).toList(),
    );
  }
}
