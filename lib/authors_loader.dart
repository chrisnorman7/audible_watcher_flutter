/// Provides the [AuthorsLoader] class.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'books_loader.dart';
import 'error_list.dart';

/// The authors key to use.
const authorsKey = 'authors';

/// A widget for loading authors from a [SharedPreferences] instance.
class AuthorsLoader extends StatefulWidget {
  /// Create an instance.
  const AuthorsLoader({Key? key}) : super(key: key);

  /// Route name.
  static const String routeName = '/';

  /// Create state for this widget.
  @override
  _AuthorsLoaderState createState() => _AuthorsLoaderState();
}

/// State for [AuthorsLoader].
class _AuthorsLoaderState extends State<AuthorsLoader> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorList(
                error: snapshot.error, stackTrace: snapshot.stackTrace);
          } else if (snapshot.hasData) {
            return BooksLoader(authors: snapshot.requireData);
          } else {
            return const CircularProgressIndicator(
              semanticsLabel: 'Loading...',
            );
          }
        },
        future: _getAuthors(),
      );

  /// Load authors.
  Future<List<String>> _getAuthors() async {
    final instance = await SharedPreferences.getInstance();
    return instance.getStringList(authorsKey) ?? [];
  }
}
