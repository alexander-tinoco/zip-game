import 'package:flutter_test/flutter_test.dart';
import 'package:zip_game/features/game/domain/services/zip_rules.dart';

import '../helpers/fakes.dart';

void main() {
  final level = tutorialLevel();
  final rules = ZipRules(size: 6, checkpoints: level.checkpoints);
  final solution = serpentine();

  group('ZipRules', () {
    test('the first move must be the cell with number 1', () {
      expect(rules.canMove([], 0).valid, isTrue);
      expect(rules.canMove([], 1).error, MoveError.mustStartOnOne);
    });

    test('horizontal and vertical moves are allowed', () {
      expect(rules.canMove([0], 1).valid, isTrue);
      expect(rules.canMove([0], 6).valid, isTrue);
    });

    test('diagonal moves and jumps are rejected', () {
      expect(rules.canMove([0], 7).error, MoveError.notAdjacent);
      expect(rules.canMove([0], 2).error, MoveError.notAdjacent);
    });

    test('a cell cannot be visited twice', () {
      expect(rules.canMove([0, 1, 7, 6], 0).error, MoveError.alreadyVisited);
    });

    test('numbers must be connected in ascending order', () {
      // Checkpoint 3 está en la celda 7 (posición 10 del camino); llegar antes que el 2 es error
      final custom = ZipRules(size: 6, checkpoints: [0, 5, 1, 35]);
      expect(custom.canMove([0], 1).error, MoveError.wrongCheckpoint);
    });

    test('the last number cannot be reached before filling the board', () {
      final custom = ZipRules(size: 6, checkpoints: [0, 1]);
      expect(custom.canMove([0], 1).error, MoveError.lastCheckpointTooEarly);
    });

    test('detects a complete solution', () {
      expect(rules.isComplete(solution), isTrue);
      expect(rules.isComplete(solution.sublist(0, 35)), isFalse);
    });

    test('computes the next checkpoint', () {
      expect(rules.nextCheckpoint([]), 1);
      expect(rules.nextCheckpoint(solution.sublist(0, 6)), 3);
      expect(rules.nextCheckpoint(solution), 9);
    });
  });
}
