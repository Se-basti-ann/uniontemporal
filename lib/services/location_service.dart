//lib/services/location_service.dart
import 'package:location/location.dart';

class GPSData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final double? pdop;
  final double? hdop;
  final double? vdop;
  final DateTime timestamp;

  GPSData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.pdop,
    this.hdop,
    this.vdop,
    required this.timestamp,
  });

  double get qualityScore {
    double score = 0.0;

    if (pdop != null) score += 1.0 / pdop!;
    if (hdop != null) score += 1.0 / hdop!;
    if (vdop != null) score += 1.0 / vdop!;

    score += 1.0 / (accuracy > 0 ? accuracy : 1.0);

    return score;
  }

  @override
  String toString() {
    return 'GPSData(lat: $latitude, lon: $longitude, accuracy: ${accuracy.toStringAsFixed(2)}m, pdop: $hdop, vdop: $vdop, quality: ${qualityScore.toStringAsFixed(2)})';
  }
}

class LocationService {
  final Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;

  static const int defaultSampleSize = 10;
  static const int sampleIntervalMs = 1000;
  static const int maxWaitTimeMs = 30000;

  Future<bool> checkPermission() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return _permissionGranted == PermissionStatus.granted;
  }

  Future<GPSData?> getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      return _convertToGPSData(locationData);
    } catch (e) {
      print('Error obteniendo ubicacion: $e');
      return null;
    }
  }

  Future<GPSData?> getBestLocation({
    int sampleSize = defaultSampleSize,
    int intervalMs = sampleIntervalMs,
    int maxWaitTime = maxWaitTimeMs,
  }) async {
    if (!await checkPermission()) {
      return null;
    }

    final List<GPSData> samples = [];
    final startTime = DateTime.now();

    try {
      _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: intervalMs,
        distanceFilter: 0,
      );

      final locationStream = _location.onLocationChanged;

      await for (final locationData in locationStream) {
        if (locationData.latitude != null && locationData.longitude != null) {
          final gpsData = _convertToGPSData(locationData);
          samples.add(gpsData);

          print('Muestra ${samples.length}: $gpsData');

          if (samples.length >= sampleSize) {
            break;
          }
        }

        if (DateTime.now().difference(startTime).inMilliseconds > maxWaitTime) {
          print('Timeout alcanzado despues de ${maxWaitTime}ms');
          break;
        }
      }
    } catch (e) {
      print('Error durante muestreo: $e');
    }

    if (samples.isEmpty) {
      return null;
    }

    samples.sort((a, b) => b.qualityScore.compareTo(a.qualityScore));
    final bestSample = samples.first;

    for (int i = 0; i < samples.length; i++) {
      final sample = samples[i];
      final prefix = i == 0 ? '>> ' : ' ${i + 1}.';
      print('$prefix${sample.toString()}');
    }

    return bestSample;
  }

  Stream<GPSData> getLocationStream() {
    return _location.onLocationChanged
        .where((locationData) =>
            locationData.latitude != null && locationData.longitude != null)
        .map(_convertToGPSData);
  }

  GPSData _convertToGPSData(LocationData locationData) {
    return GPSData(
      latitude: locationData.latitude!,
      longitude: locationData.longitude!,
      accuracy: locationData.accuracy ?? 0.0,
      altitude: locationData.altitude,
      speed: locationData.speed,
      pdop: null,
      hdop: null,
      vdop: null,
      timestamp: DateTime.now(),
    );
  }

  double? _tryParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

extension GPSDataExtensions on GPSData {

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'pdop': pdop,
      'hdop': hdop,
      'vdop': vdop,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  // Para obtener un string formateado
  String get formattedCoordinates {
    return 'Lat: ${latitude.toStringAsFixed(6)}, Lon: ${longitude.toStringAsFixed(6)}';
  }
}
