import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'audiobook.dart';
import 'authors_form.dart';
import 'error_list.dart';
import 'get_books.dart';

/// A widget that loaded a series of [Audiobook] instances.
class BooksLoader extends StatefulWidget {
  /// Create an instance.
  const BooksLoader({required this.authors, Key? key}) : super(key: key);

  /// The authors whose books should be loaded.
  final List<String> authors;

  /// Create state for this widget.
  @override
  _BooksLoaderState createState() => _BooksLoaderState();
}

/// State for [BooksLoader].
class _BooksLoaderState extends State<BooksLoader> {
  /// The stream to use for loading books.
  Stream<Audiobook>? _stream;

  /// The audiobooks that have loaded so far.
  late final List<Audiobook> _audiobooks;

  /// Initialise the audiobooks list.
  @override
  void initState() {
    super.initState();
    _audiobooks = [];
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
                  : () => setState(() {
                        _audiobooks.clear();
                        _stream = null;
                      }),
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
    var stream = _stream;
    if (stream == null) {
      stream = getBooks(widget.authors);
      _stream = stream;
    }
    return StreamBuilder<Audiobook>(
      builder: (context, snapshot) {
        final Widget child;
        if (snapshot.hasError) {
          child =
              ErrorList(error: snapshot.error, stackTrace: snapshot.stackTrace);
        } else {
          if (snapshot.hasData &&
              snapshot.connectionState != ConnectionState.waiting) {
            _audiobooks.add(snapshot.requireData);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              throw UnimplementedError('That should not have happened.');
            case ConnectionState.waiting:
              child = const CircularProgressIndicator(
                semanticsLabel: 'Loading webpage...',
              );
              break;
            default:
              if (_audiobooks.isEmpty) {
                child = const Center(
                  child: Text('There are no audiobooks to show.'),
                );
              } else {
                final listView = ListView.builder(
                  itemBuilder: (context, index) {
                    final audiobook = _audiobooks[index];
                    return ListTile(
                      autofocus: index == 0,
                      title: Text(audiobook.author),
                      subtitle: Text(audiobook.title),
                      onTap: () => launch(audiobook.url),
                    );
                  },
                  itemCount: _audiobooks.length,
                );
                if (snapshot.connectionState == ConnectionState.done) {
                  child = listView;
                } else {
                  child = Column(
                    children: [
                      Focus(
                        autofocus: _audiobooks.isEmpty,
                        child: LinearProgressIndicator(
                          semanticsLabel: 'Checked authors',
                          value: _audiobooks.length * 1 / widget.authors.length,
                        ),
                      ),
                      Expanded(child: listView)
                    ],
                  );
                }
              }
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Audible Releases'),
            actions: [
              getAuthorsButton(),
              FloatingActionButton(
                  onPressed: reload,
                  child: const Icon(Icons.refresh_outlined),
                  tooltip: 'Reload'),
            ],
          ),
          body: child,
        );
      },
      stream: stream,
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
  void reload({VoidCallback? also}) => setState(() {
        _audiobooks.clear();
        _stream = null;
        if (also != null) {
          also();
        }
      });
}
