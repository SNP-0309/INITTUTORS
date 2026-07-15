import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/route_paths.dart';
import '../../domain/institute_state.dart';
import '../controllers/institute_controller.dart';

class InstituteCreateScreen extends ConsumerStatefulWidget {
  const InstituteCreateScreen({super.key});

  @override
  ConsumerState<InstituteCreateScreen> createState() => _InstituteCreateScreenState();
}

class _InstituteCreateScreenState extends ConsumerState<InstituteCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _logoUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    
    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'website': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'logo_url': _logoUrlController.text.trim().isEmpty ? null : _logoUrlController.text.trim(),
      'timezone': 'Asia/Kolkata',
    };

    try {
      await ref.read(instituteControllerProvider.notifier).createInstitute(data);
      if (mounted) {
        context.go(RoutePaths.adminInstitute);
      }
    } catch (_) {
      // Error handled by controller state
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(instituteControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Institute'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.space4),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Institute Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Name is required';
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
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Website URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space3),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTokens.space3),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: AppTokens.space3),
                TextFormField(
                  controller: _logoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Logo Image URL',
                    border: OutlineInputBorder(),
                  ),
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
                    onPressed: state.status == InstituteLoadStatus.loading ? null : _submit,
                    child: state.status == InstituteLoadStatus.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Institute'),
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
