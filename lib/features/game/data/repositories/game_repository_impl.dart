import '../../../levels/domain/entities/level.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_remote_datasource.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._remote);

  final GameRemoteDataSource _remote;

  @override
  Future<({GameSession session, Level level})> startGame({int? levelId}) async {
    final result = await _remote.start(levelId: levelId);
    return (session: result.session, level: result.level);
  }

  @override
  Future<Hint> requestHint(int sessionId, List<int> path) => _remote.hint(sessionId, path);

  @override
  Future<GameResult> finishGame(int sessionId, List<int> path, List<MoveRecord> moves) =>
      _remote.finish(sessionId, path, moves);
}
