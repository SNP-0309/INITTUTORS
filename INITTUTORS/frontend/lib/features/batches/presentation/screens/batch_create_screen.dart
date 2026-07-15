import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../teachers/domain/teacher.dart' as dom_teacher;
import '../../domain/batch.dart';
import '../../domain/batch_state.dart';
import '../controllers/batch_controller.dart';

class BatchCreateScreen extends ConsumerStatefulWidget {
  const BatchCreateScreen({super.key});

  @override
  ConsumerState<BatchCreateScreen> createState() => _BatchCreateScreenState();
}

class _BatchCreateScreenState extends ConsumerState<BatchCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _standardController = TextEditingController();
  final _capacityController = TextEditingController(text: '30');

  String? _selectedSubjectId;
  String? _selectedTeacherId;
  String? _selectedClassroomId;

  List<dom_teacher.Teacher> _teachers = [];
  bool _isLoadingLookups = true;

  // Schedules state
  final List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadLookups());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _standardController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() => _isLoadingLookups = true);
    try {
      // Load subjects & classrooms in batch controller state
      await ref.read(batchControllerProvider.notifier).loadSubjectsAndClassrooms();

      // Load teachers
      final teacherRepo = ref.read(teacherRepositoryProvider);
      final res = await teacherRepo.listTeachers(page: 1);
      if (mounted) {
        setState(() {
          _teachers = res['teachers'] as List<dom_teacher.Teacher>;
        });
      }
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) {
        setState(() => _isLoadingLookups = false);
      }
    }
  }

  Future<void> _quickAddSubject() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Subject Name (e.g. Mathematics)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      setState(() => _isLoadingLookups = true);
      try {
        final repo = ref.read(batchRepositoryProvider);
        final created = await repo.createSubject({'name': name});
        await ref.read(batchControllerProvider.notifier).loadSubjectsAndClassrooms();
        setState(() {
          _selectedSubjectId = created.id;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subject "$name" created successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add subject: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingLookups = false);
        }
      }
    }
  }

  Future<void> _quickAddClassroom() async {
    final nameController = TextEditingController();
    final capController = TextEditingController(text: '30');
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Classroom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Classroom Name (e.g. Room A)'),
            ),
            const SizedBox(height: AppTokens.space2),
            TextField(
              controller: capController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacity'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'capacity': int.tryParse(capController.text.trim()) ?? 30,
              });
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result['name'].toString().isNotEmpty) {
      setState(() => _isLoadingLookups = true);
      try {
        final repo = ref.read(batchRepositoryProvider);
        final created = await repo.createClassroom({
          'name': result['name'],
          'capacity': result['capacity'],
        });
        await ref.read(batchControllerProvider.notifier).loadSubjectsAndClassrooms();
        setState(() {
          _selectedClassroomId = created.id;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Classroom "${result['name']}" created successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add classroom: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingLookups = false);
        }
      }
    }
  }

  void _addScheduleSlot() async {
    String day = 'mon';
    TimeOfDay startTime = const TimeOfDay(hour: 18, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 19, minute: 0);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Weekly Schedule Slot'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: day,
                    decoration: const InputDecoration(labelText: 'Day of Week'),
                    items: const [
                      DropdownMenuItem(value: 'mon', child: Text('Monday')),
                      DropdownMenuItem(value: 'tue', child: Text('Tuesday')),
                      DropdownMenuItem(value: 'wed', child: Text('Wednesday')),
                      DropdownMenuItem(value: 'thu', child: Text('Thursday')),
                      DropdownMenuItem(value: 'fri', child: Text('Friday')),
                      DropdownMenuItem(value: 'sat', child: Text('Saturday')),
                      DropdownMenuItem(value: 'sun', child: Text('Sunday')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => day = val);
                      }
                    },
                  ),
                  const SizedBox(height: AppTokens.space3),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setDialogState(() => startTime = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Start Time'),
                            child: Text(startTime.format(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTokens.space3),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setDialogState(() => endTime = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'End Time'),
                            child: Text(endTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'day_of_week': day,
                      'start_time': startTime,
                      'end_time': endTime,
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    ).then((res) {
      if (res != null) {
        final startT = res['start_time'] as TimeOfDay;
        final endT = res['end_time'] as TimeOfDay;
        
        final startStr = '${startT.hour.toString().padLeft(2, '0')}:${startT.minute.toString().padLeft(2, '0')}:00';
        final endStr = '${endT.hour.toString().padLeft(2, '0')}:${endT.minute.toString().padLeft(2, '0')}:00';

        setState(() {
          _schedules.add({
            'day_of_week': res['day_of_week'] as String,
            'start_time': startStr,
            'end_time': endStr,
          });
        });
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject is required')),
      );
      return;
    }
    if (_selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher is required')),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final data = {
      'name': _nameController.text.trim(),
      'subject_id': _selectedSubjectId,
      'teacher_id': _selectedTeacherId,
      'classroom_id': _selectedClassroomId,
      'standard': _standardController.text.trim().isEmpty ? null : _standardController.text.trim(),
      'capacity': int.tryParse(_capacityController.text.trim()) ?? 30,
      'status': 'active',
      'schedule_data': _schedules,
    };

    try {
      await ref.read(batchControllerProvider.notifier).createBatch(data);
      if (mounted) {
        context.pop(); // Returns to batch list
      }
    } catch (_) {
      // Error is stored and handled by controller state
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Batch'),
      ),
      body: SafeArea(
        child: _isLoadingLookups
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppTokens.space4),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Batch Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) return 'Batch name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSubjectId,
                              decoration: const InputDecoration(
                                labelText: 'Subject *',
                                border: OutlineInputBorder(),
                              ),
                              items: state.subjects.map((sub) {
                                return DropdownMenuItem(value: sub.id, child: Text(sub.name));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedSubjectId = val),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space2),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTokens.primary),
                            onPressed: _quickAddSubject,
                            tooltip: 'Add new subject',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        value: _selectedTeacherId,
                        decoration: const InputDecoration(
                          labelText: 'Assign Teacher *',
                          border: OutlineInputBorder(),
                        ),
                        items: _teachers.map((t) {
                          return DropdownMenuItem(value: t.id, child: Text(t.user.fullName));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedTeacherId = val),
                      ),
                      if (_teachers.isEmpty) ...[
                        const SizedBox(height: AppTokens.space1),
                        const Text(
                          'No teachers found. Please create a teacher in Teacher Management first.',
                          style: TextStyle(color: AppTokens.danger, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: AppTokens.space3),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedClassroomId,
                              decoration: const InputDecoration(
                                labelText: 'Classroom (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              items: state.classrooms.map((cls) {
                                return DropdownMenuItem(value: cls.id, child: Text(cls.name));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedClassroomId = val),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space2),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTokens.primary),
                            onPressed: _quickAddClassroom,
                            tooltip: 'Add new classroom',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextFormField(
                        controller: _standardController,
                        decoration: const InputDecoration(
                          labelText: 'Standard / Class (e.g. 10th)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Capacity *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final count = int.tryParse(value ?? '');
                          if (count == null || count <= 0) return 'Enter capacity greater than 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTokens.space4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weekly Timetable Schedules',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: _addScheduleSlot,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Add Day Slot'),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (_schedules.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTokens.space2),
                          child: Text(
                            'No schedule days configured yet. Overlap checks run on save.',
                            style: TextStyle(color: AppTokens.textSecondary, fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final sched = _schedules[index];
                            return ListTile(
                              leading: const Icon(Icons.calendar_today, color: AppTokens.primary),
                              title: Text(sched['day_of_week'].toString().toUpperCase()),
                              subtitle: Text('${sched['start_time']} - ${sched['end_time']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppTokens.danger),
                                onPressed: () {
                                  setState(() {
                                    _schedules.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      if (state.error != null) ...[
                        const SizedBox(height: AppTokens.space3),
                        Text(
                          state.error!,
                          style: const TextStyle(color: AppTokens.danger),
                        ),
                      ],
                      const SizedBox(height: AppTokens.space4 * 1.5),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: state.status == BatchLoadStatus.loading ? null : _submit,
                          child: state.status == BatchLoadStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Create Batch'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
