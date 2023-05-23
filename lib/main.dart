import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/screens/main_screen.dart';

/// The main entry point.
void main() {
  runApp(const MyApp());
}

/// The main app.
class MyApp extends StatelessWidget {
  /// Create an instance.
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(final BuildContext context) => ProviderScope(
        child: MaterialApp(
          title: 'Audible Checker',
          theme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MainScreen(),
        ),
      );
}
