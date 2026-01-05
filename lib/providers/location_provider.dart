import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  GPSData? _bestPosition;
  bool _isCapturing = false;
  bool _hasPermission = false;
  String? _currentTaskId;

  GPSData? get bestPosition => _bestPosition;
  bool get isCapturing => _isCapturing;
  bool get hasPermission => _hasPermission;

  Future<void> initializeLocation() async {
    try {
      _hasPermission = await _locationService.checkPermission();
      notifyListeners();
    } catch (e) {
      print('Error al inicializar ubicación: $e');
    }
  }

  // Iniciar captura automática silenciosa
  Future<void> startAutomaticCapture({required String taskId, int sampleSize = 15}) async {
    if (!_hasPermission) {
      await initializeLocation();
      if (!_hasPermission) {
        print('Permisos de ubicación no concedidos');
        return;
      }
    }

    _currentTaskId = taskId;
    _isCapturing = true;
    
    print('📍 Iniciando captura GPS automática para tarea: $taskId');
    
    // Iniciar captura en segundo plano sin bloquear la UI
    _captureInBackground(sampleSize: sampleSize);
  }

  // Captura en segundo plano
  Future<void> _captureInBackground({int sampleSize = 15}) async {
    try {
      print('📡 Capturando mejor posición en segundo plano...');
      
      final bestLocation = await _locationService.getBestLocation(
        sampleSize: sampleSize,
      );

      if (bestLocation != null) {
        _bestPosition = bestLocation;
        print('✅ Mejor posición capturada: ${bestLocation.latitude}, ${bestLocation.longitude}');
        
        // Guardar automáticamente en almacenamiento local
        await _saveLocationToStorage(bestLocation);
      } else {
        print('⚠️ No se pudo capturar una ubicación válida');
      }
    } catch (e) {
      print('❌ Error en captura de fondo: $e');
    } finally {
      _isCapturing = false;
    }
  }

  // Finalizar captura y guardar datos
  Future<GPSData?> finishTaskAndSaveLocation() async {
    print('🏁 Finalizando captura GPS para tarea: $_currentTaskId');
    
    // Si no tenemos una mejor posición, intentar una captura rápida
    if (_bestPosition == null && _hasPermission) {
      print('🔄 Realizando captura final rápida...');
      try {
        final finalLocation = await _locationService.getBestLocation(
          sampleSize: 5, // Menos muestras para ser rápido
        );
        if (finalLocation != null) {
          _bestPosition = finalLocation;
          await _saveLocationToStorage(finalLocation);
        }
      } catch (e) {
        print('⚠️ Error en captura final: $e');
      }
    }
    
    // Retornar la mejor posición capturada
    return _bestPosition;
  }

  // Guardar ubicación en almacenamiento local
  Future<void> _saveLocationToStorage(GPSData location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = {
        'taskId': _currentTaskId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'altitude': location.altitude,
        'speed': location.speed,
        'pdop': location.pdop,
        'hdop': location.hdop,
        'vdop': location.vdop,
        'timestamp': location.timestamp.toIso8601String(),
        'qualityScore': location.qualityScore,
      };
      
      // Guardar en SharedPreferences
      await prefs.setString('best_location_$_currentTaskId', jsonEncode(locationData));
      
      // También guardar en lista de ubicaciones pendientes por subir
      final pendingLocations = prefs.getStringList('pending_locations') ?? [];
      pendingLocations.add(jsonEncode(locationData));
      await prefs.setStringList('pending_locations', pendingLocations);
      
      print('💾 Ubicación guardada para tarea $_currentTaskId');
    } catch (e) {
      print('❌ Error al guardar ubicación: $e');
    }
  }

  // Obtener ubicación guardada por taskId
  Future<GPSData?> getSavedLocation(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString('best_location_$taskId');
      if (locationJson != null) {
        final locationData = jsonDecode(locationJson);
        return GPSData(
          latitude: locationData['latitude'],
          longitude: locationData['longitude'],
          accuracy: locationData['accuracy'],
          altitude: locationData['altitude'],
          speed: locationData['speed'],
          pdop: locationData['pdop'],
          hdop: locationData['hdop'],
          vdop: locationData['vdop'],
          timestamp: DateTime.parse(locationData['timestamp']),
        );
      }
    } catch (e) {
      print('❌ Error al obtener ubicación guardada: $e');
    }
    return null;
  }

  // Obtener todas las ubicaciones pendientes de subir
  Future<List<Map<String, dynamic>>> getPendingLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList('pending_locations') ?? [];
      return pending.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error al obtener ubicaciones pendientes: $e');
      return [];
    }
  }

  // Marcar ubicación como subida
  Future<void> markLocationAsUploaded(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Eliminar de pendientes
      final pending = prefs.getStringList('pending_locations') ?? [];
      final updatedPending = pending.where((json) {
        final data = jsonDecode(json);
        return data['taskId'] != taskId;
      }).toList();
      await prefs.setStringList('pending_locations', updatedPending);
      
      print('✅ Ubicación marcada como subida para tarea $taskId');
    } catch (e) {
      print('❌ Error al marcar ubicación como subida: $e');
    }
  }

  void clearLocationData() {
    _bestPosition = null;
    _currentTaskId = null;
  }
}