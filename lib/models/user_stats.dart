class UserStats {
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int currentStreak;
  final int productivityScore;
  final int tasksCompleted;

  UserStats({
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.currentStreak,
    required this.productivityScore,
    required this.tasksCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
      'currentStreak': currentStreak,
      'productivityScore': productivityScore,
      'tasksCompleted': tasksCompleted,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      level: json['level'] ?? 0,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 1000,
      currentStreak: json['currentStreak'] ?? 0,
      productivityScore: json['productivityScore'] ?? 0,
      tasksCompleted: json['tasksCompleted'] ?? 0,
    );
  }
}