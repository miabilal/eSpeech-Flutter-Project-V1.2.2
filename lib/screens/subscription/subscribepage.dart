import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:espeech/helper/Stripe/stripeChargeCardMethod.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/model/plans.dart';
import 'package:espeech/screens/subscription/planspage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paytm/paytm.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../mainactivity.dart';

class SubscribePage extends StatefulWidget {
  int colorindex;

  SubscribePage({Key? key, required this.colorindex}) : super(key: key);

  @override
  _SubscribePageState createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  late Plans plan;
  String paytype = Constant.paytypeStripe;
  bool isloading = false;
  final plugin = PaystackPlugin();
  late Razorpay _razorpay;
  late double amount;

  @override
  void initState() {
    super.initState();
    providerConfig();

    plan = selectedplan;
    amount = double.parse(plan.selectedtenure!.price);
  }

  providerConfig() async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    initializePaystack();
    await Constant.getUserInfo(context);
  }

  initializePaystack() async {
    if (!plugin.sdkInitialized) {
      await plugin.initialize(publicKey: Constant.paystackKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.bgcolor,
      appBar:
          DesignConfig.setAppBar(context, 0, StringsRes.lblsubscribe, true, Constant.appbarHeight),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: subscriptionWidget(),
          ),
          if (isloading) DesignConfig.loaderWidget()
        ],
      ),
    );
  }

  detailWeight() {
    return ExpansionTile(
      iconColor: ColorsRes.appcolor,
      title: Text(StringsRes.plandetail,
          style: Theme.of(context).textTheme.subtitle1!.merge(const TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorsRes.appcolor,
              letterSpacing: 0.5))),
      children: <Widget>[
        planInfoWidget(plan.noOfCharacters, StringsRes.planOverallchr),
        planInfoWidget(plan.google, StringsRes.planGooglechr),
        planInfoWidget(plan.aws, StringsRes.planAmazonchr),
        planInfoWidget(plan.ibm, StringsRes.planIbmchr),
        planInfoWidget(plan.azure, StringsRes.planMicrosoftchr),
      ],
    );
  }

  subscriptionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          decoration: DesignConfig.boxGradient(
              Constant.colorlist1[widget.colorindex],
              Constant.colorlist2[widget.colorindex],
              30),
          margin: const EdgeInsets.only(bottom: 10),
          child: Stack(
            children: [
              SvgPicture.asset(
                "${Constant.svgpath}design.svg",
                width: double.maxFinite,
                height: double.maxFinite,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: DesignConfig.boxDecoration(
                        Constant.colorlist2[widget.colorindex].withOpacity(0.5),
                        20),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Text(plan.title,
                        style: Theme.of(context).textTheme.subtitle1!.merge(
                            const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorsRes.white,
                                letterSpacing: 0.5)),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          "${Constant.currencysymbol} ${plan.selectedtenure!.price}",
                          style: Theme.of(context).textTheme.headline5!.merge(
                              const TextStyle(
                                  color: ColorsRes.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "/${plan.selectedtenure!.title.toLowerCase()}",
                          style: Theme.of(context).textTheme.caption!.merge(
                              const TextStyle(
                                  color: ColorsRes.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: DesignConfig.decorationRoundedSide(
                        Constant.colorlist1[widget.colorindex].withOpacity(0.7),
                        false,
                        false,
                        true,
                        true,
                        30),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 18),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Constant.colorlist1[widget.colorindex],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Tenure>(
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: ColorsRes.white,
                          ),
                          isExpanded: true,
                          isDense: true,
                          alignment: Alignment.center,
                          value: plan.selectedtenure,
                          onChanged: (Tenure? newValue) {
                            plan.selectedtenure = newValue!;
                            setState(() {});
                          },
                          items: plan.tenurelist.map((Tenure user) {
                            return DropdownMenuItem<Tenure>(
                              value: user,
                              child: Text(
                                user.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .merge(const TextStyle(
                                        color: ColorsRes.white)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        detailWeight(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            StringsRes.selectpaytype,
            style: Theme.of(context).textTheme.subtitle1!.merge(const TextStyle(
                color: ColorsRes.appcolor, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 15),
        payTypeWidget(),
        const SizedBox(height: 10),
        GestureDetector(
            onTap: () {
              if (Constant.upcomingsubscriptionPlan == null) {
                openPaymentPage();
              } else {
                Constant.showSnackBarMsg(
                    context, StringsRes.youhavealreadyupcomingplan, 1);
              }
            },
            child: Container(
                decoration: DesignConfig.boxDecorationGradient(15),
                alignment: Alignment.center,
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  StringsRes.lblpaynow,
                  style: Theme.of(context).textTheme.subtitle1!.merge(
                      const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorsRes.white,
                          letterSpacing: 0.5)),
                ))),
      ],
    );
  }

  payTypeBtnWidget(String title, String type, String image) {
    return GestureDetector(
      onTap: () {
        if (paytype != type) {
          setState(() {
            paytype = type;
          });
        }
      },
      child: Container(
        decoration: DesignConfig.boxDecoration(
            paytype == type
                ? ColorsRes.white
                : ColorsRes.white.withOpacity(0.4),
            10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(children: [
          Icon(
            paytype == type ? Icons.radio_button_on : Icons.radio_button_off,
            color:
                paytype == type ? ColorsRes.mainsubtextcolor : ColorsRes.grey,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(title,
                style: Theme.of(context).textTheme.subtitle1!.merge(TextStyle(
                    fontWeight: FontWeight.bold,
                    color: paytype == type
                        ? ColorsRes.mainsubtextcolor
                        : ColorsRes.grey,
                    letterSpacing: 0.5))),
          ),
          SvgPicture.asset(Constant.svgpath + image),
        ]),
      ),
    );
  }

  planInfoWidget(String number, String title) {
    return ListTile(
      leading: getIcon(number),
      dense: true,
      title: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.subtitle2!.merge(const TextStyle(
              color: ColorsRes.darktext, fontWeight: FontWeight.bold)),
          text: number,
          children: <TextSpan>[
            TextSpan(
              text: " $title",
              style: const TextStyle(
                  color: ColorsRes.darktext, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  getIcon(String number) {
    return number.trim().isEmpty || number.trim() == '0'
        ? const Icon(Icons.cancel, color: ColorsRes.red)
        : const Icon(Icons.check_circle, color: ColorsRes.green);
  }

  void openPaymentPage() {
    switch (paytype) {
      case Constant.paytypeStripe:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: StripeChargeCardMethod(
                    amount: amount,
                    callback: callPaymentStatus,
                    planid: plan.id,
                    tenureid: plan.selectedtenure!.id),
              );
            });
        break;
      case Constant.paytypePaystack:
        payStackCard();
        break;
      case Constant.paytypeRazorpay:
        var options = {
          'key': Constant.razorpayKey,
          'amount': (amount * 100).toInt(),
          'name':
              "${Constant.session!.getData(SessionManager.keyFirstName)} ${Constant.session!.getData(SessionManager.keyLastName)}",
          'description': 'Subscription',
          'prefill': {
            'contact': Constant.session!.getData(SessionManager.keyPhone),
            'email': Constant.session!.getData(SessionManager.keyEmail)
          }
        };
        try {
          _razorpay.open(options);
        } catch (e) {}
        break;
      case Constant.paytypePaytm:
        checkSum();
        break;
      case Constant.paytypeBankTransfer:
        BankTransferCard();
        break;
    }
  }

  Future<void> checkSum() async {
    String orderId =
        'eSpeech-${DateTime.now().millisecondsSinceEpoch.toString()}';

    Map<String, String?> payparameter = {
      Constant.amount: amount.toString(),
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
      Constant.orderId: orderId,
    };
    var payresponse = await Constant.sendApiRequest(
        Constant.apiGeneratePaytmCheckSum, payparameter, true, context);

    var getdata = json.decode(payresponse);

    bool error = getdata["error"];

    if (!error) {
      paytmPayment(getdata['data']['ORDER_ID']);
    }
  }

  void paytmPayment(String orderId) async {
    String? paymentResponse;

    String callBackUrl =
        '${Constant.paytmMode == "test" ? Constant.paytmUrl : 'https://securegw.paytm.in/'}theia/paytmCallback?ORDER_ID=$orderId';
    Map<String, String?> payparameter = {
      Constant.amount: amount.toString(),
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
      Constant.orderId: orderId,
      // Constant.mId:Constant.paytmMerchantId,
    };

    try {
      var payresponse = await Constant.sendApiRequest(
          Constant.apiGeneratePaytmTxnToken, payparameter, true, context);

      var getdata = json.decode(payresponse);

      bool error = getdata["error"];

      if (!error) {
        String txnToken = getdata["txn_token"];

        print("response token $txnToken");
        setState(() {
          paymentResponse = txnToken;
        });

        var paytmResponse = Paytm.payWithPaytm(
            callBackUrl: callBackUrl,
            mId: Constant.paytmMerchantId,
            orderId: orderId,
            txnToken: txnToken,
            txnAmount: amount.toString(),
            staging: Constant.paytmMode == "test" ? true : false);

        paytmResponse.then((value) {
          setState(() {
            print(value);
            if (value['error']) {
              Constant.showSnackBarMsg(context, value['errorMessage'], 1);
            } else {
              if (value['response'] != null) {
                paymentResponse = value['response']['STATUS'];
                if (paymentResponse == "TXN_SUCCESS") {
                  setTransactionData(orderId /*value['response']['TXNID']*/);
                }
              }
            }
            Constant.showSnackBarMsg(context, paymentResponse!, 1);
          });
        });
      } else {
        Constant.showSnackBarMsg(context, getdata["message"], 1);
      }
    } catch (e) {
      print(e);
    }
  }

  void BankTransferCard() {
    showGeneralDialog(
        barrierColor: ColorsRes.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0),
                  elevation: 2.0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  content: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              StringsRes.dire_bank_transfer_lbl,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                      color: ColorsRes.black,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(color: ColorsRes.lightgrey),
                          Html(
                            data: Constant.bankIntrustions,
                            style: {
                              "body": Style(color: ColorsRes.darktext),
                            },
                            onLinkTap:
                                (url, context, attributes, element) async {
                              await launchUrlString(url!);
                            },
                          ),
                          Text(
                            StringsRes.acc_details_lbl,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    color: ColorsRes.darktext,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                          ),
                          Html(
                            data: Constant.bankAccDetails,
                            style: {
                              "body": Style(color: ColorsRes.darktext),
                            },
                            onLinkTap:
                                (url, context, attributes, element) async {
                              await launchUrlString(url!);
                            },
                          ),
                          Text(
                            StringsRes.extra_details_lbl,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    color: ColorsRes.darktext,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                          ),
                          Html(
                            data: Constant.bankExtraDetails,
                            style: {
                              "body": Style(color: ColorsRes.darktext),
                            },
                            onLinkTap:
                                (url, context, attributes, element) async {
                              await launchUrlString(url!);
                            },
                          )
                        ]),
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text(StringsRes.lblcancel,
                            style: const TextStyle(
                                color: ColorsRes.darktext,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    TextButton(
                        child: Text(StringsRes.done_lbl,
                            style: const TextStyle(
                                color: ColorsRes.darktext,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          String orderId =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          int min =
                              100; //min and max values act as your 6 digit range
                          int max = 999;
                          var randomizer = Random();
                          var rNum = min + randomizer.nextInt(max - min);
                          setTransactionData(
                              'bank-transfer-$orderId-$rNum-${Constant.session!.getData(SessionManager.keyId)}');
                          Navigator.pop(context);
                        })
                  ],
                )),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  Future<void> payStackCard() async {
    bool checkinternet = await Constant.checkInternet();

    if (!checkinternet) {
      Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork, 1);
    } else {
      Charge charge = Charge()
        ..amount = (amount * 100).toInt() //*100
        ..reference = Constant.getReference()
        ..currency = Constant.paystackCurrencyCode
        ..email = Constant.session!.getData(SessionManager.keyEmail);

      initializePaystack();

      CheckoutResponse response = await plugin.checkout(
        context,
        method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
        charge: charge,
        fullscreen: false,
        logo: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            "assets/images/logo.png",
            height: 50,
            width: 50,
          ),
        ),
      );

      if (response.status) {
        setTransactionData(response.reference!);
      } else {
        Constant.showSnackBarMsg(context, response.message, 1);
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future setTransactionData(String transactionid) async {
    bool checkinternet = await Constant.checkInternet();
    if (!checkinternet) {
      Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork, 1);
    } else {
      if (mounted) {
        setState(() {
          isloading = true;
        });
      }

      Map<String, dynamic> params = {
        Constant.userId: Constant.session!.getData(SessionManager.keyId),
        Constant.planId: plan.id,
        Constant.tenureId: plan.selectedtenure!.id,
        Constant.provider: paytype,
        Constant.txnId: transactionid,
      };

      var responseapi = await Constant.sendApiRequest(
          Constant.apiaddSubscription, params, true, context);
      var res = json.decode(responseapi);

      if (mounted) {
        setState(() {
          isloading = false;
        });
      }

      if (!res[Constant.error]) {
        Constant.showSnackBarMsg(context, StringsRes.transactionsuccess, 1);

        Timer(const Duration(seconds: 1), () {
          Navigator.pop(context);
          Constant.killPreviousPages(
              context, MainActivity(from: "subscription"));
          Constant.getUserInfo(context);
        });
      } else {
        Constant.showSnackBarMsg(context, res['message'], 1);
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    callPaymentStatus(response.paymentId!, "success");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    callPaymentStatus("", response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    callPaymentStatus("", response.walletName!);
  }

  callPaymentStatus(String txnid, String msg) async {
    if (txnid.trim().isNotEmpty) {
      if (paytype == Constant.paytypeStripe) {
        Constant.showSnackBarMsg(context, StringsRes.transactionsuccess, 1);

        Timer(const Duration(seconds: 1), () {
          Navigator.pop(context);
          Constant.killPreviousPages(
              context, MainActivity(from: "subscription"));
        });
      } else {
        setTransactionData(txnid);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  payTypeWidget() {
    return Column(children: [
      if (Constant.stripeStatus == Constant.enableStatus)
        payTypeBtnWidget(
            StringsRes.lblstripe, Constant.paytypeStripe, "stripe.svg"),
      if (Constant.paystackStatus == Constant.enableStatus)
        payTypeBtnWidget(
            StringsRes.lblpaystack, Constant.paytypePaystack, "paystack.svg"),
      if (Constant.razorpayApiStatus == Constant.enableStatus)
        payTypeBtnWidget(
            StringsRes.lblrazorpay, Constant.paytypeRazorpay, "razorpay.svg"),
      if (Constant.paytmStatus == Constant.enableStatus)
        payTypeBtnWidget(
            StringsRes.lblpaytm, Constant.paytypePaytm, "paytm.svg"),
      if (Constant.bankTranStatus == Constant.enableStatus)
        payTypeBtnWidget(StringsRes.lblbanktransfer,
            Constant.paytypeBankTransfer, "banktransfer.svg"),
    ]);
  }
}
