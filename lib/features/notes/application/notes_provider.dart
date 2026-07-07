import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../business/models/note_model.dart';

class NotesProvider with ChangeNotifier {
  final List<Note> _notes = [];

  NotesProvider() {
    _loadNotes();
  }

  List<Note> get notes => List.unmodifiable(_notes);

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesJson = prefs.getString('custom_notes');
      if (notesJson != null) {
        final List<dynamic> decodedList = jsonDecode(notesJson) as List<dynamic>;
        _notes.clear();
        _notes.addAll(decodedList.map((item) => Note.fromJson(item as Map<String, dynamic>)));
      } else {
        _loadInitialNotes();
        _saveNotes();
      }
    } catch (e) {
      debugPrint('Failed to load notes: $e');
      _loadInitialNotes();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notesJson = jsonEncode(_notes.map((n) => n.toJson()).toList());
      await prefs.setString('custom_notes', notesJson);
    } catch (e) {
      debugPrint('Failed to save notes: $e');
    }
  }

  void _loadInitialNotes() {
    _notes.add(
      Note(
        id: '1',
        title: 'Welcome to Tudu 🌿',
        content: 'Here\'s how to get started:\n\n'
            '• Tap the + button to add a new task or note\n'
            '• Tap a task\'s circle to mark it complete\n'
            '• Swipe a task or note sideways to delete it (with Undo)\n'
            '• Pin important notes to keep them on top\n'
            '• Organize everything with categories\n'
            '• Set a daily reminder in Settings so you never miss a task\n\n'
            'Delete this note whenever you\'re ready. Enjoy! ✨',
        modifiedTime: DateTime.now(),
        isPinned: true,
        categoryId: 'general',
      ),
    );
  }

  // Add a note
  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
    _saveNotes();
  }

  // Insert a note (for Undo)
  void insertNote(int index, Note note) {
    if (index >= 0 && index <= _notes.length) {
      _notes.insert(index, note);
      notifyListeners();
      _saveNotes();
    }
  }

  // Update a note
  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
      _saveNotes();
    }
  }

  // Delete a note
  Note? deleteNote(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final note = _notes.removeAt(index);
      notifyListeners();
      _saveNotes();
      return note;
    }
    return null;
  }

  // Get index of a note by id
  int getNoteIndex(String id) {
    return _notes.indexWhere((n) => n.id == id);
  }

  // Toggle pinning status
  void toggleNotePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
        modifiedTime: DateTime.now(),
      );
      notifyListeners();
      _saveNotes();
    }
  }
}
