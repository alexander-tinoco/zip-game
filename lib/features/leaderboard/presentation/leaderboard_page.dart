import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_view.dart';
import '../domain/leaderboard_entry.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = AppScope.of(context).leaderboardRepository.top();
  }

  @override
  Widget build(BuildContext context) {
    final me = AppScope.of(context).authController.user?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = AppScope.of(context).leaderboardRepository.top());
          await _future;
        },
        child: AsyncView<List<LeaderboardEntry>>(
          future: _future,
          isEmpty: (rows) => rows.isEmpty,
          emptyMessage: 'Aún no hay puntajes. ¡Sé el primero!',
          onRetry: () => setState(() => _future = AppScope.of(context).leaderboardRepository.top()),
          builder: (rows) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Regla: suma del mejor puntaje de cada nivel. '
                  'Empates: más niveles completados y luego menor tiempo total.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              for (final row in rows)
                Card(
                  color: row.userId == me ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: switch (row.rank) {
                        1 => Colors.amber,
                        2 => Colors.grey.shade400,
                        3 => Colors.brown.shade300,
                        _ => null,
                      },
                      child: Text('${row.rank}'),
                    ),
                    title: Text(row.username),
                    subtitle: Text(
                      '${row.levelsCompleted} niveles · ${formatDuration(row.totalTimeSeconds)}',
                    ),
                    trailing: Text(
                      '${row.totalScore}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
