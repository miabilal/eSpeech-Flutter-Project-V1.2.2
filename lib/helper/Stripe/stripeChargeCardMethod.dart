import 'dart:convert';
import 'package:espeech/helper/Stripe/payment_card.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../colorsres.dart';
import '../constant.dart';
import '../designconfig.dart';
import '../stringsres.dart';
import 'dialogs.dart';
import 'input_formatters.dart';

String cardnamehint = 'What name is written on card ?';
String cardnohint = 'What number is written on card?';
String lblcardname = 'Card Name';
String cardno = 'Card Number';

class StripeChargeCardMethod extends StatefulWidget {
  final double? amount;
  final Function? callback;
  final String? planid;
  final String? tenureid;

  const StripeChargeCardMethod(
      {Key? key, this.amount, this.callback, this.planid, this.tenureid})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StripeChargeCardState();
  }
}

class StripeChargeCardState extends State<StripeChargeCardMethod> {
  final _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  var nameController = TextEditingController();
  final _paymentCard = PaymentCard();
  bool showLoader = false;
  final String _pubkey = Constant.stripePublishableKey;
  final String _paymode = Constant.stripeMode;

  String apimsg = '';

  bool loadingorder = false;

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  Future<void> setData() async {
    Stripe.publishableKey = _pubkey;
    //Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    //Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: stripedebitCartWidget());
  }

  stripedebitCartWidget() {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                "assets/images/logo.png",
                height: 50,
                width: 50,
              ),
            ),
            TextFormField(
              cursorColor: ColorsRes.appcolor,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                LengthLimitingTextInputFormatter(19),
                CardNumberInputFormatter()
              ],
              controller: numberController,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                icon: CardUtils.getCardIcon(_paymentCard.type),
                hintText: cardnohint,
                labelText: cardno,
              ),
              onSaved: (String? value) {
                _paymentCard.number = CardUtils.getCleanedNumber(value!);
              },
              validator: CardUtils.validateCardNum,
            ),
            TextFormField(
              cursorColor: ColorsRes.appcolor,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                LengthLimitingTextInputFormatter(4),
                CardMonthInputFormatter()
              ],
              decoration: const InputDecoration(
                //border: UnderlineInputBorder(),
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: ColorsRes.appcolor,
                ),
                hintText: 'MM/YY',
                labelText: 'Expiry Date',
              ),
              validator: CardUtils.validateDate,
              keyboardType: TextInputType.number,
              onSaved: (value) {
                List<int> expiryDate = CardUtils.getExpiryDate(value!);
                _paymentCard.month = expiryDate[0];
                _paymentCard.year = expiryDate[1];
              },
            ),
            TextFormField(
              cursorColor: ColorsRes.appcolor,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                //border: UnderlineInputBorder(),
                icon: Icon(
                  Icons.card_membership,
                  color: ColorsRes.appcolor,
                ),
                hintText: 'Number behind the card',
                labelText: 'CVV',
              ),
              validator: CardUtils.validateCVV,
              keyboardType: TextInputType.number,
              onSaved: (value) {
                _paymentCard.cvv = int.parse(value!);
              },
            ),
            const SizedBox(
              height: 50.0,
            ),
            if (loadingorder) const CircularProgressIndicator(),
            Container(
              alignment: Alignment.center,
              child: _getPayButton(),
            )
          ],
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      _paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    if (Constant.upcomingsubscriptionPlan != null) {
      Constant.showSnackBarMsg(context, StringsRes.youhavealreadyupcomingplan,1);
      return;
    }
    if (!loadingorder) {
      final FormState form = _formKey.currentState!;
      if (!form.validate()) {
        setState(() {});
      } else {
        form.save();

        proceedPayment();
      }
    }
  }

  Widget _getPayButton() {
    return GestureDetector(
      onTap: _validateInputs,
      child: Container(
          decoration: DesignConfig.boxDecorationGradient(15),
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            "Pay ${Constant.currencysymbol}${widget.amount}",
            style: Theme.of(context).textTheme.subtitle1!.merge(const TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsRes.white,
                letterSpacing: 0.5)),
          )),
    );
  }

  Future<String> getClientSec() async {
    apimsg = '';
    Map<String, dynamic> paramsdata = {
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
      Constant.planId: widget.planid,
      Constant.tenureId: widget.tenureid,
      Constant.provider: Constant.paytypeStripe,
    };

    var responseapi = await Constant.sendApiRequest(
        Constant.apiaddSubscription, paramsdata, true, context);

    var res = json.decode(responseapi);
    String clientsecret = "";
    apimsg = res[Constant.message];
    if (!res[Constant.error]) {
      clientsecret = res['data']['client_secret'];
    }
    return clientsecret;
  }

  Future<void> proceedPayment() async {
    if (!loadingorder) {
      setState(() {
        loadingorder = true;
      });
    }

    setLoadingState(true);
    CardDetails card = CardDetails(
        number: _paymentCard.number,
        cvc: _paymentCard.cvv.toString(),
        expirationMonth: _paymentCard.month,
        expirationYear: _paymentCard.year);

    String clientSecret = await getClientSec();
    if (clientSecret.trim().isNotEmpty) {
      await Stripe.instance.dangerouslyUpdateCardDetails(card);
      try {
        final billingDetails = BillingDetails(
          email: Constant.session!.getData(SessionManager.keyEmail),
          phone: Constant.session!.getData(SessionManager.keyPhone),
        );

        final paymentIntent = await Stripe.instance.confirmPayment(
          clientSecret,
          PaymentMethodParams.card(
           paymentMethodData: PaymentMethodData(billingDetails: billingDetails,),
          ),
        );

        setLoadingState(false);

        setState(() {
          loadingorder = false;
        });

        widget.callback!(paymentIntent.id, "Success");
      } on Exception catch (e) {
        setLoadingState(false);

        setState(() {
          loadingorder = false;
        });

        if (e is StripeException) {
          widget.callback!("", e.error.localizedMessage);
        } else {
          widget.callback!("", e.toString());
        }
      }
    } else {
      setLoadingState(false);

      setState(() {
        loadingorder = false;
      });
      widget.callback!("", apimsg);
    }
  }

  void setError(dynamic error) {
    if (showLoader) {
      setState(() {
        showLoader = false;
      });
    }
    Dialogs.showInfoDialog(context, error.toString());
  }

  void onApiFailure(String statusCode, String message) {
    setLoadingState(false);
    Dialogs.showInfoDialog(context, message);
  }

  void onException() {
    setLoadingState(false);
  }

  void onNoInternetConnection() {
    setLoadingState(false);
    Dialogs.showInfoDialog(context, "Check Internet Connection");
  }

  void setLoadingState(bool isShow) {
    setState(() {
      showLoader = isShow;
    });
  }
}
