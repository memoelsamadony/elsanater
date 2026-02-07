import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    final response = await _client.dio.post(
      AppConstants.loginEndpoint,
      data: request.toJson(),
    );
    return ApiResponse.fromJson(
      response.data,
      (data) => LoginResponse.fromJson(data),
    );
  }

  Future<ApiResponse> validateToken() async {
    final response = await _client.dio.post(AppConstants.validateTokenEndpoint);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> logout() async {
    final response = await _client.dio.post(AppConstants.logoutEndpoint);
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> changePassword({
    required String current,
    required String newPassword,
  }) async {
    final response = await _client.dio.post(
      AppConstants.changePasswordEndpoint,
      data: {'current': current, 'new': newPassword},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> sendOtpResetPassword(String email) async {
    final response = await _client.dio.post(
      AppConstants.sendOtpResetPasswordEndpoint,
      queryParameters: {'email': email},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> confirmResetPasswordOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.dio.post(
      AppConstants.confirmResetPasswordOtpEndpoint,
      queryParameters: {'email': email, 'OTP': otp},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final response = await _client.dio.post(
      AppConstants.resetPasswordEndpoint,
      data: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      },
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _client.dio.get(AppConstants.currentUserEndpoint);
    return ApiResponse.fromJson(
      response.data,
      (data) => User.fromJson(data),
    );
  }

  Future<ApiResponse> updateProfile(UpdateProfileRequest request) async {
    final response = await _client.dio.put(
      AppConstants.updateProfileEndpoint,
      data: request.toJson(),
    );
    return ApiResponse.fromJson(response.data, null);
  }
}
