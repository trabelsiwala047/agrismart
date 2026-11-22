import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReglagesProvider extends ChangeNotifier {
  static const _cleTheme = 'theme_mode';

  final SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ReglagesProvider(this._prefs) {
    _themeMode = _lireTheme(_prefs);
  }

  ThemeMode get themeMode => _themeMode;

  static ThemeMode _lireTheme(SharedPreferences prefs) {
    final nom = prefs.getString(_cleTheme);
    return ThemeMode.values.firstWhere(
      (m) => m.name == nom,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> changerTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_cleTheme, mode.name);
  }
}
