class CineUpdate {
  final String id;
  final String title;
  final String body;
  final String category;
  final String movieName;
  final String imageUrl;
  final String timestamp;
  final int likes;
  final List<String> likedBy;

  CineUpdate({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.movieName,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
  });

  factory CineUpdate.fromJson(Map<String, dynamic> json) {
    return CineUpdate(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      category: json['category'] ?? '',
      movieName: json['movieName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      timestamp: json['timestamp'] ?? '',
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }
}
