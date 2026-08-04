import 'package:flutter/material.dart';

import '../widgets/profile_card.dart';
import '../widgets/recent_conversations.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FE),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: const SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                children: [
                  ProfileCard(),
                  SizedBox(height: 32),
                  RecentConversations(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}