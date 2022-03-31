/// Provides the [ErrorList] class.
import 'package:flutter/material.dart';

/// A list view that shows errors.
class ErrorList extends StatelessWidget {
  /// Create an instance.
  const ErrorList({
    required this.error,
    required this.stackTrace,
    final Key? key,
  }) : super(key: key);

  /// The error to use.
  final Object? error;

  /// The stack trace to use.
  final StackTrace? stackTrace;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => ListView(
        children: [
          ListTile(
            autofocus: true,
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
