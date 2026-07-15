import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'route_paths.dart';

/// Temporary stand-in for not-yet-implemented screens. Role dashboards pass
/// `showLogout: true` so the Logout flow is reachable/demonstrable until real
/// dashboards are built in later modules.
class PlaceholderScreen extends ConsumerWidget {
  const PlaceholderScreen(this.label, {super.key, this.showLogout = false});

  final String label;
  final bool showLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        actions: [
          if (showLogout)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$label — not implemented'),
            if (label == 'Admin Dashboard') ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.push(RoutePaths.adminInstitute),
                child: const Text('Go to Institute Profile'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push(RoutePaths.adminTeachers),
                child: const Text('Manage Teachers'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push(RoutePaths.adminStudents),
                child: const Text('Manage Students'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push(RoutePaths.adminBatches),
                child: const Text('Manage Batches'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
