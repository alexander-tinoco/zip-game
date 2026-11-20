/// Perfil del jugador con estadísticas
class Profile {
  const Profile({
    required this.username,
    required this.email,
    required this.recommendedDifficulty,
    required this.gamesPlayed,
    required this.gamesCompleted,
    required this.levelsCompleted,
    required this.totalPoints,
    required this.bestScore,
    required this.completedLevels,
  });

  final String username;
  final String email;
  final String recommendedDifficulty;
  final int gamesPlayed;
  final int gamesCompleted;
  final int levelsCompleted;
  final int totalPoints;
  final int bestScore;
  final List<({String name, String difficulty, int bestScore})> completedLevels;
}

/// Partida del historial
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.levelName,
    required this.status,
    required this.difficulty,
    this.durationSeconds,
    this.points,
    this.startedAt,
  });

  final int id;
  final String levelName;
  final String status;
  final String difficulty;
  final int? durationSeconds;
  final int? points;
  final DateTime? startedAt;
}

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<List<HistoryEntry>> getHistory({int page = 1});
}
