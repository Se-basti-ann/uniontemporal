import 'package:flutter/material.dart';
import '../models/material_kit.dart';

class KitListWidget extends StatelessWidget {
  final List<MaterialKit> kits;
  final Function(MaterialKit) onSelectKit;

  const KitListWidget({
    super.key,
    required this.kits,
    required this.onSelectKit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kits.length,
      itemBuilder: (context, index) {
        final kit = kits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.assessment, color: Colors.purple),
            ),
            title: Text(kit.name),
            subtitle: Text(kit.description),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => onSelectKit(kit),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: kit.materials.map((material) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(material.name)),
                          Text('${material.quantity} ${material.unit}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}