import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/route_paths.dart';
import '../../domain/teacher_state.dart';
import '../controllers/teacher_controller.dart';

class TeacherListScreen extends ConsumerStatefulWidget {
  const TeacherListScreen({super.key});

  @override
  ConsumerState<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends ConsumerState<TeacherListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(teacherControllerProvider.notifier).loadTeachers(isRefresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(teacherControllerProvider.notifier).loadTeachers();
    }
  }

  void _onSearch(String query) {
    ref.read(teacherControllerProvider.notifier).loadTeachers(search: query, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTokens.space3),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, code...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppTokens.space2,
                    horizontal: AppTokens.space3,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.teachers.isEmpty && state.status == TeacherLoadStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.status == TeacherLoadStatus.error && state.teachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(state.error ?? 'Failed to load teachers',
                                  style: const TextStyle(color: AppTokens.danger)),
                              const SizedBox(height: AppTokens.space3),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(teacherControllerProvider.notifier)
                                    .loadTeachers(isRefresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : state.teachers.isEmpty
                          ? const Center(
                              child: Text('No teachers found',
                                  style: TextStyle(color: AppTokens.textSecondary)),
                            )
                          : RefreshIndicator(
                              onRefresh: () => ref
                                  .read(teacherControllerProvider.notifier)
                                  .loadTeachers(isRefresh: true),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: state.teachers.length + (state.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.teachers.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(AppTokens.space4),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }

                                  final teacher = state.teachers[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppTokens.space3,
                                      vertical: AppTokens.space1,
                                    ),
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: AppTokens.primary,
                                        child: Icon(Icons.person, color: Colors.white),
                                      ),
                                      title: Text(
                                        teacher.user.fullName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Code: ${teacher.employeeCode ?? 'N/A'} • Spec: ${teacher.specialization ?? 'N/A'}',
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        context.push(
                                          RoutePaths.adminTeacherDetail
                                              .replaceAll(':id', teacher.id),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.adminTeacherNew),
        child: const Icon(Icons.add),
      ),
    );
  }
}
