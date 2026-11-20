import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../levels/data/models/level_model.dart';
import '../../domain/entities/game_entities.dart';
import '../models/game_models.dart';

class GameRemoteDataSource {
  GameRemoteDataSource(this._api);

  final ApiClient _api;

  Future<({GameSessionModel session, LevelModel level})> start({int? levelId}) async {
    final json = await _api.post(ApiConstants.games, body: {
      'level_id': ?levelId,
    }) as Map<String, dynamic>;
    return (
      session: GameSessionModel.fromJson(json['session'] as Map<String, dynamic>),
      level: LevelModel.fromJson(json['level'] as Map<String, dynamic>),
    );
  }

  Future<HintModel> hint(int sessionId, List<int> path) async {
    final json = await _api.post(ApiConstants.hint(sessionId), body: {'path': path})
        as Map<String, dynamic>;
    return HintModel.fromJson(json);
  }

  Future<GameResultModel> finish(int sessionId, List<int> path, List<MoveRecord> moves) async {
    final json = await _api.post(ApiConstants.finish(sessionId), body: {
      'path': path,
      'moves': moves.map(moveToJson).toList(),
    }) as Map<String, dynamic>;
    return GameResultModel.fromJson(json);
  }
}
