import 'package:flutter_test/flutter_test.dart';
import 'package:zip_game/features/game/domain/entities/game_entities.dart';
import 'package:zip_game/features/game/presentation/controllers/game_controller.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeGameRepository repo;
  late GameController controller;

  setUp(() async {
    repo = FakeGameRepository();
    controller = GameController(repo);
    await controller.start(levelId: 1);
  });

  tearDown(() => controller.dispose());

  test('starts in playing state with an empty path', () {
    expect(controller.status, GameStatus.playing);
    expect(controller.path, isEmpty);
    expect(controller.nextCheckpoint, 1);
  });

  test('valid movements extend the path', () {
    controller.tapCell(0);
    controller.tapCell(1);
    expect(controller.path, [0, 1]);
    expect(controller.mistakes, 0);
  });

  test('invalid movements are rejected and counted as mistakes', () {
    controller.tapCell(0);
    controller.tapCell(7); // diagonal
    expect(controller.path, [0]);
    expect(controller.mistakes, 1);
    expect(controller.invalidCell, 7);
    expect(controller.moves.last.type, MoveType.invalid);
  });

  test('undo removes the last cell', () {
    controller.tapCell(0);
    controller.tapCell(1);
    controller.undo();
    expect(controller.path, [0]);
  });

  test('dragging back to the previous cell undoes the move', () {
    controller.dragToCell(0);
    controller.dragToCell(1);
    controller.dragToCell(0);
    expect(controller.path, [0]);
  });

  test('restart clears the path', () {
    controller.tapCell(0);
    controller.tapCell(1);
    controller.restart();
    expect(controller.path, isEmpty);
    expect(controller.moves.last.type, MoveType.restart);
  });

  test('hints come from the repository and are counted', () async {
    controller.tapCell(0);
    await controller.requestHint();
    expect(controller.hintCell, 1);
    expect(controller.hintsUsed, 1);
  });

  test('completing the board submits it and shows the server result', () async {
    for (final cell in serpentine()) {
      controller.tapCell(cell);
    }
    await pumpEventQueue();
    expect(controller.status, GameStatus.completed);
    expect(controller.result, isNotNull);
    expect(controller.result!.points, 1200);
    expect(repo.lastMoves!.length, 36);
  });
}
