import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/material_item.dart';
import '../models/material_kit.dart';
import '../models/selected_material.dart';
import '../providers/task_provider.dart';
import '../widgets/material_list_widget.dart';
import '../widgets/kit_list_widget.dart';
import 'task_execution_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with TickerProviderStateMixin {
  final TextEditingController _problemController = TextEditingController();
  String? _selectedProblemType;
  
  late TabController _tabController;
  final List<SelectedMaterial> _selectedMaterials = [];
  
  // Datos de ejemplo
  final List<MaterialItem> _availableMaterials = [
    MaterialItem(id: '1', name: 'Cable UTP Cat6', quantity: 100, assignedQuantity: 0, unit: 'metros'),
    MaterialItem(id: '2', name: 'Conector RJ45', quantity: 50, assignedQuantity: 0, unit: 'unidades'),
    MaterialItem(id: '3', name: 'Router WiFi', quantity: 10, assignedQuantity: 0, unit: 'unidades'),
    MaterialItem(id: '4', name: 'Switch 8 puertos', quantity: 5, assignedQuantity: 0, unit: 'unidades'),
    MaterialItem(id: '5', name: 'Patch Panel', quantity: 8, assignedQuantity: 0, unit: 'unidades'),
  ];
  
  final List<MaterialKit> _availableKits = [
    MaterialKit(
      id: 'k1',
      name: 'Kit Red Básica',
      description: 'Todo lo necesario para una instalación básica de red',
      materials: [
        MaterialItem(id: '1', name: 'Cable UTP Cat6', quantity: 50, assignedQuantity: 0, unit: 'metros', kitId: 'k1'),
        MaterialItem(id: '2', name: 'Conector RJ45', quantity: 10, assignedQuantity: 0, unit: 'unidades', kitId: 'k1'),
        MaterialItem(id: '3', name: 'Router WiFi', quantity: 1, assignedQuantity: 0, unit: 'unidades', kitId: 'k1'),
      ],
    ),
    MaterialKit(
      id: 'k2',
      name: 'Kit Red Avanzada',
      description: 'Para instalaciones corporativas',
      materials: [
        MaterialItem(id: '1', name: 'Cable UTP Cat6', quantity: 100, assignedQuantity: 0, unit: 'metros', kitId: 'k2'),
        MaterialItem(id: '4', name: 'Switch 8 puertos', quantity: 1, assignedQuantity: 0, unit: 'unidades', kitId: 'k2'),
        MaterialItem(id: '5', name: 'Patch Panel', quantity: 1, assignedQuantity: 0, unit: 'unidades', kitId: 'k2'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _addMaterial(MaterialItem material, {String? kitId, String? kitName}) {
    final newSelectedMaterial = SelectedMaterial(
      materialId: material.id,
      materialName: material.name,
      unit: material.unit,
      isFromKit: kitId != null,
      kitId: kitId,
      kitName: kitName,
    );

    // Verificar si ya existe el mismo material del mismo origen
    final alreadyExists = _selectedMaterials.any((sm) => 
      sm.materialId == material.id && sm.kitId == kitId
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${material.name} ya está seleccionado'),
          duration: const Duration(milliseconds: 800),
        ),
      );
      return;
    }

    // Verificar si ya existe un material con el mismo nombre (para advertencia)
    final existingSameName = _selectedMaterials.where(
      (sm) => sm.materialName == material.name
    ).toList();

    if (existingSameName.isNotEmpty) {
      _showDuplicateMaterialWarning(material.name);
    }

    setState(() {
      _selectedMaterials.add(newSelectedMaterial);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${material.name} agregado'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _showDuplicateMaterialWarning(String materialName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Ya existe un material con el nombre "$materialName" en la lista'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addKit(MaterialKit kit) {
    // Verificar si ya hay materiales individuales con los mismos nombres
    List<String> duplicateMaterials = [];
    for (var material in kit.materials) {
      final existingIndividual = _selectedMaterials.where(
        (sm) => sm.materialName == material.name && !sm.isFromKit
      ).isNotEmpty;
      
      if (existingIndividual) {
        duplicateMaterials.add(material.name);
      }
    }
    
    if (duplicateMaterials.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Materiales Duplicados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Los siguientes materiales ya existen como individuales:'),
              const SizedBox(height: 10),
              ...duplicateMaterials.map((name) => Text('• $name')),
              const SizedBox(height: 10),
              const Text('¿Deseas agregar el kit de todas formas?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addKitConfirmed(kit);
              },
              child: const Text('Agregar Kit'),
            ),
          ],
        ),
      );
    } else {
      _addKitConfirmed(kit);
    }
  }

  void _addKitConfirmed(MaterialKit kit) {
    for (var material in kit.materials) {
      _addMaterial(material, kitId: kit.id, kitName: kit.name);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kit ${kit.name} agregado'),
        backgroundColor: Colors.purple,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _removeMaterial(int index) async {
    final selectedMaterial = _selectedMaterials[index];
    
    // Si el material viene de un kit, pedir observación
    if (selectedMaterial.isFromKit) {
      final observation = await _showRemovalDialog(context, selectedMaterial);
      if (observation == null) return; // Usuario canceló
      
      // Aquí puedes guardar la observación junto con la eliminación
      print('Material ${selectedMaterial.materialName} removido del kit ${selectedMaterial.kitName}. Observación: $observation');
    }
    
    setState(() {
      _selectedMaterials.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Material ${selectedMaterial.materialName} removido'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<String?> _showRemovalDialog(BuildContext context, SelectedMaterial selectedMaterial) {
    final TextEditingController observationController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Material de Kit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'El material "${selectedMaterial.materialName}" forma parte del kit "${selectedMaterial.kitName}".',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor, indica el motivo por el cual lo estás removiendo:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observación',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Material dañado, no necesario, cliente ya tenía, etc.',
                ),
              ),
              const SizedBox(height: 8),
              if (observationController.text.isEmpty)
                const Text(
                  'Es obligatorio ingresar una observación',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (observationController.text.trim().isNotEmpty) {
                Navigator.pop(context, observationController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa una observación'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMaterialsSection() {
    if (_selectedMaterials.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No hay materiales seleccionados',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Agrupar materiales por nombre para mostrar en resumen
    Map<String, List<SelectedMaterial>> groupedByName = {};
    for (var material in _selectedMaterials) {
      if (!groupedByName.containsKey(material.materialName)) {
        groupedByName[material.materialName] = [];
      }
      groupedByName[material.materialName]!.add(material);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Materiales Seleccionados:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Cantidades a definir en ejecución de tarea',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            const SizedBox(height: 12),
            
            // Resumen por nombre de material
            ...groupedByName.entries.map((entry) {
              final materialName = entry.key;
              final materials = entry.value;
              final unit = materials.first.unit;
              
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
                  title: Text(materialName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Unidad: $unit'),
                      if (materials.length > 1)
                        Text(
                          '${materials.length} orígenes diferentes',
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                    ],
                  ),
                ),
              );
            }),
            
            // Lista detallada expandible con opciones de eliminación
            ExpansionTile(
              title: const Text(
                'Ver detalles por origen y eliminar materiales',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              children: _selectedMaterials.asMap().entries.map((entry) {
                final index = entry.key;
                final selectedMaterial = entry.value;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  color: selectedMaterial.isFromKit ? Colors.purple[50] : Colors.grey[50],
                  child: ListTile(
                    leading: Icon(
                      selectedMaterial.isFromKit ? Icons.assessment : Icons.inventory,
                      color: selectedMaterial.isFromKit ? Colors.purple : Colors.grey,
                    ),
                    title: Text(
                      selectedMaterial.materialName,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: selectedMaterial.isFromKit
                        ? Text(
                            'Kit: ${selectedMaterial.kitName}',
                            style: const TextStyle(fontSize: 12, color: Colors.purple),
                          )
                        : const Text(
                            'Individual',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedMaterial.unit,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: selectedMaterial.isFromKit ? Colors.red[700] : Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _removeMaterial(index),
                          tooltip: selectedMaterial.isFromKit 
                              ? 'Remover material del kit (requiere observación)' 
                              : 'Remover material',
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            // Mensaje informativo sobre eliminación de kits
            if (_selectedMaterials.any((m) => m.isFromKit))
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[800], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ Al eliminar materiales de un kit, se solicitará una observación del motivo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Resumen
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total de materiales:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedMaterials.length} items',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Materiales únicos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${groupedByName.length} tipos',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Tarea'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final task = taskProvider.getTaskById(widget.taskId);
          
          if (task == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Tarea no encontrada',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header de la tarea
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información de la tarea
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getPriorityIcon(task.priority),
                                    color: _getPriorityColor(task.priority),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.location_on, task.address),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.access_time, '${task.estimatedHours} horas estimadas'),
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.description, task.description),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Materiales seleccionados
                      _buildSelectedMaterialsSection(),
                      
                      const SizedBox(height: 20),
                      
                      // Pestañas para seleccionar materiales
                      const Text(
                        'Seleccionar Materiales:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Theme.of(context).primaryColor,
                              tabs: const [
                                Tab(
                                  icon: Icon(Icons.inventory),
                                  text: 'Materiales',
                                ),
                                Tab(
                                  icon: Icon(Icons.assessment),
                                  text: 'Kits',
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 300,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Pestaña de materiales individuales
                                  MaterialListWidget(
                                    materials: _availableMaterials,
                                    onSelectMaterial: (material) {
                                      _addMaterial(material);
                                    },
                                  ),
                                  
                                  // Pestaña de kits
                                  KitListWidget(
                                    kits: _availableKits,
                                    onSelectKit: _addKit,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.report_problem, size: 24),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'REPORTAR PROBLEMA',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                    _showProblemDialog(context, taskProvider);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'CONFIRMAR MATERIALES Y COMENZAR',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedMaterials.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor selecciona al menos un material'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                    final currentTask = taskProvider.getTaskById(widget.taskId);
                    if (currentTask != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskExecutionScreen(
                            task: currentTask,
                            selectedMaterials: _selectedMaterials,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.error;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  void _showProblemDialog(BuildContext context, TaskProvider taskProvider) {
    _selectedProblemType = null;
    _problemController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reportar Problema'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tipo de problema:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildProblemChip('Material faltante', setState),
                      _buildProblemChip('Dirección incorrecta', setState),
                      _buildProblemChip('Equipo dañado', setState),
                      _buildProblemChip('Cliente no disponible', setState),
                      _buildProblemChip('Otro', setState),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _problemController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descripción detallada del problema',
                      border: OutlineInputBorder(),
                      hintText: 'Describe el problema en detalle...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedProblemType != null && _problemController.text.isEmpty)
                    const Text(
                      'Por favor describe el problema',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_selectedProblemType == null || _problemController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor selecciona el tipo de problema y describe la situación'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  taskProvider.reportProblem(
                    widget.taskId, 
                    _selectedProblemType!, 
                    _problemController.text
                  );
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Problema reportado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Reportar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProblemChip(String problem, Function setState) {
    return ChoiceChip(
      label: Text(problem),
      selected: _selectedProblemType == problem,
      onSelected: (selected) {
        setState(() {
          _selectedProblemType = selected ? problem : null;
        });
      },
    );
  }
}