<div align="center">

# 🔍 FacialLandmarksModule

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10.5-02569B?logo=flutter)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-2.19.2-0175C2?logo=dart)](https://dart.dev/)
[![ML Kit](https://img.shields.io/badge/Google_ML_Kit-0.16.3-4285F4?logo=google)](https://developers.google.com/ml-kit)
[![Licencia MIT](https://img.shields.io/badge/Licencia-MIT-yellow.svg)](https://opensource.org/licenses/MIT)



**Módulo de reconocimiento facial con Google ML Kit para aplicaciones Flutter**

</div>

## 📋 Descripción

FacialLandmarksModule es una implementación modular y reutilizable para detección y análisis de rostros en aplicaciones Flutter. Utilizando la potencia de Google ML Kit, este módulo proporciona capacidades de detección de landmarks faciales en tiempo real, validación de calidad del rostro y procesamiento seguro de datos biométricos.

## ✨ Características Principales

- 👤 **Detección facial precisa** con Google ML Kit
- 🎯 **Extracción de landmarks faciales** (ojos, nariz, boca, etc.)
- 🔐 **Almacenamiento seguro** de datos biométricos
- 📊 **Validación de calidad** del rostro en tiempo real
- 🖼️ **Feedback visual** para guiar al usuario
- 📱 **Optimizado para dispositivos móviles**

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Descripción |
|------------|---------|-------------|
| Flutter | 3.10.5 | Framework de UI |
| Dart | 2.19.2 | Lenguaje de programación |
| Google ML Kit | 0.16.3 | API de visión artificial |
| Camera | 0.10.5+9 | Acceso a la cámara del dispositivo |
| Permission_handler | 11.3.1 | Gestión de permisos del sistema |
| Flutter_secure_storage | 9.0.0 | Almacenamiento seguro de datos |

## 🧩 Estructura del Proyecto

```
lib/
├── main.dart               # Punto de entrada de la aplicación
├── models/
│   └── face_model.dart     # Modelo de datos para rostros detectados
├── screens/
│   └── face_detection_screen.dart  # Pantalla principal de detección
├── services/
│   └── face_detector_service.dart  # Servicio de detección con ML Kit
├── utils/
│   └── permission_utils.dart       # Utilidades para manejo de permisos
└── widgets/
    └── camera_view.dart            # Widget para visualización de cámara
```

## 📝 Requisitos

- Dispositivo Android 
- Flutter 3.10.5 o superior
- Dart 2.19.2 o superior
- Cámara frontal funcional

## 🚀 Instalación

1. Agrega las dependencias al archivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_ml_kit: ^0.16.3
  camera: ^0.10.5+9
  permission_handler: ^11.3.1
  flutter_secure_storage: ^9.0.0
```

2. Instala las dependencias:

```bash
flutter pub get
```

3. Configura los permisos en `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

## 💻 Uso

```dart
import 'package:facial_landmarks_module/screens/face_detection_screen.dart';

// En tu aplicación
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => FaceDetectionScreen()),
);
```

## ⚙️ Funcionalidades Implementadas

- ✅ Solicitud y manejo de permisos de cámara
- ✅ Inicialización de cámara frontal
- ✅ Detección facial con Google ML Kit
- ✅ Extracción de landmarks faciales
- ✅ Serialización de datos faciales a formato JSON
- ✅ Validación de calidad del rostro detectado
- ✅ Feedback visual para guiar al usuario
- ✅ Almacenamiento seguro de datos faciales

## 🔜 Próximas Mejoras

- [ ] Detección de "liveness" (anti-spoofing)
- [ ] Comparación entre rostros detectados
- [ ] Optimizaciones de rendimiento
- [ ] Reconocimiento de expresiones faciales

<!-- ## 📸 Capturas de Pantalla

*[Espacio reservado para capturas de pantalla de la aplicación]* -->

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor, abre un issue para discutir lo que te gustaría cambiar o añadir.

1. Fork el repositorio
2. Crea tu rama de características (`git checkout -b feature/amazing-feature`)
3. Commit tus cambios (`git commit -m 'Add some amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Desarrollado por

- [Yasmany Boffill](https://github.com/yboffill91)

---

<div align="center">

📅 *Última actualización: 2 de Julio de 2025*

</div>
