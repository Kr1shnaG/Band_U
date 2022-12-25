class Album {
  final String image;

  const Album({
    required this.image,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    print(json);
    return Album(
      image: json['images'][2]['url'] as String,
    );
  }
}
