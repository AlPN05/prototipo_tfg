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
                    Icons.water_drop,
                    'Wash / Use',
                    Colors.redAccent,
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
                      // Swiped left -> In Closet
                      inventory.setPendingState(
                        garment.id,
                        GarmentState.inCloset,
                      );
                    } else {
                      // Swiped right -> In Wash / Use (let's say InWash for simplicity)
                      inventory.setPendingState(
                        garment.id,
                        GarmentState.inWash,
                      );
                    }
                    return false; // Don't actually dismiss the widget from the list
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
                      trailing: _buildStateBadge(context, displayState),
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
        color = Colors.redAccent;
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
