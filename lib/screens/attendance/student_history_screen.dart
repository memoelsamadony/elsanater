import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class StudentHistoryScreen extends StatefulWidget {
  const StudentHistoryScreen({super.key});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final groupStudentId =
        ModalRoute.of(context)!.settings.arguments as int;
    context.read<AttendanceProvider>().fetchStudentHistory(groupStudentId);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('studentHistory'))),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.studentHistory.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.history,
                  message: t.translate('noData'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.studentHistory.length,
                  itemBuilder: (context, index) {
                    final h = provider.studentHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: Icon(
                          h.isPresent == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: h.isPresent == true
                              ? AppTheme.success
                              : AppTheme.error,
                        ),
                        title: Text(h.date ?? ''),
                        subtitle: h.note != null && h.note!.isNotEmpty
                            ? Text(h.note!)
                            : null,
                        trailing: h.paidAmount != null
                            ? Text(
                                h.paidAmount!.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
