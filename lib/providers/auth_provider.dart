import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final AuthService _authService;

  User? _user;
  List<String> _roles = [];
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider(this._apiClient) {
    _authService = AuthService(_apiClient);
    _isAuthenticated = _apiClient.hasToken();
  }

  User? get user => _user;
  List<String> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  bool hasRole(String role) => _roles.contains(role);
  bool hasAnyRole(List<String> requiredRoles) =>
      requiredRoles.any((role) => _roles.contains(role));

  Future<bool> login({
    required String emailOrPhone,
    required String password,
    required String centerCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(
          emailOrPhone: emailOrPhone,
          password: password,
          centerCode: centerCode,
        ),
      );

      if (response.success && response.data != null) {
        await _apiClient.setToken(response.data!.token);
        _roles = response.data!.roles;
        _isAuthenticated = true;
        _user = User(
          email: response.data!.email,
          name: response.data!.firstName,
          roles: response.data!.roles,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _error = _parseDioError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> validateToken() async {
    if (!_apiClient.hasToken()) {
      _isAuthenticated = false;
      return false;
    }

    try {
      final response = await _authService.validateToken();
      if (response.success || response.code == 200 || response.code == 202) {
        _isAuthenticated = true;
        await fetchCurrentUser();
        return true;
      }
      _isAuthenticated = false;
      await _apiClient.clearToken();
      return false;
    } catch (_) {
      _isAuthenticated = false;
      await _apiClient.clearToken();
      return false;
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final response = await _authService.getCurrentUser();
      if (response.success && response.data != null) {
        _user = response.data;
        _roles = response.data!.roles;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    await _apiClient.clearToken();
    _user = null;
    _roles = [];
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String current,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
        current: current,
        newPassword: newPassword,
      );
      _isLoading = false;
      if (!response.success) _error = response.message;
      notifyListeners();
      return response.success;
    } on DioException catch (e) {
      _error = _parseDioError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtpResetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.sendOtpResetPassword(email);
      _isLoading = false;
      if (!response.success) _error = response.message;
      notifyListeners();
      return response.success;
    } on DioException catch (e) {
      _error = _parseDioError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> confirmResetPasswordOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.confirmResetPasswordOtp(
        email: email,
        otp: otp,
      );
      _isLoading = false;
      if (response.success) {
        notifyListeners();
        return response.data?.toString();
      }
      _error = response.message;
      notifyListeners();
      return null;
    } on DioException catch (e) {
      _error = _parseDioError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      _isLoading = false;
      if (!response.success) _error = response.message;
      notifyListeners();
      return response.success;
    } on DioException catch (e) {
      _error = _parseDioError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(request);
      if (response.success) {
        await fetchCurrentUser();
      } else {
        _error = response.message;
      }
      _isLoading = false;
      notifyListeners();
      return response.success;
    } on DioException catch (e) {
      _error = _parseDioError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseDioError(DioException e) {
    if (e.response?.data is Map) {
      final msg = (e.response!.data as Map)['message'];
      if (msg != null) return msg.toString();
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'connectionError';
      case DioExceptionType.connectionError:
        return 'connectionError';
      default:
        if (e.response?.statusCode == 401) return 'sessionExpired';
        if (e.response?.statusCode == 403) return 'unauthorized';
        return 'unknownError';
    }
  }
}
