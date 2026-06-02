class MovieList {
  final String id;
  final String name;
  final String description;
  final String username;
  final List<String> movieIds;
  final String createdAt;

  MovieList({
    required this.id,
    required this.name,
    this.description = '',
    required this.username,
    this.movieIds = const [],
    this.createdAt = '',
  });

  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      username: json['username'] ?? '',
      movieIds: List<String>.from(json['movieIds'] ?? []),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
