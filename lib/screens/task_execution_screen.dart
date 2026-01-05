import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/selected_material.dart';
import '../models/task.dart';
import '../providers/location_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/photo_capture.dart';

class TaskExecutionScreen extends StatefulWidget {
  final Task task;
  final List<SelectedMaterial> selectedMaterials;

  const TaskExecutionScreen(
      {super.key, required this.task, required this.selectedMaterials});

  @override
  _TaskExecutionScreenState createState() => _TaskExecutionScreenState();
}

class _TaskExecutionScreenState extends State<TaskExecutionScreen> {
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _observationControllers = {};
  final Map<String, bool> _materialNotUsed = {};
  final Map<String, int> _availableQuantities = {};

  String? _selectedWorkType;
  final TextEditingController _customWorkTypeController =
      TextEditingController();
  final List<String> _predefinedWorkTypes = [
    'Instalación Eléctrica',
    'Mantenimiento Preventivo',
    'Reparación de Red',
    'Sustitución de Equipos',
    'Pruebas y Verificación',
    'Configuración de Sistema',
    'Inspección de Seguridad',
    'Otro'
  ];
  bool _showCustomWorkTypeField = false;

  bool _arrivalPhotoTaken = false;
  bool _completionPhotoTaken = false;
  bool _materialsConfirmed = false;
  File? _arrivalPhoto;
  File? _completionPhoto;

  final TextEditingController _companionOperatorsController =
      TextEditingController();
  final TextEditingController _vehiclePlateController = TextEditingController();
  bool _showCompanionField = false;

  // Mapa para agrupar materiales por nombre
  final Map<String, MaterialGroup> _groupedMaterials = {};

