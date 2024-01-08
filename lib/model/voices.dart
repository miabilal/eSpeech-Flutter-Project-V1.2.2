class Voices {
  late String displayName;
  late String voice;
  late String language;
  late String provider;
  late String flag;
  late String type;

  Voices(
      {required this.displayName,
      required this.voice,
      required this.language,
      required this.provider,
      required this.type,
      required this.flag});
  Voices.fromJson(Map<String, dynamic> json) {
    displayName = json['display_name'];
    voice = json['voice'];
    language = json['language'];
    provider = json['provider'];
    type = json['type'];
    flag = json['provider_image'];
  }
}
