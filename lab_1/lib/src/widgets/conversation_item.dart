import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  final String imagePath;
  final String name;
  final String message;
  final String time;
  final int unreadMessages;
  final bool isRead;

  const ConversationItem({
    super.key,
    required this.imagePath,
    required this.name,
    required this.message,
    required this.time,
    this.unreadMessages = 0,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 52,
                      height: 52,
                      color: const Color(0xFFEAE5FA),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF696979),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1921),
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF696979),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: unreadMessages > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: unreadMessages > 0
                                  ? const Color(0xFF1A1921)
                                  : const Color(0xFF696979),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (unreadMessages > 0)
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5146E5),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadMessages.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.done_all,
                            size: 20,
                            color: isRead
                                ? const Color(0xFF5146E5)
                                : const Color(0xFF858293),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 66,
          color: Color(0xFFE5E2EC),
        ),
      ],
    );
  }
}