/// Jugador autenticado (entidad de dominio, sin dependencias de JSON).
class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.recommendedDifficulty,
  });

  final int id;
  final String username;
  final String email;
  final String recommendedDifficulty;
}
