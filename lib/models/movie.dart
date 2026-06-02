class CastMember {
  final String name;
  final String role;
  final String avatarUrl;

  CastMember({required this.name, required this.role, required this.avatarUrl});

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}

class ReviewReply {
  final String id;
  final String author;
  final String body;
  final String timestamp;

  ReviewReply({required this.id, required this.author, required this.body, required this.timestamp});

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      body: json['body'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class Review {
  final String id;
  final String user;
  final String avatarUrl;
  final String role;
  final double rating;
  final String text;
  final String timestamp;
  final int likes;
  final int comments;
  final List<String> likedBy;
  final List<ReviewReply> replies;

  Review({
    required this.id,
    required this.user,
    required this.avatarUrl,
    required this.role,
    required this.rating,
    required this.text,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
    this.replies = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      user: json['user'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      role: json['role'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      text: json['text'] ?? '',
      timestamp: json['timestamp'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      replies: (json['replies'] as List?)
              ?.map((r) => ReviewReply.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class OttInfo {
  final String platform;
  final String releaseDate;
  final String url;

  OttInfo({required this.platform, required this.releaseDate, required this.url});

  factory OttInfo.fromJson(Map<String, dynamic> json) {
    return OttInfo(
      platform: json['platform'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class Movie {
  final String id;
  final String title;
  final String description;
  final double rating;
  final double criticScore;
  final int audienceScore;
  final String genre;
  final int releaseYear;
  final String runtime;
  final String director;
  final String writer;
  final String studio;
  final String releaseDate;
  final String language;
  final String posterUrl;
  final String backdropUrl;
  final int? tmdbId;
  final bool isHero;
  final bool isStaffPick;
  final String staffPickType;
  final bool isUpcoming;
  final String trailerUrl;
  final String trailerChannelName;
  final OttInfo? ott;
  final List<CastMember> cast;
  final List<Review> reviews;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    this.rating = 0,
    this.criticScore = 0,
    this.audienceScore = 0,
    required this.genre,
    required this.releaseYear,
    this.runtime = '',
    this.director = '',
    this.writer = '',
    this.studio = '',
    this.releaseDate = '',
    this.language = '',
    this.posterUrl = '',
    this.backdropUrl = '',
    this.tmdbId,
    this.isHero = false,
    this.isStaffPick = false,
    this.staffPickType = '',
    this.isUpcoming = false,
    this.trailerUrl = '',
    this.trailerChannelName = '',
    this.ott,
    this.cast = const [],
    this.reviews = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      criticScore: (json['criticScore'] ?? 0).toDouble(),
      audienceScore: json['audienceScore'] ?? 0,
      genre: json['genre'] ?? '',
      releaseYear: json['releaseYear'] ?? 0,
      runtime: json['runtime'] ?? '',
      director: json['director'] ?? '',
      writer: json['writer'] ?? '',
      studio: json['studio'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      language: json['language'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      backdropUrl: json['backdropUrl'] ?? '',
      tmdbId: json['tmdbId'],
      isHero: json['isHero'] ?? false,
      isStaffPick: json['isStaffPick'] ?? false,
      staffPickType: json['staffPickType'] ?? '',
      isUpcoming: json['isUpcoming'] ?? false,
      trailerUrl: json['trailerUrl'] ?? '',
      trailerChannelName: json['trailerChannelName'] ?? '',
      ott: json['ott'] != null ? OttInfo.fromJson(json['ott']) : null,
      cast: (json['cast'] as List?)
              ?.map((c) => CastMember.fromJson(c))
              .toList() ??
          [],
      reviews: (json['reviews'] as List?)
              ?.map((r) => Review.fromJson(r))
              .toList() ??
          [],
    );
  }

  double get displayRating => rating;
}
