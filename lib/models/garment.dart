enum GarmentState { inCloset, inUse, inWash }

class Garment {
  final String id;
  String name;
  String category;
  bool isCountBased;
  int quantity;
  GarmentState state;
  String season;
  String color;

  // Used during Quick Review to temporarily hold the state before confirmation
  GarmentState? pendingState;

  Garment({
    required this.id,
    required this.name,
    required this.category,
    this.isCountBased = false,
    this.quantity = 1,
    this.state = GarmentState.inCloset,
    this.season = 'All',
    this.color = 'Unknown',
    this.pendingState,
  });

  // Since we are not using a database, this is purely in-memory.
  // We can add a method to simulate cloning or copying for edits.
  Garment copyWith({
    String? name,
    String? category,
    bool? isCountBased,
    int? quantity,
    GarmentState? state,
    String? season,
    String? color,
    GarmentState? pendingState,
  }) {
    return Garment(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      isCountBased: isCountBased ?? this.isCountBased,
      quantity: quantity ?? this.quantity,
      state: state ?? this.state,
      season: season ?? this.season,
      color: color ?? this.color,
      pendingState: pendingState, // intentionally allows nulling out
    );
  }
}
