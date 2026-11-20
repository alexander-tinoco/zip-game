/// Configuración de la API.
///
/// Se puede cambiar sin tocar código:
///   flutter run -d chrome --dart-define=API_URL=http://localhost:3333/api
///   flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:3333/api
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3333/api',
  );

  static const Duration timeout = Duration(seconds: 15);

  // Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/users/me';
  static const String levels = '/levels';
  static const String generateLevel = '/levels/generate';
  static const String games = '/games';
  static const String history = '/games/history';
  static const String leaderboard = '/leaderboard';

  static String level(int id) => '/levels/$id';
  static String hint(int sessionId) => '/games/$sessionId/hint';
  static String finish(int sessionId) => '/games/$sessionId/finish';
}
