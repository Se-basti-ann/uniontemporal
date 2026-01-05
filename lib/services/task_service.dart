// services/task_service.dart
import '../models/material_item.dart';

import '../models/task.dart';


class TaskService {
  Future<List<Task>> fetchTasks() async {
    await Future.delayed(const Duration(seconds: 2));
    
    return [
      Task(
        id: '1',
        title: 'Reparación de Línea Eléctrica en Torre Norte',
        address: 'Av. Carrera 15 #123-45, Chapinero, Bogotá',
        status: 'pending',
        materials: [
          MaterialItem(id: '1', name: 'Cable UTP Cat6', quantity: 50, assignedQuantity: 50, unit: 'metros'),
          MaterialItem(id: '2', name: 'Conectores RJ45', quantity: 12, assignedQuantity: 12, unit: 'unidades'),
          MaterialItem(id: '3', name: 'Switch 24 Puertos', quantity: 1, assignedQuantity: 1, unit: 'unidad'),
        ],
        description: 'Reemplazo completo de cableado de red en el piso 15. Verificar conexiones existentes antes de proceder.',
        priority: 'high',
        estimatedHours: 4,
        latitude: 4.6500,
        longitude: -74.0618,
      ),
      Task(
        id: '2',
        title: 'Instalación de Antena 5G en Edificio Corporativo',
        address: 'Calle 93 #14-20, Piso 8, Bogotá',
        status: 'pending',
        materials: [
          MaterialItem(id: '4', name: 'Antena 5G Omnidireccional', quantity: 1, assignedQuantity: 1, unit: 'unidad'),
          MaterialItem(id: '5', name: 'Soporte Metálico', quantity: 1, assignedQuantity: 1, unit: 'unidad'),
          MaterialItem(id: '6', name: 'Cable Coaxial LMR-400', quantity: 20, assignedQuantity: 20, unit: 'metros'),
          MaterialItem(id: '7', name: 'Conectores N-Type', quantity: 4, assignedQuantity: 4, unit: 'unidades'),
        ],
        description: 'Instalación de nueva antena 5G en la azotea del edificio. Coordinar con el administrador del edificio para acceso.',
        priority: 'medium',
        estimatedHours: 6,
        latitude: 4.6768,
        longitude: -74.0482,
      ),
      Task(
        id: '3',
        title: 'Mantenimiento Preventivo Centro de Datos',
        address: 'Diagonal 127 #15-30, Fontibón, Bogotá',
        status: 'in_progress',
        materials: [
          MaterialItem(id: '8', name: 'Kit Limpieza Equipos', quantity: 1, assignedQuantity: 1, unit: 'kit'),
          MaterialItem(id: '9', name: 'Baterías UPS', quantity: 4, assignedQuantity: 4, unit: 'unidades'),
          MaterialItem(id: '10', name: 'Filtros Aire Acondicionado', quantity: 2, assignedQuantity: 2, unit: 'unidades'),
        ],
        description: 'Mantenimiento trimestral programado. Revisar todos los sistemas y reemplazar componentes según checklist.',
        priority: 'high',
        estimatedHours: 8,
        latitude: 4.6812,
        longitude: -74.1465,
      ),
      Task(
        id: '4',
        title: 'Revisión de Cableado Subterráneo',
        address: 'Av. Ciudad de Cali #23-45, Kennedy, Bogotá',
        status: 'pending',
        materials: [
          MaterialItem(id: '11', name: 'Cable Subterráneo 240mm²', quantity: 100, assignedQuantity: 100, unit: 'metros'),
          MaterialItem(id: '12', name: 'Conectores de Empalme', quantity: 8, assignedQuantity: 8, unit: 'unidades'),
          MaterialItem(id: '13', name: 'Aislante Termorretráctil', quantity: 15, assignedQuantity: 15, unit: 'unidades'),
        ],
        description: 'Revisión y reparación de cableado subterráneo en el sector de Kennedy. Verificar humedad en conductos.',
        priority: 'high',
        estimatedHours: 5,
        latitude: 4.6097,
        longitude: -74.1465,
      ),
      Task(
        id: '5',
        title: 'Actualización de Sistema de Iluminación',
        address: 'Carrera 7 #40-62, La Candelaria, Bogotá',
        status: 'in_progress',
        materials: [
          MaterialItem(id: '14', name: 'Lámparas LED 50W', quantity: 24, assignedQuantity: 24, unit: 'unidades'),
          MaterialItem(id: '15', name: 'Balastos Electrónicos', quantity: 24, assignedQuantity: 24, unit: 'unidades'),
          MaterialItem(id: '16', name: 'Cable THHN 12 AWG', quantity: 150, assignedQuantity: 150, unit: 'metros'),
        ],
        description: 'Actualización de sistema de iluminación a tecnología LED en edificio histórico. Respetar normativa de conservación.',
        priority: 'medium',
        estimatedHours: 3,
        latitude: 4.5981,
        longitude: -74.0760,
      ),
    ];
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Tarea $taskId actualizada a estado: $status');
  }

  Future<void> reportProblem(String taskId, String problem, String description) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Problema reportado en tarea $taskId: $problem - $description');
  }
}