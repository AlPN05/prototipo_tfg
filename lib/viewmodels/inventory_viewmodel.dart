import 'package:flutter/foundation.dart';
import '../models/garment.dart';

class InventoryViewModel extends ChangeNotifier {
  // In-memory data store for the prototype.
  List<Garment> _garments = [
    // Mock Data to make the app look populated
    Garment(
      id: '1',
      name: 'White T-Shirt',
      category: 'T-Shirts',
      isCountBased: true,
      quantity: 5,
      state: GarmentState.inCloset,
      color: 'White',
    ),
    Garment(
      id: '2',
      name: 'Black Socks',
      category: 'Socks',
      isCountBased: true,
      quantity: 8,
      state: GarmentState.inCloset,
      color: 'Black',
    ),
    Garment(
      id: '3',
      name: 'Blue Jeans',
      category: 'Pants',
      state: GarmentState.inUse,
      color: 'Blue',
    ),
    Garment(
      id: '4',
      name: 'Winter Coat',
      category: 'Outerwear',
      state: GarmentState.inCloset,
      season: 'Winter',
      color: 'Grey',
    ),
    Garment(
      id: '5',
      name: 'Gym Shorts',
      category: 'Sportswear',
      state: GarmentState.inWash,
      color: 'Black',
    ),
    Garment(
      id: '6',
      name: 'Red Sweater',
      category: 'Sweaters',
      state: GarmentState.inCloset,
      color: 'Red',
    ),
  ];

  List<Garment> get garments => List.unmodifiable(_garments);

  // Statistics
  int get totalGarments {
    return _garments.fold(
      0,
      (sum, item) => sum + (item.isCountBased ? item.quantity : 1),
    );
  }

  int get inClosetCount {
    return _garments
        .where((g) => g.state == GarmentState.inCloset)
        .fold(0, (sum, item) => sum + (item.isCountBased ? item.quantity : 1));
  }

  int get inUseCount {
    return _garments
        .where((g) => g.state == GarmentState.inUse)
        .fold(0, (sum, item) => sum + (item.isCountBased ? item.quantity : 1));
  }

  int get inWashCount {
    return _garments
        .where((g) => g.state == GarmentState.inWash)
        .fold(0, (sum, item) => sum + (item.isCountBased ? item.quantity : 1));
  }

  // Basic CRUD
  void addGarment(Garment garment) {
    _garments.add(garment);
    notifyListeners();
  }

  void updateGarment(Garment updatedGarment) {
    final index = _garments.indexWhere((g) => g.id == updatedGarment.id);
    if (index != -1) {
      _garments[index] = updatedGarment;
      notifyListeners();
    }
  }

  void deleteGarment(String id) {
    _garments.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // Quick Action: Quantity increment/decrement
  void adjustQuantity(String id, int delta) {
    final index = _garments.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = _garments[index];
      if (g.isCountBased) {
        final newQty = g.quantity + delta;
        if (newQty >= 0) {
          g.quantity = newQty;
          notifyListeners();
        }
      }
    }
  }

  // Deferred Synchronization (Quick Review)
  // 1. Mark item as pending
  void setPendingState(String id, GarmentState newState) {
    final index = _garments.indexWhere((g) => g.id == id);
    if (index != -1) {
      _garments[index].pendingState = newState;
      notifyListeners();
    }
  }

  // 2. Clear pending state without saving
  void clearPendingStates() {
    for (var g in _garments) {
      g.pendingState = null;
    }
    notifyListeners();
  }

  // 3. Confirm and apply pending changes in bulk
  void syncPendingChanges() {
    for (var g in _garments) {
      if (g.pendingState != null) {
        g.state = g.pendingState!;
        g.pendingState = null;
      }
    }
    notifyListeners();
  }

  bool get hasPendingChanges {
    return _garments.any((g) => g.pendingState != null);
  }
}
