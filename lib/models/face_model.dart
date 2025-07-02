import 'dart:convert';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceModel {
  // Identificador único del rostro (si está disponible)
  final int? trackingId;
  
  // Rectángulo que enmarca el rostro
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;
  
  // Ángulos de rotación (en grados)
  final double? headEulerAngleX; // Cabeceo (pitch)
  final double? headEulerAngleY; // Guiñada (yaw)
  final double? headEulerAngleZ; // Alabeo (roll)
  
  // Puntos de referencia faciales
  final Map<FaceLandmarkType, FaceLandmark?> landmarks;
  
  // Contornos faciales
  final Map<FaceContourType, FaceContour?> contours;
  
  // Probabilidades de clasificación
  final double? smilingProbability;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;
  
  // Timestamp de la detección
  final int timestamp;
  
  FaceModel({
    this.trackingId,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.width,
    required this.height,
    this.headEulerAngleX,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    required this.landmarks,
    required this.contours,
    this.smilingProbability,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    required this.timestamp,
  });
  
  /// Convierte un objeto Face de ML Kit a nuestro modelo personalizado
  factory FaceModel.fromDetectedFace(Face face, int timestamp) {
    return FaceModel(
      trackingId: face.trackingId,
      left: face.boundingBox.left,
      top: face.boundingBox.top,
      right: face.boundingBox.right,
      bottom: face.boundingBox.bottom,
      width: face.boundingBox.width,
      height: face.boundingBox.height,
      headEulerAngleX: face.headEulerAngleX,
      headEulerAngleY: face.headEulerAngleY,
      headEulerAngleZ: face.headEulerAngleZ,
      landmarks: face.landmarks,
      contours: face.contours,
      smilingProbability: face.smilingProbability,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
      timestamp: timestamp,
    );
  }
  
  /// Convierte los landmarks a un formato JSON serializable
  Map<String, dynamic> _landmarksToJson() {
    final Map<String, dynamic> result = {};
    
    landmarks.forEach((type, landmark) {
      if (landmark != null) {
        final String key = type.toString().split('.').last;
        result[key] = {
          'x': landmark.position.x,
          'y': landmark.position.y,
        };
      }
    });
    
    return result;
  }
  
  /// Convierte los contornos a un formato JSON serializable
  Map<String, dynamic> _contoursToJson() {
    final Map<String, dynamic> result = {};
    
    contours.forEach((type, contour) {
      if (contour != null) {
        final String key = type.toString().split('.').last;
        final List<Map<String, double>> points = contour.points.map((point) => {
          'x': point.x.toDouble(),
          'y': point.y.toDouble(),
        }).toList();
        
        result[key] = points;
      }
    });
    
    return result;
  }
  
  /// Convierte el modelo a un objeto JSON
  Map<String, dynamic> toJson() {
    return {
      'trackingId': trackingId,
      'boundingBox': {
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
        'width': width,
        'height': height,
      },
      'headEulerAngle': {
        'x': headEulerAngleX,
        'y': headEulerAngleY,
        'z': headEulerAngleZ,
      },
      'landmarks': _landmarksToJson(),
      'contours': _contoursToJson(),
      'classification': {
        'smilingProbability': smilingProbability,
        'leftEyeOpenProbability': leftEyeOpenProbability,
        'rightEyeOpenProbability': rightEyeOpenProbability,
      },
      'timestamp': timestamp,
    };
  }
  
  /// Convierte el modelo a una cadena JSON
  String toJsonString() => jsonEncode(toJson());
  
  /// Verifica si el rostro es válido según criterios de calidad
  bool isValid() {
    // Verificar si tenemos los landmarks esenciales
    final bool hasEssentialLandmarks = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.bottomMouth,
    ].every((type) => landmarks.containsKey(type));
    
    // Verificar si el rostro está relativamente de frente
    final bool isFrontal = 
        (headEulerAngleY == null || (headEulerAngleY! > -15 && headEulerAngleY! < 15)) &&
        (headEulerAngleZ == null || (headEulerAngleZ! > -15 && headEulerAngleZ! < 15));
    
    // Verificar si los ojos están abiertos
    final bool eyesOpen = 
        (leftEyeOpenProbability == null || leftEyeOpenProbability! > 0.5) &&
        (rightEyeOpenProbability == null || rightEyeOpenProbability! > 0.5);
    
    return hasEssentialLandmarks && isFrontal && eyesOpen;
  }
}
