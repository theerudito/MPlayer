import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import 'components/custom_drawer.dart';
import 'song_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    // Escaneo de archivos automático al iniciar la aplicación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlayerProvider>(context, listen: false).loadSongs();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _openPlaylist(BuildContext context, PlayerProvider playerProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongListScreen(
          title: 'Todas las canciones',
          songs: playerProvider.playlist,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final currentSong = playerProvider.currentSong;

    // Controla la animación de rotación según el estado de reproducción
    playerProvider.audioPlayer.playingStream.listen((playing) {
      if (playing) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF12121E),
      appBar: AppBar(
        title: const Text(
          'Reproductor Local MP3',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Botón para abrir lista completa de canciones
          IconButton(
            tooltip: 'Lista de canciones',
            icon: const Icon(Icons.queue_music),
            onPressed: playerProvider.playlist.isEmpty
                ? null
                : () => _openPlaylist(context, playerProvider),
          ),
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => playerProvider.loadSongs(),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: playerProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    'Escaneando música...',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── 1. CARÁTULA ────────────────────────────────────
                    _buildAlbumArt(currentSong != null),

                    // ── 2. TÍTULO Y ARTISTA ────────────────────────────
                    _buildSongInfo(currentSong, playerProvider),

                    // ── 3. CONTROLES ───────────────────────────────────
                    _buildControls(playerProvider),

                    // ── 4. BARRA DE TIEMPO ─────────────────────────────
                    _buildProgressBar(playerProvider),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Widgets privados ────────────────────────────────────────────────────────

  Widget _buildAlbumArt(bool hasSong) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: hasSong
          ? Center(
              child: RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FBE), Color(0xFF9D4EDD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.music_video,
                size: 100,
                color: Colors.white12,
              ),
            ),
    );
  }

  Widget _buildSongInfo(dynamic currentSong, PlayerProvider playerProvider) {
    return Column(
      children: [
        Text(
          currentSong?.title ?? 'Ninguna pista en reproducción',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          currentSong?.artist ?? 'Desconocido',
          style: const TextStyle(color: Colors.white60, fontSize: 14),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (playerProvider.playlist.isNotEmpty) ...[
          const SizedBox(height: 6),
          // Número de pista en la playlist
          StreamBuilder<bool>(
            stream: playerProvider.audioPlayer.playingStream,
            builder: (context, _) {
              final idx = playerProvider.currentIndex;
              final total = playerProvider.playlist.length;
              return Text(
                idx >= 0 ? '${idx + 1} / $total canciones' : '$total canciones',
                style: const TextStyle(color: Colors.white24, fontSize: 11),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildControls(PlayerProvider playerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: playerProvider.isShuffle
                ? Colors.purpleAccent
                : Colors.white38,
          ),
          iconSize: 26,
          onPressed: playerProvider.toggleShuffle,
        ),
        // Anterior
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          iconSize: 44,
          onPressed: playerProvider.previousSong,
        ),
        // Play / Pause
        StreamBuilder<bool>(
          stream: playerProvider.audioPlayer.playingStream,
          builder: (context, snapshot) {
            final playing = snapshot.data ?? false;
            return GestureDetector(
              onTap: playerProvider.togglePlayPause,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D4EDD), Color(0xFF7B2FBE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            );
          },
        ),
        // Siguiente
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          iconSize: 44,
          onPressed: playerProvider.nextSong,
        ),
        // Repetir
        IconButton(
          icon: Icon(
            Icons.repeat,
            color: playerProvider.isRepeat
                ? Colors.purpleAccent
                : Colors.white38,
          ),
          iconSize: 26,
          onPressed: playerProvider.toggleRepeat,
        ),
      ],
    );
  }

  Widget _buildProgressBar(PlayerProvider playerProvider) {
    return StreamBuilder<Duration?>(
      stream: playerProvider.audioPlayer.durationStream,
      builder: (context, dSnap) {
        final duration = dSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: playerProvider.audioPlayer.positionStream,
          builder: (context, pSnap) {
            var position = pSnap.data ?? Duration.zero;
            if (position > duration) position = duration;

            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    trackHeight: 3,
                    thumbColor: Colors.purpleAccent,
                    activeTrackColor: Colors.purpleAccent,
                    inactiveTrackColor: Colors.white12,
                    overlayColor: Colors.purple.withOpacity(0.2),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                    value: position.inMilliseconds
                        .toDouble()
                        .clamp(0, duration.inMilliseconds.toDouble()),
                    onChanged: (value) {
                      playerProvider.audioPlayer.seek(
                        Duration(milliseconds: value.toInt()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(position),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                      Text(
                        _fmt(duration),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _fmt(Duration d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.inMinutes.remainder(60))}:${pad(d.inSeconds.remainder(60))}';
  }
}
