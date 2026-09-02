import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../utils/preview_player.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController =
      TextEditingController();

  final PreviewPlayer previewPlayer = PreviewPlayer();

  List<dynamic> songs = [];

  Future<void> searchSongs() async {
    final text = searchController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final url = Uri.parse(
      'https://i2thub.icesi.edu.co:5443/deezer/search?q=$text',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        songs = data['data'];
      });
    } else {
      print('Error en la petición');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    previewPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar canción o artista',
              hintText: 'Ejemplo: Eminem',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: searchSongs,
              child: const Text('Buscar'),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];

                final previewUrl =
                    song['preview'] as String?;

                final imageUrl =
                    song['album']['cover_medium'] as String?;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),

                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imageUrl ?? '',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.music_note,
                          ),
                        );
                      },
                    ),
                  ),

                  title: Text(
                    song['title'],
                  ),

                  subtitle: Text(
                    song['artist']['name'],
                  ),

                  trailing: StreamBuilder<PlayerState>(
                    stream: previewPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final isLoaded =
                          previewPlayer.currentUrl ==
                              previewUrl;

                      final isPlaying =
                          isLoaded &&
                          (snapshot.data?.playing ??
                              false);

                      return IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: previewUrl == null
                            ? null
                            : () {
                                previewPlayer.toggle(
                                  previewUrl,
                                );
                              },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}