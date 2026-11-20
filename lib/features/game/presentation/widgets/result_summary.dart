import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/game_entities.dart';

/// Resumen del resultado VALIDADO por el backend.
class ResultSummary extends StatelessWidget {
  const ResultSummary({
    super.key,
    required this.result,
    required this.onPlayNext,
    required this.onBack,
  });

  final GameResult result;
  final VoidCallback onPlayNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final b = result.breakdown;
    final changeText = switch (result.difficultyChange) {
      'increase' => '¡Subes de dificultad! Próximo reto: ${difficultyLabel(result.recommendedDifficulty)}',
      'decrease' => 'Bajamos la dificultad a ${difficultyLabel(result.recommendedDifficulty)}',
      _ => 'Dificultad recomendada: ${difficultyLabel(result.recommendedDifficulty)}',
    };

    return Card(
      key: const Key('result_summary'),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
          Text('¡Puzzle resuelto!', style: text.headlineSmall),
          const SizedBox(height: 8),
          Text('${result.points} puntos',
              key: const Key('result_points'),
              style: text.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _row('Tiempo', formatDuration(result.durationSeconds)),
          _row('Errores', '${result.mistakes}'),
          _row('Pistas', '${result.hintsUsed}'),
          const Divider(),
          _row('Base', '+${b['base'] ?? 0}'),
          _row('Bonus de tiempo', '+${b['time_bonus'] ?? 0}'),
          _row('Penalización tiempo', '-${b['time_penalty'] ?? 0}'),
          _row('Penalización errores', '-${b['mistake_penalty'] ?? 0}'),
          _row('Penalización pistas', '-${b['hint_penalty'] ?? 0}'),
          const Divider(),
          Text(changeText, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: [
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.list),
              label: const Text('Niveles'),
            ),
            FilledButton.icon(
              key: const Key('play_next'),
              onPressed: onPlayNext,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Siguiente reto'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Expanded(child: Text(label)), Text(value)]),
      );
}
