import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import 'dashboard_view.dart';
import 'quick_review_view.dart';
import 'inventory_view.dart';
import 'settings_view.dart';

/// Pantalla raíz de la aplicación con navegación inferior entre las 4 secciones.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Índice de la pestaña activa.
  int _currentIndex = 0;

  /// Lista de páginas disponibles (orden = índice en la barra inferior).
  final List<Widget> _pages = const [
    DashboardView(),
    QuickReviewView(),
    InventoryView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    // Cargamos los strings del idioma activo para las etiquetas de navegación
    final s = AppStrings.of(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: s.navDashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_circle_outline),
              label: s.navQuickReview,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              label: s.navInventory,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              label: s.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
