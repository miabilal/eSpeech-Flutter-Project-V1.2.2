class Plans {
  late String id;
  late String title;
  late String type;
  late String noOfCharacters;
  late String google;
  late String aws;
  late String ibm;
  late String azure;
  late String status;
  late String lastModified;
  late String createdOn;
  late List<Tenure> tenurelist;
  Tenure? selectedtenure;
  String? planId;
  String? price;
  String? remainingCharacters;
  String? remainingGoogle;
  String? remainingAws;
  String? remainingAzure;
  String? remainingIbm;
  String? transactionId;
  String? startsFrom;
  String? tenure;
  String? expiresOn;

  Plans({
    required this.id,
    required this.title,
    required this.type,
    required this.noOfCharacters,
    required this.google,
    required this.aws,
    required this.ibm,
    required this.azure,
    required this.status,
    required this.lastModified,
    required this.createdOn,
    required this.tenurelist,
    this.selectedtenure,
    this.planId,
    this.price,
    this.remainingCharacters,
    this.remainingGoogle,
    this.remainingAws,
    this.remainingAzure,
    this.remainingIbm,
    this.transactionId,
    this.startsFrom,
    this.tenure,
    this.expiresOn,
  });

  Plans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    noOfCharacters = json['no_of_characters'];
    google = json['google'];
    aws = json['aws'];
    ibm = json['ibm'];
    azure = json['azure'];
    status = json['status'];
    lastModified = json['last_modified'];
    createdOn = json['created_on'];
    tenurelist = [];

    if (json['tenure'] != null) {
      json['tenure'].forEach((v) {
        tenurelist.add(Tenure.fromJson(v));
      });
      selectedtenure = null;
      if (tenurelist.isNotEmpty) selectedtenure = tenurelist.first;
    }
  }

  Plans.fromSubscriptionJson(Map<String, dynamic> json) {
    id = json['id'];
    planId = json['plan_id'];
    title = json['plan_title'];
    type = json['type'];
    price = json['price'];

    noOfCharacters = json['characters'];
    google = json['google'];
    aws = json['aws'];
    ibm = json['ibm'];
    azure = json['azure'];
    status = json['status'];
    remainingCharacters = json['remaining_characters'];
    remainingGoogle = json['remaining_google'];
    remainingAws = json['remaining_aws'];
    remainingAzure = json['remaining_azure'];
    remainingIbm = json['remaining_ibm'];
    transactionId = json['transaction_id'];
    tenure = json['tenure'];
    startsFrom = json['starts_from'];
    expiresOn = json['expires_on'];

    lastModified = json['last_modified'];

    createdOn = json['created_on'];
  }
}

class Tenure {
  late String id;
  late String title;
  late String months;
  late String price;
  late String discountedPrice;

  Tenure(
      {required this.id,
      required this.title,
      required this.months,
      required this.price,
      required this.discountedPrice});

  Tenure.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    months = json['months'];
    price = json['price'];
    discountedPrice = json['discounted_price'];
  }
}
