import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/model/language.dart';
import 'package:espeech/model/plans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'stringsres.dart';
import 'package:http/http.dart' as http;

class Constant {
  static String hosturl = "PLACE_HERE_YOUR_HOST_URL";
  static String baseUrl = "${hosturl}api/v1/";

  static String flagpath = "${hosturl}public/flags/";

  //
  static String stripepath = "https://api.stripe.com/v1/";

  static String stripepaymentmethod = "payment_intents";

  //

  static Map<String, Map<String, List>> taglist = {};

  //

  static String imgpath = 'assets/images/';
  static String svgpath = 'assets/svg/';
  static String lottiepath = 'assets/lottie/';
  static String currencysymbol = '₹';
  static String currencycode = 'INR';
  static Plans? currsubscriptionPlan;
  static Plans? upcomingsubscriptionPlan;
  static String? isFreeTierAllow;
  static String? freeTierCharacters;

//

  //
  static int animationtime = 300;

  static int pageSavedText = 0;
  static int pagePlan = 1;

  static int pageUserManual = 2;

  //
  static double bottomNavigationHeight = 75;
  static double appbarHeight = 88;
  static String typeaboutus = "about_us";
  static String typetermscondition = "terms_conditions";
  static String typeprivacypolicy = "privacy_policy";
  static String generalSettings = 'general_settings';
  static String ttsConfigSettings = 'tts_config';
  static String paymentGatewaysSettings = 'payment_gateways_settings';
  static List consigsettinglist = [generalSettings, paymentGatewaysSettings];

  static Map mapgeneralsettings = {};
  static String supportEmail = 'support_email';

  static String razorpayApiStatus = "";
  static late String razorpayMode;
  static late String razorpayKey;

  static String razorpayCurrencyCode = 'INR';
  static String paystackStatus = "";
  static late String paystackMode;
  static late String paystackKey;
  static String paystackCurrencyCode = 'NGN';

  //static late String paystackSecret;
  static String stripeCurrency = 'INR';
  static late String stripePublishableKey;

  //static late String stripeSecretKey;
  static String stripeMode = "test";
  static String stripeStatus = "";
  static String bankTranStatus = "";
  static String bankIntrustions = "";
  static String bankAccDetails = "";
  static String bankExtraDetails = "";
  static String paytmMode = "";
  static String paytmMerchantId = "";
  static String paytmMerchantKey = "";
  static String paytmUrl = "";
  static String paytmWebsite = "";
  static String paytmIndustryTypeId = "";
  static String paytmStatus = "";

  static String enableStatus = 'enable';

  //
  static List languagelist = [];
  static const String paytypeStripe = 'stripe';
  static const String paytypeRazorpay = 'razorpay';
  static const String paytypePaystack = 'paystack';
  static const String paytypePaytm = 'paytm';
  static const String paytypeBankTransfer = 'bank';

  //

  //static late SessionManager session;
  static SessionManager? session;

  static SessionManager? getSession(BuildContext context) {
    return Provider.of<SessionManager>(context);
  }

  static String? validateEmail(String value) {
    RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (value.trim().isEmpty || !regex.hasMatch(value)) {
      return StringsRes.enterValidEmail;
    } else {
      return null;
    }
  }

  static String? validateMobile(String value) {
    if (value.trim().isEmpty ||
        value.trim().length < 10 ||
        value.trim().length > 14) {
      return StringsRes.enterValidMobile;
    } else {
      return null;
    }
  }

