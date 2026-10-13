class Post {
  final String id;
  final String title;
  final String content;
  final String profileId;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.profileId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'profile_id': profileId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      profileId: json['profile_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
