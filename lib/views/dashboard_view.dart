// Vista principal (Dashboard) con estadísticas del armario y acciones rápidas.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/app_config.dart';
import 'inventory_view.dart';
import 'outfit_builder_view.dart';
import 'saved_outfits_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final s = AppStrings.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, s),
              const SizedBox(height: 32),
              _buildStatsGrid(context, inventory, s),
              const SizedBox(height: 32),
              _buildVisualCloset(context, settings.closetModel, s),
              const SizedBox(height: 32),
              _buildQuickActions(context, inventory, s),
            ],
          ),
        ),
      ),
    );
  }

  /// Cabecera con título y subtítulo de la app.
  Widget _buildHeader(BuildContext context, AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.appName,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(s.appSubtitle,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey)),
      ],
    );
  }

  /// Rejilla con estadísticas: total, en uso y en lavado.
  Widget _buildStatsGrid(
      BuildContext context, InventoryViewModel inv, AppStrings s) {
    return Row(
      children: [
        _buildStatCard(context,
            title: s.totalItems,
            value: inv.totalGarments.toString(),
            icon: Icons.checkroom,
            color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Column(
          children: [
            _buildSmallStatCard(context,
                title: s.inUse,
                value: inv.inUseCount.toString(),
                icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildSmallStatCard(context,
                title: s.inWash,
                value: inv.inWashCount.toString(),
                icon: Icons.local_laundry_service),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 32),
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  /// Muestra el tipo de armario configurado.
  Widget _buildVisualCloset(
      BuildContext context, ClosetModelType model, AppStrings s) {
    late String title;
    late IconData icon;
    switch (model) {
      case ClosetModelType.basic:
        title = s.basicWardrobe;
        icon = Icons.inventory_2;
      case ClosetModelType.open:
        title = s.openRack;
        icon = Icons.line_weight;
      case ClosetModelType.compact:
        title = s.compactDresser;
        icon = Icons.kitchen;
      case ClosetModelType.custom:
        title = s.customSetup;
        icon = Icons.tune;
      default:
        title = s.modularCloset;
        icon = Icons.door_sliding;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .secondary
            .withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon,
              size: 64, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(s.currentConfigActive,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  /// Sección de acciones rápidas con chips traducidos.
  Widget _buildQuickActions(
      BuildContext context, InventoryViewModel inventory, AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.quickActions,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionChip(context, s.addItem, Icons.add,
                onPressed: () => showAddGarmentSheet(context, inventory)),
            _buildActionChip(context, s.createOutfit, Icons.style_outlined,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const OutfitBuilderView()))),
            // Chip para ver los outfits guardados
            _buildActionChip(context, s.viewOutfits, Icons.collections_bookmark_outlined,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SavedOutfitsView()))),
            _buildActionChip(context, s.sort, Icons.sort, onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData icon,
      {required VoidCallback onPressed}) {
    return ActionChip(
      elevation: 0,
      pressElevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      avatar: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
