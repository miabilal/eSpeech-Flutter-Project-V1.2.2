class Language{
  late String name;
  late String flag;
  late String languageCode;
  Language({required this.name, required this.flag, required this.languageCode});

  Language.fromJson(Map<String, dynamic> json) {

    name = json['name'];
    flag = json['flag'];
    languageCode = json['language_code'];
  }
}