import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

/// Root application widget: wires the theme and router together.
///
/// No UI/screens are defined here — screens are owned by their routes.
class AmsApp extends StatelessWidget {
  const AmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
