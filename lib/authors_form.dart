/// Provides the [AuthorsForm] class.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authors_loader.dart';

/// The line splitter to use.
const _lineSplitter = LineSplitter();

/// A form which allows the saving of authors.
class AuthorsForm extends StatefulWidget {
  /// Create an instance.
  const AuthorsForm({required this.authors, super.key});

  /// The current list of authors.
  final List<String> authors;

  /// Create state for this widget.
  @override
  AuthorsFormState createState() => AuthorsFormState();
}

/// State for [AuthorsForm].
class AuthorsFormState extends State<AuthorsForm> {
  /// The controller for the authors text field.
  late final TextEditingController _authorsController;

  /// The form key to use.
  late final GlobalKey<FormState> _formKey;

  /// Get the list of authors.
  List<String> get authors => _lineSplitter
      .convert(_authorsController.text)
      .where((final element) => element.trim().isNotEmpty)
      .toList();

  /// Set up the controller and the form key.
  @override
  void initState() {
    super.initState();
    _authorsController = TextEditingController(text: widget.authors.join('\n'));
    _formKey = GlobalKey();
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Authors'),
        ),
        body: Form(
          key: _formKey,
          child: TextFormField(
            autofocus: true,
            controller: _authorsController,
            decoration: const InputDecoration(
              hintText: 'Enter authors, 1 per line',
              labelText: 'Authors',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? true) {
              saveAuthors();
              Navigator.of(context).pop(authors);
            }
          },
          child: const Icon(
            Icons.save_rounded,
            semanticLabel: 'Save',
          ),
        ),
      );

  /// Dispose of the controller.
  @override
  void dispose() {
    super.dispose();
    _authorsController.dispose();
  }

  /// Save the current authors.
  Future<void> saveAuthors() async {
    final instance = await SharedPreferences.getInstance();
    await instance.setStringList(authorsKey, authors);
  }
}
