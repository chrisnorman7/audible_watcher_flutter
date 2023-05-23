import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';

/// A page for showing audio books.
class BooksPage extends ConsumerWidget {
  /// Create an instance.
  const BooksPage({
    super.key,
  });

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(booksProvider);
    return value.when(
      data: (final books) {
        if (books.isEmpty) {
          return const CenterText(
            text: 'No books found yet.',
            autofocus: true,
          );
        }
        return ListView.builder(
          itemBuilder: (final context, final index) {
            final book = books[index];
            return ListTile(
              autofocus: index == 0,
              title: Text(book.author),
              subtitle: Text(book.title),
              onTap: () => launchUrl(Uri.parse(book.url)),
            );
          },
          itemCount: books.length,
        );
      },
      error: ErrorListView.withPositional,
      loading: LoadingWidget.new,
    );
  }
}
