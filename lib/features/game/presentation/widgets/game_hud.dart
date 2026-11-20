import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../controllers/game_controller.dart';

/// Barra de información: cronómetro, progreso, siguiente número, errores y pistas.
class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final rules = controller.rules!;
    final next = controller.nextCheckpoint;
    final nextLabel = next > rules.lastNumber ? '✓' : '$next';

    return Column(children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _Stat(
            key: const Key('hud_timer'),
            icon: Icons.timer_outlined,
            label: formatDuration(controller.elapsed.inSeconds),
          ),
          _Stat(
            key: const Key('hud_progress'),
            icon: Icons.grid_on,
            label: '${controller.progress}/${controller.totalCells}',
          ),
          _Stat(key: const Key('hud_next'), icon: Icons.flag_outlined, label: 'Sig: $nextLabel'),
          _Stat(
            key: const Key('hud_mistakes'),
            icon: Icons.close,
            label: 'Errores: ${controller.mistakes}',
          ),
          _Stat(
            key: const Key('hud_hints'),
            icon: Icons.lightbulb_outline,
            label: 'Pistas: ${controller.hintsUsed}',
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          minHeight: 8,
          value: controller.progress / controller.totalCells,
        ),
      ),
    ]);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
