import 'package:moviles_auth/features/avatar/domain/entities/picked_photo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// The only file that talks to the post-images bucket of Supabase Storage.
class SupabasePostImageDataSource {
  static const bucket = 'post-images';

  final SupabaseClient _client = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  String get _uid {
    return _client.auth.currentUser!.id;
  }

  Future<String> upload(PickedPhoto photo) async {
    final path = '$_uid/${_uuid.v4()}.${photo.extension}';
    final type = photo.extension == 'jpg' ? 'jpeg' : photo.extension;

    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            path,
            photo.bytes,
            fileOptions: FileOptions(
              contentType: 'image/$type',
              cacheControl: '31536000',
            ),
          );

      return path;
    } on StorageException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String> signedUrl(String path) async {
    try {
      return await _client.storage.from(bucket).createSignedUrl(path, 3600);
    } on StorageException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Map<String, String>> signedUrls(List<String> paths) async {
    if (paths.isEmpty) return const {};

    final uniquePaths = paths.toSet().toList(growable: false);
    try {
      final results = await _client.storage
          .from(bucket)
          .createSignedUrlsResult(uniquePaths, 3600);
      final urls = <String, String>{};
      final errors = <String>[];

      for (final result in results) {
        switch (result) {
          case SignedUrlSuccess(:final path, :final signedUrl):
            urls[path] = signedUrl;
          case SignedUrlFailure(:final path, :final error):
            errors.add('$path: $error');
        }
      }

      if (errors.isNotEmpty) {
        throw Exception(
          'No se pudieron firmar las imágenes: ${errors.join('; ')}',
        );
      }
      return urls;
    } on StorageException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> remove(String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } on StorageException catch (e) {
      throw Exception(e.message);
    }
  }
}
