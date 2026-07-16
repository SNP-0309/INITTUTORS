import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/owner_dashboard_data.dart';
import '../controllers/owner_dashboard_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(ownerDashboardControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Zinc 950 - dark premium backdrop
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'INITTUTORS',
          style: TextStyle(
            color: Color(0xFFF8FAFC),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFF8FAFC)),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.invalidate(ownerDashboardControllerProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF8FAFC)),
            tooltip: 'Logout',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: dashboardState.when(
        data: (data) => _DashboardContent(data: data),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFC0CB), // Soft Pink loader
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load dashboard\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref
                      .invalidate(ownerDashboardControllerProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC0CB),
                    foregroundColor: const Color(0xFF09090B),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final OwnerDashboardData data;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header welcome banner
          _BentoHeaderCard(dateStr: data.date),
          const SizedBox(height: 16),

          // Responsive Bento Grid Layout
          if (isTablet) ...[
            // Tablet/Desktop grid composition
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _AttendanceCard(
                        percentage: data.attendancePercentageToday,
                        present: data.studentsPresentToday,
                        absent: data.studentsAbsentToday,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'New Admissions',
                              value: '${data.newAdmissionsThisMonth}',
                              subText: 'this month',
                              trend: '+15%',
                              backgroundColor: const Color(0xFFFCFCFD),
                              textColor: const Color(0xFF09090B),
                              accentColor: const Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Pending Fees',
                              value: '₹${(data.pendingFeesAmount / 1000).toStringAsFixed(1)}K',
                              subText: '${data.pendingFeesStudentsCount} students owe dues',
                              trend: 'Overdue',
                              backgroundColor: const Color(0xFFFCFCFD),
                              textColor: const Color(0xFF09090B),
                              accentColor: const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _BatchesCard(batches: data.todaysBatches),
                      const SizedBox(height: 16),
                      const _QuickActionsCard(),
                    ],
                  ),
                ),
              ],
            )
          ] else ...[
            // Mobile layout (vertical flow with varied cards)
            _AttendanceCard(
              percentage: data.attendancePercentageToday,
              present: data.studentsPresentToday,
              absent: data.studentsAbsentToday,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'New Admissions',
                    value: '${data.newAdmissionsThisMonth}',
                    subText: 'this month',
                    trend: '+15%',
                    backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                    textColor: const Color(0xFF0F172A),
                    accentColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Pending Fees',
                    value: '₹${(data.pendingFeesAmount / 1000).toStringAsFixed(1)}K',
                    subText: '${data.pendingFeesStudentsCount} students',
                    trend: 'Dues',
                    backgroundColor: const Color(0xFFF1F5F9),
                    textColor: const Color(0xFF0F172A),
                    accentColor: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _BatchesCard(batches: data.todaysBatches),
            const SizedBox(height: 16),
            const _QuickActionsCard(),
          ],
        ],
      ),
    );
  }
}

class _BentoHeaderCard extends StatelessWidget {
  const _BentoHeaderCard({required this.dateStr});

  final String dateStr;

  @override
  Widget build(BuildContext context) {
    return _BentoBaseContainer(
      backgroundColor: const Color(0xFFFCE1E4), // Soft Pastel Pink
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Color(0xFFC084FC), // Lavender accent
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Welcome, Institute Owner',
                  style: TextStyle(
                    color: Color(0xFF09090B),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Here is the health of your academy today.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Clean decorative circle shape similar to CUBO logo references
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF09090B),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.percentage,
    required this.present,
    required this.absent,
  });

  final double percentage;
  final int present;
  final int absent;

  @override
  Widget build(BuildContext context) {
    return _BentoBaseContainer(
      backgroundColor: const Color(0xFFFFCCD5), // Slightly deeper pastel rose
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'TODAY\'S ATTENDANCE',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Custom Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 16,
                  color: const Color(0xFF09090B), // Dark indicator
                  backgroundColor: Colors.white.withOpacity(0.3),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFF09090B),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Present',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AttendanceMiniStat(
                label: 'Present Students',
                value: '$present',
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF16A34A),
              ),
              Container(
                height: 32,
                width: 1,
                color: Colors.black.withOpacity(0.1),
              ),
              _AttendanceMiniStat(
                label: 'Absent Students',
                value: '$absent',
                icon: Icons.cancel_rounded,
                iconColor: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceMiniStat extends StatelessWidget {
  const _AttendanceMiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF09090B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subText,
    required this.trend,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String subText;
  final String trend;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return _BentoBaseContainer(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subText,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchesCard extends StatelessWidget {
  const _BatchesCard({required this.batches});

  final List<TodaysBatch> batches;

  @override
  Widget build(BuildContext context) {
    return _BentoBaseContainer(
      backgroundColor: const Color(0xFFFCFCFD), // Off-white Card
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S BATCHES',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (batches.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event_busy_rounded,
                        color: Color(0xFF64748B),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Classes Scheduled Today',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'All quiet on the schedule front.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: batches.length,
              separatorBuilder: (context, index) => const Divider(
                height: 24,
                color: Color(0xFFE2E8F0),
              ),
              itemBuilder: (context, index) {
                final batch = batches[index];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCCD5).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF09090B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch.name,
                            style: const TextStyle(
                              color: Color(0xFF09090B),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${batch.subjectName} • ${batch.teacherName}',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${batch.startTime} - ${batch.endTime}',
                          style: const TextStyle(
                            color: Color(0xFF09090B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${batch.studentCount} Students',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return _BentoBaseContainer(
      backgroundColor: const Color(0xFFFCFCFD),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _QuickActionItem(
                label: 'Manage Students',
                icon: Icons.people_rounded,
                color: const Color(0xFFEFF6FF), // Soft Blue
                iconColor: const Color(0xFF2563EB),
                onTap: () => context.push(RoutePaths.adminStudents),
              ),
              _QuickActionItem(
                label: 'Manage Batches',
                icon: Icons.layers_rounded,
                color: const Color(0xFFECFDF5), // Soft Green
                iconColor: const Color(0xFF059669),
                onTap: () => context.push(RoutePaths.adminBatches),
              ),
              _QuickActionItem(
                label: 'Manage Teachers',
                icon: Icons.co_present_rounded,
                color: const Color(0xFFFFF7ED), // Soft Orange
                iconColor: const Color(0xFFEA580C),
                onTap: () => context.push(RoutePaths.adminTeachers),
              ),
              _QuickActionItem(
                label: 'Institute Settings',
                icon: Icons.domain_rounded,
                color: const Color(0xFFF5F3FF), // Soft Purple
                iconColor: const Color(0xFF7C3AED),
                onTap: () => context.push(RoutePaths.adminInstitute),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.iconColor.withOpacity(0.08),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor,
                size: 24,
              ),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BentoBaseContainer extends StatelessWidget {
  const _BentoBaseContainer({
    required this.backgroundColor,
    required this.padding,
    required this.child,
  });

  final Color backgroundColor;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28), // Deeply rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
