import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/teacher_state.dart';
import '../controllers/teacher_controller.dart';

class TeacherEditScreen extends ConsumerStatefulWidget {
  const TeacherEditScreen({super.key});

  @override
  ConsumerState<TeacherEditScreen> createState() => _TeacherEditScreenState();
}

class _TeacherEditScreenState extends ConsumerState<TeacherEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _codeController;
  late TextEditingController _specController;
  DateTime? _joiningDate;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    final teacher = ref.read(teacherControllerProvider).teacher;
    _nameController = TextEditingController(text: teacher?.user.fullName);
    _phoneController = TextEditingController(text: teacher?.user.phone);
    _emailController = TextEditingController(text: teacher?.user.email);
    _codeController = TextEditingController(text: teacher?.employeeCode);
    _specController = TextEditingController(text: teacher?.specialization);
    _status = teacher?.status ?? 'active';
    if (teacher?.joiningDate != null) {
      _joiningDate = DateTime.tryParse(teacher!.joiningDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _specController.dispose();
    super.dispose();
  }

  Future<void> _selectJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  Future<void> _submit() async {
    final teacher = ref.read(teacherControllerProvider).teacher;
    if (teacher == null) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = {
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    };

    final data = {
      'user': user,
      'employee_code': _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
      'specialization': _specController.text.trim().isEmpty ? null : _specController.text.trim(),
      'joining_date': _joiningDate != null ? _joiningDate!.toIso8601String().split('T')[0] : null,
      'status': _status,
    };

    try {
      await ref.read(teacherControllerProvider.notifier).updateTeacher(teacher.id, data);
      if (mounted) {
        context.pop(); // Returns to details
      }
    } catch (_) {
      // Error handled by controller state
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Teacher'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.space4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'User Account Info',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTokens.space2),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Full name is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Phone number is required';
                    if (!RegExp(r'^\d{10,15}$').hasMatch(v)) {
                      return 'Enter a valid 10–15 digit phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                const Text(
                  'Teacher Profile Info',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTokens.space2),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Employee Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _specController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                InkWell(
                  onTap: _selectJoiningDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Joining Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _joiningDate == null
                          ? 'Select Date'
                          : '${_joiningDate!.day}/${_joiningDate!.month}/${_joiningDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _status = val);
                    }
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
                    onPressed: state.status == TeacherLoadStatus.loading ? null : _submit,
                    child: state.status == TeacherLoadStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
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
