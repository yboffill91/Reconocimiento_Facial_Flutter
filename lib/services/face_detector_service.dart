import 'dart:async';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../models/face_model.dart';

class FaceDetectorService {
  // Instancia del detector facial de ML Kit
  final FaceDetector _faceDetector;
  
  // Controlador para el stream de detecciones
  final StreamController<List<FaceModel>> _faceStreamController = 
      StreamController<List<FaceModel>>();
  
  // Stream para escuchar las detecciones
  Stream<List<FaceModel>> get facesStream => _faceStreamController.stream;
  
  // Flag para controlar el procesamiento
  bool _isProcessing = false;
  
  // Timestamp del último procesamiento
  int _lastProcessingTimestamp = 0;
  
  // Intervalo mínimo entre procesamiento de frames (ms)
  final int processingInterval = 500; // 500ms
  
  FaceDetectorService() : _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableTracking: true,
      enableClassification: true,
      minFaceSize: 0.15, // Tamaño mínimo de cara para ser detectada (0.0-1.0)
      performanceMode: FaceDetectorMode.accurate,
    )
  );
  
  /// Procesa la imagen de la cámara
  Future<void> processImage(CameraImage image, CameraDescription camera) async {
    // Evitar procesamiento si ya estamos procesando
    if (_isProcessing) return;
    
    // Verificar el intervalo de tiempo para limitar procesamiento
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - _lastProcessingTimestamp < processingInterval) return;
    
    _isProcessing = true;
    _lastProcessingTimestamp = currentTime;
    
    try {
      // Convertir CameraImage a InputImage (código a implementar)
      final inputImage = _convertCameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      
      // Procesar la imagen
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isNotEmpty) {
        // Convertir a nuestro modelo
        final List<FaceModel> faceModels = faces.map((face) => 
          FaceModel.fromDetectedFace(face, currentTime)
        ).toList();
        
        // Publicar en el stream
        if (!_faceStreamController.isClosed) {
          _faceStreamController.add(faceModels);
        }
      } else {
        // No se detectaron rostros
        if (!_faceStreamController.isClosed) {
          _faceStreamController.add([]);
        }
      }
    } catch (e) {
      print('Error en la detección facial: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  /// Convierte CameraImage a InputImage
  InputImage? _convertCameraImageToInputImage(CameraImage image, CameraDescription camera) {
    // Este método requiere una implementación compleja para convertir el formato
    // Para simplificar, usaremos una implementación básica por ahora
    // En una implementación real, este método debe manejar la conversión adecuadamente
    
    // Por ahora retornamos null, implementaremos esto después
    return null;
  }
  
  /// Liberar recursos
  void dispose() async {
    await _faceStreamController.close();
    await _faceDetector.close();
  }
}
