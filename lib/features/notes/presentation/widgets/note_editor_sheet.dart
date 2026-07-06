import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/models/note_model.dart';
import '../../application/notes_provider.dart';
import '../../../categories/application/categories_provider.dart';

class NoteEditorSheet extends StatefulWidget {
  final Note? note;

  const NoteEditorSheet({super.key, this.note});

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  bool _isPinned = false;
  String _selectedCategoryId = 'general';

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isPinned = widget.note!.isPinned;
      _selectedCategoryId = widget.note!.categoryId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty note.')),
      );
      return;
    }

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final now = DateTime.now();

    if (widget.note != null) {
      // Editing existing note
      final updatedNote = widget.note!.copyWith(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        modifiedTime: now,
        isPinned: _isPinned,
        categoryId: _selectedCategoryId,
      );
      notesProvider.updateNote(updatedNote);
    } else {
      // Creating new note
      final newNote = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        modifiedTime: now,
        isPinned: _isPinned,
        categoryId: _selectedCategoryId,
      );
      notesProvider.addNote(newNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesProvider = Provider.of<CategoriesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'New Note'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Pin Action
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? theme.colorScheme.primary : null,
            ),
            tooltip: _isPinned ? 'Unpin note' : 'Pin note',
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
          // Save Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: _saveNote,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              TextField(
                controller: _titleController,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              // Category choice chips horizontal list
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categoriesProvider.categories.map((category) {
                    final bool isSelected = _selectedCategoryId == category.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        avatar: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(category.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              
              const Divider(),
              // Content Input
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
