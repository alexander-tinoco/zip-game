import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zip_game/app/app_scope.dart';
import 'package:zip_game/features/game/presentation/pages/game_page.dart';
import 'package:zip_game/features/leaderboard/domain/leaderboard_entry.dart';
import 'package:zip_game/features/levels/domain/entities/level.dart';
import 'package:zip_game/features/levels/domain/repositories/levels_repository.dart';
import 'package:zip_game/features/profile/domain/profile.dart';

import '../helpers/fakes.dart';

class _Unused implements LevelsRepository, LeaderboardRepository, ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  @override
  Future<LevelsPage> getLevels({String? difficulty}) => throw UnimplementedError();
  @override
  Future<Level> getLevel(int id) => throw UnimplementedError();
  @override
  Future<Level> generate(String difficulty) => throw UnimplementedError();
  @override
  Future<List<LeaderboardEntry>> top({int limit = 20}) => throw UnimplementedError();
  @override
  Future<Profile> getProfile() => throw UnimplementedError();
  @override
  Future<List<HistoryEntry>> getHistory({int page = 1}) => throw UnimplementedError();
}

Future<void> pumpGame(WidgetTester tester, FakeGameRepository repo) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final unused = _Unused();
  final deps = AppDependencies(
    authRepository: FakeAuthRepository(),
    levelsRepository: unused,
    gameRepository: repo,
    leaderboardRepository: unused,
    profileRepository: unused,
  );
  await deps.authController.restore();

  await tester.pumpWidget(AppScope(
    dependencies: deps,
    child: const MaterialApp(home: GamePage(levelId: 1)),
  ));
  await tester.pump(); // termina start()
}

void main() {
  testWidgets('renders the 6x6 board with its numbers', (tester) async {
    await pumpGame(tester, FakeGameRepository());

    expect(find.byKey(const Key('zip_board')), findsOneWidget);
    for (var i = 0; i < 36; i++) {
      expect(find.byKey(Key('cell_$i')), findsOneWidget);
    }
    for (var n = 1; n <= 8; n++) {
      expect(find.byKey(Key('checkpoint_$n')), findsOneWidget);
    }
    expect(find.text('0/36'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping cells shows valid and invalid feedback', (tester) async {
    await pumpGame(tester, FakeGameRepository());

    await tester.tap(find.byKey(const Key('cell_0')));
    await tester.pump();
    expect(find.text('1/36'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cell_7'))); // diagonal => inválido
    await tester.pump();
    expect(find.text('Errores: 1'), findsOneWidget);
    expect(find.textContaining('horizontal o vertical'), findsOneWidget);

    await tester.tap(find.byKey(const Key('btn_restart')));
    await tester.pump();
    expect(find.text('0/36'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('completing the puzzle shows the result returned by the backend', (tester) async {
    await pumpGame(tester, FakeGameRepository());

    for (final cell in serpentine()) {
      await tester.tap(find.byKey(Key('cell_$cell')));
      await tester.pump();
    }
    await tester.pump();

    expect(find.byKey(const Key('result_summary')), findsOneWidget);
    expect(find.text('1200 puntos'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
