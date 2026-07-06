import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../business/models/category_model.dart';

class CategoriesProvider with ChangeNotifier {
  final List<Category> _categories = [];

  CategoriesProvider() {
    _loadCategories();
  }

  List<Category> get categories => List.unmodifiable(_categories);

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? categoriesJson = prefs.getString('custom_categories');
      if (categoriesJson != null) {
        final List<dynamic> decodedList = jsonDecode(categoriesJson) as List<dynamic>;
        _categories.clear();
        _categories.addAll(decodedList.map((item) => Category.fromJson(item as Map<String, dynamic>)));
      } else {
        _loadDefaultCategories();
        _saveCategories();
      }
    } catch (e) {
      debugPrint('Failed to load categories: $e');
      _loadDefaultCategories();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String categoriesJson = jsonEncode(_categories.map((c) => c.toJson()).toList());
      await prefs.setString('custom_categories', categoriesJson);
    } catch (e) {
      debugPrint('Failed to save categories: $e');
    }
  }

  void _loadDefaultCategories() {
    _categories.addAll([
      const Category(id: 'work', name: 'Work', colorValue: 0xFF0F5A47),         // Teal
      const Category(id: 'personal', name: 'Personal', colorValue: 0xFFB39DDB), // Lavender
      const Category(id: 'shopping', name: 'Shopping', colorValue: 0xFFE6AD45), // Warm Amber
      const Category(id: 'health', name: 'Health', colorValue: 0xFFD3A4A4),     // Dusty Rose
      const Category(id: 'setup', name: 'Setup', colorValue: 0xFF4A90E2),       // Soft Blue
      const Category(id: 'design', name: 'Design', colorValue: 0xFF8FBC8F),     // Sage Green
      const Category(id: 'research', name: 'Research', colorValue: 0xFF78909C), // Blue Grey
      const Category(id: 'general', name: 'General', colorValue: 0xFF707974),   // Cool Grey
    ]);
  }

  // Add a category
  void addCategory(Category category) {
    // Avoid duplicates
    if (!_categories.any((c) => c.name.toLowerCase() == category.name.toLowerCase())) {
      _categories.add(category);
      notifyListeners();
      _saveCategories();
    }
  }

  // Delete a category
  void deleteCategory(String id) {
    // Don't allow deleting 'general'
    if (id == 'general') return;
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    _saveCategories();
  }

  // Find category by ID (falls back to General if not found or list is empty)
  Category getCategoryById(String? id) {
    if (_categories.isEmpty) {
      return const Category(id: 'general', name: 'General', colorValue: 0xFF707974);
    }
    if (id == null) {
      return _categories.firstWhere(
        (c) => c.id == 'general',
        orElse: () => _categories.first,
      );
    }
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => _categories.firstWhere(
        (c) => c.id == 'general',
        orElse: () => _categories.first,
      ),
    );
  }

  // Find category by Name (useful for migrating old tasks, falls back safely)
  Category getCategoryByName(String name) {
    if (_categories.isEmpty) {
      return const Category(id: 'general', name: 'General', colorValue: 0xFF707974);
    }
    final searchName = name.trim().toLowerCase();
    return _categories.firstWhere(
      (c) => c.name.toLowerCase() == searchName,
      orElse: () {
        return _categories.firstWhere(
          (c) => c.id == 'general',
          orElse: () => _categories.first,
        );
      },
    );
  }
}
