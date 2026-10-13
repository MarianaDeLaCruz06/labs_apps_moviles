class Conversation {
  final String id;
  final String profile1Id;
  final String profile2Id;
  final DateTime createdAt;
  final String? otherUserName;

  Conversation({
    required this.id,
    required this.profile1Id,
    required this.profile2Id,
    required this.createdAt,
    this.otherUserName,
  });

  factory Conversation.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final isProfile1 = json['profile1_id'] == currentUserId;
    final otherProfile = isProfile1 ? json['profile2'] : json['profile1'];
    return Conversation(
      id: json['id'] as String,
      profile1Id: json['profile1_id'] as String,
      profile2Id: json['profile2_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUserName: otherProfile != null
          ? otherProfile['name'] as String?
          : null,
    );
  }
}
