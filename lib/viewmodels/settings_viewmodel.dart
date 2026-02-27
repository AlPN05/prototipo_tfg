import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';

class SettingsViewModel extends ChangeNotifier {
  final AppConfig _config = AppConfig();

  SettingsViewModel() {
    _loadPreferences();
  }

  String get language => _config.language;
  ThemeMode get themeMode => _config.themeMode;
  ClosetModelType get closetModel => _config.closetModel;

  // Keys for SharedPreferences
  static const _keyTheme = 'themeMode';
  static const _keyLanguage = 'language';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyTheme);
    if (themeIndex != null) {
      _config.themeMode = ThemeMode.values[themeIndex];
    }
    final lang = prefs.getString(_keyLanguage);
    if (lang != null) {
      _config.language = lang;
    }
    notifyListeners();
  }

  void setLanguage(String lang) {
    if (_config.language != lang) {
      _config.language = lang;
      SharedPreferences.getInstance()
          .then((p) => p.setString(_keyLanguage, lang));
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_config.themeMode != mode) {
      _config.themeMode = mode;
      SharedPreferences.getInstance()
          .then((p) => p.setInt(_keyTheme, mode.index));
      notifyListeners();
    }
  }

  void setClosetModel(ClosetModelType modelType) {
    if (_config.closetModel != modelType) {
      _config.closetModel = modelType;
      notifyListeners();
    }
  }
}
