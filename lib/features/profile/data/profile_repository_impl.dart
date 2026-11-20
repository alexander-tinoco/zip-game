import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Profile> getProfile() async {
    final json = await _api.get(ApiConstants.me) as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;
    final stats = json['stats'] as Map<String, dynamic>;
    return Profile(
      username: user['username'] as String,
      email: user['email'] as String,
      recommendedDifficulty: user['recommended_difficulty'] as String,
      gamesPlayed: stats['games_played'] as int,
      gamesCompleted: stats['games_completed'] as int,
      levelsCompleted: stats['levels_completed'] as int,
      totalPoints: stats['total_points'] as int,
      bestScore: stats['best_score'] as int,
      completedLevels: (json['completed_levels'] as List).map((e) {
        final l = e as Map<String, dynamic>;
        return (
          name: l['name'] as String,
          difficulty: l['difficulty'] as String,
          bestScore: (l['best_score'] as int?) ?? 0,
        );
      }).toList(),
    );
  }

  @override
  Future<List<HistoryEntry>> getHistory({int page = 1}) async {
    final json = await _api.get(ApiConstants.history, query: {'page': '$page', 'per_page': '20'})
        as Map<String, dynamic>;
    return (json['data'] as List).map((e) {
      final row = e as Map<String, dynamic>;
      return HistoryEntry(
        id: row['id'] as int,
        levelName: (row['level'] as Map<String, dynamic>)['name'] as String,
        status: row['status'] as String,
        difficulty: row['difficulty'] as String,
        durationSeconds: row['duration_seconds'] as int?,
        points: row['points'] as int?,
        startedAt: DateTime.tryParse((row['started_at'] as String?) ?? ''),
      );
    }).toList();
  }
}
