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
    final now = DateTime.now();
    _notes.addAll([
      Note(
        id: '1',
        title: 'Project Ideas 💡',
        content: 'Build a productivity tool called Tudu using Flutter and Hive. Make it look beautiful and minimal, matching a cozy theme.',
        modifiedTime: now,
        isPinned: true,
        categoryId: 'work',
      ),
      Note(
        id: '2',
        title: 'Shopping List 🛒',
        content: '- Milk\n- Apples\n- Almonds\n- Oatmeal\n- Honey\n- Dark chocolate 85%',
        modifiedTime: now.subtract(const Duration(days: 1)),
        isPinned: false,
        categoryId: 'shopping',
      ),
      Note(
        id: '3',
        title: 'Meeting Notes 📝',
        content: 'Discussed architecture design patterns. Agreed to use Feature-First Layered structure. State management: Provider.',
        modifiedTime: now.subtract(const Duration(days: 2)),
        isPinned: false,
        categoryId: 'work',
      ),
      Note(
        id: '4',
        title: 'Flutter Resources 📚',
        content: 'Check docs.flutter.dev for layout instructions. Learn more about responsive widgets like LayoutBuilder and MediaQuery.',
        modifiedTime: now.subtract(const Duration(days: 8)),
        isPinned: false,
        categoryId: 'setup',
      ),
    ]);
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
