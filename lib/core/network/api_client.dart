import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;
  late final SharedPreferences _prefs;

  ApiClient._();

  static Future<ApiClient> getInstance() async {
    if (_instance == null) {
      _instance = ApiClient._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  bool hasToken() {
    final token = _prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }
}
