import 'package:flutter/services.dart';
import '../models/song_model.dart';

/// Accede al MediaStore de Android vía MethodChannel para obtener
/// la lista de canciones sin depender de on_audio_query.
class MediaStoreChannel {
  static const _channel = MethodChannel('com.example.reproductor/media_store');

  static Future<List<Track>> querySongs() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('querySongs');
      return result.map((dynamic item) {
        final map = Map<String, dynamic>.from(item as Map);
        return Track(
          id:     (map['id']     as num).toInt(),
          title:  map['title']   as String,
          artist: map['artist']  as String,
          album:  map['album']   as String,
          path:   map['path']    as String,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
