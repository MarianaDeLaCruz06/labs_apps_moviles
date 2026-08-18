import 'package:flutter/material.dart';

/// Main screen. Hosts the three tab pages. TODO parts 5 and 7.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('TODO part 5')),
    );
  }
}
