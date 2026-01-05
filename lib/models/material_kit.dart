import 'package:uniontemporal/models/material_item.dart';

class MaterialKit {
  final String id;
  final String name;
  final String description;
  final List<MaterialItem> materials;

  MaterialKit({
    required this.id,
    required this.name,
    required this.description,
    required this.materials,
  });
}