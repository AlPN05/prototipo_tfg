import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/app_config.dart';

/// Pantalla de ajustes: idioma, tema, tipo de armario y versión de la app.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const String _appVersion = '1.0.4';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // ── Sección: Preferencias ────────────────────────────────────────
          _buildSectionHeader(context, s.preferences),
          Card(
            child: Column(
              children: [
                // Selector de idioma
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(s.language2),
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setLanguage(val);
                    },
                  ),
                ),
                const Divider(height: 1),
                // Selector de tema (claro / oscuro / sistema)
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text(s.theme),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(s.themeSystem),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(s.themeLight),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(s.themeDark),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setThemeMode(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Sección: Configuración del armario ────────────────────────────
          _buildSectionHeader(context, s.closetConfiguration),
          Card(
            child: Column(
              children: ClosetModelType.values.map((model) {
                return RadioListTile<ClosetModelType>(
                  value: model,
                  groupValue: settings.closetModel,
                  title: Text(_getClosetModelName(model, s)),
                  onChanged: (val) {
                    if (val != null) settings.setClosetModel(val);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Sección: Información de la aplicación ─────────────────────────
          _buildSectionHeader(context, s.version),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('Smart Closet'),
              subtitle: const Text(
                'Smart Closet App – TFG Prototype',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'v$_appVersion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Cabecera de sección con estilo minimalista en mayúsculas.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Devuelve el nombre del tipo de armario según el idioma activo.
  String _getClosetModelName(ClosetModelType model, AppStrings s) {
    switch (model) {
      case ClosetModelType.basic:
        return s.basicWardrobe;
      case ClosetModelType.modular:
        return s.modularCloset;
      case ClosetModelType.open:
        return s.openRack;
      case ClosetModelType.compact:
        return s.compactDresser;
      case ClosetModelType.custom:
        return s.customSetup;
    }
  }
}
