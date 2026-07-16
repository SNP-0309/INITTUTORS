import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/route_paths.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/auth_state.dart';
import '../../domain/institute_state.dart';
import '../controllers/institute_controller.dart';

class InstituteProfileScreen extends ConsumerStatefulWidget {
  const InstituteProfileScreen({super.key});

  @override
  ConsumerState<InstituteProfileScreen> createState() => _InstituteProfileScreenState();
}

class _InstituteProfileScreenState extends ConsumerState<InstituteProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(instituteControllerProvider.notifier).loadInstitutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(instituteControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.user?.role.name == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Institute Profile'),
        actions: [
          if (isAdmin && state.institute != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(RoutePaths.adminInstituteEdit),
            ),
        ],
      ),
      body: SafeArea(
        child: state.status == InstituteLoadStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : state.status == InstituteLoadStatus.error
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.space4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.error ?? 'An error occurred',
                              style: const TextStyle(color: AppTokens.danger)),
                          const SizedBox(height: AppTokens.space3),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(instituteControllerProvider.notifier)
                                .loadInstitutes(),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  )
                : state.institute == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTokens.space4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No institute configuration found.',
                                  style: TextStyle(
                                      color: AppTokens.textSecondary)),
                              if (isAdmin) ...[
                                const SizedBox(height: AppTokens.space3),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.push(RoutePaths.adminInstituteCreate),
                                  child: const Text('Create Institute Profile'),
                                ),
                              ]
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTokens.space4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  if (state.institute!.logoUrl != null &&
                                      state.institute!.logoUrl!.isNotEmpty)
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          state.institute!.logoUrl!),
                                    )
                                  else
                                    const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppTokens.primary,
                                      child: Icon(Icons.school,
                                          size: 50, color: Colors.white),
                                    ),
                                  const SizedBox(height: AppTokens.space3),
                                  Text(
                                    state.institute!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTokens.textPrimary,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppTokens.space1),
                                  Chip(
                                    label: Text(
                                      state.institute!.status.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: state.institute!.status ==
                                            'active'
                                        ? AppTokens.success
                                        : AppTokens.neutral,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTokens.space4 * 1.5),
                            const Text(
                              'Contact Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.phone,
                                  color: AppTokens.primary),
                              title: const Text('Phone'),
                              subtitle: Text(state.institute!.phone),
                            ),
                            if (state.institute!.email != null)
                              ListTile(
                                leading: const Icon(Icons.email,
                                    color: AppTokens.primary),
                                title: const Text('Email'),
                                subtitle: Text(state.institute!.email!),
                              ),
                            if (state.institute!.website != null)
                              ListTile(
                                leading: const Icon(Icons.web,
                                    color: AppTokens.primary),
                                title: const Text('Website'),
                                subtitle: Text(state.institute!.website!),
                              ),
                            const SizedBox(height: AppTokens.space4),
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.location_on,
                                  color: AppTokens.primary),
                              title: const Text('Address'),
                              subtitle: Text(
                                '${state.institute!.address}\n${state.institute!.city}, ${state.institute!.state} - ${state.institute!.pincode}',
                              ),
                            ),
                            const SizedBox(height: AppTokens.space4),
                            const Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.access_time,
                                  color: AppTokens.primary),
                              title: const Text('Timezone'),
                              subtitle: Text(state.institute!.timezone),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
