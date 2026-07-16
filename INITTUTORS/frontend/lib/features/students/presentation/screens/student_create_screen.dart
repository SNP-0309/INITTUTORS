import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/student_state.dart';
import '../controllers/student_controller.dart';

class StudentCreateScreen extends ConsumerStatefulWidget {
  const StudentCreateScreen({super.key});

  @override
  ConsumerState<StudentCreateScreen> createState() => _StudentCreateScreenState();
}

class _StudentCreateScreenState extends ConsumerState<StudentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _rollController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _schoolController = TextEditingController();
  final _standardController = TextEditingController();
  
  // Parent info
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  String _parentRelation = 'guardian';

  DateTime? _admissionDate;
  String? _photoUrl;
  bool _isUploadingPhoto = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _schoolController.dispose();
    _standardController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectAdmissionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Prevents future dates
    );
    if (picked != null) {
      setState(() => _admissionDate = picked);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await ref.read(studentControllerProvider.notifier).uploadPhoto(pickedFile.path);
      setState(() {
        _photoUrl = url;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_admissionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission Date is required')),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final parent = {
      'full_name': _parentNameController.text.trim(),
      'phone': _parentPhoneController.text.trim(),
      'relation': _parentRelation,
      'is_primary': true,
    };

    final student = {
      'roll_number': _rollController.text.trim(),
      'admission_date': _admissionDate!.toIso8601String().split('T')[0],
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'school': _schoolController.text.trim().isEmpty ? null : _schoolController.text.trim(),
      'standard': _standardController.text.trim(),
      'photo_url': _photoUrl,
      'status': 'active',
      'parent': parent,
    };

    try {
      await ref.read(studentControllerProvider.notifier).createStudent(student);
      if (mounted) {
        context.pop(); // Returns to list
      }
    } catch (_) {
      // Error handled by controller state
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll Student'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.space4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppTokens.primary.withOpacity(0.1),
                        backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                        child: _photoUrl == null && !_isUploadingPhoto
                            ? const Icon(Icons.add_a_photo, size: 30, color: AppTokens.primary)
                            : _isUploadingPhoto
                                ? const CircularProgressIndicator()
                                : null,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(45),
                            onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                const Text(
                  'Academic Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTokens.space2),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'First name is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _rollController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Roll Number is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _standardController,
                  decoration: const InputDecoration(
                    labelText: 'Standard / Class (e.g. 10th) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Standard is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                InkWell(
                  onTap: _selectAdmissionDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Admission Date *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _admissionDate == null
                          ? 'Select Date'
                          : '${_admissionDate!.day}/${_admissionDate!.month}/${_admissionDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                const Text(
                  'Contact & Personal Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTokens.space2),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Student Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Student Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                    labelText: 'Current School',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Residential Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                const Text(
                  'Parent Contact Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTokens.space2),
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Parent name is required';
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _parentPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Parent Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Parent phone is required';
                    if (!RegExp(r'^\d{10,15}$').hasMatch(v)) {
                      return 'Enter a valid 10–15 digit phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTokens.space3),
                DropdownButtonFormField<String>(
                  initialValue: _parentRelation,
                  decoration: const InputDecoration(
                    labelText: 'Relation *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'father', child: Text('Father')),
                    DropdownMenuItem(value: 'mother', child: Text('Mother')),
                    DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _parentRelation = val);
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
                    onPressed: state.status == StudentLoadStatus.loading ? null : _submit,
                    child: state.status == StudentLoadStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Student'),
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
