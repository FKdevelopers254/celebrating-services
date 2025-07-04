class CelebrityProfile {
  final String id;
  final String userId;
  final String? stageName;
  final List<String> professions;
  final List<String> majorAchievements;
  final List<String> notableProjects;
  final List<String> collaborations;
  final String? netWorth;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CelebrityProfile({
    required this.id,
    required this.userId,
    this.stageName,
    this.professions = const [],
    this.majorAchievements = const [],
    this.notableProjects = const [],
    this.collaborations = const [],
    this.netWorth,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CelebrityProfile.fromJson(Map<String, dynamic> json) {
    return CelebrityProfile(
      id: json['id'],
      userId: json['userId'],
      stageName: json['stageName'],
      professions: List<String>.from(json['professions'] ?? []),
      majorAchievements: List<String>.from(json['majorAchievements'] ?? []),
      notableProjects: List<String>.from(json['notableProjects'] ?? []),
      collaborations: List<String>.from(json['collaborations'] ?? []),
      netWorth: json['netWorth'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stageName': stageName,
      'professions': professions,
      'majorAchievements': majorAchievements,
      'notableProjects': notableProjects,
      'collaborations': collaborations,
      'netWorth': netWorth,
      if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
