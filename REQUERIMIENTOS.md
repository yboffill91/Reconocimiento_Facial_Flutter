# Requerimientos para la App de Reconocimiento Facial

## 1. Configuración del entorno
- [x] Agregar plugin google_ml_kit en pubspec.yaml
- [x] Agregar plugin flutter_secure_storage en pubspec.yaml
- [x] Agregar plugin camera en pubspec.yaml
- [x] Agregar plugin permission_handler en pubspec.yaml

## 2. Solicitar permisos
- [x] Implementar solicitud de permisos de cámara
- [x] Manejar casos donde el usuario rechaza los permisos

## 3. Inicializar la cámara
- [x] Usar paquete camera para acceder al stream de video
- [x] Seleccionar cámara frontal
- [x] Iniciar vista previa en tiempo real

## 4. Crear instancia de FaceDetector
- [x] Inicializar detector facial de ML Kit
- [x] Configurar opciones del detector (precisión, landmarks, clasificación)

## 5. Procesar fotogramas del video
- [x] Convertir CameraImage a InputImage (estructura creada, implementación pendiente)
- [x] Pasar InputImage al faceDetector
- [ ] Extraer landmarks faciales
- [x] Implementar procesamiento cada X ms (no cada frame)

## 6. Extraer y serializar landmarks
- [x] Obtener puntos faciales principales
- [x] Convertir landmarks a formato JSON

## 7. Serialización final
- [x] Generar JSON estructurado para enviar al core biométrico
- [x] Incluir metadatos relevantes (timestamp, etc)

## 8. Validación visual del rostro
- [x] Mostrar indicador cuando se detecta un rostro único
- [x] Verificar que todos los puntos necesarios están presentes
- [x] Comprobar que el rostro está centrado y estable
- [x] Implementar feedback visual (borde verde, animación, etc)
