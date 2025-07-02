import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/face_detector_service.dart';
import '../widgets/camera_view.dart';
import '../utils/permission_utils.dart';
import '../models/face_model.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> with WidgetsBindingObserver {
  bool _isCameraPermissionGranted = false;
  CameraController? _cameraController;
  FaceDetectorService? _faceDetectorService;
  List<CameraDescription> _cameras = [];
  bool _isFaceValid = false;
  bool _isProcessing = false;
  
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
      print('Error al configurar las cámaras: $e');
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
      ResolutionPreset.medium, // Usar una resolución media para mejor rendimiento
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
            print('Rostro válido detectado: ${faces.first.toJsonString()}');
            // Aquí podrías guardar o enviar el rostro detectado
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
      print('Error al inicializar la cámara: $e');
    }
  }
  
  Future<void> _startImageProcessing() async {
    // En una implementación real, aquí configurarías un ImageStream para procesar las imágenes
    // Por ahora, solo mostraremos la vista previa
    // Esta es una implementación simulada que normalmente procesaría frames
  }
  
  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController!.dispose();
      _cameraController = null;
    }
    
    if (_faceDetectorService != null) {
      _faceDetectorService!.dispose();
      _faceDetectorService = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detección Facial'),
      ),
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Estado: ${_isFaceValid ? "Rostro detectado correctamente" : "Ajuste su rostro"}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isFaceValid ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            size: 100,
            color: Colors.grey,
          ),
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
