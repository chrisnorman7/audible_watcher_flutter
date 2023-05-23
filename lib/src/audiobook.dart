/// A book to show.
class Audiobook {
  /// Create an instance.
  const Audiobook({
    required this.author,
    required this.title,
    required this.url,
  });

  /// The author of the book.
  final String author;

  /// The title of the book.
  final String title;

  /// The URL where there book can be found.
  final String url;
}
