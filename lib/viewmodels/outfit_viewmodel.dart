// ViewModel para gestionar los outfits guardados por el usuario.
import 'package:flutter/foundation.dart';
import '../models/outfit.dart';

class OutfitViewModel extends ChangeNotifier {
  /// Lista en memoria de outfits guardados.
  final List<Outfit> _outfits = [];

  List<Outfit> get outfits => List.unmodifiable(_outfits);

  bool get hasOutfits => _outfits.isNotEmpty;

  /// Guarda un nuevo outfit en la lista.
  void addOutfit(Outfit outfit) {
    _outfits.add(outfit);
    notifyListeners();
  }

  /// Elimina un outfit por ID.
  void deleteOutfit(String id) {
    _outfits.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}
