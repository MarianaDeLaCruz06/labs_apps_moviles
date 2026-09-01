import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController =
      TextEditingController();

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

                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(song['title']),
                  subtitle: Text(song['artist']['name']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}