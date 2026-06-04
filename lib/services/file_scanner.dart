import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/song_model.dart';
import 'media_store_channel.dart';

class FileScanner {
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (SDK 33): permiso de audio específico
      if (await Permission.audio.request().isGranted) {
        return true;
      }
      // Android 12 o inferior: permiso de almacenamiento genérico
      if (await Permission.storage.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  Future<List<Track>> scanDeviceAudio() async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      debugLog("Error: Permisos de lectura denegados.");
      return [];
    }

    try {
      // Consulta MediaStore de Android vía MethodChannel nativo
      return await MediaStoreChannel.querySongs();
    } catch (e) {
      debugLog("Error al consultar MediaStore: $e");
      return [];
    }
  }

  void debugLog(String msg) {
    assert(() {
      // ignore: avoid_print
      print(msg);
      return true;
    }());
  }
}
