import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/malzama_model.dart';
import '../models/teacher_model.dart';
import '../services/malzama_service.dart';

class MalzamaProvider extends ChangeNotifier {
  late final MalzamaService _service;

  List<Malzama> _malzamas = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = false;
  String? _error;

  List<MalzamaStudent> _students = [];
  int _studentsTotalCount = 0;
  int _studentsCurrentPage = 1;
  int _studentsTotalPages = 0;

  MalzamaProvider(ApiClient apiClient) {
    _service = MalzamaService(apiClient);
  }

  List<Malzama> get malzamas => _malzamas;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MalzamaStudent> get students => _students;
  int get studentsTotalCount => _studentsTotalCount;
  int get studentsCurrentPage => _studentsCurrentPage;
  int get studentsTotalPages => _studentsTotalPages;

  Future<void> fetchMalzamas({
    int? page,
    int? teacherId,
    int? subjectId,
    int? level,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getMalzamas(
        pageNumber: page ?? _currentPage,
        teacherId: teacherId,
        subjectId: subjectId,
        level: level,
      );
      if (response.success && response.data != null) {
        _malzamas = response.data!.malzamas;
        _totalCount = response.data!.totalCount;
        _currentPage = response.data!.pageNumber;
        _totalPages = response.data!.totalPages;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'connectionError';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Malzama?> getMalzamaById(int id) async {
    try {
      final response = await _service.getMalzamaById(id);
      if (response.success && response.data != null) return response.data;
    } catch (_) {}
    return null;
  }

  Future<bool> createMalzama(Malzama malzama) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.createMalzama(malzama);
      _isLoading = false;
      if (!response.success) _error = response.message;
      notifyListeners();
      return response.success;
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'unknownError';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMalzama(int id, Malzama malzama) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.updateMalzama(id, malzama);
      _isLoading = false;
      if (!response.success) _error = response.message;
      notifyListeners();
      return response.success;
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'unknownError';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMalzama(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.deleteMalzama(id);
      _isLoading = false;
      if (response.success) {
        _malzamas.removeWhere((m) => m.id == id);
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

  Future<List<Group>> getMatchingGroups({
    required int teacherId,
    required int subjectId,
    required int level,
  }) async {
    try {
      final response = await _service.getMatchingGroups(
        teacherId: teacherId,
        subjectId: subjectId,
        level: level,
      );
      if (response.success && response.data != null) return response.data!;
    } catch (_) {}
    return [];
  }

  Future<void> fetchMalzamaStudents(int malzamaId, {int? page, String? search}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.getMalzamaStudents(
        malzamaId,
        pageNumber: page ?? _studentsCurrentPage,
        search: search,
      );
      if (response.success && response.data != null) {
        _students = response.data!.students;
        _studentsTotalCount = response.data!.totalCount;
        _studentsCurrentPage = response.data!.pageNumber;
        _studentsTotalPages = response.data!.totalPages;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markReceived({required int malzamaId, required int studentId}) async {
    try {
      final response = await _service.markReceived(
        malzamaId: malzamaId,
        studentId: studentId,
      );
      if (response.success) {
        await fetchMalzamaStudents(malzamaId);
      }
      return response.success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelReceive({required int malzamaId, required int studentId}) async {
    try {
      final response = await _service.cancelReceive(
        malzamaId: malzamaId,
        studentId: studentId,
      );
      if (response.success) {
        await fetchMalzamaStudents(malzamaId);
      }
      return response.success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> refreshStudents(int malzamaId) async {
    try {
      final response = await _service.refreshStudents(malzamaId);
      if (response.success) {
        await fetchMalzamaStudents(malzamaId);
      }
      return response.success;
    } catch (_) {
      return false;
    }
  }

  void goToPage(int page) {
    _currentPage = page;
    fetchMalzamas(page: page);
  }
}
