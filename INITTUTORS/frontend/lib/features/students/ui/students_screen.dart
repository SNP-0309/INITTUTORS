// lib/features/students/ui/students_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/students_provider.dart';
import '../data/student_models.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  int _page = 1;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = (page: _page, search: _search);
    final studentsAsync = ref.watch(studentsProvider(key));
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          // ── Sticky Search + Filter ──────────────────────────────────────
          Container(
            color: AppTheme.surfaceBright,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) {
                    Future.delayed(const Duration(milliseconds: 350), () {
                      if (v == _searchCtrl.text) {
                        setState(() { _search = v; _page = 1; });
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, roll number, phone…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() { _search = ''; _page = 1; });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All', selected: true, onTap: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Active', onTap: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Left', onTap: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Suspended', onTap: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: studentsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) => const StudentCardSkeleton(),
              ),
              error: (e, _) => Center(
                child: Text(e.toString(),
                    style: tt.bodyMedium
                        ?.copyWith(color: AppTheme.onSurfaceVariant)),
              ),
              data: (paginated) {
                if (paginated.results.isEmpty) {
                  return _EmptyStudents(search: _search);
                }
                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => ref.refresh(studentsProvider(key).future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: paginated.results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) =>
                        _StudentCard(student: paginated.results[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceContainer),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            AppAvatar(photoUrl: student.photoUrl, name: student.fullName, size: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName,
                      style: tt.headlineSmall
                          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    'Roll: #${student.rollNumber} • Grade ${student.standard}',
                    style: tt.bodyMedium
                        ?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: student.status),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryContainer : AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppTheme.primaryContainer : AppTheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _EmptyStudents extends StatelessWidget {
  final String search;
  const _EmptyStudents({required this.search});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            search.isEmpty ? Icons.people_outline_rounded : Icons.search_off_rounded,
            size: 56, color: AppTheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            search.isEmpty ? 'No students yet' : 'No students match "$search"',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
