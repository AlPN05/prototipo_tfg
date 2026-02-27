import 'package:flutter/material.dart';
import '../models/app_config.dart';

class SettingsViewModel extends ChangeNotifier {
  final AppConfig _config = AppConfig();

  String get language => _config.language;
  ThemeMode get themeMode => _config.themeMode;
  ClosetModelType get closetModel => _config.closetModel;

  void setLanguage(String lang) {
    if (_config.language != lang) {
      _config.language = lang;
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_config.themeMode != mode) {
      _config.themeMode = mode;
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
