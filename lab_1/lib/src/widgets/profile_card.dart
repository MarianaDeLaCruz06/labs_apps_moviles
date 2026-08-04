import 'package:flutter/material.dart';

import 'profile_information.dart';
import 'stats_row.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8E5EE),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        children: [
          ProfileInformation(
            imagePath: 'assets/images/mariana.jpg',
            name: 'Mariana Valenzuela',
            username: '@marianav',
            role: 'Diseñadora de Producto',
            description:
                'Creando experiencias digitales enfocadas en el usuario. '
                'Amante del café y del minimalismo.',
            email: 'm.val@estudio.com',
            location: 'Madrid, ES',
          ),
          SizedBox(height: 28),
          Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5E2EC),
          ),
          SizedBox(height: 22),
          StatsRow(),
        ],
      ),
    );
  }
}