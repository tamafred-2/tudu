import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../notes/application/notes_provider.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../categories/application/categories_provider.dart';

class NoteSearchDelegate extends SearchDelegate<void> {
  NoteSearchDelegate()
      : super(
          searchFieldLabel: 'Search notes...',
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResultGrid(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResultGrid(context);
  }

  Widget _buildSearchResultGrid(BuildContext context) {
    final theme = Theme.of(context);
    final search = query.trim().toLowerCase();
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width < 600 ? 2 : (width < 1024 ? 3 : 4);

    return Consumer2<NotesProvider, CategoriesProvider>(
      builder: (context, notesProvider, categoriesProvider, child) {
        final allNotes = notesProvider.notes;
        final filteredNotes = allNotes.where((note) {
          return note.title.toLowerCase().contains(search) ||
              note.content.toLowerCase().contains(search);
        }).toList();

        // Sort by modified time
        filteredNotes.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));

        if (filteredNotes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No matching notes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try checking your spelling or search for something else.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
            childAspectRatio: 0.85,
          ),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            return NoteCard(
              note: note,
              swipeable: false,
            );
          },
        );
      },
    );
  }
}
