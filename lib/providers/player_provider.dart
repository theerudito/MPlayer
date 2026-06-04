import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/file_scanner.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FileScanner _fileScanner = FileScanner();

  List<Track> _playlist = [];
  int _currentIndex = -1;
  bool _isLoading = false;

  bool _isShuffle = false;
  bool _isRepeat = false;

  // Getters para acceder desde la UI
  AudioPlayer get audioPlayer => _audioPlayer;
  List<Track> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;

  Track? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _playlist.length)
      ? _playlist[_currentIndex]
      : null;

  PlayerProvider() {
    // Escucha automática para pasar a la siguiente canción al terminar el archivo actual
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
    });
  }

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    _playlist = await _fileScanner.scanDeviceAudio();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> playSong(int index) async {
    if (_playlist.isEmpty || index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    notifyListeners();

    try {
      await _audioPlayer.setFilePath(_playlist[_currentIndex].path);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error al reproducir el archivo físico: $e");
    }
  }

  void togglePlayPause() {
    if (_playlist.isEmpty) return;
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      if (_currentIndex == -1) {
        playSong(0);
      } else {
        _audioPlayer.play();
      }
    }
    notifyListeners();
  }

  void nextSong() {
    if (_playlist.isEmpty) return;
    if (_isRepeat) {
      // Si la repetición está activa, vuelve a iniciar la misma canción
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else if (_currentIndex < _playlist.length - 1) {
      playSong(_currentIndex + 1);
    } else {
      // Volver al inicio si es la última canción
      playSong(0);
    }
  }

  void previousSong() {
    if (_playlist.isEmpty) return;
    if (_currentIndex > 0) {
      playSong(_currentIndex - 1);
    } else {
      // Ir a la última si se presiona atrás desde el inicio
      playSong(_playlist.length - 1);
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _audioPlayer.setShuffleModeEnabled(_isShuffle);
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    _audioPlayer.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  // Agrupar canciones por carpetas para mostrarlas en el Drawer lateral
  Map<String, List<Track>> getSongsByFolders() {
    Map<String, List<Track>> folders = {};
    for (var song in _playlist) {
      // Extrae el nombre de la carpeta contenedora a partir de la ruta del archivo
      List<String> parts = song.path.split('/');
      String folderName = parts.length > 2 ? parts[parts.length - 2] : "Raíz";

      if (!folders.containsKey(folderName)) {
        folders[folderName] = [];
      }
      folders[folderName]!.add(song);
    }
    return folders;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
