import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/route_paths.dart';
import '../../domain/student_state.dart';
import '../controllers/student_controller.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  const StudentDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentControllerProvider.notifier).loadStudentDetails(widget.id);
    });
  }

  Future<void> _deleteStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student? This will soft-delete their profile record.'),
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
        await ref.read(studentControllerProvider.notifier).deleteStudent(widget.id);
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
    final state = ref.watch(studentControllerProvider);
    final student = state.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        actions: [
          if (student != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(
                RoutePaths.adminStudentEdit.replaceAll(':id', student.id),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteStudent,
            ),
          ]
        ],
      ),
      body: SafeArea(
        child: state.status == StudentLoadStatus.loading && student == null
            ? const Center(child: CircularProgressIndicator())
            : state.status == StudentLoadStatus.error && student == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error ?? 'Failed to load details',
                            style: const TextStyle(color: AppTokens.danger)),
                        const SizedBox(height: AppTokens.space3),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(studentControllerProvider.notifier)
                              .loadStudentDetails(widget.id),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : student == null
                    ? const Center(child: Text('Student not found'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTokens.space4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: AppTokens.primary,
                                    backgroundImage: student.photoUrl != null
                                        ? NetworkImage(student.photoUrl!)
                                        : null,
                                    child: student.photoUrl == null
                                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(height: AppTokens.space3),
                                  Text(
                                    student.fullName,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: AppTokens.space1),
                                  Chip(
                                    label: Text(
                                      student.status.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: student.status == 'active'
                                        ? AppTokens.success
                                        : AppTokens.neutral,
                                  ),
                                  if (student.statusReason != null && student.statusReason!.isNotEmpty) ...[
                                    const SizedBox(height: AppTokens.space1),
                                    Text(
                                      'Reason: ${student.statusReason!}',
                                      style: const TextStyle(color: AppTokens.textSecondary, fontStyle: FontStyle.italic),
                                    ),
                                  ],
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
                              leading: const Icon(Icons.badge),
                              title: const Text('Roll Number'),
                              subtitle: Text(student.rollNumber),
                            ),
                            ListTile(
                              leading: const Icon(Icons.school),
                              title: const Text('Standard'),
                              subtitle: Text(student.standard),
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Admission Date'),
                              subtitle: Text(student.admissionDate),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Student Phone'),
                              subtitle: Text(student.phone ?? 'N/A'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email'),
                              subtitle: Text(student.email ?? 'N/A'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.location_on),
                              title: const Text('Address'),
                              subtitle: Text(student.address ?? 'N/A'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.business),
                              title: const Text('School'),
                              subtitle: Text(student.school ?? 'N/A'),
                            ),
                            const SizedBox(height: AppTokens.space3),
                            const Text(
                              'Parent Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.contacts),
                              title: const Text('Primary Contact Name'),
                              subtitle: Text(student.primaryParent?.fullName ?? 'N/A'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone_android),
                              title: const Text('Parent Phone'),
                              subtitle: Text(student.primaryParent?.phone ?? student.parentPhone),
                            ),
                            ListTile(
                              leading: const Icon(Icons.family_restroom),
                              title: const Text('Relation'),
                              subtitle: Text(student.primaryParent?.relation.toUpperCase() ?? 'GUARDIAN'),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
