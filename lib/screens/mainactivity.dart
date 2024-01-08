import 'dart:convert';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/screens/profilePage.dart';

import 'package:espeech/screens/texttospeechfiles/savedttslist.dart';
import 'package:espeech/screens/subscription/planspage.dart';
import 'package:espeech/screens/termsconditionactivity.dart';
import 'package:espeech/screens/usermanualpage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/BottomAppProvider.dart';
import '../helper/sessionmanager.dart';

double keyboardvisibility = 0;

class MainActivity extends StatefulWidget {
  String from;

  MainActivity({Key? key, required this.from}) : super(key: key);

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity>
    with SingleTickerProviderStateMixin {
  int currentpage = 0;
  bool isfullscreen = false;
  DateTime? currentBackPressTime;
  List<Widget> pages = [];
  late List settinglist;

  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin
    duration: const Duration(milliseconds: 500),
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Constant.showSnackBarMsg(context, StringsRes.doubletapexitmsg, 1);

      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      context
          .read<BottomAppProvider>()
          .setAnimationController(navigationContainerAnimationController);
    });
    settinglist = [];
    currentpage = 0;
    setConfigs();
  }

  setPages() {
    pages = [];
    pages = [
      const SavedTtsList(
        isBack: false,
      ),
      const PlansPage(
        appbar: false,
        isBack: false,
      ),
      UserManualPage(
        goToPage: changePage,
      ),
    ];
  }

  setFullScreen() {
    isfullscreen = !isfullscreen;
    setState(() {});
  }

  setStripeData() async {
    Stripe.publishableKey = Constant.stripePublishableKey;

    await Stripe.instance.applySettings();
  }

  setConfigs() async {
    setPages();

    SharedPreferences pref = await SharedPreferences.getInstance();
    SessionManager sessionManager =
        SessionManager(prefs: pref, context: context);
    Constant.session = sessionManager;

//langdata
    if (Constant.session!
        .getData(SessionManager.keyLanguageData)
        .trim()
        .isEmpty) {
      await Constant.getLanguageList(context);
    } else {
      Constant.getLanguageListFromSession();
    }

//get settings
    Map<String, String?> parameter = {};

    var response = await Constant.sendApiRequest(
        Constant.apiGetAvailableSettings, parameter, true, context);

    var getdata = json.decode(response);

    if (!getdata[Constant.error]) {
      settinglist.clear();
      settinglist = getdata['data'];

      if (mounted) setState(() {});
    }
    //
    await Constant.getUserInfo(context);

    getTagList();
    setState(() {});

    //getttsconfig
    Map<String, String?> ttsparameter = {
      Constant.variable: Constant.ttsConfigSettings
    };
    var ttsresponse = await Constant.sendApiRequest(
        Constant.apiGetSettings, ttsparameter, true, context);

    var ttsgetdata = json.decode(ttsresponse);



    if (!ttsgetdata[Constant.error]) {
      var data = ttsgetdata["data"];
      if (data.containsKey(Constant.isFreeTierAllowsLbl) &&
          data[Constant.isFreeTierAllowsLbl] != null) {
        Constant.isFreeTierAllow = data[Constant.isFreeTierAllowsLbl];
      }
      if (data.containsKey(Constant.freeTierCharacterLimitLbl) &&
          data[Constant.freeTierCharacterLimitLbl] != null) {

        Constant.freeTierCharacters = data[Constant.freeTierCharacterLimitLbl];
      }
    }

//generalsettings
    Map<String, String?> genparameter = {
      Constant.variable: Constant.generalSettings
    };
    var genresponse = await Constant.sendApiRequest(
        Constant.apiGetSettings, genparameter, true, context);

    var gengetdata = json.decode(genresponse);

    if (!gengetdata[Constant.error]) {
      Constant.mapgeneralsettings = gengetdata['data'];
      Constant.currencysymbol = Constant.mapgeneralsettings['currency'];
    }
//
//paymentsettings
    Map<String, String?> payparameter = {
      Constant.variable: Constant.paymentGatewaysSettings
    };
    var payresponse = await Constant.sendApiRequest(
        Constant.apiGetSettings, payparameter, true, context);

    var paygetdata = json.decode(payresponse);


    if (!paygetdata[Constant.error]) {
      //razorpay
      Constant.razorpayApiStatus = paygetdata['data']['razorpay']['status'];
      Constant.razorpayMode = paygetdata['data']['razorpay']['mode'];
      Constant.razorpayKey = paygetdata['data']['razorpay']['key'];

      Constant.razorpayCurrencyCode =
          paygetdata['data']['razorpay']['currency'];

      //paystack
      Constant.paystackStatus = paygetdata['data']['paystack']['status'];
      Constant.paystackMode = paygetdata['data']['paystack']['mode'];
      Constant.paystackKey = paygetdata['data']['paystack']['key'];

      Constant.paystackCurrencyCode =
          paygetdata['data']['paystack']['currency'];

      //stripe
      Constant.stripeStatus = paygetdata['data']['stripe']['status'];
      Constant.stripeMode = paygetdata['data']['stripe']['mode'];
      Constant.stripeCurrency = paygetdata['data']['stripe']['currency'];
      Constant.stripePublishableKey =
          paygetdata['data']['stripe']['publishable_key'];

      setStripeData();

      //bank transfer
      Constant.bankTranStatus = paygetdata['data']['bank']['status'];
      Constant.bankAccDetails = paygetdata['data']['bank']['account_details'];
      Constant.bankIntrustions = paygetdata['data']['bank']['instructions'];
      Constant.bankExtraDetails = paygetdata['data']['bank']['extra_details'];

      //paytm
      Constant.paytmStatus = paygetdata['data']['paytm']['status'];
      Constant.paytmMode = paygetdata['data']['paytm']['mode'];
      Constant.paytmMerchantId =
          paygetdata['data']['paytm']['paytm_merchant_id'];
      Constant.paytmMerchantKey =
          paygetdata['data']['paytm']['paytm_merchant_key'];
      Constant.paytmUrl = paygetdata['data']['paytm']['url'];
      Constant.paytmWebsite = paygetdata['data']['paytm']['paytm_website'];
      Constant.paytmIndustryTypeId =
          paygetdata['data']['paytm']['paytm_industry_type_id'];
    }

    try {
      if (Constant.session!.isUserLoggedIn()) {
        FirebaseMessaging.instance.getToken().then((token) async {
          if (token != null &&
              Constant.session!.getData(SessionManager.keyFcmId).trim() !=
                  token) {
            updateFirebaseToken(token);
          }
        });
      }
    } on Exception catch (_) {}

    if (mounted) setState(() {});
//
  }

  updateFirebaseToken(String token) async {
    Map<String, String> body = {
      Constant.fcmId: token,
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
    };

    var response = await Constant.sendApiRequest(
        Constant.apiUpdateFcm, body, true, context);
    var getdata = json.decode(response);
    if (!getdata[Constant.error]) {
      Constant.session!.setData(SessionManager.keyFcmId, token);
    }
  }

  getTagList() async {
    Map<String, String?> parameter = {};

    var response = await Constant.sendApiRequest(
        Constant.apiGetTags, parameter, true, context);
    var getdata = json.decode(response);
    if (!getdata[Constant.error]) {
      Map data = getdata['data'];
      List keys = data.keys.toList();
      Constant.taglist = {};
      for (String key in keys) {
        Map<String, List> datalist = {};

        data[key].forEach((key, value) {
          datalist[key] = value;
        });
        Constant.taglist[key] = datalist;
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          key: _scaffoldKey,
          extendBody: true,
          extendBodyBehindAppBar:
              Provider.of<BottomAppProvider>(context).isShowBar ? false : true,

          backgroundColor: ColorsRes.white,
          bottomNavigationBar: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(
                      parent: navigationContainerAnimationController,
                      curve: Curves.easeInOut)),
              child: SlideTransition(
                  position: Tween<Offset>(
                          begin: Offset.zero, end: const Offset(0.0, 1.0))
                      .animate(CurvedAnimation(
                          parent: navigationContainerAnimationController,
                          curve: Curves.easeInOut)),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: bottomWidget()))),
          body: pages[currentpage]),
    );
  }

  changePage(int no) {
    if (currentpage != no) {
      currentpage = no;
      setState(() {});
    }
  }

  bottomWidget() {
    return Container(
      height: Constant.bottomNavigationHeight,
      alignment: Alignment.center,
      padding: const EdgeInsetsDirectional.only(start: 10.0, end: 10.0),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(39), topLeft: Radius.circular(39)),
          boxShadow: [
            BoxShadow(
                color: ColorsRes.circleBtnShadow,
                offset: Offset(0, -3),
                blurRadius: 6,
                spreadRadius: 0)
          ],
          gradient: LinearGradient(
            begin: Alignment(0, 0.00930662266910076),
            end: Alignment(1, 1),
            colors: [ColorsRes.gradient1, ColorsRes.gradient2],
          )),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              changePage(Constant.pageSavedText);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                currentpage == 0
                    ? SvgPicture.asset("${Constant.svgpath}active_home.svg")
                    : SvgPicture.asset("${Constant.svgpath}home.svg",
                        color: ColorsRes.lightIccolor),
                if (currentpage == 0)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 5.0),
                    child: Text(StringsRes.homeLbl,
                        style: const TextStyle(
                            color: ColorsRes.white,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0),
                        textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
            child: GestureDetector(
          onTap: () {
            changePage(Constant.pagePlan);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              currentpage == 1
                  ? SvgPicture.asset("${Constant.svgpath}active_premium.svg")
                  : SvgPicture.asset("${Constant.svgpath}premium.svg",
                      color: ColorsRes.lightIccolor),
              if (currentpage == 1)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5.0),
                  child: Text(StringsRes.premiLbl,
                      style: const TextStyle(
                          color: ColorsRes.white,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      textAlign: TextAlign.center),
                ),
            ],
          ),
        )),
        Expanded(
            child: GestureDetector(
          onTap: () {
            changePage(Constant.pageUserManual);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              currentpage == 2
                  ? SvgPicture.asset("${Constant.svgpath}active_profile.svg")
                  : SvgPicture.asset("${Constant.svgpath}profile.svg",
                      color: ColorsRes.lightIccolor),
              if (currentpage == 2)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5.0),
                  child: Text(StringsRes.profileLbl,
                      style: const TextStyle(
                          color: ColorsRes.white,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0),
                      textAlign: TextAlign.center),
                ),
            ],
          ),
        )),
      ]),
    );
  }

  drawerHeader() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();

        Constant.goToNextPage(const ProfilePage(), context, false);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 5),
          Container(
            width: 79,
            height: 79,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(45.0)),
                border: Border.all(
                  color: ColorsRes.grey,
                  width: 2,
                )),
            child: ClipOval(
                child: Constant.getSession(context)!
                        .getData(SessionManager.keyImage)
                        .trim()
                        .isNotEmpty
                    ? Image.network(
                        Constant.getSession(context)!
                            .getData(SessionManager.keyImage),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Constant.defaultImage(75, 75);
                        },
                        loadingBuilder: (BuildContext context, Widget? child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child!;
                          return Constant.defaultImage(75, 75);
                        },
                      )
                    : Constant.defaultImage(75, 75)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${Constant.getSession(context)!.getData(SessionManager.keyFirstName)} ${Constant.getSession(context)!.getData(SessionManager.keyLastName)}",
                    style: Theme.of(context).textTheme.subtitle1!.merge(
                          const TextStyle(
                            color: ColorsRes.black,
                          ),
                        )),
                Text(
                    Constant.getSession(context)!
                        .getData(SessionManager.keyEmail),
                    style: Theme.of(context).textTheme.subtitle2!.merge(
                          const TextStyle(
                            color: ColorsRes.black,
                          ),
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  drawerWidget() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: 0, vertical: MediaQuery.of(context).padding.top),
        children: [
          drawerHeader(),
          ListTile(
            leading: const Icon(Icons.mic),
            title: Text(StringsRes.texttospeech),
            onTap: () {
              Navigator.of(context).pop();
              changePage(Constant.pageSavedText);
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined),
            title: Text(StringsRes.plans),
            onTap: () {
              Navigator.of(context).pop();
              changePage(Constant.pagePlan);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_sharp),
            title: Text(StringsRes.transactions),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_sharp),
            title: Text(StringsRes.subscriptions),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_sharp),
            title: Text(StringsRes.savedtexttospeech),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          settingWidget(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(StringsRes.logout),
            onTap: () {
              Navigator.of(context).pop();
              Constant.session!.logoutUser(context);
            },
          ),
        ],
      ),
    );
  }

  settingWidget() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(settinglist.length, (index) {
          String mainname = settinglist[index];
          String title = Constant.setFirstLetterUppercase(mainname);
          return Constant.consigsettinglist.contains(mainname)
              ? Container()
              : ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(title),
                  onTap: () {
                    Navigator.of(context).pop();
                    Constant.goToNextPage(
                        TermsConditionPage(title, mainname), context, false);
                  },
                );
        }));
  }
}
