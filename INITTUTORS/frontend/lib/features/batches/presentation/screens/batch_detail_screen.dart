import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../students/domain/student.dart' as dom;
import '../../../../app/providers/app_providers.dart';
import '../../domain/batch_state.dart';
import '../controllers/batch_controller.dart';

class BatchDetailScreen extends ConsumerStatefulWidget {
  const BatchDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(batchControllerProvider.notifier).loadBatchDetails(widget.id);
    });
  }

  Future<void> _deleteBatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: const Text('Are you sure you want to delete this batch?'),
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
        await ref.read(batchControllerProvider.notifier).deleteBatch(widget.id);
        if (mounted) {
          context.pop(); // Return to list
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

  Future<void> _showAssignStudentDialog() async {
    final studentRepo = ref.read(studentRepositoryProvider);
    String searchQuery = '';
    List<dom.Student> matchingStudents = [];
    bool isSearching = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> search(String query) async {
              setDialogState(() {
                searchQuery = query;
                isSearching = true;
              });
              try {
                final res = await studentRepo.listStudents(search: query, page: 1);
                setDialogState(() {
                  matchingStudents = res['students'] as List<dom.Student>;
                });
              } catch (_) {
                // Ignore error
              } finally {
                setDialogState(() {
                  isSearching = false;
                });
              }
            }

            return AlertDialog(
              title: const Text('Assign Student'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Student name/roll...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        if (val.trim().length >= 2) {
                          search(val.trim());
                        }
                      },
                    ),
                    const SizedBox(height: AppTokens.space3),
                    Expanded(
                      child: isSearching
                          ? const Center(child: CircularProgressIndicator())
                          : matchingStudents.isEmpty
                              ? Center(
                                  child: Text(
                                    searchQuery.isEmpty
                                        ? 'Type to search students'
                                        : 'No students found',
                                    style: const TextStyle(color: AppTokens.textSecondary),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: matchingStudents.length,
                                  itemBuilder: (context, index) {
                                    final s = matchingStudents[index];
                                    return ListTile(
                                      title: Text(s.fullName),
                                      subtitle: Text('Roll: ${s.rollNumber} • Standard: ${s.standard}'),
                                      trailing: const Icon(Icons.add, color: AppTokens.primary),
                                      onTap: () async {
                                        Navigator.pop(context); // Close dialog
                                        try {
                                          await ref
                                              .read(batchControllerProvider.notifier)
                                              .assignStudent(s.id);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Student assigned successfully!')),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Assignment failed: $e')),
                                            );
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removeStudent(String studentId, String studentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove $studentName from this batch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTokens.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(batchControllerProvider.notifier).removeStudent(studentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student removed from batch.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove student: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchControllerProvider);
    final batch = state.batch;
    final roster = state.roster;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Details'),
        actions: [
          if (batch != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteBatch,
            ),
        ],
      ),
      body: SafeArea(
        child: state.status == BatchLoadStatus.loading && batch == null
            ? const Center(child: CircularProgressIndicator())
            : state.status == BatchLoadStatus.error && batch == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error ?? 'Failed to load details',
                            style: const TextStyle(color: AppTokens.danger)),
                        const SizedBox(height: AppTokens.space3),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(batchControllerProvider.notifier)
                              .loadBatchDetails(widget.id),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : batch == null
                    ? const Center(child: Text('Batch not found'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTokens.space4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batch.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppTokens.space1),
                            Chip(
                              label: Text(
                                batch.status.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: batch.status == 'active'
                                  ? AppTokens.success
                                  : AppTokens.neutral,
                            ),
                            const SizedBox(height: AppTokens.space3),
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
                              leading: const Icon(Icons.school),
                              title: const Text('Subject'),
                              subtitle: Text(batch.subject.name),
                            ),
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Assigned Teacher'),
                              subtitle: Text(batch.teacher.user.fullName),
                            ),
                            ListTile(
                              leading: const Icon(Icons.room),
                              title: const Text('Classroom'),
                              subtitle: Text(batch.classroom?.name ?? 'No classroom assigned'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.layers),
                              title: const Text('Standard / Class'),
                              subtitle: Text(batch.standard ?? 'N/A'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.people),
                              title: const Text('Capacity Status'),
                              subtitle: Text('Capacity: ${batch.capacity} (Current Enrolled: ${roster.length})'),
                            ),
                            const SizedBox(height: AppTokens.space3),
                            const Text(
                              'Weekly Schedule',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Divider(),
                            if (batch.schedules.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
                                child: Text('No schedule set for this batch.', style: TextStyle(color: AppTokens.textSecondary)),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: batch.schedules.length,
                                itemBuilder: (context, index) {
                                  final sched = batch.schedules[index];
                                  return ListTile(
                                    leading: const Icon(Icons.access_time, color: AppTokens.primary),
                                    title: Text(sched.dayOfWeek.toUpperCase()),
                                    subtitle: Text('${sched.startTime} - ${sched.endTime}'),
                                  );
                                },
                              ),
                            const SizedBox(height: AppTokens.space4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Student Roster',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTokens.textPrimary,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showAssignStudentDialog,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Assign'),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (roster.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppTokens.space4),
                                child: Center(
                                  child: Text('No students currently assigned.', style: TextStyle(color: AppTokens.textSecondary)),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: roster.length,
                                itemBuilder: (context, index) {
                                  final enrollment = roster[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: AppTokens.space1),
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                      title: Text(enrollment.student.fullName),
                                      subtitle: Text('Roll: ${enrollment.student.rollNumber} • Enrolled: ${enrollment.enrolledOn}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppTokens.danger),
                                        onPressed: () => _removeStudent(enrollment.student.id, enrollment.student.fullName),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
