// Datos de inventario de ejemplo y lógica CRUD de prendas.
import 'package:flutter/foundation.dart';
import '../models/garment.dart';

class InventoryViewModel extends ChangeNotifier {
  // Inventario inicial con prendas de distintos tipos para el prototipo.
  List<Garment> _garments = [
    // ── Camisetas ─────────────────────────────────────────────────────────
    Garment(id: '1',  name: 'White T-Shirt',      category: 'T-Shirts',   isCountBased: true,  quantity: 5, state: GarmentState.inCloset, color: 'White',    season: 'All'),
    Garment(id: '2',  name: 'Black T-Shirt',       category: 'T-Shirts',   isCountBased: true,  quantity: 3, state: GarmentState.inCloset, color: 'Black',    season: 'All'),
    Garment(id: '3',  name: 'Navy T-Shirt',        category: 'T-Shirts',   isCountBased: false, quantity: 1, state: GarmentState.inUse,    color: 'Navy',     season: 'All'),

    // ── Camisas ───────────────────────────────────────────────────────────
    Garment(id: '4',  name: 'White Dress Shirt',   category: 'Shirts',     isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'White',    season: 'All'),
    Garment(id: '5',  name: 'Blue Oxford Shirt',   category: 'Shirts',     isCountBased: false, quantity: 1, state: GarmentState.inWash,   color: 'Blue',     season: 'All'),
    Garment(id: '6',  name: 'Flannel Shirt',       category: 'Shirts',     isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Red',      season: 'Winter'),

    // ── Sudaderas / Hoodies ───────────────────────────────────────────────
    Garment(id: '7',  name: 'Grey Hoodie',         category: 'Hoodies',    isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Grey',     season: 'All'),
    Garment(id: '8',  name: 'Black Sweatshirt',    category: 'Sweaters',   isCountBased: false, quantity: 1, state: GarmentState.inUse,    color: 'Black',    season: 'All'),
    Garment(id: '9',  name: 'Navy Jumper',         category: 'Jumpers',    isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Navy',     season: 'Winter'),

    // ── Pantalones ────────────────────────────────────────────────────────
    Garment(id: '10', name: 'Blue Jeans',          category: 'Jeans',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Blue',     season: 'All'),
    Garment(id: '11', name: 'Chino Pants',         category: 'Pants',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Beige',    season: 'All'),
    Garment(id: '12', name: 'Black Dress Pants',   category: 'Pants',      isCountBased: false, quantity: 1, state: GarmentState.inWash,   color: 'Black',    season: 'All'),
    Garment(id: '13', name: 'Grey Joggers',        category: 'Pants',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Grey',     season: 'All'),
    Garment(id: '14', name: 'Gym Shorts',          category: 'Shorts',     isCountBased: false, quantity: 1, state: GarmentState.inWash,   color: 'Black',    season: 'Summer'),

    // ── Abrigos / Chaquetas ───────────────────────────────────────────────
    Garment(id: '15', name: 'Winter Coat',         category: 'Outerwear',  isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Grey',     season: 'Winter'),
    Garment(id: '16', name: 'Denim Jacket',        category: 'Jackets',    isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Blue',     season: 'Spring'),
    Garment(id: '17', name: 'Leather Jacket',      category: 'Jackets',    isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Black',    season: 'All'),
    Garment(id: '18', name: 'Rain Jacket',         category: 'Jackets',    isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Olive',    season: 'Spring'),

    // ── Zapatos / Zapatillas / Botas ──────────────────────────────────────
    Garment(id: '19', name: 'White Sneakers',      category: 'Sneakers',   isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'White',    season: 'All'),
    Garment(id: '20', name: 'Black Dress Shoes',   category: 'Shoes',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Black',    season: 'All'),
    Garment(id: '21', name: 'Running Shoes',       category: 'Sneakers',   isCountBased: false, quantity: 1, state: GarmentState.inUse,    color: 'Blue',     season: 'All'),
    Garment(id: '22', name: 'Chelsea Boots',       category: 'Boots',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Brown',    season: 'Winter'),
    Garment(id: '23', name: 'Hiking Boots',        category: 'Boots',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Brown',    season: 'All'),

    // ── Calcetines / Ropa interior ────────────────────────────────────────
    Garment(id: '24', name: 'Black Socks',         category: 'Socks',      isCountBased: true,  quantity: 8, state: GarmentState.inCloset, color: 'Black',    season: 'All'),
    Garment(id: '25', name: 'White Socks',         category: 'Socks',      isCountBased: true,  quantity: 6, state: GarmentState.inCloset, color: 'White',    season: 'All'),
    Garment(id: '26', name: 'Underwear Pack',      category: 'Underwear',  isCountBased: true,  quantity: 7, state: GarmentState.inCloset, color: 'Multicolor', season: 'All'),

    // ── Cinturones / Accesorios ───────────────────────────────────────────
    Garment(id: '27', name: 'Black Leather Belt',  category: 'Belts',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Black',    season: 'All'),
    Garment(id: '28', name: 'Brown Leather Belt',  category: 'Belts',      isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Brown',    season: 'All'),
    Garment(id: '29', name: 'Wool Scarf',          category: 'Scarves',    isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Grey',     season: 'Winter'),
    Garment(id: '30', name: 'Baseball Cap',        category: 'Hats',       isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Navy',     season: 'Summer'),
    Garment(id: '31', name: 'Leather Gloves',      category: 'Gloves',     isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Black',    season: 'Winter'),
    Garment(id: '32', name: 'Backpack',            category: 'Bags',       isCountBased: false, quantity: 1, state: GarmentState.inUse,    color: 'Black',    season: 'All'),

    // ── Ropa deportiva ────────────────────────────────────────────────────
    Garment(id: '33', name: 'Compression Tights',  category: 'Sportswear', isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Black',    season: 'All'),
    Garment(id: '34', name: 'Sport Tank Top',      category: 'Sportswear', isCountBased: false, quantity: 1, state: GarmentState.inWash,   color: 'Grey',     season: 'Summer'),

    // ── Pijamas ───────────────────────────────────────────────────────────
    Garment(id: '35', name: 'Pyjama Set',          category: 'Sleepwear',  isCountBased: false, quantity: 1, state: GarmentState.inCloset, color: 'Blue',     season: 'All'),
  ];

  List<Garment> get garments => List.unmodifiable(_garments);

  // ─── Estadísticas ──────────────────────────────────────────────────────────

  int get totalGarments =>
      _garments.fold(0, (s, g) => s + (g.isCountBased ? g.quantity : 1));

  int get inClosetCount => _garments
      .where((g) => g.state == GarmentState.inCloset)
      .fold(0, (s, g) => s + (g.isCountBased ? g.quantity : 1));

  int get inUseCount => _garments
      .where((g) => g.state == GarmentState.inUse)
      .fold(0, (s, g) => s + (g.isCountBased ? g.quantity : 1));

  int get inWashCount => _garments
      .where((g) => g.state == GarmentState.inWash)
      .fold(0, (s, g) => s + (g.isCountBased ? g.quantity : 1));

  // ─── CRUD ──────────────────────────────────────────────────────────────────

  void addGarment(Garment garment) {
    _garments.add(garment);
    notifyListeners();
  }

  void updateGarment(Garment updated) {
    final idx = _garments.indexWhere((g) => g.id == updated.id);
    if (idx != -1) {
      _garments[idx] = updated;
      notifyListeners();
    }
  }

  void deleteGarment(String id) {
    _garments.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // ─── Gestión de cantidad ───────────────────────────────────────────────────

  void adjustQuantity(String id, int delta) {
    final idx = _garments.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final g = _garments[idx];
      if (g.isCountBased) {
        final newQty = g.quantity + delta;
        if (newQty >= 0) {
          g.quantity = newQty;
          notifyListeners();
        }
      }
    }
  }

  // ─── Quick Review: sincronización diferida ─────────────────────────────────

  void setPendingState(String id, GarmentState newState) {
    final idx = _garments.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _garments[idx].pendingState = newState;
      notifyListeners();
    }
  }

  void clearPendingStates() {
    for (final g in _garments) {
      g.pendingState = null;
    }
    notifyListeners();
  }

  void syncPendingChanges() {
    for (final g in _garments) {
      if (g.pendingState != null) {
        g.state = g.pendingState!;
        g.pendingState = null;
      }
    }
    notifyListeners();
  }

  bool get hasPendingChanges => _garments.any((g) => g.pendingState != null);
}
