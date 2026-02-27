// Clase centralizada de cadenas de texto traducibles. Cubre todos los textos
// de la app incluyendo nombres de prendas, categorías y colores.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class AppStrings {
  final String language;
  AppStrings(this.language);

  /// Obtiene la instancia de AppStrings a partir del idioma activo en el contexto.
  static AppStrings of(BuildContext context) {
    final lang = context.watch<SettingsViewModel>().language;
    return AppStrings(lang);
  }

  // ─── General ──────────────────────────────────────────────────────────────
  String get appName => _s('Smart Closet', 'Smart Closet');
  String get appSubtitle =>
      _s('Your intelligent wardrobe', 'Tu armario inteligente');
  String get save => _s('Save', 'Guardar');
  String get cancel => _s('Cancel', 'Cancelar');
  String get noItems => _s('No items found', 'No se encontraron prendas');
  String get delete => _s('Delete', 'Eliminar');

  // ─── Bottom Navigation ────────────────────────────────────────────────────
  String get navDashboard => _s('Dashboard', 'Inicio');
  String get navQuickReview => _s('Quick Review', 'Revisión');
  String get navInventory => _s('Inventory', 'Inventario');
  String get navSettings => _s('Settings', 'Ajustes');

  // ─── Dashboard ────────────────────────────────────────────────────────────
  String get totalItems => _s('Total items', 'Total prendas');
  String get inUse => _s('In Use', 'En uso');
  String get inWash => _s('In Wash', 'Lavando');
  String get quickActions => _s('Quick Actions', 'Acciones rápidas');
  String get addItem => _s('Add Item', 'Añadir prenda');
  String get createOutfit => _s('Create Outfit', 'Crear outfit');
  String get viewOutfits => _s('My Outfits', 'Mis outfits');
  String get sort => _s('Sort', 'Ordenar');
  String get currentConfigActive =>
      _s('Current configuration active', 'Configuración actual activa');

  // ─── Inventory ────────────────────────────────────────────────────────────
  String get inventory => _s('Inventory', 'Inventario');
  String get addNewGarment => _s('Add New Garment', 'Añadir nueva prenda');
  String get name => _s('Name', 'Nombre');
  String get category => _s('Category', 'Categoría');
  String get color => _s('Color', 'Color');
  String get season => _s('Season', 'Temporada');
  String get manageByQuantity =>
      _s('Manage by quantity', 'Gestionar por cantidad');
  String get initialQuantity => _s('Initial Quantity:', 'Cantidad inicial:');
  String get saveItem => _s('Save Item', 'Guardar prenda');
  String get quantityManagement =>
      _s('Quantity Management', 'Gestión de cantidad');
  String get all => _s('All', 'Todas');

  // ─── Estado de prenda ─────────────────────────────────────────────────────
  String get inCloset => _s('In Closet', 'En armario');
  String get inUseState => _s('In Use', 'En uso');
  String get inWashState => _s('In Wash', 'Lavando');
  String get closet => _s('Closet', 'Armario');
  String get washing => _s('Washing', 'Lavando');

  // ─── Quick Review ─────────────────────────────────────────────────────────
  String get quickReview => _s('Quick Review', 'Revisión rápida');
  String get noItemsToReview =>
      _s('No items to review', 'No hay prendas para revisar');
  String get clearPending => _s('Clear pending changes', 'Descartar cambios');
  String get confirmChanges => _s('Confirm Changes', 'Confirmar cambios');
  String get syncSuccess =>
      _s('Changes synchronized successfully', 'Cambios sincronizados');
  String get toWash => _s('To Wash', 'A lavar');
  String get units => _s('units', 'unid.');
  String get edit => _s('Edit', 'Editar');
  String get editGarment => _s('Edit Garment', 'Editar prenda');
  String get saveChanges => _s('Save Changes', 'Guardar cambios');
  String get state => _s('State', 'Estado');
  String get quantity => _s('Quantity:', 'Cantidad:');
  String get setInUse => _s('In Use', 'En uso');
  String get deleteSelected => _s('Delete selected', 'Eliminar seleccionadas');
  String selectedCount(int n) => _s('$n selected', '$n seleccionadas');
  String get garmentDeleted => _s('Garment deleted', 'Prenda eliminada');
  String get garmentsDeleted => _s('Garments deleted', 'Prendas eliminadas');
  String get deleteConfirmTitle => _s('Delete garments?', '¿Eliminar prendas?');
  String deleteConfirmContent(int n) =>
      _s('Delete $n garment(s)?', '¿Eliminar $n prenda(s)?');
  String get confirmDelete => _s('Delete', 'Eliminar');
  String get cancelSelection => _s('Cancel', 'Cancelar');

  // ─── Outfit Builder ───────────────────────────────────────────────────────
  String get createOutfitTitle => _s('Create Outfit', 'Crear outfit');
  String get outfitName => _s('Outfit name', 'Nombre del outfit');
  String get outfitNameHint =>
      _s('e.g. Monday casual', 'ej: Lunes casual');
  String get selectPieces => _s('Select pieces', 'Seleccionar prendas');
  String get outfitPreview => _s('Outfit Preview', 'Vista previa');
  String get saveOutfit => _s('Save Outfit', 'Guardar outfit');
  String get tapToSelect => _s('Tap to select…', 'Toca para elegir…');
  String get noAvailableGarments =>
      _s('No available garments', 'Sin prendas disponibles');
  String get pickSlot => _s('Pick', 'Elegir');
  String get myOutfit => _s('My Outfit', 'Mi outfit');
  String outfitSaved(String n) =>
      _s('Outfit "$n" saved! ✨', '¡Outfit "$n" guardado! ✨');

  // ─── Outfits guardados ────────────────────────────────────────────────────
  String get savedOutfits => _s('My Outfits', 'Mis outfits');
  String get noSavedOutfits =>
      _s('No outfits yet.\nCreate your first one!',
         'Aún no hay outfits.\n¡Crea el primero!');
  String get outfitDeletedMsg => _s('Outfit deleted', 'Outfit eliminado');

  // ─── Settings ─────────────────────────────────────────────────────────────
  String get settings => _s('Settings', 'Ajustes');
  String get preferences => _s('Preferences', 'Preferencias');
  String get language2 => _s('Language', 'Idioma');
  String get theme => _s('Theme', 'Tema');
  String get themeSystem => _s('System', 'Sistema');
  String get themeLight => _s('Light', 'Claro');
  String get themeDark => _s('Dark', 'Oscuro');
  String get closetConfiguration =>
      _s('Closet Configuration', 'Configuración del armario');
  String get version => _s('Version', 'Versión');

  // ─── Categorías traducibles ───────────────────────────────────────────────
  String get catTshirts      => _s('T-Shirts',     'Camisetas');
  String get catShirts       => _s('Shirts',        'Camisas');
  String get catPolos        => _s('Polos',         'Polos');
  String get catTanktops     => _s('Tank Tops',     'Tirantes');
  String get catSweaters     => _s('Sweaters',      'Sudaderas');
  String get catHoodies      => _s('Hoodies',       'Hoodies');
  String get catJumpers      => _s('Jumpers',       'Jerseys');
  String get catPants        => _s('Pants',         'Pantalones');
  String get catJeans        => _s('Jeans',         'Vaqueros');
  String get catShorts       => _s('Shorts',        'Pantalones cortos');
  String get catSkirts       => _s('Skirts',        'Faldas');
  String get catSocks        => _s('Socks',         'Calcetines');
  String get catUnderwear    => _s('Underwear',     'Ropa interior');
  String get catSneakers     => _s('Sneakers',      'Zapatillas');
  String get catShoes        => _s('Shoes',         'Zapatos');
  String get catBoots        => _s('Boots',         'Botas');
  String get catSandals      => _s('Sandals',       'Sandalias');
  String get catBelts        => _s('Belts',         'Cinturones');
  String get catHats         => _s('Hats',          'Gorras/Sombreros');
  String get catScarves      => _s('Scarves',       'Bufandas');
  String get catGloves       => _s('Gloves',        'Guantes');
  String get catOuterwear    => _s('Outerwear',     'Abrigos');
  String get catJackets      => _s('Jackets',       'Chaquetas');
  String get catSuits        => _s('Suits',         'Trajes');
  String get catSportswear   => _s('Sportswear',    'Ropa deportiva');
  String get catSleepwear    => _s('Sleepwear',     'Pijamas');
  String get catAccessories  => _s('Accessories',   'Accesorios');
  String get catBags         => _s('Bags',          'Mochilas/Bolsas');

  /// Traduce una categoría almacenada (en inglés interno) al idioma activo.
  String translateCategory(String raw) {
    const map = <String, String>{
      'T-Shirts': 'Camisetas',
      'Shirts': 'Camisas',
      'Polos': 'Polos',
      'Tank Tops': 'Tirantes',
      'Sweaters': 'Sudaderas',
      'Hoodies': 'Hoodies',
      'Jumpers': 'Jerseys',
      'Pants': 'Pantalones',
      'Jeans': 'Vaqueros',
      'Shorts': 'Pantalones cortos',
      'Skirts': 'Faldas',
      'Socks': 'Calcetines',
      'Underwear': 'Ropa interior',
      'Sneakers': 'Zapatillas',
      'Shoes': 'Zapatos',
      'Boots': 'Botas',
      'Sandals': 'Sandalias',
      'Belts': 'Cinturones',
      'Hats': 'Gorras/Sombreros',
      'Scarves': 'Bufandas',
      'Gloves': 'Guantes',
      'Outerwear': 'Abrigos',
      'Jackets': 'Chaquetas',
      'Suits': 'Trajes',
      'Sportswear': 'Ropa deportiva',
      'Sleepwear': 'Pijamas',
      'Accessories': 'Accesorios',
      'Bags': 'Mochilas/Bolsas',
    };
    if (language == 'es') return map[raw] ?? raw;
    return raw;
  }

  // ─── Colores traducibles ──────────────────────────────────────────────────
  String translateColor(String raw) {
    const map = <String, String>{
      'White': 'Blanco',
      'Black': 'Negro',
      'Grey': 'Gris',
      'Gray': 'Gris',
      'Blue': 'Azul',
      'Navy': 'Azul marino',
      'Red': 'Rojo',
      'Green': 'Verde',
      'Yellow': 'Amarillo',
      'Orange': 'Naranja',
      'Pink': 'Rosa',
      'Purple': 'Morado',
      'Brown': 'Marrón',
      'Beige': 'Beis',
      'Cream': 'Crema',
      'Khaki': 'Caqui',
      'Olive': 'Verde oliva',
      'Burgundy': 'Burdeos',
      'Teal': 'Verde azulado',
      'Multicolor': 'Multicolor',
      'Unknown': 'Desconocido',
    };
    if (language == 'es') return map[raw] ?? raw;
    return raw;
  }

  // ─── Categorías de armario ─────────────────────────────────────────────────
  String get basicWardrobe     => _s('Basic Wardrobe',      'Armario básico');
  String get modularCloset     => _s('Modular Closet',      'Armario modular');
  String get openRack          => _s('Open Rack',            'Perchero abierto');
  String get compactDresser    => _s('Compact Dresser',      'Cómoda compacta');
  String get customSetup       => _s('Custom Setup',         'Config. personalizada');

  // ─── Slots del outfit ─────────────────────────────────────────────────────
  String get slotTop       => _s('Top',        'Superior');
  String get slotBottom    => _s('Bottom',     'Inferior');
  String get slotFootwear  => _s('Footwear',   'Calzado');
  String get slotOuterwear => _s('Outerwear',  'Abrigo');
  String get slotAccessory => _s('Accessory',  'Accesorio');
  String get slotUnderwear => _s('Underwear',  'Ropa interior');

  // ─── Helper interno ───────────────────────────────────────────────────────
  String _s(String en, String es) => language == 'es' ? es : en;
}
