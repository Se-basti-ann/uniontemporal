// models/connected_operator.dart
import 'package:meta/meta.dart';

@immutable
class ConnectedOperator {
  final String id;
  final String name;
  final String? email;
  final double latitude;
  final double longitude;
  final DateTime lastSeen;
  final bool isActive;
  final String? currentTaskId;
  final double? batteryLevel;
  final double accuracy;

  const ConnectedOperator({
    required this.id,
    required this.name,
    this.email,
    required this.latitude,
    required this.longitude,
    required this.lastSeen,
    this.isActive = true,
    this.currentTaskId,
    this.batteryLevel,
    this.accuracy = 0.0,
  });

  ConnectedOperator copyWith({
    String? id,
    String? name,
    String? email,
    double? latitude,
    double? longitude,
    DateTime? lastSeen,
    bool? isActive,
    String? currentTaskId,
    double? batteryLevel,
    double? accuracy,
  }) {
    return ConnectedOperator(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
      currentTaskId: currentTaskId ?? this.currentTaskId,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'isActive': isActive,
      'currentTaskId': currentTaskId,
      'batteryLevel': batteryLevel,
      'accuracy': accuracy,
    };
  }

  factory ConnectedOperator.fromMap(Map<String, dynamic> map) {
    return ConnectedOperator(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(map['lastSeen'] as int),
      isActive: map['isActive'] as bool? ?? true,
      currentTaskId: map['currentTaskId'] as String?,
      batteryLevel: map['batteryLevel'] as double?,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}