import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/garment.dart';

/// Shows the Add Garment bottom sheet. Can be called from any screen.
void showAddGarmentSheet(BuildContext context, InventoryViewModel inventory) {
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final colorController = TextEditingController();
  bool isCountBased = false;
  int quantity = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Garment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    labelText: 'Category (e.g., T-Shirts)',
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
                SwitchListTile(
                  title: const Text('Manage by quantity (for basics)'),
                  value: isCountBased,
                  onChanged: (val) {
                    setModalState(() {
                      isCountBased = val;
                    });
                  },
                ),
                if (isCountBased)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Initial Quantity:'),
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
                      if (nameController.text.isNotEmpty &&
                          categoryController.text.isNotEmpty) {
                        inventory.addGarment(
                          Garment(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text,
                            category: categoryController.text,
                            color: colorController.text.isEmpty
                                ? 'Unknown'
                                : colorController.text,
                            isCountBased: isCountBased,
                            quantity: isCountBased ? quantity : 1,
                            state: GarmentState.inCloset,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Item'),
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

class InventoryView extends StatefulWidget {
  const InventoryView({Key? key}) : super(key: key);

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  String _filterCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();

    // Get unique categories for filter
    final categories = [
      'All',
      ...inventory.garments.map((g) => g.category).toSet().toList(),
    ];

    // Apply filter
    final filteredGarments = _filterCategory == 'All'
        ? inventory.garments
        : inventory.garments
              .where((g) => g.category == _filterCategory)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _filterCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filterCategory = selected ? cat : 'All';
                      });
                    },
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: filteredGarments.isEmpty
          ? const Center(child: Text('No items found'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredGarments.length,
              itemBuilder: (context, index) {
                final garment = filteredGarments[index];
                return _buildGarmentCard(context, garment, inventory);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddGarmentSheet(context, inventory),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGarmentCard(
    BuildContext context,
    Garment garment,
    InventoryViewModel inventory,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
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
                        '${garment.category} • ${garment.color}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildStateIcon(context, garment.state),
              ],
            ),
            if (garment.isCountBased) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity Management',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: garment.quantity > 0
                            ? () => inventory.adjustQuantity(garment.id, -1)
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

  Widget _buildStateIcon(BuildContext context, GarmentState state) {
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
        color = Colors.blue;  // ← azul en vez de rojo
        break;
    }
    return Icon(icon, color: color, size: 28);
  }
}
