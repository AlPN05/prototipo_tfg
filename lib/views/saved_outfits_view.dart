// Vista que muestra la lista de outfits guardados por el usuario.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../viewmodels/outfit_viewmodel.dart';
import '../models/outfit.dart';

class SavedOutfitsView extends StatelessWidget {
  const SavedOutfitsView({super.key});

  /// Devuelve la etiqueta traducida del slot y su icono.
  Map<String, dynamic> _slotInfo(String slotKey, AppStrings s) {
    switch (slotKey) {
      case 'top':
        return {'label': s.slotTop, 'icon': Icons.dry_cleaning};
      case 'bottom':
        return {'label': s.slotBottom, 'icon': Icons.airline_seat_legroom_normal};
      case 'footwear':
        return {'label': s.slotFootwear, 'icon': Icons.airline_seat_flat};
      case 'outer':
        return {'label': s.slotOuterwear, 'icon': Icons.umbrella};
      case 'acc':
        return {'label': s.slotAccessory, 'icon': Icons.watch};
      case 'underwear':
        return {'label': s.slotUnderwear, 'icon': Icons.dry_cleaning_outlined};
      default:
        return {'label': slotKey, 'icon': Icons.checkroom};
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfitVM = context.watch<OutfitViewModel>();
    final s = AppStrings.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.savedOutfits)),
      body: outfitVM.outfits.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.style_outlined,
                      size: 72,
                      color: colorScheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    s.noSavedOutfits,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: outfitVM.outfits.length,
              itemBuilder: (context, index) {
                final outfit = outfitVM.outfits[index];
                return _buildOutfitCard(context, outfit, outfitVM, s);
              },
            ),
    );
  }

  Widget _buildOutfitCard(
    BuildContext context,
    Outfit outfit,
    OutfitViewModel vm,
    AppStrings s,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Expandimos slots → lista de filas (una por prenda)
    final rows = outfit.slots.entries.expand((entry) {
      final info = _slotInfo(entry.key, s);
      return entry.value.map((g) => (
        slotLabel: info['label'] as String,
        slotIcon: info['icon'] as IconData,
        garment: g,
      ));
    }).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.style, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    outfit.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.redAccent,
                  tooltip: s.delete,
                  onPressed: () {
                    vm.deleteOutfit(outfit.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(s.outfitDeletedMsg),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // ── Prendas agrupadas por parte del cuerpo ──────────────────────
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(row.slotIcon,
                            size: 16, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${row.slotLabel}: ',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(
                          row.garment.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.translateCategory(row.garment.category),
                          style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
