import 'dart:convert';
import 'dart:io';
import 'package:espeech/helper/slideAnimation.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../termsconditionactivity.dart';
import '../mainactivity.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  TextEditingController edtemail = TextEditingController();
  TextEditingController edtpsw = TextEditingController();
  TextEditingController edtcpsw = TextEditingController();
  TextEditingController edtfname = TextEditingController();
  TextEditingController edtlname = TextEditingController();
  TextEditingController edtphone = TextEditingController();
  final scaffoldKeyregister = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;

  bool pswvisible = true,
      isloading = false,
      cpswvisible = true,
      acceptterms = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKeyregister,
      backgroundColor: ColorsRes.bgcolor,
      body: Stack(
        children: [
          Container(
            decoration: DesignConfig.gradientBg(),
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 35),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                      padding: const EdgeInsets.only(
                          top: kToolbarHeight, bottom: 20),
                      children: [
                        SlideAnimation(
                          position: 0,
                          itemCount: 8,
                          slideDirection: SlideDirection.fromTop,
                          animationController: _animationController,
                          child: SvgPicture.asset(
                            '${Constant.svgpath}login_logo.svg',
                          ),
                        ),
                        const SizedBox(height: 20),
                        formWidget(),
                        SlideAnimation(
                          position: 6,
                          itemCount: 8,
                          slideDirection: SlideDirection.fromLeft,
                          animationController: _animationController,
                          child: Center(
                              child: DesignConfig.loginBtn(
                                  signinProcess,
                                  StringsRes.createaccount,
                                  isloading,
                                  context)),
                        )
                      ]),
                ),
                SlideAnimation(
                    position: 7,
                    itemCount: 8,
                    slideDirection: SlideDirection.fromBottom,
                    animationController: _animationController,
                    child: bottomWidget()),
              ],
            ),
          ),
          if (Platform.isIOS)
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top, left: 15),
                child: const Icon(Icons.keyboard_arrow_left,
                    color: ColorsRes.white, size: 35),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  bottomWidget() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.subtitle2!.merge(const TextStyle(
            color: ColorsRes.lighttext, fontWeight: FontWeight.w600)),
        text: StringsRes.alreadyhvac,
        children: <TextSpan>[
          TextSpan(
              text: StringsRes.lbllogin,
              style: const TextStyle(
                  color: ColorsRes.white, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pop();
                }),
        ],
      ),
    );
  }

  Widget formWidget() {
    return Form(
      key: _formKey,
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SlideAnimation(
          position: 1,
          itemCount: 8,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: TextFormField(
            style: const TextStyle(color: ColorsRes.white),
            cursorColor: ColorsRes.white,
            decoration: InputDecoration(
              prefixIcon: Container(
                width: double.minPositive,
                margin: const EdgeInsets.only(bottom: 5, left: 5),
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  '${Constant.svgpath}mail.svg',
                ),
              ),
              hintText: StringsRes.emailaddress,
              hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      color: ColorsRes.offwhite, letterSpacing: 0.5)),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.offwhite),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.offwhite),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.errorColor),
              ),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: ColorsRes.errorColor,
              )),
              errorStyle: TextStyle(
                color: ColorsRes.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (val) => Constant.validateEmail(val!),
            controller: edtemail,
          ),
        ),
        const SizedBox(height: 20),
        SlideAnimation(
          position: 2,
          itemCount: 8,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: const TextStyle(color: ColorsRes.white),
                  cursorColor: ColorsRes.white,
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: double.minPositive,
                      margin: const EdgeInsets.only(bottom: 5, left: 5),
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        '${Constant.svgpath}username.svg',
                      ),
                    ),
                    hintText: StringsRes.firstname,
                    hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                        const TextStyle(
                            color: ColorsRes.offwhite, letterSpacing: 0.5)),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorsRes.offwhite),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorsRes.offwhite),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorsRes.errorColor),
                    ),
                    errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: ColorsRes.errorColor,
                    )),
                    errorStyle: TextStyle(
                      color: ColorsRes.errorColor /*ColorsRes.red*/,
                      fontWeight: FontWeight.bold, /*fontFamily: 'Raleway'*/
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) => val.toString().trim().isEmpty
                      ? StringsRes.enterfname
                      : null,
                  controller: edtfname,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  style: const TextStyle(color: ColorsRes.white),
                  cursorColor: ColorsRes.white,
                  decoration: InputDecoration(
                    hintText: StringsRes.lastname,
                    hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                        const TextStyle(
                            color: ColorsRes.offwhite, letterSpacing: 0.5)),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorsRes.offwhite),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorsRes.offwhite),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ColorsRes.errorColor),
                    ),
                    errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: ColorsRes.errorColor,
                    )),
                    errorStyle: TextStyle(
                      color: ColorsRes.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) => val.toString().trim().isEmpty
                      ? StringsRes.enterlname
                      : null,
                  controller: edtlname,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SlideAnimation(
          position: 3,
          itemCount: 8,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: TextFormField(
            style: const TextStyle(color: ColorsRes.white),
            cursorColor: ColorsRes.white,
            decoration: InputDecoration(
              prefixIcon: Container(
                width: double.minPositive,
                margin: const EdgeInsets.only(bottom: 5, left: 5),
                alignment: Alignment.centerLeft,
                child: const Icon(
                  Icons.call,
                  color: ColorsRes.white,
                ),
              ),
              hintText: StringsRes.phonenumber,
              hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      color: ColorsRes.offwhite, letterSpacing: 0.5)),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.offwhite),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.offwhite),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.errorColor),
              ),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: ColorsRes.errorColor,
              )),
              errorStyle: TextStyle(
                color: ColorsRes.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (val) => Constant.validateMobile(val!),
            controller: edtphone,
          ),
        ),
        const SizedBox(height: 20),
        SlideAnimation(
          position: 4,
          itemCount: 8,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: TextFormField(
            obscureText: pswvisible,
            style: const TextStyle(color: ColorsRes.white),
            cursorColor: ColorsRes.white,
            decoration: InputDecoration(
              prefixIcon: Container(
                width: double.minPositive,
                margin: const EdgeInsets.only(bottom: 5, left: 5),
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  '${Constant.svgpath}password.svg',
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                    pswvisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: ColorsRes.white),
                onPressed: () {
                  setState(() {
                    pswvisible = !pswvisible;
                  });
                },
              ),
              hintText: StringsRes.password,
              hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      color: ColorsRes.offwhite, letterSpacing: 0.5)),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.offwhite),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.offwhite),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.errorColor),
              ),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: ColorsRes.errorColor,
              )),
              errorStyle: TextStyle(
                color: ColorsRes.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            keyboardType: TextInputType.text,
            validator: (val) =>
                val.toString().trim().isEmpty ? StringsRes.enterpassword : null,
            controller: edtpsw,
          ),
        ),
        const SizedBox(height: 30),
        SlideAnimation(
          position: 5,
          itemCount: 8,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: Switch(
                      inactiveThumbColor: ColorsRes.darktext,
                      inactiveTrackColor: ColorsRes.grey,
                      activeColor: ColorsRes.switchcolor,
                      value: acceptterms,
                      onChanged: (value) => setState(() {
                            acceptterms = !acceptterms;
                          })),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .merge(const TextStyle(color: ColorsRes.white)),
                          text: StringsRes.iAccept,
                          children: <TextSpan>[
                            TextSpan(
                                text: StringsRes.termsAndCondition,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .merge(const TextStyle(
                                        color: ColorsRes.white,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Constant.goToNextPage(
                                        TermsConditionPage(
                                            StringsRes.termsandcondition,
                                            Constant.typetermscondition),
                                        context,
                                        false);
                                  }),
                            TextSpan(text: " ${StringsRes.lblAND} "),
                            TextSpan(
                                text: StringsRes.privacyPolicy,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .merge(const TextStyle(
                                        color: ColorsRes.white,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Constant.goToNextPage(
                                        TermsConditionPage(
                                            StringsRes.privacyPolicy,
                                            Constant.typeprivacypolicy),
                                        context,
                                        false);
                                  }),
                          ])),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  signinProcess() async {
    if (_formKey.currentState!.validate() && !isloading) {
      if (!acceptterms) {
        Constant.showSnackBarMsg1(context, StringsRes.acceptTermcondition);

        return;
      }
      bool checkinternet = await Constant.checkInternet();
      if (!checkinternet) {
        Constant.showSnackBarMsg1(context, StringsRes.lblchecknetwork);
        return;
      }

      setState(() {
        isloading = true;
      });

      //
      Map<String, String?> parameter = {
        Constant.email: edtemail.text,
        Constant.password: edtpsw.text,
        Constant.firstName: edtfname.text,
        Constant.lastName: edtlname.text,
        Constant.phone: edtphone.text,
      };

      //
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Constant.session = SessionManager(prefs: prefs, context: context);
      //
      var response = await Constant.sendApiRequest(
          Constant.apiRegister, parameter, true, context);

      var getdata = json.decode(response);
      Constant.showSnackBarMsg1(
          context,
          getdata[Constant.message]
              .toString()
              .replaceAll('{', '')
              .replaceAll('}', ''));
      if (!getdata[Constant.error]) {
        Constant.session!.setUserDetail(getdata['data'], getdata['token']);
        Constant.killPreviousPages(context, MainActivity(from: 'login'));
      } else {
        setState(() {
          isloading = false;
        });
      }

      //
    }
  }
}
