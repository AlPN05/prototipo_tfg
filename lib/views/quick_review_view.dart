import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/garment.dart';

/// Vista de revisión rápida con gestos completos:
/// - Doble tap        → poner en uso
/// - Deslizar derecha → a lavar
/// - Deslizar izquierda → armario
/// - Mantener pulsado → modo selección múltiple (eliminar varios)
class QuickReviewView extends StatefulWidget {
  const QuickReviewView({super.key});

  @override
  State<QuickReviewView> createState() => _QuickReviewViewState();
}

class _QuickReviewViewState extends State<QuickReviewView> {
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _deleteSelected(
    BuildContext context,
    InventoryViewModel inventory,
    AppStrings s,
  ) async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteConfirmTitle),
        content: Text(s.deleteConfirmContent(count)),
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
      for (final id in _selectedIds) {
        inventory.deleteGarment(id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s.garmentsDeleted)));
      }
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final garments = inventory.garments;
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text(s.selectedCount(_selectedIds.length)),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              actions: [
                IconButton(
                  icon: Icon(
                    _selectedIds.length == garments.length
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  tooltip: _selectedIds.length == garments.length
                      ? s.deselectAll
                      : s.selectAll,
                  onPressed: () {
                    setState(() {
                      if (_selectedIds.length == garments.length) {
                        _selectedIds.clear();
                        _selectionMode = false;
                      } else {
                        _selectedIds.addAll(garments.map((g) => g.id));
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: s.deleteSelected,
                  onPressed: () => _deleteSelected(context, inventory, s),
                ),
              ],
            )
          : AppBar(
              title: Text(s.quickReview),
              actions: [
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: garments.length,
              itemBuilder: (context, index) {
                final garment = garments[index];
                final pending = garment.pendingState;
                final currentState = garment.state;
                final displayState = pending ?? currentState;
                final isSelected = _selectedIds.contains(garment.id);

                Widget card = Card(
                  elevation: isSelected ? 6 : (pending != null ? 4 : 0),
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15)
                      : pending != null
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05)
                      : Theme.of(context).cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : pending != null
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: _selectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleSelection(garment.id),
                          )
                        : null,
                    title: Text(
                      garment.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                        if (!_selectionMode)
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
                );

                // En modo selección, tap simple alterna la selección
                if (_selectionMode) {
                  card = GestureDetector(
                    onTap: () => _toggleSelection(garment.id),
                    onLongPress: () => _toggleSelection(garment.id),
                    child: card,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: card,
                  );
                }

                // Modo normal: Dismissible + gestos
                return Dismissible(
                  key: ValueKey(
                    '${garment.id}_${pending?.toString() ?? currentState.toString()}',
                  ),
                  // Deslizar a la derecha → a lavar (azul)
                  background: _buildSwipeBackground(
                    context,
                    Icons.local_laundry_service,
                    s.toWash,
                    Colors.blue,
                    Alignment.centerLeft,
                  ),
                  // Deslizar a la izquierda → armario (verde)
                  secondaryBackground: _buildSwipeBackground(
                    context,
                    Icons.checkroom,
                    s.inCloset,
                    Colors.green,
                    Alignment.centerRight,
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      inventory.setPendingState(
                        garment.id,
                        GarmentState.inCloset,
                      );
                    } else {
                      inventory.setPendingState(
                        garment.id,
                        GarmentState.inWash,
                      );
                    }
                    return false;
                  },
                  child: GestureDetector(
                    // Doble tap → poner en uso
                    onDoubleTap: () {
                      inventory.setPendingState(garment.id, GarmentState.inUse);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${garment.name}: ${s.setInUse}'),
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    },
                    // Mantener pulsado → modo selección
                    onLongPress: () => _enterSelectionMode(garment.id),
                    child: card,
                  ),
                );
              },
            ),
      // FAB de confirmación: solo visible cuando hay cambios pendientes y NO en modo selección
      floatingActionButton: !_selectionMode && inventory.hasPendingChanges
          ? FloatingActionButton.extended(
              onPressed: () {
                inventory.syncPendingChanges();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(s.syncSuccess)));
              },
              icon: const Icon(Icons.sync),
              label: Text(s.confirmChanges),
            )
          : null,
    );
  }

  /// Fondo del gesto de deslizamiento.
  Widget _buildSwipeBackground(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de color que indica el estado actual o pendiente de la prenda.
  Widget _buildStateBadge(
    BuildContext context,
    GarmentState state,
    AppStrings s,
  ) {
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
        color = Colors.blue;
        label = s.inWashState;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
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
                    Text(
                      s.editGarment,
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
                    Text(s.state, style: Theme.of(ctx).textTheme.labelLarge),
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
                          icon: const Icon(
                            Icons.local_laundry_service,
                            size: 16,
                          ),
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
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                          backgroundColor: Theme.of(ctx).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
}
