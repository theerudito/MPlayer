/// Modelo de canción propio de la aplicación.
/// Se llama [Track] para evitar conflicto con el [SongModel] de on_audio_query.
class Track {
  final int id;
  final String title;
  final String artist;
  final String path;
  final String album;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.path,
    required this.album,
  });
}
