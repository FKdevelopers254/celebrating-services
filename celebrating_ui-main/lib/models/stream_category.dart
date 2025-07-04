class StreamCategory {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int streamCount;
  final int followerCount;
  final String coverUrl;
  final List<String> tags;

  StreamCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.streamCount,
    required this.followerCount,
    required this.coverUrl,
    required this.tags,
  });

  factory StreamCategory.fromJson(Map<String, dynamic> json) => StreamCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
        streamCount: json['streamCount'] as int,
        followerCount: json['followerCount'] as int,
        coverUrl: json['coverUrl'] as String,
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      );
}
