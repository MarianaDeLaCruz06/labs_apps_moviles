import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';

/// Something the home screen asks the FeedBloc to do.
abstract class FeedEvent {}

/// Load the profile of the signed in user.
class ProfileRequested extends FeedEvent {
  @override
  String toString() {
    return 'ProfileRequested()';
  }
}

/// The user pressed Cerrar sesión.
class SignOutRequested extends FeedEvent {
  @override
  String toString() {
    return 'SignOutRequested()';
  }
}

/// Load the wall from page 0, and the latest posts of the user.
class FeedStarted extends FeedEvent {
  @override
  String toString() {
    return 'FeedStarted()';
  }
}

/// Load the next page of the wall.
class FeedMoreRequested extends FeedEvent {
  @override
  String toString() {
    return 'FeedMoreRequested()';
  }
}

/// The user touched the heart of a post.
class FeedLikeToggled extends FeedEvent {
  final Post post;

  FeedLikeToggled(this.post);

  @override
  String toString() {
    return 'FeedLikeToggled($post)';
  }
}

/// The user confirmed deletion of one of their posts.
class FeedPostDeleteRequested extends FeedEvent {
  final Post post;

  FeedPostDeleteRequested(this.post);

  @override
  String toString() => 'FeedPostDeleteRequested(${post.id})';
}

/// The user wants a new profile photo from the gallery.
/// El usuario quiere cambiar su fotografía de perfil.
class AvatarChangeRequested extends FeedEvent {
  final PhotoSource source;

  AvatarChangeRequested({this.source = PhotoSource.gallery});

  @override
  String toString() {
    return 'AvatarChangeRequested(source: $source)';
  }
}

/// The user wants to remove the current profile photo.
class AvatarRemoveRequested extends FeedEvent {
  @override
  String toString() => 'AvatarRemoveRequested()';
}
