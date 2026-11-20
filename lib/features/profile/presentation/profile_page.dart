import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_view.dart';
import '../domain/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<(Profile, List<HistoryEntry>)> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _load();
  }

  Future<(Profile, List<HistoryEntry>)> _load() async {
    final repo = AppScope.of(context).profileRepository;
    final results = await Future.wait([repo.getProfile(), repo.getHistory()]);
    return (results[0] as Profile, results[1] as List<HistoryEntry>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: AsyncView<(Profile, List<HistoryEntry>)>(
        future: _future,
        onRetry: () => setState(() => _future = _load()),
        builder: (data) {
          final (profile, history) = data;
          final text = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: CircleAvatar(child: Text(profile.username[0].toUpperCase())),
                title: Text(profile.username, style: text.titleLarge),
                subtitle: Text(profile.email),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _stat('Puntos totales', '${profile.totalPoints}'),
                _stat('Mejor puntaje', '${profile.bestScore}'),
                _stat('Niveles completados', '${profile.levelsCompleted}'),
                _stat('Partidas jugadas', '${profile.gamesPlayed}'),
                _stat('Dificultad recomendada', difficultyLabel(profile.recommendedDifficulty)),
              ]),
              const SizedBox(height: 16),
              Text('Niveles completados', style: text.titleMedium),
              if (profile.completedLevels.isEmpty) const Text('Todavía no completas ningún nivel.'),
              for (final l in profile.completedLevels)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(l.name),
                  subtitle: Text(difficultyLabel(l.difficulty)),
                  trailing: Text('${l.bestScore} pts'),
                ),
              const SizedBox(height: 16),
              Text('Historial de partidas', style: text.titleMedium),
              if (history.isEmpty) const Text('Sin partidas registradas.'),
              for (final h in history)
                ListTile(
                  dense: true,
                  leading: Icon(
                    h.status == 'completed' ? Icons.emoji_events : Icons.hourglass_bottom,
                    color: h.status == 'completed' ? Colors.amber : null,
                  ),
                  title: Text('${h.levelName} · ${difficultyLabel(h.difficulty)}'),
                  subtitle: Text(h.status == 'completed'
                      ? 'Tiempo ${formatDuration(h.durationSeconds ?? 0)}'
                      : 'En progreso / sin terminar'),
                  trailing: Text(h.points == null ? '-' : '${h.points} pts'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value) => SizedBox(
        width: 160,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ),
      );
}
