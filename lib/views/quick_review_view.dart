import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/garment.dart';

class QuickReviewView extends StatelessWidget {
  const QuickReviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final garments = inventory.garments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Review'),
        actions: [
          if (inventory.hasPendingChanges)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => inventory.clearPendingStates(),
              tooltip: 'Clear pending changes',
            ),
        ],
      ),
      body: garments.isEmpty
          ? const Center(child: Text('No items to review'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: garments.length,
              itemBuilder: (context, index) {
                final garment = garments[index];
                final pending = garment.pendingState;
                final currentState = garment.state;
                final displayState = pending ?? currentState;

                return Dismissible(
                  key: ValueKey(
                    '${garment.id}_${pending?.toString() ?? currentState.toString()}',
                  ),
                  background: _buildSwipeBackground(
                    context,
                    Icons.local_laundry_service,
                    'To Wash',
                    Colors.blue,
                    Alignment.centerLeft,
                  ),
                  secondaryBackground: _buildSwipeBackground(
                    context,
                    Icons.checkroom,
                    'In Closet',
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
                  child: Card(
                    elevation: pending != null ? 4 : 0,
                    color: pending != null
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.05)
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
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        garment.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        garment.isCountBased
                            ? '${garment.category} (${garment.quantity} units)'
                            : garment.category,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStateBadge(context, displayState),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            tooltip: 'Edit',
                            onPressed: () =>
                                _showEditSheet(context, inventory, garment),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: inventory.hasPendingChanges
          ? FloatingActionButton.extended(
              onPressed: () {
                inventory.syncPendingChanges();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changes synchronized successfully'),
                  ),
                );
              },
              icon: const Icon(Icons.sync),
              label: const Text('Confirm Changes'),
            )
          : null,
    );
  }

  void _showEditSheet(
    BuildContext context,
    InventoryViewModel inventory,
    Garment garment,
  ) {
    final nameController = TextEditingController(text: garment.name);
    final categoryController = TextEditingController(text: garment.category);
    final colorController = TextEditingController(text: garment.color);
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
                      'Edit Garment',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // State selector
                    Text(
                      'State',
                      style: Theme.of(ctx).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<GarmentState>(
                      segments: const [
                        ButtonSegment(
                          value: GarmentState.inCloset,
                          label: Text('Closet'),
                          icon: Icon(Icons.checkroom, size: 16),
                        ),
                        ButtonSegment(
                          value: GarmentState.inUse,
                          label: Text('In Use'),
                          icon: Icon(Icons.person, size: 16),
                        ),
                        ButtonSegment(
                          value: GarmentState.inWash,
                          label: Text('Washing'),
                          icon: Icon(Icons.local_laundry_service, size: 16),
                        ),
                      ],
                      selected: {selectedState},
                      onSelectionChanged: (s) =>
                          setModalState(() => selectedState = s.first),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Manage by quantity'),
                      value: isCountBased,
                      onChanged: (val) =>
                          setModalState(() => isCountBased = val),
                    ),
                    if (isCountBased)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quantity:'),
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
                          if (nameController.text.isNotEmpty &&
                              categoryController.text.isNotEmpty) {
                            inventory.updateGarment(
                              garment.copyWith(
                                name: nameController.text,
                                category: categoryController.text,
                                color: colorController.text.isEmpty
                                    ? garment.color
                                    : colorController.text,
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Changes'),
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

  Widget _buildStateBadge(BuildContext context, GarmentState state) {
    Color color;
    String label;

    switch (state) {
      case GarmentState.inCloset:
        color = Colors.green;
        label = 'In Closet';
        break;
      case GarmentState.inUse:
        color = Colors.orange;
        label = 'In Use';
        break;
      case GarmentState.inWash:
        color = Colors.blue; // ← azul en vez de rojo
        label = 'In Wash';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
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
}
