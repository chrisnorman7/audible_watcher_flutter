import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';

/// A page to show all authors.
class AuthorsPage extends ConsumerWidget {
  /// Create an instance.
  const AuthorsPage({
    super.key,
  });

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(authorsProvider);
    return value.when(
      data: (final authors) {
        if (authors.isEmpty) {
          return const CenterText(
            text: 'You have not added any authors yet.',
            autofocus: true,
          );
        }
        return ReorderableListView.builder(
          itemBuilder: (final context, final index) {
            final author = authors[index];
            final uri = ref.watch(authorUriProvider.call(author));
            return CommonShortcuts(
              moveDownCallback: () => reorderAuthor(ref, index, index + 1),
              moveUpCallback: () => reorderAuthor(ref, index, index - 1),
              key: ValueKey(author),
              child: ListTile(
                autofocus: index == 0,
                title: Text(author),
                onTap: () => launchUrl(uri),
              ),
            );
          },
          itemCount: authors.length,
          onReorder: (final oldIndex, final newIndex) => reorderAuthor(
            ref,
            oldIndex,
            newIndex,
          ),
        );
      },
      error: ErrorListView.withPositional,
      loading: LoadingWidget.new,
    );
  }

  /// Move an author from the [oldIndex] to [newIndex].
  Future<void> reorderAuthor(
    final WidgetRef ref,
    final int oldIndex,
    final int newIndex,
  ) async {
    final authors = await ref.watch(authorsProvider.future);
    if (newIndex < 0 || newIndex >= authors.length) {
      return;
    }
    final author = authors.removeAt(oldIndex);
    if (newIndex == authors.length) {
      authors.add(author);
    } else {
      authors.insert(newIndex, author);
    }
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    await preferences.setStringList(authorsKey, authors);
    ref.invalidate(authorsProvider);
  }
}
