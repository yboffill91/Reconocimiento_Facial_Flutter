import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/face_detector_service.dart';

class CameraView extends StatelessWidget {
  final CameraController controller;
  final FaceDetectorService faceDetectorService;
  final bool isFaceValid;

  const CameraView({
    super.key,
    required this.controller,
    required this.faceDetectorService,
    required this.isFaceValid,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Vista de la cámara
        CameraPreview(controller),

        // Marco para el rostro (verde cuando es válido)
        StreamBuilder<List<dynamic>>(
          stream: faceDetectorService.facesStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              // Mostrar un overlay para el rostro
              return CustomPaint(
                painter: FaceOverlayPainter(isFaceValid: isFaceValid),
                child: Container(),
              );
            }
            return Container();
          },
        ),

        // Indicaciones para el usuario
        Positioned(
          bottom: 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isFaceValid
                  ? 'Rostro detectado correctamente'
                  : 'Centre su rostro en la cámara',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Clase para dibujar el contorno facial
class FaceOverlayPainter extends CustomPainter {
  final bool isFaceValid;

  FaceOverlayPainter({required this.isFaceValid});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFaceValid ? Colors.green : Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Dibujar un óvalo que simula un rostro centrado
    final center = Offset(size.width / 2, size.height / 2);
    final radiusX = size.width * 0.25; // 25% del ancho
    final radiusY = size.height * 0.3; // 30% del alto

    canvas.drawOval(
      Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) =>
      isFaceValid != oldDelegate.isFaceValid;
}
