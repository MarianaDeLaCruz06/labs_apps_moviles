class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumCover,
  });

  final int id;
  final String title;
  final String artist;
  final String albumCover;

  factory Track.fromJson(Map<String, dynamic> json) {
    final artistJson = json['artist'];
    final albumJson = json['album'];
    return Track(
      id: _readId(json['id']),
      title: json['title']?.toString() ?? 'Sin título',
      artist: artistJson is Map<String, dynamic>
          ? artistJson['name']?.toString() ?? 'Artista desconocido'
          : 'Artista desconocido',
      albumCover: albumJson is Map<String, dynamic>
          ? albumJson['cover_medium']?.toString() ?? ''
          : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'albumCover': albumCover,
  };

  factory Track.fromLikedJson(Map<String, dynamic> json) => Track(
    id: _readId(json['id']),
    title: json['title']?.toString() ?? 'Sin título',
    artist: json['artist']?.toString() ?? 'Artista desconocido',
    albumCover: json['albumCover']?.toString() ?? '',
  );

  static int _readId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
