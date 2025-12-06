import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'themeBox';
  static const String _themeModeKey = 'isDarkMode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      _isDarkMode = box.get(_themeModeKey, defaultValue: false) as bool;
      notifyListeners();
    } catch (e) {
      _isDarkMode = false;
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      final box = await Hive.openBox(_themeBoxName);
      await box.put(_themeModeKey, _isDarkMode);
    } catch (e) {
      // Handle error silently
    }
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
