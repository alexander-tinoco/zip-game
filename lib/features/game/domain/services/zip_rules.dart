/// Motivos por los que un movimiento puede ser inválido.
enum MoveError {
  mustStartOnOne,
  notAdjacent,
  alreadyVisited,
  wrongCheckpoint,
  lastCheckpointTooEarly,
  complete,
}

/// Resultado de validar un movimiento.
class MoveCheck {
  const MoveCheck.ok()
      : valid = true,
        error = null;
  const MoveCheck.fail(this.error) : valid = false;

  final bool valid;
  final MoveError? error;
}

/// Reglas puras de ZIP (capa de dominio, sin Flutter ni HTTP).
///
/// Son las MISMAS reglas que valida el backend en GameValidatorService;
/// aquí se usan para dar retroalimentación inmediata al jugador.
class ZipRules {
  ZipRules({required this.size, required List<int> checkpoints})
      : checkpoints = List.unmodifiable(checkpoints),
        _numberAt = {for (var i = 0; i < checkpoints.length; i++) checkpoints[i]: i + 1};

  final int size;
  final List<int> checkpoints;
  final Map<int, int> _numberAt;

  int get totalCells => size * size;
  int get lastNumber => checkpoints.length;

  /// Número que contiene la celda (o null si no es checkpoint)
  int? numberAt(int cell) => _numberAt[cell];

  int rowOf(int cell) => cell ~/ size;
  int colOf(int cell) => cell % size;

  /// Sólo vecinos horizontales o verticales (sin diagonales)
  bool areAdjacent(int a, int b) =>
      (rowOf(a) - rowOf(b)).abs() + (colOf(a) - colOf(b)).abs() == 1;

  /// Siguiente número que el jugador debe alcanzar con el camino actual
  int nextCheckpoint(List<int> path) {
    var next = 1;
    for (final cell in path) {
      if (_numberAt[cell] == next) next++;
    }
    return next;
  }

  /// ¿Se puede extender [path] con [cell]?
  MoveCheck canMove(List<int> path, int cell) {
    if (path.length >= totalCells) return const MoveCheck.fail(MoveError.complete);

    if (path.isEmpty) {
      return cell == checkpoints.first
          ? const MoveCheck.ok()
          : const MoveCheck.fail(MoveError.mustStartOnOne);
    }
    if (path.contains(cell)) return const MoveCheck.fail(MoveError.alreadyVisited);
    if (!areAdjacent(path.last, cell)) return const MoveCheck.fail(MoveError.notAdjacent);

    final number = _numberAt[cell];
    if (number != null) {
      if (number != nextCheckpoint(path)) {
        return const MoveCheck.fail(MoveError.wrongCheckpoint);
      }
      if (number == lastNumber && path.length + 1 != totalCells) {
        return const MoveCheck.fail(MoveError.lastCheckpointTooEarly);
      }
    }
    return const MoveCheck.ok();
  }

  /// Completo: 36 celdas y termina en el número mayor
  bool isComplete(List<int> path) =>
      path.length == totalCells && path.last == checkpoints.last;

  static String describe(MoveError error) {
    switch (error) {
      case MoveError.mustStartOnOne:
        return 'Debes iniciar en el número 1';
      case MoveError.notAdjacent:
        return 'Sólo puedes moverte en horizontal o vertical a una celda vecina';
      case MoveError.alreadyVisited:
        return 'No puedes pasar dos veces por la misma celda';
      case MoveError.wrongCheckpoint:
        return 'Debes conectar los números en orden ascendente';
      case MoveError.lastCheckpointTooEarly:
        return 'Llena todas las celdas antes de llegar al último número';
      case MoveError.complete:
        return 'El camino ya está completo';
    }
  }
}
