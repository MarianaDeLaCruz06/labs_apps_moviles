import 'package:image_picker/image_picker.dart';
import 'package:moviles_auth/features/avatar/domain/entities/picked_photo.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';

class DevicePhotoDataSource {
  final ImagePicker _picker = ImagePicker();

  Future<PickedPhoto?> pick({PhotoSource source = PhotoSource.gallery}) async {
    final imageSource = source == PhotoSource.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final file = await _picker.pickImage(
      source: imageSource,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (file == null) return null;

    return PickedPhoto(
      bytes: await file.readAsBytes(),
      extension: file.name.split('.').last.toLowerCase(),
    );
  }
}
