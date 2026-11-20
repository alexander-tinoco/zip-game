import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/game/presentation/pages/game_page.dart';
import '../../features/leaderboard/presentation/leaderboard_page.dart';
import '../../features/levels/presentation/pages/levels_page.dart';
import '../../features/profile/presentation/profile_page.dart';

/// Rutas con nombre de la aplicación
class AppRoutes {
  AppRoutes._();

  static const register = '/register';
  static const levels = '/levels';
  static const game = '/game'; // argumento opcional: int levelId
  static const leaderboard = '/leaderboard';
  static const profile = '/profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case register:
        page = const RegisterPage();
      case levels:
        page = const LevelsPage();
      case game:
        page = GamePage(levelId: settings.arguments as int?);
      case leaderboard:
        page = const LeaderboardPage();
      case profile:
        page = const ProfilePage();
      default:
        return null;
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
