import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late int _groupId;
  late String _groupTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _groupId = args['groupId'];
    _groupTitle = args['groupTitle'];
    context.read<AttendanceProvider>().fetchGroupHistory(_groupId);
  }

  Future<void> _startNewDay() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final provider = context.read<AttendanceProvider>();
    await provider.startOrOpenDay(groupId: _groupId, date: dateStr);

    if (!mounted) return;
    if (provider.dayDetails != null) {
      Navigator.pushNamed(
        context,
        '/attendance-day',
        arguments: provider.dayDetails!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(_groupTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewDay,
        icon: const Icon(Icons.add),
        label: Text(t.translate('startAttendance')),
      ),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.history.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.event_note_outlined,
                  message: t.translate('noAttendanceDays'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.history.length,
                  itemBuilder: (context, index) {
                    final day = provider.history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calendar_today,
                              color: AppTheme.primaryBlue),
                        ),
                        title: Text(
                          _formatDate(day.attendanceDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: day.examTitle != null
                            ? Text('${t.translate('exam')}: ${day.examTitle}')
                            : null,
                        trailing: day.presentCount != null
                            ? Chip(
                                label: Text(
                                  '${day.presentCount}/${day.totalStudents ?? 0}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )
                            : null,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/attendance-day',
                          arguments: day.id,
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return date;
    }
  }
}