  @override
  void initState() {
    super.initState();

    _initializeAvailableQuantities();

    _groupMaterials();

    _showCustomWorkTypeField = false;

    _companionOperatorsController.addListener(() {
      setState(() {});
    });

    _vehiclePlateController.addListener(() {
      setState(() {});
    });

    for (var group in _groupedMaterials.values) {
      _quantityControllers[group.name] = TextEditingController();
      _observationControllers[group.name] = TextEditingController();
      _materialNotUsed[group.name] = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Inicializar ubicación automáticamente en segundo plano
      Provider.of<LocationProvider>(context, listen: false)
          .initializeLocation();
    });
  }

  void _initializeAvailableQuantities() {
    // En producción, estas cantidades vendrían de tu API/backend
    _availableQuantities['Cable UTP Cat6'] = 100;
    _availableQuantities['Conector RJ45'] = 50;
    _availableQuantities['Router WiFi'] = 10;
    _availableQuantities['Switch 8 puertos'] = 5;
    _availableQuantities['Patch Panel'] = 8;
  }

  void _groupMaterials() {
    _groupedMaterials.clear();

    for (var selectedMaterial in widget.selectedMaterials) {
      final materialName = selectedMaterial.materialName;
      final unit = selectedMaterial.unit;
      final availableQuantity = _availableQuantities[materialName] ?? 0;

      if (!_groupedMaterials.containsKey(materialName)) {
        _groupedMaterials[materialName] = MaterialGroup(
          name: materialName,
          unit: unit,
          availableQuantity: availableQuantity,
          origins: [],
        );
      }

      // Agregar el origen
      _groupedMaterials[materialName]!.origins.add(
            MaterialOrigin(
              name: selectedMaterial.materialName,
              unit: unit,
              isFromKit: selectedMaterial.isFromKit,
              kitName: selectedMaterial.kitName,
              materialId: selectedMaterial.materialId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejecutar Tarea'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la tarea
            _buildTaskInfoCard(),

            const SizedBox(height: 20),

            _buildOperatorAndVehicleSection(),

            const SizedBox(height: 20),

            _buildWorkTypeSection(),

            const SizedBox(height: 20),
            // Detalles de materiales agrupados
            if (_groupedMaterials.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Materiales seleccionados:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total de materiales: ${_groupedMaterials.length} tipos',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  ..._groupedMaterials.values
                      .map((group) => _buildMaterialGroupCard(group)),
                  const SizedBox(height: 20),
                ],
              ),

            // Confirmación de materiales
            if (!_materialsConfirmed) _buildMaterialsConfirmationSection(),

            if (_materialsConfirmed) ...[
              PhotoCapture(
                onArrivalPhotoTaken: (file) {
                  setState(() {
                    _arrivalPhoto = file;
                    _arrivalPhotoTaken = true;
                  });
                },
                onCompletionPhotoTaken: (file) {
                  setState(() {
                    _completionPhoto = file;
                    _completionPhotoTaken = true;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Definición de cantidades utilizadas
              _buildMaterialsQuantitySection(),
            ],
          ],
        ),
      ),
      // Botones fijos en la parte inferior con padding seguro
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildWorkTypeSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Trabajo Realizado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona el tipo de trabajo que estás ejecutando en esta tarea:',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedWorkType,
              decoration: InputDecoration(
                labelText: 'Tipo de trabajo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _predefinedWorkTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWorkType = newValue;
                  _showCustomWorkTypeField = (newValue == 'Otro');
                  if (!_showCustomWorkTypeField) {
                    _customWorkTypeController.clear();
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona un tipo de trabajo';
                }
                return null;
              },
            ),
            if (_showCustomWorkTypeField) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customWorkTypeController,
                decoration: InputDecoration(
                  labelText: 'Especificar tipo de trabajo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.orange[50],
                  hintText:
                      'Ej: Actualización de firmware, Cableado estructurado, etc.',
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedWorkType = value.isNotEmpty ? value : 'Otro';
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Este tipo de trabajo personalizado se guardará para referencia futura.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                ),
              ),
            ],

            /* const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.blue[800], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📝 Información del operario en campo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Esta información ayuda a categorizar el trabajo real realizado y mejora el seguimiento de actividades. El operario es quien mejor conoce el trabajo específico ejecutado en campo.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ), */
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorAndVehicleSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Operario en campo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'Completa esta informacion para el registro',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                '¿Que otros operarios lo acompañan?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 8,
              ),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Solo'),
                    selected: !_showCompanionField,
                    onSelected: (selected) {
                      setState(() {
                        _showCompanionField = !selected;
                        if (!_showCompanionField) {
                          _companionOperatorsController.clear();
                        }
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Con acompañantes'),
                    selected: _showCompanionField,
                    onSelected: (selected) {
                      setState(() {
                        _showCompanionField = selected;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              if (_showCompanionField)
                TextField(
                  controller: _companionOperatorsController,
                  decoration: InputDecoration(
                      labelText: 'Nombres de operarios acompañantes',
                      border: const OutlineInputBorder(),
                      hintText: 'Ej: Juan Perez',
                      filled: true,
                      fillColor: Colors.blue[50],
                      suffixIcon: _companionOperatorsController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _companionOperatorsController.clear();
                              },
                            )
                          : null),
                  maxLines: 2,
                ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Placa del vehiculo de movilazación',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: _vehiclePlateController,
                decoration: InputDecoration(
                  labelText: 'Placa del vehículo',
                  border: const OutlineInputBorder(),
                  hintText: 'Ej: ABC123 o ABC-123',
                  filled: true,
                  fillColor: Colors.green[50],
                  prefixIcon: const Icon(Icons.directions_car),
                  suffixIcon: _vehiclePlateController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _vehiclePlateController.clear();
                          },
                          icon: const Icon(Icons.clear))
                      : null,
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  setState(() {
                    //Validacion de placa en BD
                  });
                },
              ),
            ],
          )),
    );
  }

  Widget _buildBottomButtons() {
    if (!_materialsConfirmed) {
      return SafeArea(
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'CONFIRMAR Y COMENZAR TAREA',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 244, 245, 247),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _confirmAndStartTask,
            ),
          ),
        ),
      );
    }

    return SafeArea(
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
                icon: const Icon(Icons.check_circle, size: 24),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'FINALIZAR TAREA',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 243, 243, 243),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _validateAndComplete,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa todos los campos antes de finalizar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.address,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.task.estimatedHours} horas estimadas',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialGroupCard(MaterialGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Disponible: ${group.availableQuantity} ${group.unit}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Unidad: ${group.unit}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (group.origins.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${group.origins.length} orígenes diferentes',
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ),
            // Detalles de orígenes (colapsable)
            if (group.origins.length > 1)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Ver detalles por origen',
                  style: TextStyle(fontSize: 12),
                ),
                children: group.origins.map((origin) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          origin.isFromKit ? Icons.assessment : Icons.inventory,
                          size: 12,
                          color: origin.isFromKit ? Colors.purple : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            origin.isFromKit
                                ? 'Kit ${origin.kitName}'
                                : 'Individual',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsConfirmationSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmación de Materiales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Revisa los materiales seleccionados antes de comenzar. Las cantidades utilizadas se definirán al finalizar la tarea.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ..._groupedMaterials.values.map((group) => ListTile(
                  title: Text(group.name),
                  subtitle: Text(
                      'Disponible: ${group.availableQuantity} ${group.unit}'),
                  leading: const Icon(Icons.inventory),
                )),
            const SizedBox(height: 20),
            // Nota: El botón se movió al bottomNavigationBar
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Definir Cantidades Utilizadas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Indica la cantidad real utilizada de cada material:',
          style: TextStyle(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        ..._groupedMaterials.values
            .map((group) => _buildMaterialQuantityCard(group)),
      ],
    );
  }

  Widget _buildMaterialQuantityCard(MaterialGroup group) {
    final hasError = _hasMaterialError(group);
    final isNotUsed = _materialNotUsed[group.name]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: hasError && !isNotUsed
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Disponible: ${group.availableQuantity} ${group.unit}',
                  style: TextStyle(
                    color: isNotUsed ? Colors.grey : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Campo para cantidad utilizada (solo visible si no está marcado como "No usado")
            if (!isNotUsed)
              TextField(
                controller: _quantityControllers[group.name],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad utilizada',
                  border: const OutlineInputBorder(),
                  suffixText: group.unit,
                  errorText: hasError ? 'Cantidad inválida' : null,
                  hintText: 'Ej: 10',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  // Validar en tiempo real
                  setState(() {});
                },
              ),

            const SizedBox(height: 12),

            // Checkbox para "No usado"
            Row(
              children: [
                Checkbox(
                  value: isNotUsed,
                  onChanged: (selected) {
                    setState(() {
                      _materialNotUsed[group.name] = selected ?? false;
                      if (selected == true) {
                        // Limpiar campo de cantidad si se marca como no usado
                        _quantityControllers[group.name]!.clear();
                      }
                    });
                  },
                ),
                const Text('No se utilizó este material'),
              ],
            ),

            // Campo de observación solo visible si está marcado como "No usado"
            if (isNotUsed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Explica por qué no se utilizó este material:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _observationControllers[group.name],
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Observación',
                      border: const OutlineInputBorder(),
                      hintText:
                          'Ej: Material dañado, no era necesario, cliente ya tenía, etc.',
                      filled: true,
                      fillColor: Colors.orange[50],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Esta observación será registrada junto con el material no utilizado.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),

            if (group.origins.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ Este material tiene ${group.origins.length} orígenes diferentes',
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasMaterialError(MaterialGroup group) {
    final controller = _quantityControllers[group.name];
    if (controller == null) return false;

    if (_materialNotUsed[group.name]!) return false;

    if (controller.text.isEmpty) return false;

    final used = int.tryParse(controller.text) ?? 0;
    return used < 0 || used > group.availableQuantity;
  }

  void _confirmAndStartTask() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Iniciar captura GPS automática en segundo plano sin mostrar UI
    await locationProvider.startAutomaticCapture(
      taskId: widget.task.id,
      sampleSize: 15,
    );

    setState(() {
      _materialsConfirmed = true;
    });

    // Actualizar estado de la tarea
    Provider.of<TaskProvider>(context, listen: false)
        .updateTaskStatus(widget.task.id, 'in_progress');
  }

  void _validateAndComplete() {
    if (_vehiclePlateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes ingresar la placa del vehículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_showCompanionField && _companionOperatorsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Debes ingresar los nombres de los operarios acompañantes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Validar fotos
    if (!_arrivalPhotoTaken || !_completionPhotoTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes tomar ambas fotos (llegada y finalización)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final workType = _getActualWorkType();
    if (workType == null || workType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un tipo de trabajo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Validar materiales
    bool hasMaterialErrors = false;
    List<String> materialErrors = [];

    for (var group in _groupedMaterials.values) {
      if (_materialNotUsed[group.name]!) {
        // Validar que tenga observación si no se usó
        final observation =
            _observationControllers[group.name]?.text.trim() ?? '';
        if (observation.isEmpty) {
          hasMaterialErrors = true;
          materialErrors
              .add('${group.name}: debe explicar por qué no se utilizó');
        }
        continue;
      }

      // Validar materiales que sí se usaron
      final controller = _quantityControllers[group.name];
      if (controller == null || controller.text.isEmpty) {
        hasMaterialErrors = true;
        materialErrors.add('${group.name}: cantidad no especificada');
        continue;
      }

      final used = int.tryParse(controller.text) ?? 0;
      if (used <= 0) {
        hasMaterialErrors = true;
        materialErrors.add('${group.name}: cantidad debe ser mayor a 0');
      } else if (used > group.availableQuantity) {
        hasMaterialErrors = true;
        materialErrors.add(
            '${group.name}: no puede exceder ${group.availableQuantity} ${group.unit}');
      }
    }

    if (hasMaterialErrors) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Errores en Materiales'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children:
                  materialErrors.map((error) => Text('• $error')).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Corregir'),
            ),
          ],
        ),
      );
      return;
    }

    // Mostrar resumen y confirmar
    _showCompletionSummary();
  }

  void _showCompletionSummary() {
    final workType = _getActualWorkType();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen de Finalización'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Confirmas que has completado la tarea?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('👥 Operarios:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  '• ${_showCompanionField ? _companionOperatorsController.text.trim() : 'Operario trabajando solo'}'),
              const SizedBox(height: 12),
              const Text('🚗 Vehículo:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Placa: ${_vehiclePlateController.text.trim()}'),
              const SizedBox(height: 16),
              const Text(
                '📸 Fotos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '• Llegada: ${_arrivalPhotoTaken ? 'Capturada' : 'Pendiente'}'),
              Text(
                  '• Finalización: ${_completionPhotoTaken ? 'Capturada' : 'Pendiente'}'),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              const Text('🔧 Tipo de trabajo:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• ${workType ?? ''}'),
/*               const Text(
                '📍 Ubicación GPS:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Capturada automáticamente (almacenada localmente)'), */
              const SizedBox(height: 12),
              const Text(
                '📦 Materiales utilizados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._groupedMaterials.values.map((group) {
                if (_materialNotUsed[group.name]!) {
                  final observation =
                      _observationControllers[group.name]?.text.trim() ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${group.name}: NO UTILIZADO'),
                        if (observation.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 2),
                            child: Text(
                              'Observación: $observation',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  final used = _quantityControllers[group.name]!.text;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Text(
                        '• ${group.name}: $used ${group.unit} de ${group.availableQuantity} disponibles'),
                  );
                }
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Revisar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTask();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirmar Finalización'),
          ),
        ],
      ),
    );
  }

  String? _getActualWorkType() {
    if (_selectedWorkType == 'Otro') {
      return _customWorkTypeController.text.trim().isNotEmpty
          ? _customWorkTypeController.text.trim()
          : null;
    }
    return _selectedWorkType;
  }

  Future<void> _completeTask() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Finalizar captura GPS y obtener mejor ubicación
    final bestLocation = await locationProvider.finishTaskAndSaveLocation();

    // Actualizar estado de la tarea
    taskProvider.updateTaskStatus(widget.task.id, 'completed');

    final workType = _getActualWorkType();
    // Preparar datos para enviar al servidor
    final taskData = {
      'taskId': widget.task.id,
      'status': 'completed',
      'workType': workType,
      'workTypeCustom': _selectedWorkType == 'Otro' ? 'custom' : 'predefined',
      'operatorInfo': {
        'companions': _showCompanionField
            ? _companionOperatorsController.text.trim()
            : 'Solo',
        'vehiclePlate': _vehiclePlateController.text.trim(),
        'isSolo': !_showCompanionField,
      },
      'materials': _groupedMaterials.values.map((group) {
        final isNotUsed = _materialNotUsed[group.name]!;
        return {
          'name': group.name,
          'unit': group.unit,
          'availableQuantity': group.availableQuantity,
          'usedQuantity': isNotUsed
              ? 0
              : int.tryParse(_quantityControllers[group.name]!.text) ?? 0,
          'notUsed': isNotUsed,
          'observation': isNotUsed
              ? _observationControllers[group.name]?.text.trim()
              : null,
          'origins': group.origins
              .map((origin) => ({
                    'materialId': origin.materialId,
                    'fromKit': origin.isFromKit,
                    'kitName': origin.kitName,
                  }))
              .toList(),
        };
      }).toList(),
      'photos': {
        'arrival': _arrivalPhotoTaken,
        'completion': _completionPhotoTaken,
      },
      'location': bestLocation != null
          ? {
              'latitude': bestLocation.latitude,
              'longitude': bestLocation.longitude,
              'accuracy': bestLocation.accuracy,
              'timestamp': bestLocation.timestamp.toIso8601String(),
            }
          : null,
    };

    // Guardar datos localmente para enviar más tarde
    await _saveTaskDataLocally(taskData);

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Tarea completada exitosamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Regresar a la pantalla anterior
    Navigator.pop(context);
  }

  Future<void> _saveTaskDataLocally(Map<String, dynamic> taskData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingTasks = prefs.getStringList('pending_tasks') ?? [];
      pendingTasks.add(jsonEncode(taskData));
      await prefs.setStringList('pending_tasks', pendingTasks);
    } catch (e) {
      print('Error al guardar datos de tarea: $e');
    }
  }

  @override
  void dispose() {
    _quantityControllers.forEach((key, controller) {
      controller.dispose();
    });
    _observationControllers.forEach((key, controller) {
      controller.dispose();
    });
    _customWorkTypeController.dispose();
    _companionOperatorsController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }
}

// Clases auxiliares para agrupar materiales
class MaterialGroup {
  final String name;
  final String unit;
  final int availableQuantity;
  List<MaterialOrigin> origins;

  MaterialGroup({
    required this.name,
    required this.unit,
    required this.availableQuantity,
    required this.origins,
  });
}

class MaterialOrigin {
  final String name;
  final String unit;
  final bool isFromKit;
  final String? kitName;
  final String materialId;

  MaterialOrigin({
    required this.name,
    required this.unit,
    required this.isFromKit,
    this.kitName,
    required this.materialId,
  });
}
