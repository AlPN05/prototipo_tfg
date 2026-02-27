import 'package:flutter/material.dart';

enum ClosetModelType { basic, modular, open, compact, custom }

class AppConfig {
  String language;
  ThemeMode themeMode;
  ClosetModelType closetModel;

  AppConfig({
    this.language = 'es',
    this.themeMode = ThemeMode.system,
    this.closetModel = ClosetModelType.modular,
  });
}
