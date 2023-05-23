import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'audiobook.dart';

/// The authors key.
const authorsKey = 'audible_watcher_flutter_authors';

/// Provide the shared preferences instance.
final sharedPreferencesProvider =
    FutureProvider((final ref) => SharedPreferences.getInstance());

/// Get the list of authors.
final authorsProvider = FutureProvider<List<String>>((final ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return preferences.getStringList(
        authorsKey,
      ) ??
      [];
});

/// Provides an HTTP client.
final dioProvider = Provider<Dio>((final ref) => Dio());

/// Provide a URI for a single author.
final authorUriProvider = Provider.family<Uri, String>(
  (final ref, final author) => Uri(
    scheme: uriScheme,
    host: uriHost,
    path: '/search',
    queryParameters: <String, String>{
      'searchAuthor': author,
      'sort': 'pubdate-desc-rank'
    },
  ),
);

/// Provide the latest book for a single author.
final bookProvider = FutureProvider.family<Audiobook?, String>(
  (final ref, final author) async {
    final dio = ref.watch(dioProvider);
    final uri = ref.watch(authorUriProvider.call(author));
    final url = uri.toString();
    final response = await dio.get<String>(url);
    final document = parse(response.data);
    final bookHeadings = document.getElementsByTagName('h3');
    if (bookHeadings.isEmpty) {
      return null;
    }
    for (final heading in bookHeadings) {
      if (heading.classes.contains('bc-color-link') == true) {
        final bookName = heading.text.trim();
        final bookAnchor = heading.querySelector('a');
        final ul = heading.parent?.parent?.innerHtml;
        if (ul != null && ul.contains(RegExp(' +English'))) {
          final bookUrl =
              '$uriScheme://$uriHost${bookAnchor!.attributes["href"]}';
          return Audiobook(
            author: author,
            title: bookName,
            url: bookUrl,
          );
        }
      }
    }
    return null;
  },
);

/// Provide all the books to show.
final booksProvider = StreamProvider<List<Audiobook>>(
  (final ref) async* {
    final books = <Audiobook>[];
    final authors = await ref.watch(authorsProvider.future);
    if (authors.isEmpty) {
      yield books;
    }
    for (final author in authors) {
      final book = await ref.watch(bookProvider.call(author).future);
      if (book == null) {
        final authorUrl = ref.watch(authorUriProvider.call(author)).toString();
        books.add(
          Audiobook(author: author, title: 'No Books Found', url: authorUrl),
        );
      } else {
        books.add(book);
      }
      yield books;
    }
  },
);
