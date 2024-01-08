class Audio {
  late String id;
  late String voice;
  late String language;
  late String provider;
  late String text;
  late String base64;
  late String usedCharacters;
  late String status;
  late String createdOn;

  Audio({
    required this.id,
    required this.voice,
    required this.language,
    required this.provider,
    required this.text,
    required this.base64,
    required this.usedCharacters,
    required this.status,
    required this.createdOn,
  });
  Audio.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    voice = json['voice'];
    language = json['language'];
    provider = json['provider'];
    text = json['text'];
    base64 = json['base_64'];
    usedCharacters = json['used_characters'];
    status = json['status'];
    createdOn = json['created_on'];
  }
}
