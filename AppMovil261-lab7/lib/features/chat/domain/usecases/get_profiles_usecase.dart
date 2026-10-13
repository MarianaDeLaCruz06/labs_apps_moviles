import 'package:appmovil261/features/chat/data/repository/chat_repository_impl.dart';
import 'package:appmovil261/features/chat/domain/repository/chat_repository.dart';
import 'package:appmovil261/features/profile/domain/model/profile.dart';

class GetProfilesUsecase {
  final ChatRepository _repository = ChatRepositoryImpl();

  Future<List<Profile>> execute() {
    return _repository.getProfiles();
  }
}
