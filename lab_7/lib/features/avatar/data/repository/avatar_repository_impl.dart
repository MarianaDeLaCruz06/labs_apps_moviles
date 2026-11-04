import 'package:moviles_auth/features/avatar/domain/entities/picked_photo.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';
import 'package:moviles_auth/features/avatar/domain/repository/avatar_repository.dart';

import 'package:moviles_auth/features/avatar/data/source/device_photo_data_source.dart';
import 'package:moviles_auth/features/avatar/data/source/supabase_avatar_data_source.dart';

/// Fulfils AvatarRepository with the device and Supabase Storage.
class AvatarRepositoryImpl implements AvatarRepository {
  final DevicePhotoDataSource _device = DevicePhotoDataSource();
  final SupabaseAvatarDataSource _storage = SupabaseAvatarDataSource();

  @override
  Future<PickedPhoto?> pick({PhotoSource source = PhotoSource.gallery}) async {
    return _device.pick(source: source);
  }

  @override
  Future<String> upload(PickedPhoto photo) async {
    return _storage.upload(photo);
  }

  @override
  Future<void> remove(String path) async {
    return _storage.remove(path);
  }
}
