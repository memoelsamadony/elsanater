import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/malzama_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/malzama_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class MalzamaStudentsScreen extends StatefulWidget {
  const MalzamaStudentsScreen({super.key});

  @override
  State<MalzamaStudentsScreen> createState() => _MalzamaStudentsScreenState();
}

class _MalzamaStudentsScreenState extends State<MalzamaStudentsScreen> {
  late Malzama _malzama;
  final _searchCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _malzama = ModalRoute.of(context)!.settings.arguments as Malzama;
    context.read<MalzamaProvider>().fetchMalzamaStudents(_malzama.id!);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<MalzamaProvider>();
    final auth = context.watch<AuthProvider>();
    final canDeliver = auth.hasAnyRole([
      AppConstants.roleAdmin,
      AppConstants.roleCenterOwner,
      AppConstants.roleMalzamaDelivery,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(_malzama.title),
        actions: [
          if (auth.hasAnyRole([
            AppConstants.roleAdmin,
            AppConstants.roleCenterOwner,
            AppConstants.roleEditMalzama,
          ]))
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.refreshStudents(_malzama.id!),
              tooltip: t.translate('refreshStudents'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: t.translate('search'),
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (v) => provider.fetchMalzamaStudents(
                _malzama.id!,
                search: v,
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.students.isEmpty
                ? const LoadingWidget()
                : provider.students.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.people_outline,
                        message: t.translate('noStudents'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final s = provider.students[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              leading: Icon(
                                s.isReceived
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: s.isReceived
                                    ? AppTheme.success
                                    : Colors.grey,
                              ),
                              title: Text(s.studentName),
                              subtitle: s.isReceived && s.receivedAt != null
                                  ? Text(
                                      '${t.translate('receivedAt')}: ${s.receivedAt}',
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                              trailing: canDeliver
                                  ? s.isReceived
                                      ? TextButton(
                                          onPressed: () =>
                                              provider.cancelReceive(
                                            malzamaId: _malzama.id!,
                                            studentId: s.studentId,
                                          ),
                                          child: Text(
                                            t.translate('cancelReceive'),
                                            style: const TextStyle(
                                                color: AppTheme.error,
                                                fontSize: 12),
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () =>
                                              provider.markReceived(
                                            malzamaId: _malzama.id!,
                                            studentId: s.studentId,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                          ),
                                          child: Text(
                                              t.translate('markReceived'),
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
