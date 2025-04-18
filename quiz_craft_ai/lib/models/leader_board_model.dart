class LeaderboardUser {
  final int rank;
  final String userId;
  final String name;
  final int score;
  final String? imageUrl;
  final String category;
  final String subCategory;
  final String subject;

  const LeaderboardUser({
    required this.rank,
    required this.userId,
    required this.name,
    required this.score,
    this.imageUrl,
    required this.category,
    required this.subCategory,
    required this.subject,
  });

  LeaderboardUser copyWith({
    int? rank,
    String? userId,
    String? name,
    int? score,
    String? imageUrl,
    String? category,
    String? subCategory,
    String? subject,
  }) {
    return LeaderboardUser(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      score: score ?? this.score,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      subject: subject ?? this.subject,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LeaderboardUser &&
        other.runtimeType == runtimeType &&
        other.rank == rank &&
        other.userId == userId &&
        other.name == name &&
        other.score == score &&
        other.imageUrl == imageUrl &&
        other.category == category &&
        other.subCategory == subCategory &&
        other.subject == subject;
  }

  @override
  int get hashCode {
    return Object.hash(
      rank,
      userId,
      name,
      score,
      imageUrl,
      category,
      subCategory,
      subject,
    );
  }

  @override
  String toString() {
    return 'LeaderboardUser(rank: $rank, userId: $userId, name: $name, score: $score, '
        'imageUrl: $imageUrl, category: $category, subCategory: $subCategory, '
        'subject: $subject)';
  }
}

class FilterCategory {
  final String type;
  final String? subType;
  final String? subject;

  const FilterCategory({
    required this.type,
    this.subType,
    this.subject,
  });

  FilterCategory copyWith({
    String? type,
    String? subType,
    String? subject,
  }) {
    return FilterCategory(
      type: type ?? this.type,
      subType: subType ?? this.subType,
      subject: subject ?? this.subject,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FilterCategory &&
        other.runtimeType == runtimeType &&
        other.type == type &&
        other.subType == subType &&
        other.subject == subject;
  }

  @override
  int get hashCode => Object.hash(type, subType, subject);

  @override
  String toString() {
    return 'FilterCategory(type: $type, subType: $subType, subject: $subject)';
  }
}
