import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/inventory_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const SmartClosetApp(),
    ),
  );
}

class SmartClosetApp extends StatelessWidget {
  const SmartClosetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Smart Closet',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}
