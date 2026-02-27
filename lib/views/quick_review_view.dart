import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/garment.dart';

/// Vista de revisión rápida: permite revisar y cambiar el estado
/// de las prendas mediante gestos de deslizamiento.
class QuickReviewView extends StatelessWidget {
  const QuickReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final garments = inventory.garments;
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.quickReview),
        actions: [
          // Botón para descartar todos los cambios pendientes
          if (inventory.hasPendingChanges)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => inventory.clearPendingStates(),
              tooltip: s.clearPending,
            ),
        ],
      ),
      body: garments.isEmpty
          ? Center(child: Text(s.noItemsToReview))
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: garments.length,
              itemBuilder: (context, index) {
                final garment = garments[index];
                final pending = garment.pendingState;
                final currentState = garment.state;
                final displayState = pending ?? currentState;

                return Dismissible(
                  // Clave única que incluye el estado pendiente para forzar rebuild
                  key: ValueKey(
                    '${garment.id}_${pending?.toString() ?? currentState.toString()}',
                  ),
                  // Deslizar a la derecha → marcar para lavar (azul)
                  background: _buildSwipeBackground(
                    context,
                    Icons.local_laundry_service,
                    s.toWash,
                    Colors.blue,
                    Alignment.centerLeft,
                  ),
                  // Deslizar a la izquierda → marcar en armario (verde)
                  secondaryBackground: _buildSwipeBackground(
                    context,
                    Icons.checkroom,
                    s.inCloset,
                    Colors.green,
                    Alignment.centerRight,
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Derecha → izquierda: volver al armario
                      inventory.setPendingState(
                          garment.id, GarmentState.inCloset);
                    } else {
                      // Izquierda → derecha: enviar a lavar
                      inventory.setPendingState(
                          garment.id, GarmentState.inWash);
                    }
                    return false; // No eliminar el widget de la lista
                  },
                  child: Card(
                    elevation: pending != null ? 4 : 0,
                    color: pending != null
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.05)
                        : Theme.of(context).cardTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: pending != null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      title: Text(garment.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        garment.isCountBased
                            ? '${s.translateCategory(garment.category)} (${garment.quantity} ${s.units})'
                            : s.translateCategory(garment.category),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStateBadge(context, displayState, s),
                          const SizedBox(width: 4),
                          // Botón de editar prenda
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            tooltip: s.edit,
                            onPressed: () =>
                                _showEditSheet(context, inventory, garment, s),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      // FAB de confirmación: solo visible cuando hay cambios pendientes
      floatingActionButton: inventory.hasPendingChanges
          ? FloatingActionButton.extended(
              onPressed: () {
                inventory.syncPendingChanges();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.syncSuccess)),
                );
              },
              icon: const Icon(Icons.sync),
              label: Text(s.confirmChanges),
            )
          : null,
    );
  }

  /// Bottom sheet para editar los datos de una prenda existente.
  void _showEditSheet(
    BuildContext context,
    InventoryViewModel inventory,
    Garment garment,
    AppStrings s,
  ) {
    final nameCtrl = TextEditingController(text: garment.name);
    final categoryCtrl = TextEditingController(text: garment.category);
    final colorCtrl = TextEditingController(text: garment.color);
    bool isCountBased = garment.isCountBased;
    int quantity = garment.quantity;
    GarmentState selectedState = garment.state;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.editGarment,
                        style: Theme.of(ctx)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                          labelText: s.name,
                          border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryCtrl,
                      decoration: InputDecoration(
                          labelText: s.category,
                          border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: colorCtrl,
                      decoration: InputDecoration(
                          labelText: s.color,
                          border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    // Selector de estado con botones segmentados
                    Text(s.state,
                        style: Theme.of(ctx).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<GarmentState>(
                      segments: [
                        ButtonSegment(
                          value: GarmentState.inCloset,
                          label: Text(s.closet),
                          icon: const Icon(Icons.checkroom, size: 16),
                        ),
                        ButtonSegment(
                          value: GarmentState.inUse,
                          label: Text(s.inUseState),
                          icon: const Icon(Icons.person, size: 16),
                        ),
                        ButtonSegment(
                          value: GarmentState.inWash,
                          label: Text(s.washing),
                          icon: const Icon(Icons.local_laundry_service,
                              size: 16),
                        ),
                      ],
                      selected: {selectedState},
                      onSelectionChanged: (sel) =>
                          setModalState(() => selectedState = sel.first),
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
                          Text(s.quantity),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: quantity > 1
                                    ? () => setModalState(() => quantity--)
                                    : null,
                              ),
                              Text('$quantity',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    setModalState(() => quantity++),
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
                            inventory.updateGarment(
                              garment.copyWith(
                                name: nameCtrl.text,
                                category: categoryCtrl.text,
                                color: colorCtrl.text.isEmpty
                                    ? garment.color
                                    : colorCtrl.text,
                                isCountBased: isCountBased,
                                quantity: quantity,
                                state: selectedState,
                              ),
                            );
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(ctx).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(s.saveChanges),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Fondo del gesto de deslizamiento (lavar o archivar).
  Widget _buildSwipeBackground(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Badge de color que indica el estado actual o pendiente de la prenda.
  Widget _buildStateBadge(
      BuildContext context, GarmentState state, AppStrings s) {
    Color color;
    String label;

    switch (state) {
      case GarmentState.inCloset:
        color = Colors.green;
        label = s.inCloset;
        break;
      case GarmentState.inUse:
        color = Colors.orange;
        label = s.inUseState;
        break;
      case GarmentState.inWash:
        color = Colors.blue; // azul en vez de rojo
        label = s.inWashState;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
