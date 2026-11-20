import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../controllers/game_controller.dart';

/// Tablero interactivo 6x6.
///  - Mouse (Chrome): clic o arrastrar con el botón presionado.
///  - Táctil (móvil): tocar o deslizar el dedo.
class ZipBoard extends StatelessWidget {
  const ZipBoard({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final rules = controller.rules!;
    final size = rules.size;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(builder: (context, constraints) {
      final side = math.min(constraints.maxWidth, 460.0);
      final cell = side / size;

      int? cellAt(Offset p) {
        if (p.dx < 0 || p.dy < 0 || p.dx >= side || p.dy >= side) return null;
        return (p.dy ~/ cell) * size + (p.dx ~/ cell);
      }

      return Center(
        child: SizedBox(
          key: const Key('zip_board'),
          width: side,
          height: side,
          child: GestureDetector(
            onTapUp: (d) {
              final c = cellAt(d.localPosition);
              if (c != null) controller.tapCell(c);
            },
            onPanStart: (d) {
              final c = cellAt(d.localPosition);
              if (c != null) controller.dragToCell(c);
            },
            onPanUpdate: (d) {
              final c = cellAt(d.localPosition);
              if (c != null) controller.dragToCell(c);
            },
            onPanEnd: (_) => controller.endDrag(),
            child: Stack(children: [
              // 1) Celdas
              for (var i = 0; i < size * size; i++)
                Positioned(
                  left: (i % size) * cell,
                  top: (i ~/ size) * cell,
                  width: cell,
                  height: cell,
                  child: _Cell(
                    key: Key('cell_$i'),
                    visited: controller.path.contains(i),
                    invalid: controller.invalidCell == i,
                    hinted: controller.hintCell == i,
                    completed: controller.isComplete,
                    scheme: scheme,
                  ),
                ),
              // 2) Línea del camino
              IgnorePointer(
                child: CustomPaint(
                  size: Size(side, side),
                  painter: _PathPainter(
                    path: List.of(controller.path),
                    size: size,
                    color: controller.isComplete ? Colors.green : scheme.primary,
                  ),
                ),
              ),
              // 3) Números (checkpoints)
              for (var n = 0; n < rules.checkpoints.length; n++)
                Positioned(
                  left: (rules.checkpoints[n] % size) * cell + cell * 0.2,
                  top: (rules.checkpoints[n] ~/ size) * cell + cell * 0.2,
                  width: cell * 0.6,
                  height: cell * 0.6,
                  child: IgnorePointer(
                    child: Container(
                      key: Key('checkpoint_${n + 1}'),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: n + 1 < controller.nextCheckpoint
                            ? scheme.primary
                            : Colors.black87,
                      ),
                      child: Text(
                        '${n + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: cell * 0.26,
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      );
    });
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.visited,
    required this.invalid,
    required this.hinted,
    required this.completed,
    required this.scheme,
  });

  final bool visited;
  final bool invalid;
  final bool hinted;
  final bool completed;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    Color color = scheme.surfaceContainerHighest;
    if (visited) color = completed ? Colors.green.shade100 : scheme.primaryContainer;
    if (invalid) color = Colors.red.shade300;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: hinted ? Border.all(color: Colors.amber.shade700, width: 4) : null,
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({required this.path, required this.size, required this.color});

  final List<int> path;
  final int size;
  final Color color;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (path.isEmpty) return;
    final cell = canvasSize.width / size;
    Offset center(int i) => Offset((i % size + 0.5) * cell, (i ~/ size + 0.5) * cell);

    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = cell * 0.32
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final line = Path()..moveTo(center(path.first).dx, center(path.first).dy);
    for (final i in path.skip(1)) {
      line.lineTo(center(i).dx, center(i).dy);
    }
    canvas.drawPath(line, paint);
    canvas.drawCircle(center(path.last), cell * 0.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.path.length != path.length || old.color != color || !_same(old.path, path);

  bool _same(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
