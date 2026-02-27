import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/garment.dart';

/// Muestra el bottom sheet para añadir una prenda nueva.
/// Función de nivel superior para poder llamarla desde cualquier pantalla.
void showAddGarmentSheet(BuildContext context, InventoryViewModel inventory) {
  final nameCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  bool isCountBased = false;
  int quantity = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      // Cargamos los strings del idioma activo
      final s = AppStrings.of(context);
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.addNewGarment,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: s.name,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryCtrl,
                  decoration: InputDecoration(
                    labelText: s.category,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: colorCtrl,
                  decoration: InputDecoration(
                    labelText: s.color,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(s.manageByQuantity),
                  value: isCountBased,
                  onChanged: (val) =>
                      setModalState(() => isCountBased = val),
                ),
                if (isCountBased)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.initialQuantity),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: quantity > 1
                                ? () => setModalState(() => quantity--)
                                : null,
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setModalState(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isNotEmpty &&
                          categoryCtrl.text.isNotEmpty) {
                        inventory.addGarment(
                          Garment(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: nameCtrl.text,
                            category: categoryCtrl.text,
                            color: colorCtrl.text.isEmpty
                                ? 'Unknown'
                                : colorCtrl.text,
                            isCountBased: isCountBased,
                            quantity: isCountBased ? quantity : 1,
                            state: GarmentState.inCloset,
                          ),
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(s.saveItem),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );
    },
  );
}

// ─── Vista de inventario ────────────────────────────────────────────────────

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  /// Categoría seleccionada en el filtro horizontal.
  String _filterCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final s = AppStrings.of(context);

    // Categorías únicas para el filtro
    final categories = [
      s.all,
      ...inventory.garments.map((g) => g.category).toSet().toList(),
    ];

    // Aplicar filtro de categoría
    final filteredGarments = _filterCategory == s.all || _filterCategory == 'All'
        ? inventory.garments
        : inventory.garments
            .where((g) => g.category == _filterCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.inventory),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _filterCategory ||
                    (index == 0 &&
                        (_filterCategory == 'All' ||
                            _filterCategory == s.all));
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s.translateCategory(cat)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filterCategory = selected ? cat : s.all;
                      });
                    },
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.2),
                    checkmarkColor:
                        Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: filteredGarments.isEmpty
          ? Center(child: Text(s.noItems))
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredGarments.length,
              itemBuilder: (context, index) {
                final garment = filteredGarments[index];
                return _buildGarmentCard(context, garment, inventory, s);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddGarmentSheet(context, inventory),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Tarjeta de una prenda individual con sus controles de cantidad.
  Widget _buildGarmentCard(
    BuildContext context,
    Garment garment,
    InventoryViewModel inventory,
    AppStrings s,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  child: Icon(
                    Icons.checkroom,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garment.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.translateCategory(garment.category)} • ${s.translateColor(garment.color)}',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildStateIcon(garment.state),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, inventory, garment, s),
                  tooltip: s.delete,
                ),
              ],
            ),
            if (garment.isCountBased) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.quantityManagement,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: garment.quantity > 0
                            ? () =>
                                inventory.adjustQuantity(garment.id, -1)
                            : null,
                      ),
                      Text(
                        '${garment.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            inventory.adjustQuantity(garment.id, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Devuelve el icono y color correspondiente al estado de la prenda.
  Widget _buildStateIcon(GarmentState state) {
    IconData icon;
    Color color;
    switch (state) {
      case GarmentState.inCloset:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case GarmentState.inUse:
        icon = Icons.person;
        color = Colors.orange;
        break;
      case GarmentState.inWash:
        icon = Icons.local_laundry_service;
        color = Colors.blue; // azul para "en lavado"
        break;
    }
    return Icon(icon, color: color, size: 28);
  }

  Future<void> _confirmDelete(BuildContext context, InventoryViewModel inventory,
      Garment garment, AppStrings s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteConfirmTitle),
        content: Text(s.deleteConfirmContent(1)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.confirmDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      inventory.deleteGarment(garment.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.garmentDeleted)),
        );
      }
    }
  }
}
