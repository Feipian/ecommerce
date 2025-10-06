class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final DateTime releaseDate;


  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.releaseDate,
  });

  factory Movie.fromFirestore(Map<String, dynamic> data, String docId) {
    return Movie(
      id: docId,
      title: data['title'],
      description: data['description'],
      posterUrl: data['posterUrl'],
      releaseDate: data['releaseDate'].toDate(),
    );
  }
}

