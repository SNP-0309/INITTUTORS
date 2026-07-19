// lib/shared/widgets/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/data/auth_models.dart';
import '../../core/constants/app_constants.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: _AppTopBar(user: user),
      body: navigationShell,
      bottomNavigationBar: _BottomNav(shell: navigationShell),
    );
  }
}

class _AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  const _AppTopBar({this.user});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppBar(
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryContainer,
          ),
          alignment: Alignment.center,
          child: Text(
            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
            style: const TextStyle(
              color: AppTheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
      title: Text(
        AppConstants.appName,
        style: tt.headlineSmall?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppTheme.primary,
          onPressed: () {},
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppTheme.surfaceContainer),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _BottomNav({required this.shell});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (index) =>
          shell.goBranch(index, initialLocation: index == shell.currentIndex),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group_rounded),
          label: 'Students',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups_rounded),
          label: 'Batches',
        ),
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          selectedIcon: Icon(Icons.campaign_rounded),
          label: 'More',
        ),
      ],
    );
  }
}
