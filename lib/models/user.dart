class User {
  final String username;
  final String email;
  final String role;
  final String avatarUrl;
  final String bio;
  final String token;
  final List<String> followers;
  final List<String> following;

  User({
    required this.username,
    this.email = '',
    this.role = 'Cinema Enthusiast',
    this.avatarUrl = '',
    this.bio = '',
    this.token = '',
    this.followers = const [],
    this.following = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Cinema Enthusiast',
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      token: json['token'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'token': token,
      'followers': followers,
      'following': following,
    };
  }

  bool get isAdmin => role == 'admin';
}
