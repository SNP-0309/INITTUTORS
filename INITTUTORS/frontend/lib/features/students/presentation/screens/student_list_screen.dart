import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/route_paths.dart';
import '../../domain/student_state.dart';
import '../controllers/student_controller.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentControllerProvider.notifier).loadStudents(isRefresh: true);
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
      ref.read(studentControllerProvider.notifier).loadStudents();
    }
  }

  void _onSearch(String query) {
    ref.read(studentControllerProvider.notifier).loadStudents(search: query, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
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
                  hintText: 'Search standard, roll number, parent...',
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
              child: state.students.isEmpty && state.status == StudentLoadStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.status == StudentLoadStatus.error && state.students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(state.error ?? 'Failed to load students',
                                  style: const TextStyle(color: AppTokens.danger)),
                              const SizedBox(height: AppTokens.space3),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(studentControllerProvider.notifier)
                                    .loadStudents(isRefresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : state.students.isEmpty
                          ? const Center(
                              child: Text('No students found',
                                  style: TextStyle(color: AppTokens.textSecondary)),
                            )
                          : RefreshIndicator(
                              onRefresh: () => ref
                                  .read(studentControllerProvider.notifier)
                                  .loadStudents(isRefresh: true),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: state.students.length + (state.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.students.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(AppTokens.space4),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }

                                  final student = state.students[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppTokens.space3,
                                      vertical: AppTokens.space1,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTokens.primary,
                                        backgroundImage: student.photoUrl != null
                                            ? NetworkImage(student.photoUrl!)
                                            : null,
                                        child: student.photoUrl == null
                                            ? const Icon(Icons.person, color: Colors.white)
                                            : null,
                                      ),
                                      title: Text(
                                        student.fullName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Roll: ${student.rollNumber} • Standard: ${student.standard}',
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        context.push(
                                          RoutePaths.adminStudentDetail
                                              .replaceAll(':id', student.id),
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
        onPressed: () => context.push(RoutePaths.adminStudentNew),
        child: const Icon(Icons.add),
      ),
    );
  }
}
