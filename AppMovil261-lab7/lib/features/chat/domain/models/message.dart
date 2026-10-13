class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String? imagePath;
  final String? imageUrl;
  final DateTime createdAt;
  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.imagePath,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'conversation_id': conversationId,
    'sender_id': senderId,
    'content': content,
    if (imagePath != null) 'image_path': imagePath,
  };

  Message copyWith({String? imageUrl}) => Message(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    content: content,
    imagePath: imagePath,
    imageUrl: imageUrl ?? this.imageUrl,
    createdAt: createdAt,
  );

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      imagePath: json['image_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
