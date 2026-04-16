class UserStats {
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int tasksCompleted;
  final int currentStreak;
  final int productivityScore;

  UserStats({
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.tasksCompleted,
    required this.currentStreak,
    required this.productivityScore,
  });

  UserStats copyWith({
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? tasksCompleted,
    int? currentStreak,
    int? productivityScore,
  }) {
    return UserStats(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      productivityScore: productivityScore ?? this.productivityScore,
    );
  }

  double get xpProgress => (xp / xpToNextLevel) * 100;

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
      'tasksCompleted': tasksCompleted,
      'currentStreak': currentStreak,
      'productivityScore': productivityScore,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      level: json['level'],
      xp: json['xp'],
      xpToNextLevel: json['xpToNextLevel'],
      tasksCompleted: json['tasksCompleted'],
      currentStreak: json['currentStreak'],
      productivityScore: json['productivityScore'],
    );
  }
}