  static showSnackBarMsg1(BuildContext? context, String msg) {
    ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: ColorsRes.appcolor)),
      backgroundColor: ColorsRes.white,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static showSnackBarMsg(BuildContext? context, String msg, int bg) {
    return showToast(msg,
        fullWidth: true,
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.slideToBottom,
        position: StyledToastPosition.bottom,
        animDuration: const Duration(milliseconds: 300),
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
        borderRadius: BorderRadius.circular(10.0),
        backgroundColor: bg == 1 ? ColorsRes.appcolor : ColorsRes.white,
        textStyle:
            TextStyle(color: bg == 1 ? ColorsRes.white : ColorsRes.appcolor));
  }

  static String getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'I';
    } else {
      platform = 'A';
    }

    return '${platform}_${Constant.session!.getData(SessionManager.keyId)}_${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<bool> checkInternet() async {
    bool check = false;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      check = true;
    }
    return check;
  }

  static killPreviousPages(BuildContext context, var nextpage) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => nextpage),
        (Route<dynamic> route) => false);
  }

  static goToNextPage(var nextpage, BuildContext context, bool isreplace) {
    if (isreplace) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextpage,
      ));
    } else {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextpage,
      ));
    }
  }

  static goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  static Future sendApiRequest(String url, Map<String, dynamic> body,
      bool ispost, BuildContext context) async {
    String token = Constant.session!.getData(SessionManager.keyToken);
    print("token-======$token");
    print("========url===params=>$url==$body");

    Map<String, String> headersdata = {
      "accept": "application/json",
    };

    if (token.trim().isNotEmpty) {
      headersdata["Authorization"] = "Bearer $token";
    }

    Response response;
    if (ispost) {
      response = await post(Uri.parse(baseUrl + url),
          body: body.isNotEmpty ? body : null, headers: headersdata);
    } else {
      response = await get(Uri.parse(baseUrl + url), headers: headersdata);
    }

    print("response status****${response.statusCode}");
    print("response****${response.body}");
    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 401) {
      Constant.session!.logoutUser(context);
    } else {}
  }

  static Future postApiFile(String url, Map<String, List<File>> filelist,
      BuildContext context, Map<String, dynamic> body, int from) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl + url));

    body.forEach((key, value) {
      request.fields[key] = value;
    });

    String token = Constant.session!.getData(SessionManager.keyToken);

    Map<String, String> headersdata = {
      'Accept': "application/json",
    };
    if (token.trim().isNotEmpty) {
      headersdata["Authorization"] = "Bearer $token";
    }

    request.headers.addAll(headersdata);

    filelist.forEach((key, value) async {
      for (var i = 0; i < value.length; i++) {
        var pic = await http.MultipartFile.fromPath(
            from == 1 ? key : "$key[$i]", value[i].path);
        request.files.add(pic);
      }
    });

    var res = await request.send();

    var responseData = await res.stream.toBytes();
    var response = String.fromCharCodes(responseData);
    print("========response==code=${res.statusCode}");

    if (res.statusCode == 200) {
      print("========response===$response");
      return response;
    } else if (res.statusCode == 401) {
      Constant.session!.logoutUser(context);
    } else {
      //print("====data-err-${response}");
    }
  }

  //
  static getLanguageListFromSession() {
    String locallanglist =
        Constant.session!.getData(SessionManager.keyLanguageData);
    if (locallanglist.trim().isNotEmpty) {
      List list = json.decode(locallanglist);
      //languagelist.clear();
      List newlanguagelist = [];

      newlanguagelist
          .addAll(list.map((model) => Language.fromJson(model)).toList());
      languagelist = newlanguagelist;
    }
  }

  static getLanguageList(BuildContext context) async {
    Map<String, String?> parameter = {};

    var response = await Constant.sendApiRequest(
        Constant.apiLanguages, parameter, true, context);

    var getdata = json.decode(response);

    if (!getdata[Constant.error]) {
      Constant.session!.setData(
          SessionManager.keyLanguageData, json.encode(getdata['data']));
      List list = getdata['data'];
      //languagelist.clear();
      List newlanguagelist = [];

      newlanguagelist
          .addAll(list.map((model) => Language.fromJson(model)).toList());
      languagelist = newlanguagelist;
    }
  }

  static getUserInfo(BuildContext context) async {
    Map<String, String?> parameter = {
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
    };

    var response = await Constant.sendApiRequest(
        Constant.apiGetUserDetails, parameter, true, context);

    var getdata = json.decode(response);
    if (!getdata[Constant.error]) {
      Constant.session!.setUserDetail(getdata['data'], "");
    }
  }

  static String numberFormattor(String number) {
    double num = double.parse(number);
    RegExp regex = RegExp(r"([.]*0)(?!.*\d)");
    if (num > 999 && num < 99999) {
      return "${(num / 1000).toStringAsFixed(1).replaceAll(regex, '')} K";
    } else if (num > 99999 && num < 999999) {
      return "${(num / 1000).toStringAsFixed(1).replaceAll(regex, '')} K";
    } else if (num > 999999 && num < 999999999) {
      return "${(num / 1000000).toStringAsFixed(1).replaceAll(regex, '')} M";
    } else if (num > 999999999) {
      return "${(num / 1000000000).toStringAsFixed(1).replaceAll(regex, '')} B";
    } else {
      return num.toStringAsFixed(1).replaceAll(regex, '');
    }
  }

  static defaultImage(double iwidth, double iheight) {
    return SvgPicture.asset("${Constant.svgpath}placeholder.svg",
        width: iwidth, height: iheight, fit: BoxFit.cover);
  }

  static String setFirstLetterUppercase(String value) {
    if (value.isNotEmpty) value = value.replaceAll("_", '');
    return value.isEmpty
        ? ""
        : "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
  }

  static List<Color> colorlist1 = [
    ColorsRes.c1,
    ColorsRes.c2,
    ColorsRes.c3,
    ColorsRes.c4,
    ColorsRes.c5,
    ColorsRes.c6
  ];
  static List<Color> colorlist2 = [
    ColorsRes.c11,
    ColorsRes.c22,
    ColorsRes.c33,
    ColorsRes.c44,
    ColorsRes.c55,
    ColorsRes.c66
  ];

  static Color statusColor(String value) {
    Color color = ColorsRes.bgcolor;

    switch (value.trim().toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'success':
        color = Colors.green;
        break;
      case 'upcoming':
        color = Colors.orange;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'expired':
        color = Colors.red;
        break;
      case 'failed':
        color = Colors.red;
        break;
      case 'authorized':
        color = ColorsRes.darktext;
        break;
    }
    return color;
  }

  static String getBase64ConvertedText(String basetextmain) {
    String basetext = basetextmain;
    if (basetext.length % 4 > 0) {
      basetext += '=' * (4 - basetext.length % 4);
    }
    return basetext;
  }

  static String formatDateString(String dt) {
    return Jiffy(dt, "yyyy-MM-dd hh:mm:ss").format("do MMM yyyy, h:mm a");
  }

  //
  static String apiGetTags = 'get_tags';
  static String apiLogin = 'login';
  static String apiRegister = 'register';
  static String apiForgotPassword = 'forgot_password';
  static String apiLanguages = 'languages';
  static String apiUpdateUser = 'update_user';
  static String apiGetUserDetails = 'user_details';
  static String apiChangePassword = 'change_password';
  static String apiGetVoices = 'voices';
  static String apiGetPredefinedTts = 'predefined_tts';
  static String apiGetAvailableSettings = 'available_settings';
  static String apiGetSettings = 'settings';
  static String apiSynthesizeText = 'synthesize';
  static String apiGetPlans = 'plans';
  static String apiaddSubscription = 'add_subscription';
  static String apiGetTransactions = 'get_transactions';
  static String apiGetSubscriptions = 'subscriptions';
  static String apiGetSavedTts = 'saved_tts';
  static String apiDeleteTts = 'delete_tts';
  static String apiSaveTts = 'save_tts';
  static String apiConvertActive = 'convert_active';
  static String apiUpdateFcm = 'update_fcm';
  static String apiGeneratePaytmTxnToken = 'generate_paytm_txn_token';
  static String apiGeneratePaytmCheckSum = 'generate_paytm_checksum';
  static String apiUploadReceipts = 'upload_receipts';
  static String isFreeCharAllow = 'is_free_characters_allowed';

  //
  static String offset = 'offset';
  static String limit = 'limit';
  static String firstName = 'first_name';
  static String lastName = 'last_name';
  static String phone = 'phone';
  static String email = 'email';
  static String password = 'password';
  static String type = 'type';
  static String fcmId = 'fcm_id';
  static String variable = 'variable';
  static String id = 'id';
  static String userId = 'user_id';
  static String active = 'active';
  static String error = 'error';
  static String upcoming = 'upcoming';
  static String message = 'message';
  static String image = 'image';
  static String activeSubscription = 'active_subscription';
  static String upcomingSubscription = 'upcoming_subscription';
  static String isFreeTierAllowsLbl = 'isFreeTierAllows';
  static String freeTierCharacterLimitLbl = 'freeTierCharacterLimit';
  static String oldPassword = 'old_password';
  static String newPassword = 'new_password';
  static String language = 'language';
  static String voice = 'voice';
  static String provider = 'provider';
  static String text = 'text';
  static String title = 'title';
  static String subscriptionId = 'subscription_id';
  static String paymentMethod = 'payment_method';
  static String txnId = 'txn_id';
  static String amount = 'amount';
  static String currencyCode = 'currency_code';
  static String status = 'status';
  static String planId = 'plan_id';
  static String tenureId = 'tenure_id';
  static String ttsId = 'tts_id';
  static String base64 = 'base64';
  static String orderId = 'order_id';
  static String mId = 'mId';
  static String recipets = 'reciept';
  static String attachments = 'attachments';
}
