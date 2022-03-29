import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'audiobook.dart';
import 'authors_form.dart';
import 'error_object.dart';
import 'get_books.dart';

/// A widget that loaded a series of [Audiobook] instances.
class BooksLoader extends StatefulWidget {
  /// Create an instance.
  const BooksLoader({required this.authors, Key? key}) : super(key: key);

  /// The authors whose books should be loaded.
  final List<String> authors;

  /// Create state for this widget.
  @override
  BooksLoaderState createState() => BooksLoaderState();
}

/// State for [BooksLoader].
class BooksLoaderState extends State<BooksLoader> {
  /// The stream to use for loading books.
  StreamSubscription<Audiobook>? _subscription;

  /// The audiobooks that have loaded so far.
  late final List<Audiobook> _audiobooks;

  /// Any error that has occurred.
  ErrorObject? _errorObject;

  /// Initialise the audiobooks list.
  @override
  void initState() {
    super.initState();
    _audiobooks = [];
    startSubscription();
  }

  /// Start listening for books.
  void startSubscription() {
    _subscription = getBooks(widget.authors).listen(
      (event) => setState(() => _audiobooks.add(event)),
      onError: (Object e, StackTrace? s) {
        setState(() => _errorObject = ErrorObject(e, s));
      },
      onDone: () => _subscription = null,
    );
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    if (widget.authors.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nothing To Show'),
          actions: [
            getAuthorsButton(),
            ElevatedButton(
              onPressed: widget.authors.isEmpty
                  ? null
                  : () => setState(
                        () {
                          _audiobooks.clear();
                          _subscription = null;
                        },
                      ),
              child:
                  const Icon(Icons.refresh_rounded, semanticLabel: 'Refresh'),
            )
          ],
        ),
        body: const Center(
          child: Text(
              'You have not entered any authors to check. Please click the '
              '"Authors" button and enter some.'),
        ),
      );
    }
    final List<Widget> children = [];
    if (_subscription != null) {
      children.add(
        Focus(
          autofocus: true,
          child: LinearProgressIndicator(
            value: _audiobooks.length / widget.authors.length,
          ),
        ),
      );
    }
    final errorObject = _errorObject;
    if (errorObject != null) {
      _errorObject = null;
      children.add(
        ListTile(
          title: Text('${errorObject.e}'),
          subtitle: Text('${errorObject.s}'),
          onTap: () {},
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          getAuthorsButton(),
          ElevatedButton(
            onPressed: reload,
            child: const Icon(
              Icons.refresh_outlined,
              semanticLabel: 'Refresh',
            ),
          ),
        ],
        title: const Text('New Releases'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index < children.length) {
            return children[index];
          }
          final audiobook = _audiobooks[index - children.length];
          return ListTile(
            autofocus: index == 0,
            title: Text(audiobook.author),
            subtitle: Text(audiobook.title),
            onTap: () => launch(audiobook.url),
          );
        },
        itemCount: _audiobooks.length + children.length,
      ),
    );
  }

  /// Get the authors button.
  Widget getAuthorsButton() => IconButton(
        onPressed: () async {
          final authors = await Navigator.of(context).push<List<String>>(
            MaterialPageRoute<List<String>>(
              builder: (context) => AuthorsForm(authors: widget.authors),
            ),
          );
          if (authors != null) {
            reload(
                also: () => widget.authors
                  ..clear()
                  ..addAll(authors));
          }
        },
        icon: const Icon(
          Icons.people_rounded,
          semanticLabel: 'Authors',
        ),
      );

  /// Refresh the book list.
  void reload({VoidCallback? also}) {
    _subscription?.cancel();
    _audiobooks.clear();
    startSubscription();
    setState(() {});
  }

  /// Dispose of the subscription.
  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}
