// models/task.dart
import '../models/material_item.dart';


class Task {
  final String id;
  final String title;
  final String address;
  final String status;
  final List<MaterialItem> materials;
  final String description;
  final String priority;  
  final int estimatedHours;
  final double? latitude;
  final double? longitude;
  final String? assignedOperatorId;

  Task({
    required this.id,
    required this.title,
    required this.address,
    required this.status,
    required this.materials,
    this.description = '',
    this.priority = 'medium',
    this.estimatedHours = 0,
    this.latitude,
    this.longitude,
    this.assignedOperatorId
  });

  Task copyWith({
    String? id,
    String? title,
    String? address,
    String? status,
    List<MaterialItem>? materials,
    String? description,
    String? priority,
    int? estimatedHours, 
    double? latitude,
    double? longitude,
    String? assignedOperatorId,
    required Map<String, Object> locationData,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      status: status ?? this.status,
      materials: materials ?? this.materials,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      assignedOperatorId: assignedOperatorId ?? this.assignedOperatorId,
    );
  }
}