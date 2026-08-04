import 'package:flutter/material.dart';

class ProfileInformation extends StatelessWidget {
  final String imagePath;
  final String name;
  final String username;
  final String role;
  final String description;
  final String email;
  final String location;

  const ProfileInformation({
    super.key,
    required this.imagePath,
    required this.name,
    required this.username,
    required this.role,
    required this.description,
    required this.email,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 125,
          height: 125,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEAE5FA),
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              width: 115,
              height: 115,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFEAE5FA),
                  child: const Icon(
                    Icons.person,
                    size: 70,
                    color: Color(0xFF6A6480),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1921),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$username • $role',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF696979),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF555362),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 10,
          children: [
            _InformationItem(
              icon: Icons.mail_outline,
              text: email,
            ),
            _InformationItem(
              icon: Icons.location_on_outlined,
              text: location,
            ),
          ],
        ),
      ],
    );
  }
}

class _InformationItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InformationItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFF696979),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF696979),
          ),
        ),
      ],
    );
  }
}
