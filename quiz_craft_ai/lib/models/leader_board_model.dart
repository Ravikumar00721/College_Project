class LeaderboardUser {
  final int rank;
  final String name;
  final int score;
  final String? imageUrl;
  final String category;
  final String subCategory;
  final String subject;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.score,
    this.imageUrl,
    required this.category,
    required this.subCategory,
    required this.subject,
  });
}

class FilterCategory {
  final String type;
  final String? subType;
  final String? subject;

  FilterCategory({required this.type, this.subType, this.subject});
}
