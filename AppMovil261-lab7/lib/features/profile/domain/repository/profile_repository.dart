import 'package:appmovil261/features/profile/domain/model/profile.dart';

abstract class ProfileRepository {
  //save
  Future<void> saveProfile(Profile profile);
}
