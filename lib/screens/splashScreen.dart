import 'dart:async';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/helper/stringsres.dart';

import 'package:espeech/screens/intropage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../helper/colorsres.dart';
import '../helper/constant.dart';
import 'auth/loginactivity.dart';
import 'mainactivity.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    getData();

    Timer(const Duration(seconds: 3), () async {
      if (!Constant.session!.getBoolData(SessionManager.isIntorSet)) {
        Constant.session!.setBoolData(SessionManager.isIntorSet, true, false);
        Constant.goToNextPage(const IntroPage(), context, true);
      } else if (Constant.session!.isUserLoggedIn()) {
        Constant.goToNextPage(MainActivity(from: "splash"), context, true);
      } else {
        Constant.goToNextPage(LoginActivity(from: "splash"), context, true);
      }
    });
  }

  getData() async {
    if (Constant.session!.isUserLoggedIn()) {
      if (Constant.session!
          .getData(SessionManager.keyLanguageData)
          .trim()
          .isNotEmpty) {
        Constant.getLanguageListFromSession();
      }

      await Constant.getLanguageList(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              alignment: Alignment.center,
              decoration: DesignConfig.gradientBg(),
              child: SvgPicture.asset(
                '${Constant.svgpath}splash_logo.svg',
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(StringsRes.madeby,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .merge(const TextStyle(
                          color: ColorsRes.lighttext,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.5,
                        ))),
                const SizedBox(height: 8),
                SvgPicture.asset(
                  '${Constant.svgpath}wrteam_logo.svg',
                ),
                const SizedBox(height: 10),
              ],
            ),
          )
        ],
      ),
    );
  }
}
