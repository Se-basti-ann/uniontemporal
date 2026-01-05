// lib/services/background_sync_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

class BackgroundSyncService {
  static const String syncTask = "syncPendingDataTask";
  final String apiUrl = 'http://micol-apps.com.co:8094/WsMOAP_emcali/'; 

  // Inicializar el servicio de sincronización en segundo plano
  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    // Programar sincronización periódica (cada 15 minutos)
    Workmanager().registerPeriodicTask(
      "1",
      syncTask,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
    );
  }

  // Callback para el workmanager
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final service = BackgroundSyncService();
      await service.syncAllPendingData();
      return Future.value(true);
    });
  }

  // Sincronizar todos los datos pendientes
  Future<bool> syncAllPendingData() async {
    print('🔄 Iniciando sincronización en segundo plano...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Sincronizar ubicaciones
      final pendingLocations = prefs.getStringList('pending_locations') ?? [];
      for (var locationJson in pendingLocations) {
        final locationData = jsonDecode(locationJson);
        final success = await _uploadToServer('locations', locationData);
        if (success) {
          final taskId = locationData['taskId'];
          await _markLocationAsUploaded(taskId);
        }
      }
      
      // Sincronizar tareas
      final pendingTasks = prefs.getStringList('pending_tasks') ?? [];
      for (var taskJson in pendingTasks) {
        final taskData = jsonDecode(taskJson);
        final success = await _uploadToServer('tasks/complete', taskData);
        if (success) {
          await _removeTaskFromPending(taskJson);
        }
      }
      
      print('✅ Sincronización completada');
      return true;
    } catch (e) {
      print('❌ Error en sincronización: $e');
      return false;
    }
  }

  // Subir datos al servidor
  Future<bool> _uploadToServer(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error subiendo datos a $endpoint: $e');
      return false;
    }
  }

  // Marcar ubicación como subida
  Future<void> _markLocationAsUploaded(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_locations') ?? [];
    final updated = pending.where((json) {
      final data = jsonDecode(json);
      return data['taskId'] != taskId;
    }).toList();
    await prefs.setStringList('pending_locations', updated);
  }

  // Eliminar tarea de pendientes
  Future<void> _removeTaskFromPending(String taskJson) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_tasks') ?? [];
    final updated = pending.where((json) => json != taskJson).toList();
    await prefs.setStringList('pending_tasks', updated);
  }

  // Sincronizar manualmente (desde UI si es necesario)
  Future<bool> syncNow() async {
    return await syncAllPendingData();
  }
}