import 'package:appmovil261/features/profile/data/source/profile_data_source.dart';
import 'package:appmovil261/features/profile/domain/model/profile.dart';
import 'package:appmovil261/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  ProfileDataSource source = ProfileDataSource();

  @override
  Future<void> saveProfile(Profile profile) async {
    await source.saveProfile(profile);
  }
}
