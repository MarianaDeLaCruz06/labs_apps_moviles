import 'package:flutter/material.dart';

import '../models/music_profile.dart';
import '../pages/step1_page.dart';
import '../pages/step2_page.dart';
import '../pages/step3_page.dart';
import '../pages/summary_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentStep = 0;

  final MusicProfile profile = MusicProfile();

  void nextStep() {
    setState(() {
      currentStep++;
    });
  }

  void goBack() {
    if (currentStep == 0) {
      Navigator.pop(context);
    } else {
      setState(() {
        currentStep--;
      });
    }
  }

  void startApp() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
      arguments: profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    profile.email = email;

    Widget currentPage;

    if (currentStep == 0) {
      currentPage = Step1Page(
        onNameChanged: (value) {
          profile.fullName = value;
        },
        onUsernameChanged: (value) {
          profile.username = value;
        },
        onNext: nextStep,
      );
    } else if (currentStep == 1) {
      currentPage = Step2Page(
        onArtistChanged: (value) {
          profile.favoriteArtist = value;
        },
        onMoodChanged: (value) {
          profile.mood = value;
        },
        onNext: nextStep,
      );
    } else if (currentStep == 2) {
      currentPage = Step3Page(
        onPlaylistChanged: (value) {
          profile.playlistName = value;
        },
        onCoverChanged: (value) {
          profile.coverUrl = value;
        },
        onNext: nextStep,
      );
    } else {
      currentPage = SummaryPage(
        profile: profile,
        onStart: startApp,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: goBack,
                icon: const Icon(Icons.arrow_back),
              ),
            ),

            Expanded(
              child: currentPage,
            ),
          ],
        ),
      ),
    );
  }
}