import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoCapture extends StatefulWidget {
  final Function(File)? onArrivalPhotoTaken;
  final Function(File)? onCompletionPhotoTaken;

  const PhotoCapture({
    super.key,
    this.onArrivalPhotoTaken,
    this.onCompletionPhotoTaken,
  });

  @override
  _PhotoCaptureState createState() => _PhotoCaptureState();
}

class _PhotoCaptureState extends State<PhotoCapture> {
  final ImagePicker _picker = ImagePicker();
  File? _arrivalPhoto;
  File? _completionPhoto;

  Future<void> _selectPhotoSource(bool isArrival) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Tomar foto con cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhotoFromCamera(isArrival);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhotoFromGallery(isArrival);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePhotoFromCamera(bool isArrival) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null) {
        _handlePhotoSelection(photo, isArrival);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPhotoFromGallery(bool isArrival) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1200,
        maxWidth: 1200,
        imageQuality: 85,
        );

        if (photo != null) {
          _handlePhotoSelection(photo, isArrival);
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar foto: ${e.toString()}'),
            backgroundColor: Colors.red,
            ),
        );
      }
    }
  }

  void _handlePhotoSelection(XFile photo, bool isArrival) {
    final file = File(photo.path);

    setState(() {
      if (isArrival) {
        _arrivalPhoto = file;
        widget.onArrivalPhotoTaken?.call(_arrivalPhoto!);
      } else {
        _completionPhoto = file;
        widget.onCompletionPhotoTaken?.call(_completionPhoto!);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArrival 
              ? 'Foto de llegada ${photo.path.contains("DCIM") ? "tomada" : "seleccionada"}'
              : 'Foto de finalización ${photo.path.contains("DCIM") ? "tomada" : "seleccionada"}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildPhotoPreview(File? photo, String label, bool isArrival) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: photo != null ? Colors.green : Colors.grey.shade300,
          width: photo != null ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectPhotoSource(isArrival),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          photo,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error, color: Colors.red, size: 30),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.grey.shade400,
                          size: 30,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      photo != null ? 'Foto cargada' : 'Tocar para seleccionar',
                      style: TextStyle(
                        fontSize: 14,
                        color: photo != null ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(File? photo, String label, bool isArrival) {
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
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (photo != null)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    photo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Error al cargar imagen',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Cámara'),
                    onPressed: () => _takePhotoFromCamera(isArrival),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library, size: 20),
                    label: const Text('Galería'),
                    onPressed: () => _pickPhotoFromGallery(isArrival),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Eliminar foto'),
                    onPressed: () {
                      setState(() {
                        if (isArrival) {
                          _arrivalPhoto = null;
                          widget.onArrivalPhotoTaken?.call(File(''));
                        } else {
                          _completionPhoto = null;
                          widget.onCompletionPhotoTaken?.call(File(''));
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📸 Captura de Fotos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Toma fotos con la cámara o selecciona desde tu galería',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        
        // Opción 1: Diseño con botones separados (recomendado)
        _buildActionButtons(_arrivalPhoto, 'Foto de Llegada', true),
        const SizedBox(height: 16),
        _buildActionButtons(_completionPhoto, 'Foto de Finalización', false),
        
        // Opción 2: Diseño con menú emergente (alternativa)
        // Descomenta esta sección si prefieres esta versión:
        /*
        _buildPhotoPreview(_arrivalPhoto, 'Foto de Llegada', true),
        const SizedBox(height: 12),
        _buildPhotoPreview(_completionPhoto, 'Foto de Finalización', false),
        */
      ],
    );
  }
}