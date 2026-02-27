// Modelo que representa un outfit guardado por el usuario.
// Los slots de selección múltiple (acc, underwear) pueden contener
// varias prendas; los demás tienen máximo 1.
import '../models/garment.dart';

class Outfit {
  final String id;
  String name;

  /// Mapa de clave de slot → lista de prendas elegidas (vacía = slot vacío).
  /// Slots de una sola prenda: 'top', 'bottom', 'footwear', 'outer'.
  /// Slots multi-prenda:       'acc', 'underwear'.
  final Map<String, List<Garment>> slots;

  Outfit({
    required this.id,
    required this.name,
    required this.slots,
  });
}
