import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/loading_widget.dart';

class AttendanceDayScreen extends StatefulWidget {
  const AttendanceDayScreen({super.key});

  @override
  State<AttendanceDayScreen> createState() => _AttendanceDayScreenState();
}

class _AttendanceDayScreenState extends State<AttendanceDayScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dayId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<AttendanceProvider>().fetchDayDetails(dayId);
  }

  Future<void> _toggleAttendance(AttendanceStudent student) async {
    final provider = context.read<AttendanceProvider>();
    final day = provider.dayDetails!;

    int paymentMethod = 0;
    if (!student.isPresent && student.hasWallet == true) {
      final method = await _showPaymentDialog(student);
      if (method == null) return;
      paymentMethod = method;
    }

    await provider.markAttendance(MarkAttendanceRequest(
      attendanceDayId: day.id,
      groupStudentId: student.groupStudentId,
      isPresent: !student.isPresent,
      paymentMethod: paymentMethod,
    ));
  }

  Future<int?> _showPaymentDialog(AttendanceStudent student) {
    final t = context.tr;
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.translate('paymentMethod')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (student.walletBalance != null)
              Text(
                '${t.translate('wallet')}: ${student.walletBalance!.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.money),
              title: Text(t.translate('cash')),
              onTap: () => Navigator.pop(ctx, 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              tileColor: Colors.grey[100],
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(t.translate('wallet')),
              onTap: () => Navigator.pop(ctx, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              tileColor: Colors.grey[100],
            ),
          ],
        ),
      ),
    );
  }

  void _showSummary() async {
    final provider = context.read<AttendanceProvider>();
    await provider.fetchSummary(provider.dayDetails!.id);
    if (!mounted) return;
    final summary = provider.summary;
    if (summary == null) return;

    final t = context.tr;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.translate('attendanceSummary'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _summaryRow(t.translate('totalStudents'),
                '${summary.totalStudents ?? 0}'),
            _summaryRow(t.translate('presentCount'),
                '${summary.presentCount ?? 0}',
                color: AppTheme.success),
            _summaryRow(
                t.translate('absentCount'), '${summary.absentCount ?? 0}',
                color: AppTheme.error),
            const Divider(),
            _summaryRow(t.translate('totalCollected'),
                '${summary.totalCollected?.toStringAsFixed(2) ?? 0}'),
            _summaryRow(t.translate('cash'),
                '${summary.cashAmount?.toStringAsFixed(2) ?? 0}'),
            _summaryRow(t.translate('wallet'),
                '${summary.walletAmount?.toStringAsFixed(2) ?? 0}'),
            _summaryRow(t.translate('totalDiscounts'),
                '${summary.totalDiscounts?.toStringAsFixed(2) ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<AttendanceProvider>();
    final day = provider.dayDetails;

    if (provider.isLoading || day == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.translate('markAttendance'))),
        body: const LoadingWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(day.groupTitle ?? t.translate('markAttendance')),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showSummary,
            tooltip: t.translate('attendanceSummary'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: day.students.length,
        itemBuilder: (context, index) {
          final student = day.students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: student.isPresent
                    ? AppTheme.success.withValues(alpha: 0.2)
                    : Colors.grey[200],
                child: Icon(
                  student.isPresent ? Icons.check : Icons.close,
                  color: student.isPresent ? AppTheme.success : Colors.grey,
                ),
              ),
              title: Text(student.studentName,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: student.hasTransaction == true
                  ? Text(
                      '${student.paidAmount?.toStringAsFixed(2) ?? ''} (${student.paymentMethod ?? ''})',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (student.walletBalance != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Chip(
                        label: Text(
                          student.walletBalance!.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 11),
                        ),
                        avatar: const Icon(Icons.account_balance_wallet,
                            size: 14),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  Switch(
                    value: student.isPresent,
                    activeThumbColor: AppTheme.success,
                    onChanged: (_) => _toggleAttendance(student),
                  ),
                ],
              ),
              onLongPress: () => Navigator.pushNamed(
                context,
                '/student-attendance-history',
                arguments: student.groupStudentId,
              ),
            ),
          );
        },
      ),
    );
  }
}
