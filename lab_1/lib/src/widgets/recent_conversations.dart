import 'package:flutter/material.dart';

import 'conversation_item.dart';

class RecentConversations extends StatelessWidget {
  const RecentConversations({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Últimas conversaciones',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1921),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Más adelante se puede navegar a otra pantalla.
              },
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  color: Color(0xFF5146E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        const ConversationItem(
          imagePath: 'assets/images/javier.jpg',
          name: 'Javier Montes',
          message: '¿Te parece si revisamos los cambios?',
          time: '10:24 a.m.',
          isRead: true,
        ),

        const ConversationItem(
          imagePath: 'assets/images/sofia.jpg',
          name: 'Sofía Rivas',
          message: '¡Ese diseño quedó increíble!',
          time: '09:15 a.m.',
          unreadMessages: 3,
        ),

        const ConversationItem(
          imagePath: 'assets/images/alex.jpg',
          name: 'Alex Torres',
          message: 'Mañana enviamos el reporte',
          time: 'Ayer',
          isRead: false,
        ),

        const ConversationItem(
          imagePath: 'assets/images/david.jpg',
          name: 'David Luna',
          message: 'Hola Mariana, ¿tienes un momento?',
          time: 'Ayer',
          unreadMessages: 1,
        ),
      ],
    );
  }
}