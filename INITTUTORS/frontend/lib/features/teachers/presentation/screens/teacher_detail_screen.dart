import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/route_paths.dart';
import '../../domain/teacher_state.dart';
import '../controllers/teacher_controller.dart';

class TeacherDetailScreen extends ConsumerStatefulWidget {
  const TeacherDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends ConsumerState<TeacherDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(teacherControllerProvider.notifier).loadTeacherDetails(widget.id);
    });
  }

  Future<void> _deleteTeacher() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: const Text('Are you sure you want to delete this teacher? This will also soft-delete their user profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTokens.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(teacherControllerProvider.notifier).deleteTeacher(widget.id);
        if (mounted) {
          context.pop(); // Returns to list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherControllerProvider);
    final teacher = state.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Details'),
        actions: [
          if (teacher != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(
                RoutePaths.adminTeacherEdit.replaceAll(':id', teacher.id),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTeacher,
            ),
          ]
        ],
      ),
      body: SafeArea(
        child: state.status == TeacherLoadStatus.loading && teacher == null
            ? const Center(child: CircularProgressIndicator())
            : state.status == TeacherLoadStatus.error && teacher == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error ?? 'Failed to load details',
                            style: const TextStyle(color: AppTokens.danger)),
                        const SizedBox(height: AppTokens.space3),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(teacherControllerProvider.notifier)
                              .loadTeacherDetails(widget.id),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : teacher == null
                    ? const Center(child: Text('Teacher not found'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTokens.space4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: AppTokens.primary,
                                    child: Icon(Icons.person, size: 40, color: Colors.white),
                                  ),
                                  const SizedBox(height: AppTokens.space3),
                                  Text(
                                    teacher.user.fullName,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: AppTokens.space1),
                                  Chip(
                                    label: Text(
                                      teacher.status.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: teacher.status == 'active'
                                        ? AppTokens.success
                                        : AppTokens.neutral,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTokens.space4),
                            const Text(
                              'Profile Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Phone'),
                              subtitle: Text(teacher.user.phone),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email'),
                              subtitle: Text(teacher.user.email ?? 'N/A'),
                            ),
                            const SizedBox(height: AppTokens.space3),
                            const Text(
                              'Employment Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.badge),
                              title: const Text('Employee Code'),
                              subtitle: Text(teacher.employeeCode ?? 'N/A'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.star),
                              title: const Text('Specialization'),
                              subtitle: Text(teacher.specialization ?? 'N/A'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Joining Date'),
                              subtitle: Text(teacher.joiningDate ?? 'N/A'),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
