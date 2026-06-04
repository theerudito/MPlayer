import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song_model.dart';
import '../../providers/player_provider.dart';

/// Pantalla que muestra una lista de canciones (de una carpeta o de toda la playlist).
/// Al tocar una canción la reproduce y vuelve al reproductor.
class SongListScreen extends StatefulWidget {
  final String title;
  final List<Track> songs;

  const SongListScreen({
    super.key,
    required this.title,
    required this.songs,
  });

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Track> get _filteredSongs {
    if (_searchQuery.isEmpty) return widget.songs;
    final q = _searchQuery.toLowerCase();
    return widget.songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q) ||
          s.album.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final filtered = _filteredSongs;

    return Scaffold(
      backgroundColor: const Color(0xFF12121E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar canción...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF2A2A3C),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off, size: 64, color: Colors.white12),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No hay canciones en esta carpeta'
                        : 'No se encontraron resultados',
                    style: const TextStyle(color: Colors.white38, fontSize: 15),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final song = filtered[index];
                final globalIndex = playerProvider.playlist.indexOf(song);
                final isPlaying =
                    playerProvider.currentIndex == globalIndex && globalIndex >= 0;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isPlaying
                        ? Colors.purple.withOpacity(0.25)
                        : Colors.transparent,
                    border: isPlaying
                        ? Border.all(color: Colors.purpleAccent.withOpacity(0.5))
                        : null,
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isPlaying
                              ? [const Color(0xFF9D4EDD), const Color(0xFF7B2FBE)]
                              : [const Color(0xFF2A2A3C), const Color(0xFF1E1E2C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        isPlaying ? Icons.equalizer : Icons.music_note,
                        color: isPlaying ? Colors.white : Colors.white38,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        color: isPlaying ? Colors.purpleAccent : Colors.white,
                        fontWeight: isPlaying
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${song.artist}  •  ${song.album}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isPlaying
                        ? const Icon(Icons.volume_up,
                            color: Colors.purpleAccent, size: 18)
                        : const Icon(Icons.play_arrow,
                            color: Colors.white24, size: 22),
                    onTap: () {
                      if (globalIndex >= 0) {
                        playerProvider.playSong(globalIndex);
                      }
                      // Vuelve al reproductor principal
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
    );
  }
}
