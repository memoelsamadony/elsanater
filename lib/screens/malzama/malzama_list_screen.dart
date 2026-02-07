import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/malzama_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class MalzamaListScreen extends StatefulWidget {
  const MalzamaListScreen({super.key});

  @override
  State<MalzamaListScreen> createState() => _MalzamaListScreenState();
}

class _MalzamaListScreenState extends State<MalzamaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MalzamaProvider>().fetchMalzamas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<MalzamaProvider>();
    final auth = context.watch<AuthProvider>();
    final canAdd = auth.hasAnyRole([
      AppConstants.roleAdmin,
      AppConstants.roleCenterOwner,
      AppConstants.roleAddMalzama,
    ]);

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('malzamas'))),
      floatingActionButton: canAdd
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/malzama-form');
                if (mounted) provider.fetchMalzamas();
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: provider.isLoading && provider.malzamas.isEmpty
          ? const LoadingWidget()
          : provider.malzamas.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.menu_book_outlined,
                  message: t.translate('noMalzamas'),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.fetchMalzamas(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: provider.malzamas.length,
                          itemBuilder: (context, index) {
                            final m = provider.malzamas[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.menu_book,
                                      color: Color(0xFF9C27B0)),
                                ),
                                title: Text(m.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${m.teacherName ?? ''} - ${m.subjectName ?? ''}'),
                                    Text(
                                      '${t.translate('price')}: ${m.price.toStringAsFixed(2)} | ${t.translate('received')}: ${m.receivedCount ?? 0}/${m.totalStudents ?? 0}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton(
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'students',
                                      child: Text(
                                          t.translate('malzamaStudents')),
                                    ),
                                    if (auth.hasAnyRole([
                                      AppConstants.roleAdmin,
                                      AppConstants.roleCenterOwner,
                                      AppConstants.roleEditMalzama,
                                    ]))
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(t.translate('edit')),
                                      ),
                                    if (auth.hasAnyRole([
                                      AppConstants.roleAdmin,
                                      AppConstants.roleCenterOwner,
                                      AppConstants.roleRemoveMalzama,
                                    ]))
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(t.translate('delete'),
                                            style: const TextStyle(
                                                color: AppTheme.error)),
                                      ),
                                  ],
                                  onSelected: (v) async {
                                    if (v == 'students') {
                                      Navigator.pushNamed(
                                        context,
                                        '/malzama-students',
                                        arguments: m,
                                      );
                                    } else if (v == 'edit') {
                                      await Navigator.pushNamed(
                                        context,
                                        '/malzama-form',
                                        arguments: m.id,
                                      );
                                      if (mounted) provider.fetchMalzamas();
                                    } else if (v == 'delete') {
                                      _confirmDelete(m.id!);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (provider.totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: provider.currentPage > 1
                                  ? () =>
                                      provider.goToPage(provider.currentPage - 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              '${t.translate('page')} ${provider.currentPage} ${t.translate('of')} ${provider.totalPages}',
                            ),
                            IconButton(
                              onPressed:
                                  provider.currentPage < provider.totalPages
                                      ? () => provider
                                          .goToPage(provider.currentPage + 1)
                                      : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }

  void _confirmDelete(int id) {
    final t = context.tr;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.translate('deleteMalzama')),
        content: Text(t.translate('deleteMalzamaConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<MalzamaProvider>().deleteMalzama(id);
            },
            child: Text(t.translate('delete'),
                style: const TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
