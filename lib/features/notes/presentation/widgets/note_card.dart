import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/models/note_model.dart';
import '../../application/notes_provider.dart';
import '../../../categories/application/categories_provider.dart';
import 'note_editor_sheet.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool swipeable;

  const NoteCard({
    super.key,
    required this.note,
    this.swipeable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate =
        '${note.modifiedTime.year}-${note.modifiedTime.month.toString().padLeft(2, '0')}-${note.modifiedTime.day.toString().padLeft(2, '0')}';

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
    final category = categoriesProvider.getCategoryById(note.categoryId);

    Widget buildCardContent(BuildContext context) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteEditorSheet(note: note)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header: Title & Pin Action
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 16,
                        color: note.isPinned
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        notesProvider.toggleNotePin(note.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Card Body
                Expanded(
                  child: Text(
                    note.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: 8),
                // Card Footer (Date and Category Tag)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(category.colorValue).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: Color(category.colorValue),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget transitionChild = TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: buildCardContent(context),
    );

    if (!swipeable) {
      return transitionChild;
    }

    return Dismissible(
      key: Key(note.id),
      background: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (direction) {
        final noteIndex = notesProvider.getNoteIndex(note.id);
        final deletedNote = notesProvider.deleteNote(note.id);

        if (deletedNote != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note "${note.title}" deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  notesProvider.insertNote(noteIndex, deletedNote);
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: transitionChild,
    );
  }
}
