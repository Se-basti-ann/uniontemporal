// providers/supervisor_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/connected_operator.dart';
import '../services/location_service.dart';

class SupervisorProvider with ChangeNotifier {
  final List<Task> _allTasks = [];
  final List<ConnectedOperator> _connectedOperators = [];
  bool _isLoading = false;
  StreamSubscription<GPSData>? _locationSubscription;
  StreamSubscription? _operatorsSubscription;

  List<Task> get allTasks => _allTasks;
  List<ConnectedOperator> get connectedOperators => _connectedOperators;
  bool get isLoading => _isLoading;

  // Método para cargar datos de ejemplo con ubicaciones en Bogotá
  void loadMockData() {
    _isLoading = true;
    notifyListeners();

    // Tareas con ubicaciones en Bogotá
    _allTasks.clear();
    _allTasks.addAll([
      Task(
        id: '1',
        title: 'Reparación de Línea Eléctrica en Torre Norte',
        address: 'Av. Carrera 15 #123-45, Chapinero, Bogotá',
        status: 'pending',
        materials: [],
        latitude: 4.6500, // Coordenadas aproximadas de Chapinero
        longitude: -74.0618,
        priority: 'high',
        estimatedHours: 4,
        assignedOperatorId: 'op1',
      ),
      Task(
        id: '2',
        title: 'Instalación de Antena 5G en Edificio Corporativo',
        address: 'Calle 93 #14-20, Piso 8, Bogotá',
        status: 'in_progress',
        materials: [],
        latitude: 4.6768, // Zona de negocios al norte de Bogotá
        longitude: -74.0482,
        priority: 'medium',
        estimatedHours: 6,
        assignedOperatorId: 'op2',
      ),
      Task(
        id: '3',
        title: 'Mantenimiento Preventivo Centro de Datos',
        address: 'Diagonal 127 #15-30, Fontibón, Bogotá',
        status: 'completed',
        materials: [],
        latitude: 4.6812, // Fontibón
        longitude: -74.1465,
        priority: 'low',
        estimatedHours: 8,
        assignedOperatorId: 'op3',
      ),
      Task(
        id: '4',
        title: 'Revisión de Cableado Subterráneo',
        address: 'Av. Ciudad de Cali #23-45, Kennedy, Bogotá',
        status: 'pending',
        materials: [],
        latitude: 4.6097, // Kennedy
        longitude: -74.1465,
        priority: 'high',
        estimatedHours: 5,
        assignedOperatorId: 'op4',
      ),
      Task(
        id: '5',
        title: 'Actualización de Sistema de Iluminación',
        address: 'Carrera 7 #40-62, La Candelaria, Bogotá',
        status: 'in_progress',
        materials: [],
        latitude: 4.5981, // Centro histórico
        longitude: -74.0760,
        priority: 'medium',
        estimatedHours: 3,
        assignedOperatorId: 'op1',
      ),
      Task(
        id: '6',
        title: 'Instalación de Paneles Solares',
        address: 'Transversal 23 #45-67, Usaquén, Bogotá',
        status: 'pending',
        materials: [],
        latitude: 4.6942, // Usaquén
        longitude: -74.0306,
        priority: 'low',
        estimatedHours: 7,
      ),
    ]);

    // Operarios conectados con ubicaciones en Bogotá
    _connectedOperators.clear();
    _connectedOperators.addAll([
      ConnectedOperator(
        id: 'op1',
        name: 'Juan Pérez',
        email: 'juan@empresa.com',
        latitude: 4.6520, // Cerca de la tarea 1
        longitude: -74.0600,
        lastSeen: DateTime.now(),
        isActive: true,
        currentTaskId: '1',
        batteryLevel: 0.85,
        accuracy: 15.5,
      ),
      ConnectedOperator(
        id: 'op2',
        name: 'María Gómez',
        email: 'maria@empresa.com',
        latitude: 4.6780, // Cerca de la tarea 2
        longitude: -74.0470,
        lastSeen: DateTime.now(),
        isActive: true,
        currentTaskId: '2',
        batteryLevel: 0.65,
        accuracy: 8.2,
      ),
      ConnectedOperator(
        id: 'op3',
        name: 'Carlos López',
        email: 'carlos@empresa.com',
        latitude: 4.6820, // Cerca de la tarea 3
        longitude: -74.1450,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        isActive: false,
        currentTaskId: '3',
        batteryLevel: 0.45,
        accuracy: 25.0,
      ),
      ConnectedOperator(
        id: 'op4',
        name: 'Ana Rodríguez',
        email: 'ana@empresa.com',
        latitude: 4.6100, // Cerca de la tarea 4
        longitude: -74.1450,
        lastSeen: DateTime.now(),
        isActive: true,
        currentTaskId: '4',
        batteryLevel: 0.90,
        accuracy: 12.0,
      ),
      ConnectedOperator(
        id: 'op5',
        name: 'Pedro Martínez',
        email: 'pedro@empresa.com',
        latitude: 4.6950, // Usaquén, sin tarea asignada
        longitude: -74.0310,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
        isActive: true,
        batteryLevel: 0.70,
        accuracy: 18.0,
      ),
    ]);

    Future.delayed(const Duration(seconds: 1), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  // Simular actualización en tiempo real de ubicaciones de operarios
  void startRealTimeUpdates() {
    // Simular movimiento de operarios
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_connectedOperators.isNotEmpty) {
        for (int i = 0; i < _connectedOperators.length; i++) {
          var op = _connectedOperators[i];
          if (op.isActive) {
            // Mover ligeramente la ubicación (simulación)
            double lat = op.latitude + (0.0001 * (i + 1));
            double lon = op.longitude + (0.0001 * (i + 1));
            
            _connectedOperators[i] = op.copyWith(
              latitude: lat,
              longitude: lon,
              lastSeen: DateTime.now(),
            );
          }
        }
        notifyListeners();
      }
    });
  }

  // Actualizar ubicación de un operario
  void updateOperatorLocation(String operatorId, double lat, double lon, double accuracy) {
    final index = _connectedOperators.indexWhere((op) => op.id == operatorId);
    if (index != -1) {
      _connectedOperators[index] = _connectedOperators[index].copyWith(
        latitude: lat,
        longitude: lon,
        lastSeen: DateTime.now(),
        accuracy: accuracy,
      );
      notifyListeners();
    }
  }

  // Actualizar estado de una tarea
  void updateTaskStatus(String taskId, String newStatus) {
    final index = _allTasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _allTasks[index] = _allTasks[index].copyWith(status: newStatus, locationData: {});
      notifyListeners();
    }
  }

  // Asignar operario a tarea
  void assignOperatorToTask(String taskId, String operatorId) {
    final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
    final operatorIndex = _connectedOperators.indexWhere((op) => op.id == operatorId);
    
    if (taskIndex != -1 && operatorIndex != -1) {
      _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(
        assignedOperatorId: operatorId, locationData: {},
      );
      
      _connectedOperators[operatorIndex] = _connectedOperators[operatorIndex].copyWith(
        currentTaskId: taskId,
      );
      
      notifyListeners();
    }
  }

  // Obtener tarea por ID
  Task? getTaskById(String taskId) {
    try {
      return _allTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Obtener operario por ID
  ConnectedOperator? getOperatorById(String operatorId) {
    try {
      return _connectedOperators.firstWhere((op) => op.id == operatorId);
    } catch (e) {
      return null;
    }
  }

  // Filtrar tareas por estado
  List<Task> getTasksByStatus(String status) {
    return _allTasks.where((task) => task.status == status).toList();
  }

  // Filtrar operarios activos
  List<ConnectedOperator> getActiveOperators() {
    return _connectedOperators.where((op) => op.isActive).toList();
  }

  // Obtener tareas asignadas a un operario
  List<Task> getTasksByOperator(String operatorId) {
    return _allTasks.where((task) => task.assignedOperatorId == operatorId).toList();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _operatorsSubscription?.cancel();
    super.dispose();
  }
}