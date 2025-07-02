import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// Solicita permiso de cámara y retorna el estado
  static Future<PermissionStatus> requestCameraPermission() async {
    // Verificar estado actual del permiso
    var status = await Permission.camera.status;
    
    // Si ya está concedido, retornar el estado actual
    if (status.isGranted) {
      return status;
    }
    
    // Si está denegado permanentemente, abre la configuración
    if (status.isPermanentlyDenied) {
      return status;
    }
    
    // Solicitar permiso
    return await Permission.camera.request();
  }
  
  /// Verifica si el permiso de cámara está concedido
  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }
  
  /// Abre la configuración de la aplicación
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
