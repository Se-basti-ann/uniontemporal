import 'package:flutter/material.dart';
import '../models/material_item.dart';

class MaterialListWidget extends StatelessWidget {
  final List<MaterialItem> materials;
  final Function(MaterialItem) onSelectMaterial;
  final bool showOnlyAvailable;

  const MaterialListWidget({
    super.key,
    required this.materials,
    required this.onSelectMaterial,
    this.showOnlyAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final filteredMaterials = showOnlyAvailable
        ? materials.where((m) => m.quantity > 0).toList()
        : materials;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredMaterials.length,
      itemBuilder: (context, index) {
        final material = filteredMaterials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory, color: Colors.blue),
            ),
            title: Text(material.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Disponible: ${material.quantity} ${material.unit}'),
                if (material.assignedQuantity > 0)
                  Text(
                    'Asignado: ${material.assignedQuantity} ${material.unit}',
                    style: const TextStyle(color: Colors.orange),
                  ),
              ],
            ),
            trailing: material.quantity > 0
                ? IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () => onSelectMaterial(material),
                  )
                : const Text(
                    'Agotado',
                    style: TextStyle(color: Colors.red),
                  ),
          ),
        );
      },
    );
  }
}