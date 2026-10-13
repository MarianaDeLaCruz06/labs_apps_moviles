import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/track.dart';

class DeezerDataSource {
  DeezerDataSource({required this.client});
  static const _baseUrl = 'https://i2thub.icesi.edu.co:5443/deezer';
  final http.Client client;

  Future<List<Track>> searchTracks(String query) async {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) {
      throw const FormatException('Escribe un artista o una canción.');
    }
    final uri = Uri.parse('$_baseUrl/search')
        .replace(queryParameters: {'q': normalizedQuery});
    try {
      final response = await client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DeezerException(
          'Deezer respondió con el código ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const DeezerException('La respuesta de Deezer no es válida.');
      }
      final data = decoded['data'];
      if (data == null) return const [];
      if (data is! List) {
        throw const DeezerException(
          'Deezer no devolvió una lista de canciones.',
        );
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(Track.fromJson)
          .toList(growable: false);
    } on DeezerException {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (error) {
      throw DeezerException('No fue posible consultar Deezer: $error');
    }
  }
}

class DeezerException implements Exception {
  const DeezerException(this.message);
  final String message;
  @override
  String toString() => message;
}
