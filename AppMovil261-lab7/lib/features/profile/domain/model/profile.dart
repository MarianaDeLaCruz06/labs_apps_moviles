class Profile {
  final String id; // UID de Supabase Auth
  final String name;
  final String email;

  Profile({required this.id, required this.name, required this.email});

  /// Para enviar a Supabase (ej: insert)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }

  /// Para leer desde Supabase (ej: select)
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
