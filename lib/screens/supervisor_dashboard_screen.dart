// screens/supervisor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/supervisor_provider.dart';
import '../models/task.dart';
import '../models/connected_operator.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  _SupervisorDashboardScreenState createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen>
    with TickerProviderStateMixin {
  late MapController _mapController;
  LatLng? _currentLocation;
  String _selectedFilter = 'all';
  bool _showOperators = true;
  bool _showTasks = true;
  late TabController _tabController;
  final ScrollController _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _tabController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final supervisorProvider =
        Provider.of<SupervisorProvider>(context, listen: false);
    supervisorProvider.loadMockData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentLocation != null) {
          _mapController.move(_currentLocation!, 13.0);
        }
      });
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      // Usar ubicación por defecto (Lima, Perú)
      _currentLocation = const LatLng(-12.0464, -77.0428);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_currentLocation!, 13.0);
      });
    }
  }

  Marker _buildTaskMarker(Task task) {
    Color markerColor;
    IconData markerIcon;

    switch (task.priority) {
      case 'high':
        markerColor = Colors.red;
        markerIcon = Icons.flag;
        break;
      case 'medium':
        markerColor = Colors.orange;
        markerIcon = Icons.flag;
        break;
      case 'low':
        markerColor = Colors.green;
        markerIcon = Icons.flag;
        break;
      default:
        markerColor = Colors.blue;
        markerIcon = Icons.flag;
    }

    return Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(task.latitude ?? -12.0464, task.longitude ?? -77.0428),
      builder: (ctx) => GestureDetector(
        onTap: () => _showTaskDetails(task),
        child: Container(
          decoration: BoxDecoration(
            color: markerColor.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              markerIcon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Marker _buildOperatorMarker(ConnectedOperator operator) {
    return Marker(
      width: 60.0,
      height: 60.0,
      point: LatLng(operator.latitude, operator.longitude),
      builder: (ctx) => GestureDetector(
        onTap: () => _showOperatorDetails(operator),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: operator.isActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              if (operator.currentTaskId != null)
                Container(
                  margin: const EdgeInsets.only(top: 2), 
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1), 
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8, // Reducido
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailsSheet(task: task),
    );
  }

  void _showOperatorDetails(ConnectedOperator operator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OperatorDetailsSheet(operator: operator),
    );
  }

  Widget _buildStatsCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 140,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supervisorProvider = Provider.of<SupervisorProvider>(context);
    final tasks = supervisorProvider.allTasks;
    final operators = supervisorProvider.connectedOperators;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Supervisión'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Mapa'),
            Tab(icon: Icon(Icons.list), text: 'Lista'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => supervisorProvider.loadMockData(),
            tooltip: 'Refrescar datos',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 15.0);
              }
            },
            tooltip: 'Mi ubicación',
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Barra de estadísticas
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  const SizedBox(width: 8),
                  _buildStatsCard(
                    'Total Tareas',
                    tasks.length.toString(),
                    Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  _buildStatsCard(
                    'En Progreso',
                    tasks
                        .where((t) => t.status == 'in_progress')
                        .length
                        .toString(),
                    Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  _buildStatsCard(
                    'Operarios Activos',
                    operators.where((o) => o.isActive).length.toString(),
                    Colors.green,
                  ),
                  const SizedBox(width: 4),
                  _buildStatsCard(
                    'Pendientes',
                    tasks.where((t) => t.status == 'pending').length.toString(),
                    Colors.red,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Filtros
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primera fila: Dropdown
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Filtrar Tareas',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'all', child: Text('Todas')),
                            DropdownMenuItem(
                                value: 'pending', child: Text('Pendientes')),
                            DropdownMenuItem(
                                value: 'in_progress',
                                child: Text('En Progreso')),
                            DropdownMenuItem(
                                value: 'completed', child: Text('Completadas')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value ?? 'all';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Segunda fila: Switches
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Switch(
                                value: _showTasks,
                                onChanged: (value) =>
                                    setState(() => _showTasks = value),
                                activeColor: Colors.blue,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 4),
                              const Text('Tareas'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Switch(
                                value: _showOperators,
                                onChanged: (value) =>
                                    setState(() => _showOperators = value),
                                activeColor: Colors.green,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 4),
                              const Text('Operarios'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mapa y lista (TabBarView)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña del Mapa
                  ClipRect(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _currentLocation ??
                            const LatLng(-12.0464, -77.0428),
                        zoom: 13.0,
                        maxZoom: 18.0,
                        minZoom: 5.0,
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.uniontemporal',
                        ),
                        if (_showTasks)
                          MarkerLayer(
                            markers: _getFilteredTasks(tasks)
                                .where((task) =>
                                    task.latitude != null &&
                                    task.longitude != null)
                                .map(_buildTaskMarker)
                                .toList(),
                          ),
                        if (_showOperators)
                          MarkerLayer(
                            markers: _getFilteredOperators(operators)
                                .map(_buildOperatorMarker)
                                .toList(),
                          ),
                        if (_currentLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 30.0,
                                height: 30.0,
                                point: _currentLocation!,
                                builder: (ctx) => const Icon(
                                  Icons.location_pin,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Pestaña de Lista
                  Consumer<SupervisorProvider>(
                    builder: (context, provider, child) {
                      final filteredTasks = _getFilteredTasks(tasks);

                      if (filteredTasks.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.task, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay tareas para mostrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Scrollbar(
                          controller: _listScrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _listScrollController,
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              final assignedOperator =
                                  task.assignedOperatorId != null
                                      ? provider.getOperatorById(
                                          task.assignedOperatorId!)
                                      : null;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Icono de estado
                                        Container(
                                          margin: const EdgeInsets.only(
                                              right: 12, top: 4),
                                          child: CircleAvatar(
                                            backgroundColor:
                                                _getStatusColor(task.status),
                                            radius: 20,
                                            child: Icon(
                                              _getStatusIcon(task.status),
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        // Contenido principal
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                task.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                task.address,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (assignedOperator != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        size: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          assignedOperator.name,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Información lateral
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getPriorityColor(
                                                        task.priority)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                task.priority.toUpperCase(),
                                                style: TextStyle(
                                                  color: _getPriorityColor(
                                                      task.priority),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${task.estimatedHours}h',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    return _selectedFilter == 'all'
        ? tasks
        : tasks.where((task) => task.status == _selectedFilter).toList();
  }

  List<ConnectedOperator> _getFilteredOperators(
      List<ConnectedOperator> operators) {
    return operators.where((op) => _showOperators).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'in_progress':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
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
}

// Hoja inferior para detalles de tarea - VERSIÓN SIMPLIFICADA
class TaskDetailsSheet extends StatelessWidget {
  final Task task;

  const TaskDetailsSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Barra de arrastre
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Estado y prioridad
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                _getStatusText(task.status),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: _getStatusColor(task.status),
                            ),
                            Chip(
                              label: Text(
                                task.priority.toUpperCase(),
                                style: TextStyle(
                                  color: _getPriorityColor(task.priority),
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: _getPriorityColor(task.priority)
                                  .withOpacity(0.1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Información
                        _buildDetailItem(
                            Icons.location_on, 'Dirección', task.address),
                        const SizedBox(height: 16),
                        _buildDetailItem(Icons.access_time, 'Tiempo estimado',
                            '${task.estimatedHours} horas'),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Descripción:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'in_progress':
        return 'EN PROGRESO';
      case 'completed':
        return 'COMPLETADA';
      default:
        return 'DESCONOCIDO';
    }
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
}

// Hoja inferior para detalles de operario - VERSIÓN SIMPLIFICADA
class OperatorDetailsSheet extends StatelessWidget {
  final ConnectedOperator operator;

  const OperatorDetailsSheet({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Barra de arrastre
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    operator.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (operator.email != null)
                                    Text(
                                      operator.email!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Estado
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                operator.isActive ? 'ACTIVO' : 'INACTIVO',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: operator.isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            if (operator.batteryLevel != null)
                              Chip(
                                label: Text(
                                  '${(operator.batteryLevel! * 100).toInt()}%',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor:
                                    _getBatteryColor(operator.batteryLevel!),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Información
                        _buildDetailItem(
                            Icons.location_on,
                            'Ubicación',
                            'Lat: ${operator.latitude.toStringAsFixed(4)}\n'
                                'Lon: ${operator.longitude.toStringAsFixed(4)}'),
                        const SizedBox(height: 16),
                        _buildDetailItem(Icons.access_time, 'Última conexión',
                            _formatLastSeen(operator.lastSeen)),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getBatteryColor(double batteryLevel) {
    if (batteryLevel > 0.7) return Colors.green;
    if (batteryLevel > 0.3) return Colors.orange;
    return Colors.red;
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
