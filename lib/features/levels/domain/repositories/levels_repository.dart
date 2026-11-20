import '../entities/level.dart';

class LevelsPage {
  const LevelsPage({required this.levels, required this.recommendedDifficulty});

  final List<Level> levels;
  final String recommendedDifficulty;
}

abstract class LevelsRepository {
  Future<LevelsPage> getLevels({String? difficulty});

  Future<Level> getLevel(int id);

  /// Pide al backend que genere y guarde un nivel nuevo
  Future<Level> generate(String difficulty);
}
