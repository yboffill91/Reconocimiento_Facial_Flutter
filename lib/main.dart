import 'package:flutter/material.dart';
import 'screens/face_detection_screen.dart';

void main() async {
  // Asegurar que las dependencias de Flutter estén inicializadas
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FacialLandmarksApp());
}

class FacialLandmarksApp extends StatelessWidget {
  const FacialLandmarksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detección Facial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Seguir configuración del sistema
      home: const FaceDetectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
