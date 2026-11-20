import 'package:material_ui/material_ui.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/utils/formatters.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_hud.dart';
import '../widgets/result_summary.dart';
import '../widgets/zip_board.dart';

/// Pantalla de juego. Si [levelId] es null el backend elige el nivel
/// según la dificultad adaptativa del jugador.
class GamePage extends StatefulWidget {
  const GamePage({super.key, this.levelId});

  final int? levelId;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = GameController(AppScope.of(context).gameRepository);
      _controller!.addListener(_onChange);
      _controller!.start(levelId: widget.levelId);
    }
  }

  Object? _reportedResult;

  void _onChange() {
    final result = _controller!.result;
    // Actualiza (una sola vez) la dificultad recomendada del usuario al terminar
    if (result != null && !identical(result, _reportedResult)) {
      _reportedResult = result;
      AppScope.of(context).authController.updateRecommendedDifficulty(result.recommendedDifficulty);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChange);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final level = controller.level;
        return Scaffold(
          appBar: AppBar(
            title: Text(level == null
                ? 'ZIP Game'
                : '${level.name} · ${difficultyLabel(level.difficulty)}'),
          ),
          body: SafeArea(child: _body(context, controller)),
        );
      },
    );
  }

  Widget _body(BuildContext context, GameController c) {
    switch (c.status) {
      case GameStatus.idle:
      case GameStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case GameStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(c.error ?? 'Error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => c.start(levelId: widget.levelId),
                child: const Text('Reintentar'),
              ),
            ]),
          ),
        );
      default:
        break;
    }

    final busy = c.status == GameStatus.submitting;
    final invalidMessage = c.invalidCell != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(children: [
            GameHud(controller: c),
            const SizedBox(height: 12),
            ZipBoard(controller: c),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: c.message == null
                  ? const SizedBox(height: 24)
                  : Text(
                      c.message!,
                      key: ValueKey(c.message),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: invalidMessage ? Colors.red.shade700 : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            if (c.status == GameStatus.completed && c.result != null)
              ResultSummary(
                result: c.result!,
                onBack: () => Navigator.of(context).pop(),
                onPlayNext: () => c.start(),
              )
            else
              Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                OutlinedButton.icon(
                  key: const Key('btn_undo'),
                  onPressed: busy || c.path.isEmpty ? null : c.undo,
                  icon: const Icon(Icons.undo),
                  label: const Text('Deshacer'),
                ),
                OutlinedButton.icon(
                  key: const Key('btn_restart'),
                  onPressed: busy ? null : c.restart,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reiniciar'),
                ),
                FilledButton.tonalIcon(
                  key: const Key('btn_hint'),
                  onPressed: busy ? null : c.requestHint,
                  icon: const Icon(Icons.lightbulb),
                  label: const Text('Pista'),
                ),
                if (busy) const CircularProgressIndicator(),
              ]),
          ]),
        ),
      ),
    );
  }
}
