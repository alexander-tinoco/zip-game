import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/leaderboard_entry.dart';

/// Datasource + repositorio del ranking (módulo pequeño: una sola clase en la capa data).
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<LeaderboardEntry>> top({int limit = 20}) async {
    final json = await _api.get(ApiConstants.leaderboard, query: {'limit': '$limit'})
        as Map<String, dynamic>;
    return (json['data'] as List).map((e) {
      final row = e as Map<String, dynamic>;
      return LeaderboardEntry(
        rank: row['rank'] as int,
        userId: row['user_id'] as int,
        username: row['username'] as String,
        totalScore: row['total_score'] as int,
        levelsCompleted: row['levels_completed'] as int,
        totalTimeSeconds: row['total_time_seconds'] as int,
      );
    }).toList();
  }
}
