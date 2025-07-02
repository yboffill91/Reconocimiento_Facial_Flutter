import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/face_detector_service.dart';
import '../widgets/camera_view.dart';
import '../utils/permission_utils.dart';
import '../models/face_model.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen>
    with WidgetsBindingObserver {
  bool _isCameraPermissionGranted = false;
  CameraController? _cameraController;
  FaceDetectorService? _faceDetectorService;
  List<CameraDescription> _cameras = [];
  bool _isFaceValid = false;
  bool _isProcessing = false;

  // Almacenamiento seguro
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Información del rostro detectado
  String _lastDetectedFaceInfo = 'Ningún rostro detectado aún';
  DateTime? _lastDetectionTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }
  
  @override
  void deactivate() {
    // Asegurarnos de liberar los recursos cuando el widget se desactiva
    _stopCamera();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Manejar el ciclo de vida de la app
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await PermissionUtils.requestCameraPermission();
    setState(() {
      _isCameraPermissionGranted = status == PermissionStatus.granted;
    });

    if (_isCameraPermissionGranted) {
      _setupCameras();
    }
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();
      await _initializeCamera();
    } catch (e) {
      setState(() {
        _lastDetectedFaceInfo = 'Error al configurar las cámaras';
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) return;

    // Buscar la cámara frontal
    final frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    // Inicializar el controlador de cámara
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset
          .medium, // Usar una resolución media para mejor rendimiento
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();

      // Inicializar servicio de detección facial
      _faceDetectorService = FaceDetectorService();

      // Suscribirse al stream de rostros detectados
      _faceDetectorService!.facesStream.listen((List<FaceModel> faces) {
        if (faces.isNotEmpty) {
          // Verificar si el rostro cumple criterios
          final isValid = faces.length == 1 && faces.first.isValid();

          setState(() {
            _isFaceValid = isValid;
          });

          // Acción cuando se detecta un rostro válido
          if (isValid && !_isProcessing) {
            _isProcessing = true;

            // Guardar en almacenamiento seguro
            _saveFaceDataToStorage(faces.first);

            setState(() {
              _lastDetectionTime = DateTime.now();
              _lastDetectedFaceInfo = 'Rostro válido guardado';
            });

            _isProcessing = false;
          }
        } else {
          setState(() {
            _isFaceValid = false;
          });
        }
      });

      // Iniciar el procesamiento de imágenes
      _startImageProcessing();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _lastDetectedFaceInfo = 'Error al inicializar la cámara';
      });
    }
  }

  Future<void> _startImageProcessing() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      // Iniciar el stream de imágenes
      _cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          // Procesar la imagen con el detector facial
          _faceDetectorService?.processImage(image, _cameraController!.description);
        }
      });
    } catch (e) {
      setState(() {
        _lastDetectedFaceInfo = 'Error al procesar imágenes: $e';
      });
    }
  }

  void _stopCamera() {
    try {
      // Detener primero los servicios
      if (_faceDetectorService != null) {
        _faceDetectorService!.dispose();
        _faceDetectorService = null;
      }
      
      // Luego detener la cámara con un pequeño delay
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _cameraController!.dispose();
        _cameraController = null;
      }
    } catch (e) {
      print('Error al detener recursos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detección Facial')),
      body: _isCameraPermissionGranted
          ? _buildCameraView()
          : _buildPermissionRequest(),
    );
  }

  Widget _buildCameraView() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: CameraView(
            controller: _cameraController!,
            faceDetectorService: _faceDetectorService!,
            isFaceValid: _isFaceValid,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.black.withOpacity(0.1),
          child: Column(
            children: [
              Text(
                'Estado: ${_isFaceValid ? "Rostro detectado correctamente" : "Ajuste su rostro"}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isFaceValid ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(_lastDetectedFaceInfo, style: const TextStyle(fontSize: 14)),
              if (_lastDetectionTime != null)
                Text(
                  'Última detección: ${_formatTime(_lastDetectionTime!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  /// Guarda los datos del rostro en almacenamiento seguro
  Future<void> _saveFaceDataToStorage(FaceModel face) async {
    try {
      final String key = 'face_data_${DateTime.now().millisecondsSinceEpoch}';
      final String value = face.toJsonString();

      await _secureStorage.write(key: key, value: value);

      // También guardamos el último ID para fácil acceso
      await _secureStorage.write(key: 'last_face_id', value: key);
    } catch (e) {
      setState(() {
        _lastDetectedFaceInfo = 'Error al guardar: $e';
      });
    }
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Se requiere acceso a la cámara',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requestCameraPermission,
            child: const Text('Conceder acceso'),
          ),
        ],
      ),
    );
  }
}
