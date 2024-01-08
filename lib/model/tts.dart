class TTS {
  late String id;
  late String voice;
  late String language;
  late String provider;
  late String title;
  late String base64;
  late String usedCharacters;
  late String status;
  late String createdOn;
  late String identity;
  late String userId;
  late String isSsml;
  late String text;
  late String isSaved;

  TTS({
    required this.id,
    required this.identity,
    required this.voice,
    required this.language,
    required this.provider,
    required this.title,
    required this.base64,
    required this.usedCharacters,
    required this.status,
    required this.createdOn,
    required this.userId,
    required this.isSsml,
    required this.text,
    required this.isSaved,
  });
  TTS.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    identity = json['identity'];
    voice = json['voice'];
    userId = json['user_id'];
    language = json['language'];
    provider = json['provider'];
    title = json['title'];
    text = json['text'];
    base64 = json['base_64'];
    usedCharacters = json['used_characters'];
    isSaved = json['is_saved'];
    createdOn = json['created_on'];
    isSsml = json['is_ssml'];
  }
}
