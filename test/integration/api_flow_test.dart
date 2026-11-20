// Prueba de INTEGRACIÓN contra el backend real (AdonisJS + MySQL).
//
// Requisitos: backend encendido (`node ace serve --hmr`) y seeders ejecutados.
// Ejecutar:
//   flutter test test/integration --dart-define=INTEGRATION=true
//
// Flujo: registrar -> obtener niveles -> iniciar partida -> construir la
// solución pidiendo pistas al servidor -> enviar -> recibir puntaje validado.
import 'package:flutter_test/flutter_test.dart';
import 'package:zip_game/core/network/api_client.dart';
import 'package:zip_game/core/network/token_storage.dart';
import 'package:zip_game/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:zip_game/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zip_game/features/game/data/datasources/game_remote_datasource.dart';
import 'package:zip_game/features/game/data/repositories/game_repository_impl.dart';
import 'package:zip_game/features/game/domain/entities/game_entities.dart';
import 'package:zip_game/features/levels/data/datasources/levels_remote_datasource.dart';
import 'package:zip_game/features/levels/data/repositories/levels_repository_impl.dart';

const runIntegration = bool.fromEnvironment('INTEGRATION');

void main() {
  test(
    'Flutter retrieves a level, plays it and gets the backend result',
    () async {
      final api = ApiClient(tokenStorage: MemoryTokenStorage());
      final auth = AuthRepositoryImpl(AuthRemoteDataSource(api), api.tokenStorage);
      final levels = LevelsRepositoryImpl(LevelsRemoteDataSource(api));
      final games = GameRepositoryImpl(GameRemoteDataSource(api));

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final user = await auth.register(
        username: 'it_$stamp',
        email: 'it_$stamp@zipgame.test',
        password: 'integration123',
      );
      expect(user.username, 'it_$stamp');

      final page = await levels.getLevels();
      expect(page.levels, isNotEmpty);
      final level = page.levels.first;

      final started = await games.startGame(levelId: level.id);
      expect(started.level.checkpoints, level.checkpoints);

      // Se construye la solución con las pistas del servidor
      final path = <int>[];
      final moves = <MoveRecord>[];
      while (path.length < level.totalCells) {
        final hint = await games.requestHint(started.session.id, path);
        expect(hint.type, HintType.next);
        path.add(hint.nextCell);
        moves.add(MoveRecord(type: MoveType.add, cell: hint.nextCell, elapsedMs: 0));
      }

      final result = await games.finishGame(started.session.id, path, moves);
      expect(result.hintsUsed, level.totalCells);
      expect(result.points, greaterThan(0));
    },
    skip: runIntegration ? false : 'Usa --dart-define=INTEGRATION=true con el backend encendido',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
