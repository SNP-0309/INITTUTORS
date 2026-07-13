import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';

/// Application entrypoint.
///
/// Loads environment config, then mounts the app inside a Riverpod
/// [ProviderScope]. No business logic or UI lives here.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  runApp(const ProviderScope(child: AmsApp()));
}
