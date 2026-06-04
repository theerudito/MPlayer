import 'package:just_audio/just_audio.dart';

class AudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Expone los streams de just_audio para que la UI reaccione en tiempo real
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// Inicializa y reproduce un archivo de audio mediante su ruta local
  Future<void> playFromFile(String path) async {
    try {
      // Configura la ruta del archivo (funciona con almacenamiento interno y SD)
      await _audioPlayer.setFilePath(path);
      _audioPlayer.play();
    } catch (e) {
      rethrow;
    }
  }

  void pause() => _audioPlayer.pause();
  void resume() => _audioPlayer.play();
  void stop() => _audioPlayer.stop();

  void seek(Duration position) => _audioPlayer.seek(position);

  void setShuffle(bool enable) {
    _audioPlayer.setShuffleModeEnabled(enable);
  }

  void setRepeatMode(bool enable) {
    _audioPlayer.setLoopMode(enable ? LoopMode.one : LoopMode.off);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
