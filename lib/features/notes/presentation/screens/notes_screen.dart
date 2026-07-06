import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/features/notes/application/notes_provider.dart';
import 'package:tudu/features/search/presentation/widgets/note_search_delegate.dart';
import '../widgets/note_card.dart';
import '../widgets/note_editor_sheet.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final notesProvider = Provider.of<NotesProvider>(context);
    final allNotes = notesProvider.notes;

    // Filter notes into pinned and others
    final pinnedNotes = allNotes.where((note) => note.isPinned).toList();
    final otherNotes = allNotes.where((note) => !note.isPinned).toList();

    // Sort notes by modified time (newest first)
    pinnedNotes.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
    otherNotes.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));

    // Responsive grid column count
    final int crossAxisCount = width < 600 ? 2 : (width < 1024 ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: allNotes.isEmpty
          ? _buildEmptyState(context)
          : CustomScrollView(
              slivers: [
                // Pinned Section Header
                if (pinnedNotes.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.push_pin, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'PINNED',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = pinnedNotes[index];
                          return NoteCard(note: note);
                        },
                        childCount: pinnedNotes.length,
                      ),
                    ),
                  ),
                ],

                // All Notes Section Header
                if (otherNotes.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                      child: Text(
                        pinnedNotes.isNotEmpty ? 'OTHERS' : 'ALL NOTES',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = otherNotes[index];
                          return NoteCard(note: note);
                        },
                        childCount: otherNotes.length,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorSheet()),
          );
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the edit button below to start taking notes.',
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
}
