import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/exam_model.dart';
import '../services/exam_service.dart';

class ExamProvider extends ChangeNotifier {
  late final ExamService _service;

  List<Exam> _exams = [];
  bool _isLoading = false;
  String? _error;

  ExamProvider(ApiClient apiClient) {
    _service = ExamService(apiClient);
  }

  List<Exam> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExams({
    required int level,
    required int teacherId,
    required int subjectId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getExams(
        level: level,
        teacherId: teacherId,
        subjectId: subjectId,
      );
      if (response.success && response.data != null) {
        _exams = response.data!;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'connectionError';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExam(Exam exam) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.addExam(exam);
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

  Future<bool> editExam(int examId, Exam exam) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.editExam(examId, exam);
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

  Future<bool> deleteExam(int examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.deleteExam(examId);
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
}
