// Vista para construir un outfit personalizado combinando prendas del inventario.
// Al guardar, el outfit queda registrado en OutfitViewModel y se navega a la lista.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../viewmodels/inventory_viewmodel.dart';
import '../viewmodels/outfit_viewmodel.dart';
import '../models/garment.dart';
import '../models/outfit.dart';
import 'saved_outfits_view.dart';

class OutfitBuilderView extends StatefulWidget {
  const OutfitBuilderView({super.key});

  @override
  State<OutfitBuilderView> createState() => _OutfitBuilderViewState();
}

class _OutfitBuilderViewState extends State<OutfitBuilderView> {
  /// Slots de prenda única (máximo 1 prenda por slot).
  final Map<String, Garment?> _single = {};

  /// Slots de prenda múltiple (pueden tener varias prendas).
  final Map<String, List<Garment>> _multi = {
    'acc': [],
    'underwear': [],
  };

  /// Nombre que el usuario da al outfit.
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Categorías permitidas por slot ──────────────────────────────────────────

  static const Map<String, List<String>> _slotCategories = {
    'top': [
      'T-Shirts', 'Shirts', 'Polos', 'Tank Tops',
      'Sweaters', 'Hoodies', 'Jumpers', 'Sportswear', 'Sleepwear',
    ],
    'bottom': [
      'Pants', 'Jeans', 'Shorts', 'Skirts', 'Sportswear', 'Sleepwear',
    ],
    'footwear': [
      'Sneakers', 'Shoes', 'Boots', 'Sandals', 'Socks',
    ],
    'outer': [
      'Outerwear', 'Jackets', 'Suits',
    ],
    'acc': [
      'Belts', 'Hats', 'Scarves', 'Gloves', 'Accessories', 'Bags',
    ],
    'underwear': [
      'Underwear', 'Socks',
    ],
  };

