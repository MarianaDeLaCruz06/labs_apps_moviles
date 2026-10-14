import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<void> createProfile(Profile profile);
}
