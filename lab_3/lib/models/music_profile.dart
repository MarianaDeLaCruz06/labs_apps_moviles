/// Profile filled in step by step during the onboarding. TODO part 2.
///
/// It has to model everything the user fills in during the three steps, plus
/// the email that comes from the login. How you model it is up to you.
class MusicProfile {
  String email;
  String fullName;
  String username;
  String favoriteArtist;
  String mood;
  String playlistName;
  String coverUrl;

  MusicProfile({
    this.email = '',
    this.fullName = '',
    this.username = '',
    this.favoriteArtist = '',
    this.mood = '',
    this.playlistName = '',
    this.coverUrl = '',
  });
}
