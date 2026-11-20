/// Fila del ranking
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.totalScore,
    required this.levelsCompleted,
    required this.totalTimeSeconds,
  });

  final int rank;
  final int userId;
  final String username;
  final int totalScore;
  final int levelsCompleted;
  final int totalTimeSeconds;
}

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> top({int limit = 20});
}
