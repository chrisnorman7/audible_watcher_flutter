import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/util.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';
import '../widgets/books_page.dart';

/// The main application screen.
class MainScreen extends ConsumerStatefulWidget {
  /// Create an instance.
  const MainScreen({
    super.key,
  });

  /// Create state for this widget.
  @override
  MainScreenState createState() => MainScreenState();
}

/// State for [MainScreen].
class MainScreenState extends ConsumerState<MainScreen> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) => TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Books',
            icon: const Text('The books that have been found'),
            builder: (final context) => const BooksPage(),
          ),
          TabbedScaffoldTab(
            title: 'Authors',
            icon: const Text('The authors whose books will be shown'),
            builder: (final context) => CommonShortcuts(
              newCallback: newAuthor,
              child: getAuthorsPage(),
            ),
          )
        ],
      );

  /// Add a new author.
  Future<void> newAuthor() => pushWidget(
        context: context,
        builder: (final context) => GetText(
          onDone: (final value) async {
            Navigator.pop(context);
            final authors = await ref.watch(authorsProvider.future);
            authors.add(value);
            final preferences = await ref.watch(
              sharedPreferencesProvider.future,
            );
            await preferences.setStringList(authorsKey, authors);
            ref
              ..invalidate(authorsProvider)
              ..invalidate(booksProvider);
          },
          labelText: 'Author Name',
          title: 'Add Author',
          validator: (final value) => value == null || value.isEmpty
              ? 'You must provide a value'
              : null,
        ),
      );

  /// Get the authors page.
  Widget getAuthorsPage() {
    final value = ref.watch(authorsProvider);
    return value.when(
      data: (final data) {
        if (data.isEmpty) {
          return const CenterText(
            text: 'You have not added any authors to track.',
            autofocus: true,
          );
        }
        return BuiltSearchableListView(
          items: data,
          builder: (final context, final index) {
            final author = data[index];
            return SearchableListTile(
              searchString: author,
              child: CommonShortcuts(
                copyText: author,
                deleteCallback: () async {
                  final authors = await ref.watch(authorsProvider.future);
                  authors.removeWhere((final element) => element == author);
                  final preferences =
                      await ref.watch(sharedPreferencesProvider.future);
                  await preferences.setStringList(authorsKey, authors);
                  ref.invalidate(authorsProvider);
                },
                child: ListTile(
                  autofocus: index == 0,
                  title: Text(author),
                  onTap: () => launchUrl(
                    ref.watch(
                      authorUriProvider.call(author),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      error: ErrorListView.withPositional,
      loading: LoadingWidget.new,
    );
  }
}
