import 'dart:convert';
import 'dart:io';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/slideAnimation.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/screens/mainactivity.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'registerpage.dart';

GlobalKey<ScaffoldState>? scaffoldKey;

class LoginActivity extends StatefulWidget {
  String from;

  LoginActivity({Key? key, required this.from}) : super(key: key);

  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity>
    with SingleTickerProviderStateMixin {
  bool isloading = false;
  TextEditingController edtemail = TextEditingController();
  TextEditingController edtpsw = TextEditingController();
  bool pswvisible = true;
  final _formKey = GlobalKey<FormState>();
  AnimationController? _animationController;
  String? supportEmail;

  @override
  void initState() {
    super.initState();

    setConfigs();

    scaffoldKey = GlobalKey<ScaffoldState>();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
  }

  setConfigs() async {
//generalsettings
    Map<String, String?> genparameter = {
      Constant.variable: Constant.generalSettings
    };
    var genresponse = await Constant.sendApiRequest(
        Constant.apiGetSettings, genparameter, true, context);

    var gengetdata = json.decode(genresponse);

    if (!gengetdata[Constant.error]) {
      var data = gengetdata["data"];
      supportEmail = data[Constant.supportEmail];
    }

    if (mounted) setState(() {});
  }

  bottomWidget() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.subtitle2!.merge(const TextStyle(
            color: ColorsRes.lighttext, fontWeight: FontWeight.w600)),
        text: StringsRes.donthvac,
        children: <TextSpan>[
          TextSpan(
              text: StringsRes.register,
              style: const TextStyle(
                  color: ColorsRes.white, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Constant.goToNextPage(const RegisterPage(), context, false);
                }),
        ],
      ),
    );
  }

  forgotPassWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          child: Text(
            StringsRes.forgotpassword,
            style: const TextStyle(color: ColorsRes.white, fontSize: 13),
          ),
          onTap: () {
            showDialog(
                context: context, builder: (context) => const ForgotDialog());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(children: [
                            SlideAnimation(
                              position: 0,
                              itemCount: 5,
                              slideDirection: SlideDirection.fromTop,
                              animationController: _animationController,
                              child: SvgPicture.asset(
                                '${Constant.svgpath}login_logo.svg',
                              ),
                            ),
                            const SizedBox(height: 20),
                            formWidget(),
                            const SizedBox(height: 50),
                            SlideAnimation(
                                position: 3,
                                itemCount: 5,
                                slideDirection: SlideDirection.fromLeft,
                                animationController: _animationController,
                                child: DesignConfig.loginBtn(signinProcess,
                                    StringsRes.lbllogin, isloading, context))
                          ]),
                        ),
                      ),
                    ),
                    SlideAnimation(
                        position: 4,
                        itemCount: 5,
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
                    exit(0);
                  },
                ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  child: const Padding(
                    padding: EdgeInsets.only(top: 30, right: 15),
                    child: Icon(Icons.info),
                  ),
                  onTap: () {
                    _launchEmail();
                  },
                ),
              ),
            ],
          )),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: encodeQueryParameters(<String, String>{'subject': ''}),
    );

    if (await canLaunchUrlString(emailLaunchUri.toString())) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  Widget formWidget() {
    return Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SlideAnimation(
          position: 1,
          itemCount: 5,
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
                  '${Constant.svgpath}username.svg',
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
          itemCount: 5,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: TextFormField(
            obscureText: true,
            style: const TextStyle(color: ColorsRes.white),
            cursorColor: ColorsRes.white,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.only(bottom: 5, left: 5),
                alignment: Alignment.centerLeft,
                width: double.minPositive,
                child: SvgPicture.asset(
                  '${Constant.svgpath}password.svg',
                ),
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
        SlideAnimation(
            position: 2,
            itemCount: 5,
            slideDirection: SlideDirection.fromLeft,
            animationController: _animationController,
            child: forgotPassWidget())
      ]),
    );
  }

  signinProcess() async {
    if (_formKey.currentState!.validate() && !isloading) {
      bool checkinternet = await Constant.checkInternet();
      if (!checkinternet) {
        Constant.showSnackBarMsg1(context, StringsRes.lblchecknetwork);
      } else {
        setState(() {
          isloading = true;
        });

        //
        Map<String, String?> parameter = {
          Constant.email: edtemail.text,
          Constant.password: edtpsw.text,
        };

        var response = await Constant.sendApiRequest(
            Constant.apiLogin, parameter, true, context);

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
      }
    }
  }
}

class ForgotDialog extends StatefulWidget {
  const ForgotDialog({Key? key}) : super(key: key);

  @override
  ForgotAlert createState() => ForgotAlert();
}

class ForgotAlert extends State<ForgotDialog> {
  late BuildContext _scaffoldContext;
  bool iserror = false;
  late TextEditingController forgotedtemail;
  bool isdialogloading = false;

  @override
  initState() {
    forgotedtemail = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return openForgotDialog();
  }

  openForgotDialog() {
    return AlertDialog(
      title: Text(StringsRes.forgotpassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: forgotedtemail,
            decoration: InputDecoration(
              hintText: StringsRes.emailaddress,
              errorText: iserror ? StringsRes.enterValidEmail : null,
            ),
          ),
          const SizedBox(height: 5),
          isdialogloading ? const CircularProgressIndicator() : Container(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(StringsRes.lblcancel),
          onPressed: () {
            Navigator.of(_scaffoldContext).pop();
          },
        ),
        TextButton(
          child: Text(StringsRes.recoverpassword),
          onPressed: () async {
            setState(() {
              Constant.validateEmail(forgotedtemail.text) == null
                  ? iserror = false
                  : iserror = true;
              if (!iserror) isdialogloading = true;
            });

            if (!iserror) {
              Map<String, String?> parameter = {
                Constant.email: forgotedtemail.text,
              };

              var response = await Constant.sendApiRequest(
                  Constant.apiForgotPassword, parameter, true, context);

              var getdata = json.decode(response);
              Constant.showSnackBarMsg1(context, getdata[Constant.message]);

              Navigator.of(_scaffoldContext).pop();
            }
          },
        ),
      ],
    );
  }
}
