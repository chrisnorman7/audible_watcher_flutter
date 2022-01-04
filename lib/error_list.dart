/// Provides the [ErrorList] class.
import 'package:flutter/material.dart';

/// A list view that shows errors.
class ErrorList extends StatelessWidget {
  /// Create an instance.
  const ErrorList({required this.error, required this.stackTrace, Key? key})
      : super(key: key);

  /// The error to use.
  final Object? error;

  /// The stack trace to use.
  final StackTrace? stackTrace;
  @override
  Widget build(BuildContext context) => ListView(
        children: [
          ListTile(
            title: const Text('Error'),
            subtitle: Text('$error'),
          ),
          ListTile(
            title: const Text('Snapshot'),
            subtitle: Text('$stackTrace'),
          ),
        ],
      );
}
