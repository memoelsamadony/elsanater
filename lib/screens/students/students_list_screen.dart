import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/student_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final provider = context.watch<StudentProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final levels = isAr ? AppConstants.schoolLevelsAr : AppConstants.schoolLevelsEn;

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('students'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.translate('search'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearch(null);
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => provider.setSearch(v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: t.translate('all'),
                  selected: provider.filterLevel == null,
                  onSelected: () => provider.setFilter(level: null),
                ),
                ...levels.entries.map((e) => _FilterChip(
                      label: e.value,
                      selected: provider.filterLevel == e.key,
                      onSelected: () => provider.setFilter(level: e.key),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildBody(provider, t),
          ),
          if (provider.totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: provider.currentPage > 1
                        ? provider.previousPage
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${t.translate('page')} ${provider.currentPage} ${t.translate('of')} ${provider.totalPages}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: provider.currentPage < provider.totalPages
                        ? provider.nextPage
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

  Widget _buildBody(StudentProvider provider, AppLocalizations t) {
    if (provider.isLoading && provider.students.isEmpty) {
      return const LoadingWidget();
    }
    if (provider.error != null && provider.students.isEmpty) {
      return AppErrorWidget(
        message: t.translate(provider.error!),
        onRetry: () => provider.fetchStudents(),
      );
    }
    if (provider.students.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        message: t.translate('noStudents'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchStudents(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: provider.students.length,
        itemBuilder: (context, index) {
          final student = provider.students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: student.gender
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.pink.withValues(alpha: 0.2),
                child: Icon(
                  student.gender ? Icons.male : Icons.female,
                  color: student.gender ? Colors.blue : Colors.pink,
                ),
              ),
              title: Text(student.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(student.schoolLevelName ?? ''),
              trailing: Text(
                student.codeId ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              onTap: () => Navigator.pushNamed(
                context,
                '/student-detail',
                arguments: student.id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onSelected(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
