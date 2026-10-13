import 'package:appmovil261/features/chat/ui/pages/conversations_page.dart';
import 'package:appmovil261/features/home/ui/pages/home_page.dart';
import 'package:appmovil261/features/profile/ui/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    // Espera a que el arbol de componentes se monte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Rompi el patron
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  static const _pages = <Widget>[ProfilePage(), HomePage(), ConversationsPage()];

  static const _titles = ['Perfil', 'Feed', 'Chat'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}
