/// Provides the [getBooks] function.
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

import 'audiobook.dart';

/// The HTTP client to use.
final http = Dio();

/// Download audible books.
Stream<Audiobook> getBooks(List<String> authors) async* {
  AUTHORS:
  for (final author in authors) {
    final uri = Uri(
      scheme: 'https',
      host: 'audible.co.uk',
      path: '/search',
      queryParameters: <String, String>{
        'searchAuthor': author,
        'sort': 'pubdate-desc-rank'
      },
    );
    final url = uri.toString();
    final response = await http.get<String>(url);
    final document = parse(response.data);
    final bookHeadings = document.getElementsByTagName('h3');
    if (bookHeadings.isEmpty) {
      yield Audiobook(author: author, title: '(No books to show)', url: url);
      continue;
    }
    for (final heading in bookHeadings) {
      if (heading.classes.contains('bc-color-link') == true) {
        final bookName = heading.text.trim();
        final bookAnchor = heading.querySelector('a')!;
        final ul = heading.parent?.parent?.innerHtml;
        if (ul != null && ul.contains(RegExp(' +English'))) {
          final bookUrl =
              '${uri.scheme}://${uri.host}${bookAnchor.attributes["href"]}';
          yield Audiobook(author: author, title: bookName, url: bookUrl);
          continue AUTHORS;
        }
      }
    }
    yield Audiobook(author: author, title: 'No English books found', url: url);
  }
}
