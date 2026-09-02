import 'package:just_audio/just_audio.dart';

class PreviewPlayer {
  final AudioPlayer _player = AudioPlayer();

  String? _currentUrl;

  String? get currentUrl => _currentUrl;

  Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream;

  Future<void> toggle(String url) async {
    // Si es la misma canción
    if (_currentUrl == url) {
      if (_player.playing) {
        await _player.pause();
      } else {
        // Si ya terminó, vuelve al inicio
        if (_player.processingState ==
            ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }

        _player.play();
      }

      return;
    }

    // Si es otra canción, detenemos primero la anterior
    await _player.stop();

    // Cargamos la nueva
    await _player.setUrl(url);

    _currentUrl = url;

    // Reproducimos la nueva
    _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}