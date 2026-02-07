import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  late final StudentService _service;

  List<Student> _students = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = false;
  String? _error;

  int? _filterLevel;
  bool? _filterGender;
  String? _searchQuery;

  StudentProvider(ApiClient apiClient) {
    _service = StudentService(apiClient);
  }

  List<Student> get students => _students;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get filterLevel => _filterLevel;
  bool? get filterGender => _filterGender;

  void setFilter({int? level, bool? gender}) {
    _filterLevel = level;
    _filterGender = gender;
    _currentPage = 1;
    fetchStudents();
  }

  void setSearch(String? query) {
    _searchQuery = query;
    _currentPage = 1;
    fetchStudents();
  }

  Future<void> fetchStudents({int? page}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getStudents(
        pageNumber: page ?? _currentPage,
        level: _filterLevel,
        gender: _filterGender,
        search: _searchQuery,
      );

      if (response.success && response.data != null) {
        _students = response.data!.students;
        _totalCount = response.data!.totalCount;
        _currentPage = response.data!.pageNumber;
        _totalPages = response.data!.totalPages;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'connectionError';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Student?> getStudentById(int id) async {
    try {
      final response = await _service.getStudentById(id);
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateStudent(int id, UpdateStudentRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.updateStudent(id, request);
      _isLoading = false;
      if (response.success) {
        await fetchStudents();
      } else {
        _error = response.message;
      }
      notifyListeners();
      return response.success;
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'unknownError';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<StudentGroup>> getStudentGroups(int studentId) async {
    try {
      final response = await _service.getStudentGroups(studentId);
      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (_) {}
    return [];
  }

  void goToPage(int page) {
    _currentPage = page;
    fetchStudents(page: page);
  }

  void nextPage() {
    if (_currentPage < _totalPages) goToPage(_currentPage + 1);
  }

  void previousPage() {
    if (_currentPage > 1) goToPage(_currentPage - 1);
  }
}
