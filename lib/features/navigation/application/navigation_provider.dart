import 'package:flutter/material.dart';

enum NavigationTab {
  today,
  tasks,
  notes,
  settings,
}

class NavigationProvider with ChangeNotifier {
  NavigationTab _currentTab = NavigationTab.today;

  NavigationTab get currentTab => _currentTab;

  int get currentIndex => _currentTab.index;

  void setTab(NavigationTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }

  void setIndex(int index) {
    if (index >= 0 && index < NavigationTab.values.length) {
      setTab(NavigationTab.values[index]);
    }
  }
}