  // ── Definición de slots ─────────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildSingleSlots(AppStrings s) => [
        {'key': 'top',      'label': s.slotTop,       'icon': Icons.dry_cleaning},
        {'key': 'bottom',   'label': s.slotBottom,    'icon': Icons.airline_seat_legroom_normal},
        {'key': 'footwear', 'label': s.slotFootwear,  'icon': Icons.airline_seat_flat},
        {'key': 'outer',    'label': s.slotOuterwear, 'icon': Icons.umbrella},
      ];

  List<Map<String, dynamic>> _buildMultiSlots(AppStrings s) => [
        {'key': 'acc',       'label': s.slotAccessory, 'icon': Icons.watch},
        {'key': 'underwear', 'label': s.slotUnderwear, 'icon': Icons.dry_cleaning_outlined},
      ];

  // ── Comprobación de si hay algo seleccionado ────────────────────────────────

  bool get _hasAny =>
      _single.values.any((g) => g != null) ||
      _multi.values.any((list) => list.isNotEmpty);

  // ── Build principal ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final s = AppStrings.of(context);
    final singleSlots = _buildSingleSlots(s);
    final multiSlots  = _buildMultiSlots(s);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.createOutfitTitle),
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
            // Campo para el nombre del outfit
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: s.outfitName,
                hintText: s.outfitNameHint,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 32),
            Text(s.selectPieces,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // ── Slots de prenda única ─────────────────────────────────────
            ...singleSlots.map((slot) {
              final key = slot['key'] as String;
              return _buildSingleSlotTile(
                context,
                slotKey:   key,
                label:     slot['label'] as String,
                icon:      slot['icon'] as IconData,
                chosen:    _single[key],
                inventory: inventory,
                s:         s,
              );
            }),

            const SizedBox(height: 8),

            // ── Slots de prenda múltiple ──────────────────────────────────
            ...multiSlots.map((slot) {
              final key = slot['key'] as String;
              return _buildMultiSlotSection(
                context,
                slotKey:   key,
                label:     slot['label'] as String,
                icon:      slot['icon'] as IconData,
                items:     _multi[key]!,
                inventory: inventory,
                s:         s,
              );
            }),

            const SizedBox(height: 32),

            // ── Vista previa ──────────────────────────────────────────────
            if (_hasAny) ...[
              Text(s.outfitPreview,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    colorScheme.primary.withValues(alpha: 0.08),
                    colorScheme.secondary.withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Prendas únicas seleccionadas
                    ...singleSlots
                        .where((sl) => _single[sl['key']] != null)
                        .map((sl) {
                      final g = _single[sl['key']]!;
                      return _buildPreviewRow(
                          context, sl['icon'] as IconData, sl['label'] as String, g, s, colorScheme);
                    }),
                    // Prendas múltiples seleccionadas
                    ...multiSlots.expand((sl) {
                      final items = _multi[sl['key']]!;
                      return items.map((g) => _buildPreviewRow(
                          context, sl['icon'] as IconData, sl['label'] as String, g, s, colorScheme));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Botón guardar ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _hasAny ? () => _saveOutfit(context, s) : null,
                icon: const Icon(Icons.save_outlined),
                label: Text(s.saveOutfit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Vista previa: fila de prenda ────────────────────────────────────────────

  Widget _buildPreviewRow(
    BuildContext context,
    IconData icon,
    String slotLabel,
    Garment g,
    AppStrings s,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text('$slotLabel: ',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
            child: Text(g.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(s.translateColor(g.color),
                style: TextStyle(fontSize: 11, color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  // ── Guardar outfit ──────────────────────────────────────────────────────────

  void _saveOutfit(BuildContext context, AppStrings s) {
    final name = _nameController.text.trim().isEmpty
        ? s.myOutfit
        : _nameController.text.trim();

    // Construimos el mapa unificado Map<String, List<Garment>>
    final Map<String, List<Garment>> slots = {};
    for (final entry in _single.entries) {
      if (entry.value != null) slots[entry.key] = [entry.value!];
    }
    for (final entry in _multi.entries) {
      if (entry.value.isNotEmpty) slots[entry.key] = List.from(entry.value);
    }

    context.read<OutfitViewModel>().addOutfit(
          Outfit(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            slots: slots,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.outfitSaved(name)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Volver atrás y abrir la vista de outfits guardados para ver el resultado
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedOutfitsView()),
    );
  }

  // ── Tile de slot de prenda única ────────────────────────────────────────────

  Widget _buildSingleSlotTile(
    BuildContext context, {
    required String slotKey,
    required String label,
    required IconData icon,
    required Garment? chosen,
    required InventoryViewModel inventory,
    required AppStrings s,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: chosen != null
            ? colorScheme.primary.withValues(alpha: 0.07)
            : Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _pickSingle(context, slotKey, label, inventory, s),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: chosen != null
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      size: 22,
                      color: chosen != null ? colorScheme.primary : Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              fontSize: 12)),
                      Text(
                        chosen != null ? chosen.name : s.tapToSelect,
                        style: TextStyle(
                          fontWeight: chosen != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: chosen != null ? null : Colors.grey,
                        ),
                      ),
                      if (chosen != null)
                        Text(
                          '${s.translateCategory(chosen.category)} · ${s.translateColor(chosen.color)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                ),
                if (chosen != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.grey,
                    onPressed: () => setState(() => _single[slotKey] = null),
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

  // ── Sección de slot multi-prenda ────────────────────────────────────────────

  Widget _buildMultiSlotSection(
    BuildContext context, {
    required String slotKey,
    required String label,
    required IconData icon,
    required List<Garment> items,
    required InventoryViewModel inventory,
    required AppStrings s,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: items.isNotEmpty
              ? colorScheme.primary.withValues(alpha: 0.07)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: items.isNotEmpty
                ? colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            // Cabecera del slot
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: items.isNotEmpty
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 22,
                    color: items.isNotEmpty ? colorScheme.primary : Colors.grey),
              ),
              title: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: 12)),
              subtitle: items.isEmpty
                  ? Text(s.tapToSelect,
                      style: const TextStyle(color: Colors.grey))
                  : null,
              trailing: IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: colorScheme.primary),
                tooltip: s.tapToSelect,
                onPressed: () =>
                    _pickMulti(context, slotKey, label, inventory, s),
              ),
            ),
            // Lista de prendas seleccionadas
            if (items.isNotEmpty)
              ...items.map((g) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 52),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '${s.translateCategory(g.category)} · ${s.translateColor(g.color)}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.grey,
                          onPressed: () => setState(
                              () => _multi[slotKey]!.remove(g)),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  // ── Picker de prenda única ──────────────────────────────────────────────────

  void _pickSingle(
    BuildContext context,
    String slotKey,
    String slotLabel,
    InventoryViewModel inventory,
    AppStrings s,
  ) {
    _openPicker(
      context: context,
      slotKey: slotKey,
      slotLabel: slotLabel,
      inventory: inventory,
      s: s,
      onPick: (g) => setState(() => _single[slotKey] = g),
    );
  }

  // ── Picker de prenda múltiple ───────────────────────────────────────────────

  void _pickMulti(
    BuildContext context,
    String slotKey,
    String slotLabel,
    InventoryViewModel inventory,
    AppStrings s,
  ) {
    _openPicker(
      context: context,
      slotKey: slotKey,
      slotLabel: slotLabel,
      inventory: inventory,
      s: s,
      onPick: (g) => setState(() => _multi[slotKey]!.add(g)),
    );
  }

  // ── Bottom sheet de selección de prenda ────────────────────────────────────

  void _openPicker({
    required BuildContext context,
    required String slotKey,
    required String slotLabel,
    required InventoryViewModel inventory,
    required AppStrings s,
    required void Function(Garment) onPick,
  }) {
    final allowedCats = _slotCategories[slotKey] ?? [];
    final available = inventory.garments
        .where((g) =>
            g.state != GarmentState.inWash &&
            (allowedCats.isEmpty || allowedCats.contains(g.category)))
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
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          builder: (ctx, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 16),
                  Text('${s.pickSlot} $slotLabel',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: available.isEmpty
                        ? Center(child: Text(s.noAvailableGarments))
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
                                      .withValues(alpha: 0.1),
                                  child: Icon(Icons.checkroom,
                                      color: Theme.of(ctx).colorScheme.primary,
                                      size: 18),
                                ),
                                title: Text(g.name),
                                subtitle: Text(
                                    '${s.translateCategory(g.category)} · ${s.translateColor(g.color)}'),
                                onTap: () {
                                  onPick(g);
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
