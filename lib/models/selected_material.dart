
class SelectedMaterial {
  final String materialId;
  final String materialName;
  final String unit;
  final bool isFromKit;
  final String? kitId;
  final String? kitName;

  SelectedMaterial({
    required this.materialId,
    required this.materialName,
    required this.unit,
    required this.isFromKit,
    this.kitId,
    this.kitName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedMaterial &&
        other.materialId == materialId &&
        other.kitId == kitId;
  }

  @override
  int get hashCode => materialId.hashCode ^ kitId.hashCode;
}