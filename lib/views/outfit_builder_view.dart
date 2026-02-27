import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../models/garment.dart';

class OutfitBuilderView extends StatefulWidget {
  const OutfitBuilderView({Key? key}) : super(key: key);

  @override
  State<OutfitBuilderView> createState() => _OutfitBuilderViewState();
}

class _OutfitBuilderViewState extends State<OutfitBuilderView> {
  // Outfit slots
  static const List<Map<String, dynamic>> _slots = [
    {'label': 'Top',       'icon': Icons.dry_cleaning},
    {'label': 'Bottom',    'icon': Icons.airline_seat_legroom_normal},
    {'label': 'Footwear',  'icon': Icons.airline_seat_flat},
    {'label': 'Outerwear', 'icon': Icons.umbrella},
    {'label': 'Accessory', 'icon': Icons.watch},
  ];

  final Map<String, Garment?> _selected = {};
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Outfit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outfit name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Outfit name',
                hintText: 'e.g. Monday casual',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Select pieces',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Slot list
            ..._slots.map((slot) {
              final label = slot['label'] as String;
              final icon = slot['icon'] as IconData;
              final chosen = _selected[label];
              return _buildSlotTile(
                context,
                label: label,
                icon: icon,
                chosen: chosen,
                inventory: inventory,
              );
            }),
            const SizedBox(height: 32),
            // Outfit preview card
            if (_selected.values.any((g) => g != null)) ...[
              Text(
                'Outfit Preview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.08),
                      colorScheme.secondary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: _slots
                      .where((s) => _selected[s['label']] != null)
                      .map((s) {
                    final g = _selected[s['label']]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(s['icon'] as IconData,
                              size: 18, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            '${s['label']}: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            g.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              g.color,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _selected.values.any((g) => g != null)
                    ? () {
                        final name = _nameController.text.trim().isEmpty
                            ? 'My Outfit'
                            : _nameController.text.trim();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Outfit "$name" saved! ✨'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Outfit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotTile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Garment? chosen,
    required InventoryViewModel inventory,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: chosen != null
            ? colorScheme.primary.withOpacity(0.07)
            : Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _pickGarment(context, label, inventory),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: chosen != null
                        ? colorScheme.primary.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: chosen != null ? colorScheme.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        chosen != null ? chosen.name : 'Tap to select…',
                        style: TextStyle(
                          fontWeight: chosen != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: chosen != null ? null : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (chosen != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.grey,
                    onPressed: () =>
                        setState(() => _selected[label] = null),
                  )
                else
                  const Icon(Icons.add_circle_outline, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickGarment(
    BuildContext context,
    String slot,
    InventoryViewModel inventory,
  ) {
    final available = inventory.garments
        .where((g) => g.state != GarmentState.inWash)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          builder: (ctx, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pick $slot',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: available.isEmpty
                        ? const Center(
                            child: Text('No available garments'),
                          )
                        : ListView.separated(
                            controller: scrollCtrl,
                            itemCount: available.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final g = available[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(ctx)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.checkroom,
                                    color: Theme.of(ctx).colorScheme.primary,
                                    size: 18,
                                  ),
                                ),
                                title: Text(g.name),
                                subtitle: Text('${g.category} • ${g.color}'),
                                onTap: () {
                                  setState(() => _selected[slot] = g);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
