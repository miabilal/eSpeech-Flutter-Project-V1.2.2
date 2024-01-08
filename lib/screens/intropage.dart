import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/screens/auth/loginactivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late PageController pagecontroller;
  int currind = 0;
  double btmmargin = 150;
  List imglist = [
    'onbo_a.png',
    'onbo_b.png',
    'onbo_c.png',
  ];
  List titlelist = [
    StringsRes.introtitle1,
    StringsRes.introtitle2,
    StringsRes.introtitle3,
  ];

  List desclist = [
    StringsRes.introdesc1,
    StringsRes.introdesc2,
    StringsRes.introdesc3,
  ];

  @override
  void dispose() {
    pagecontroller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    pagecontroller = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
            decoration: DesignConfig.gradientBg(),
            child: Stack(children: [
              Container(
                decoration: DesignConfig.decorationRoundedSide(
                    ColorsRes.bgcolor, false, false, true, true, 34),
                margin: EdgeInsets.only(bottom: btmmargin),
                height: MediaQuery.of(context).size.height,
                child: PageView(
                  controller: pagecontroller,
                  onPageChanged: (int ind) {
                    currind = ind;
                    setState(() {});
                  },
                  children: List.generate(
                      imglist.length,
                      (index) => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(Constant.imgpath + imglist[index],
                                  width: double.maxFinite,
                                  fit: BoxFit.fitWidth),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 30),
                                child: Column(
                                  children: [
                                    Text(
                                      titlelist[index],
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .merge(const TextStyle(
                                            color: ColorsRes.maintextcolor,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.normal,
                                          )),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      desclist[index],
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .merge(const TextStyle(
                                            color: ColorsRes.subtextcolor,
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                          )),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),
                ),
              ),
              Positioned(
                top: kToolbarHeight,
                left: 0,
                right: 0,
                child: SvgPicture.asset(
                  '${Constant.svgpath}intro_logo.svg',
                ),
              ),
              Positioned(
                  bottom: btmmargin - 28,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      if (currind < 2) {
                        currind++;
                        pagecontroller.animateToPage(
                          currind,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        Constant.goToNextPage(
                            LoginActivity(from: 'splash'), context, true);
                      }
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration:
                            DesignConfig.boxDecoration(ColorsRes.btncolor, 42),
                        child: Text(StringsRes.lblnext.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .merge(const TextStyle(
                                  letterSpacing: 0.5,
                                  color: ColorsRes.white,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                )))),
                  )),
              Positioned(
                bottom: btmmargin,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            margin:
                                const EdgeInsets.only(right: 15.0, bottom: 50),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: currind == index
                                  ? ColorsRes.appcolor
                                  : ColorsRes.bgcolor,
                              border: Border.all(
                                color: ColorsRes.appcolor,
                              ),
                              shape: BoxShape.circle,
                            ),
                          )),
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                      onPressed: () {
                        Constant.goToNextPage(
                            LoginActivity(from: 'splash'), context, true);
                      },
                      child: Text(StringsRes.skipintro,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .merge(const TextStyle(
                                color: ColorsRes.offwhite,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              )))))
            ])),
      ),
    );
  }
}
