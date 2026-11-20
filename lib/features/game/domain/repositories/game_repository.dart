import '../../../levels/domain/entities/level.dart';
import '../entities/game_entities.dart';

/// Contrato para la comunicación de partidas con el backend.
abstract class GameRepository {
  /// Inicia una sesión. Si [levelId] es null el backend elige un nivel
  /// según la dificultad adaptativa.
  Future<({GameSession session, Level level})> startGame({int? levelId});

  /// Pide una pista para el camino actual (el backend la valida y la cuenta).
  Future<Hint> requestHint(int sessionId, List<int> path);

  /// Envía la solución. Lanza ApiException(422) si el backend la rechaza.
  Future<GameResult> finishGame(int sessionId, List<int> path, List<MoveRecord> moves);
}
