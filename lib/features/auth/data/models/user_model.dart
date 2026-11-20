import '../../domain/entities/user.dart';

/// Conversión JSON <-> User
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.recommendedDifficulty,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        recommendedDifficulty: (json['recommended_difficulty'] as String?) ?? 'easy',
      );
}
