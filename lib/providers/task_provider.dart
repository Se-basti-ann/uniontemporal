import 'package:flutter/material.dart';
import 'package:uniontemporal/models/material_item.dart';
import 'package:uniontemporal/models/selected_material.dart';
import 'package:uniontemporal/providers/location_provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.fetchTasks();
    } catch (e) {
      _error = 'Error al cargar las tareas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final List<SelectedMaterial> _selectedMaterials = [];

  List<SelectedMaterial> get selectedMaterials => _selectedMaterials;

  void addSelectedMaterial(MaterialItem material, {String? kitId, String? kitName}) {
    _selectedMaterials.add(SelectedMaterial(
      //material: material, 
      kitId: kitId,
      kitName: kitName,
      isFromKit: kitId != null, materialId: '', materialName: '', unit: '',
      ));
      notifyListeners();
  }

  void removeSelectedMaterial(int index) {
    _selectedMaterials.removeAt(index);
    notifyListeners();
  }

  void clearSelectedMaterials() {
    _selectedMaterials.clear();
    notifyListeners();
  }

  Future<void> startTaskWithLocation(String taskId) async {
    final locationProvider = LocationProvider(); // Obtener de donde corresponda
    await locationProvider.startAutomaticCapture(taskId: taskId);

    // Actualizar estado de la tarea
    updateTaskStatus(taskId, 'in_progress');
  }

  Future<void> completeTaskWithLocation(String taskId) async {
    final locationProvider = LocationProvider(); // Obtener de donde corresponda

    // Finalizar y obtener ubicación
    final bestLocation = await locationProvider.finishTaskAndSaveLocation();

    // Actualizar tarea con datos de ubicación
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1 && bestLocation != null) {
      final locationData = {
        'latitude': bestLocation.latitude,
        'longitude': bestLocation.longitude,
        'accuracy': bestLocation.accuracy,
        'timestamp': bestLocation.timestamp.toIso8601String(),
      };
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(locationData: locationData);
      notifyListeners();
    }

    updateTaskStatus(taskId, 'completed');
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(status: status, locationData: {});
      notifyListeners();

      // En una implementación real, aquí enviarías los cambios al servidor
      await _taskService.updateTaskStatus(taskId, status);
    }
  }

  Future<void> reportProblem(
      String taskId, String problemType, String description) async {
    // Simular reporte de problema
    await Future.delayed(const Duration(seconds: 1));
    print('Problema reportado en tarea $taskId: $problemType - $description');

    // Actualizar estado de la tarea
    updateTaskStatus(taskId, 'problem: $problemType');
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }
}
