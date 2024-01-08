import 'package:espeech/model/plans.dart';

class Transaction {
  late String id;
  late String userId;
  late String paymentMethod;
  late String txnId;
  late String amount;
  late String currencyCode;
  late String message;
  late String status;
  late String lastModified;
  late String createdOn;
  late Plans? subscriptiondetail;
  late List<String>? attachList;

  Transaction(
      {required this.id,
      required this.userId,
      required this.paymentMethod,
      required this.txnId,
      required this.amount,
      required this.currencyCode,
      required this.message,
      required this.status,
      required this.lastModified,
      required this.createdOn,
      required this.subscriptiondetail,
      this.attachList});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    paymentMethod = json['payment_method'];
    txnId = json['txn_id'];
    amount = json['amount'];
    currencyCode = json['currency_code'];
    message = json['message'];
    status = json['status'];
    lastModified = json['last_modified'];
    createdOn = json['created_on'];
    List<String> attachmentlist = List<String>.from(json['attachments']);
    if (attachmentlist.isEmpty) {
      attachList = [];
    } else {
      attachList = attachmentlist;
    }
    var subscriptionlist = json['subscription'];
    if (subscriptionlist == null || subscriptionlist.isEmpty) {
      subscriptiondetail = null;
    } else {
      subscriptiondetail = Plans.fromSubscriptionJson(json['subscription']);
    }
  }
}
