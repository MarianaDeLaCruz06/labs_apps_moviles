import 'package:flutter/material.dart';

import '../components/app_top_bar.dart';
import '../models/music_profile.dart';
import '../pages/home_page.dart';
import '../pages/playlist_page.dart';
import '../pages/profile_page.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile =
        ModalRoute.of(context)!.settings.arguments as MusicProfile;

    Widget currentPage;
    String title;

    if (selectedIndex == 0) {
      currentPage = HomePage(
        profile: profile,
      );

      title = 'Inicio';
    } else if (selectedIndex == 1) {
      currentPage = PlaylistPage(
        profile: profile,
      );

      title = 'Tu playlist';
    } else {
      currentPage = ProfilePage(
        profile: profile,
        onEditProfile: () {},
        onLogout: () {},
      );

      title = 'Perfil';
    }

    return Scaffold(
      appBar: AppTopBar(
        title: title,
      ),

      body: currentPage,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.textSecondary,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Playlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}