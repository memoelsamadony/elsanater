import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/attendance_model.dart';
import '../models/exam_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  late final AttendanceService _service;

  AttendanceFilterOptions? _filterOptions;
  List<AttendanceGroup> _groups = [];
  List<AttendanceSubject> _subjects = [];
  List<AttendanceDay> _history = [];
  AttendanceDayDetails? _dayDetails;
  AttendanceSummary? _summary;
  List<StudentAttendanceHistory> _studentHistory = [];

  bool _isLoading = false;
  String? _error;

  AttendanceProvider(ApiClient apiClient) {
    _service = AttendanceService(apiClient);
  }

  AttendanceFilterOptions? get filterOptions => _filterOptions;
  List<AttendanceGroup> get groups => _groups;
  List<AttendanceSubject> get subjects => _subjects;
  List<AttendanceDay> get history => _history;
  AttendanceDayDetails? get dayDetails => _dayDetails;
  AttendanceSummary? get summary => _summary;
  List<StudentAttendanceHistory> get studentHistory => _studentHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFilterOptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getFilterOptions();
      if (response.success && response.data != null) {
        _filterOptions = response.data;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'connectionError';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSubjectsByTeacher(int teacherId) async {
    try {
      final response = await _service.getSubjectsByTeacher(teacherId);
      if (response.success && response.data != null) {
        _subjects = response.data!;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchGroups({
    required int teacherId,
    required int level,
    required int subjectId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.getGroups(
        teacherId: teacherId,
        level: level,
        subjectId: subjectId,
      );
      if (response.success && response.data != null) {
        _groups = response.data!;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchGroupHistory(int groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getGroupHistory(groupId);
      if (response.success && response.data != null) {
        _history = response.data!;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'connectionError';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startOrOpenDay({
    required int groupId,
    required String date,
    int? examId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.startAttendanceDay(
        groupId: groupId,
        date: date,
        examId: examId,
      );
      if (response.success && response.data != null) {
        _dayDetails = response.data;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'connectionError';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDayDetails(int attendanceDayId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _service.getAttendanceDayDetails(attendanceDayId);
      if (response.success && response.data != null) {
        _dayDetails = response.data;
      } else {
        _error = response.message;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'connectionError';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAttendance(MarkAttendanceRequest request) async {
    try {
      final response = await _service.markAttendance(request);
      if (response.success) {
        if (_dayDetails != null) {
          await fetchDayDetails(_dayDetails!.id);
        }
        return true;
      }
      _error = response.message;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      _error = e.response?.data?['message']?.toString() ?? 'unknownError';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSummary(int attendanceDayId) async {
    try {
      final response = await _service.getAttendanceSummary(attendanceDayId);
      if (response.success && response.data != null) {
        _summary = response.data;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchStudentHistory(int groupStudentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.getStudentHistory(groupStudentId);
      if (response.success && response.data != null) {
        _studentHistory = response.data!;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<PaymentOptions?> getPaymentOptions({
    required int groupStudentId,
    required int attendanceDayId,
  }) async {
    try {
      final response = await _service.getPaymentOptions(
        groupStudentId: groupStudentId,
        attendanceDayId: attendanceDayId,
      );
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> setExamForDay({
    required int attendanceDayId,
    int? examId,
  }) async {
    try {
      final response = await _service.setExamForDay(
        attendanceDayId: attendanceDayId,
        examId: examId,
      );
      return response.success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveExamMarks({
    required int attendanceDayId,
    required List<ExamMark> marks,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.saveExamMarks(
        attendanceDayId: attendanceDayId,
        marks: marks,
      );
      _isLoading = false;
      notifyListeners();
      return response.success;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearDayDetails() {
    _dayDetails = null;
    _summary = null;
    notifyListeners();
  }
}
