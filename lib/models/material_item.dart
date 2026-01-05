// models/material_item.dart
class MaterialItem {
  final String id;
  final String name;
  final int quantity;
  final int assignedQuantity;
  final String unit;
  final String? kitId; // Si es parte de un kit

  MaterialItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.assignedQuantity,
    this.unit = 'unidades',
    this.kitId,
  });

  MaterialItem copyWith({
    String? id,
    String? name,
    int? quantity,
    int? assignedQuantity,
    String? unit,
    String? kitId,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      assignedQuantity: assignedQuantity ?? this.assignedQuantity,
      unit: unit ?? this.unit,
      kitId: kitId ?? this.kitId,
    );
  }
}