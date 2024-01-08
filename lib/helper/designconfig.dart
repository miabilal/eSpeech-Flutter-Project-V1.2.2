
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'BottomAppProvider.dart';

class DesignConfig {
  static RoundedRectangleBorder setRoundedBorder(
      Color bordercolor, double bradius, bool isboarder) {
    return RoundedRectangleBorder(
        side: BorderSide(color: bordercolor, width: isboarder ? 1.0 : 0),
        borderRadius: BorderRadius.circular(bradius));
  }

  static RoundedRectangleBorder setRoundedSpecificBorder(
      double bradius, bool istop, bool isbtm) {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(istop ? bradius : 0),
      topRight: Radius.circular(istop ? bradius : 0),
      bottomLeft: Radius.circular(isbtm ? bradius : 0),
      bottomRight: Radius.circular(isbtm ? bradius : 0),
    ));
  }

  static Widget loaderWidget() {
    return Center(
      child: const CircularProgressIndicator(),
    );
  }

  static BoxDecoration gradientBg() {
    return BoxDecoration(
        gradient: linearGradient(ColorsRes.gradient1, ColorsRes.gradient2));
  }

  static BoxDecoration boxGradient(Color color1, Color color2, double radius) {
    return BoxDecoration(
        gradient: linearGradient(color1, color2),
        borderRadius: BorderRadius.circular(radius));
  }

  static LinearGradient linearGradient(Color color1, Color color2) {
    return LinearGradient(
      colors: [color1, color2],
      stops: const [0, 1],
      begin: const Alignment(-0.42, -0.91),
      end: const Alignment(0.42, 0.91),
      // angle: 155,
      // scale: undefined,
    );
  }

  static BoxDecoration boxDecorationBorder(
      Color bcolor, Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: bcolor),
    );
  }

  static BoxDecoration boxDecoration(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationGradient(double radius) {
    return BoxDecoration(
      gradient: linearGradient(ColorsRes.gradient1, ColorsRes.gradient2),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static setAppBar(
      BuildContext context, int cur, String title, bool isBack, double? height) {
    return PreferredSize(
        preferredSize: Size.fromHeight(height!),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: height == 0 ? 0 : -MediaQuery.of(context).size.width * (1),
            top: height == 0 ? 0 : -MediaQuery.of(context).size.width * (2.749),
            child: Container(
              width: height == 0 ? 0 : MediaQuery.of(context).size.width * (3),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(

                        color:ColorsRes.shadowcolor,
                        blurRadius: height == 0 ? 0 : 10,
                        spreadRadius: height == 0 ? -5 : 0.0,
                        offset: Offset.zero)
                  ],
                  shape: BoxShape.circle),
              height: height == 0 ? 0 : MediaQuery.of(context).size.width * (3),
            ),
          ),
          Positioned(
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: Colors.white,
              height: height == 0 ? 0 : height,
              width: MediaQuery.of(context).size.width,
              child: height == 0
                  ? Container(
                      width: 0,
                    )
                  : AppBar(
                      elevation: height == 0 ? 0 : 8,
                      automaticallyImplyLeading: isBack ? true : false,
                      shadowColor: Colors.black38,
                      centerTitle: true,
                      title: cur == 1
                          ? Text(
                              StringsRes.plans,
                              style: const TextStyle(
                                  color: ColorsRes.black,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 20.0),
                            )
                          : cur == 2
                              ? Text(
                                  StringsRes.profile,
                                  style: const TextStyle(
                                      color: ColorsRes.black,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 20.0),
                                )
                              : title != ""
                                  ? Text(
                                      title,
                                      style: const TextStyle(
                                          color: ColorsRes.black,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 20.0),
                                    )
                                  : SvgPicture.asset(
                                      "${Constant.svgpath}homelogo.svg",
                                    ),
                      backgroundColor: ColorsRes.bgcolor,
                      leading: isBack
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_outlined,
                                  color: ColorsRes.black),
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          : Container(),
                    ),
            ),
          ),
        ]));
  }


  static dialogAnimate(BuildContext context, Widget dialge) {
    return showGeneralDialog(
        barrierColor: ColorsRes.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(opacity: a1.value, child: dialge),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        // pageBuilder: null
        pageBuilder: (context, animation1, animation2) {
          return Container();
        } //as Widget Function(BuildContext, Animation<double>, Animation<double>)
        );
  }



  static BoxDecoration decorationRoundedSide(Color color, bool istopleft,
      bool istopright, bool isbtmleft, bool isbtmright, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(istopright ? radius : 0),
          bottomRight: Radius.circular(isbtmright ? radius : 0),
          topLeft: Radius.circular(istopleft ? radius : 0),
          bottomLeft: Radius.circular(isbtmleft ? radius : 0)),
      boxShadow: const [
        BoxShadow(
            color: ColorsRes.proContShadow,
            offset: Offset(0, -3),
            blurRadius: 20,
            spreadRadius: 0)
      ],
    );
  }

  static characterUsageWidget(String img, String title, String chrusage,
      BuildContext context, bool fromlist) {
    return fromlist
        ? ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: SvgPicture.asset(Constant.svgpath + img),
            title: Text(title),
            subtitle: Text(chrusage),
          )
        : Container(
            decoration: DesignConfig.boxDecoration(
                ColorsRes.mainsubtextcolor.withOpacity(0.2), 15),
            margin: EdgeInsets.only(bottom: fromlist ? 5 : 10),
            padding: EdgeInsets.only(
                left: fromlist ? 5 : 10,
                top: fromlist ? 5 : 10,
                bottom: fromlist ? 5 : 10),
            child: Row(children: [
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5),
                  child: SvgPicture.asset(Constant.svgpath + img)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: Theme.of(context).textTheme.subtitle1!.merge(
                            const TextStyle(
                                color: ColorsRes.maintextcolor, fontSize: 14,fontWeight: FontWeight.w500,))),
                    const SizedBox(height: 8),
                    Text(chrusage,
                        style: Theme.of(context).textTheme.headline6!.merge(
                            const TextStyle(
                                color: ColorsRes.subtextcolor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14))),
                  ])),
            ]),
          );
  }

  static loginBtn(
      Function callback, String btntext, bool isloading, BuildContext context) {
    double opacity;
    if (isloading) {
      opacity = 0.0;
    } else {
      opacity = 1.0;
    }
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (isloading) return;
            callback();
            /*  setState(() {
              isloading = !isloading;
              _opacity = _opacity == 1.0 ? 0.0 : 1.0;
            }); */
          },
          child: AnimatedContainer(
            width: isloading ? 65 : MediaQuery.of(context).size.width,
            height: 65,
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isloading ? 70.0 : 42.0),
              color: ColorsRes.white,
            ),
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 700),
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: opacity,
              child: Text(
                btntext.toUpperCase(),
                style: Theme.of(context).textTheme.headline6!.merge(
                    const TextStyle(
                        color: ColorsRes.appcolor,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (isloading) return;
            callback();
          },
          child: AnimatedContainer(
            width: isloading ? 65 : MediaQuery.of(context).size.width,
            height: 65,
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isloading ? 70.0 : 42.0),
            ),
            duration: const Duration(milliseconds: 700),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: opacity == 0.0 ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: CircularProgressIndicator(
                    backgroundColor: ColorsRes.appcolor,
                    valueColor: AlwaysStoppedAnimation<Color>(isloading
                        ? ColorsRes.loadercolor
                        : ColorsRes.appcolor)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void hideAppbarAndBottomBarOnScroll(
  ScrollController scrollBottomBarController,
  BuildContext context,
) {
  scrollBottomBarController.addListener(() {
    if (scrollBottomBarController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!context.read<BottomAppProvider>().animationController.isAnimating) {

          context.read<BottomAppProvider>().setBottom(true);
          context.read<BottomAppProvider>().showBars(false);
          context.read<BottomAppProvider>().animationController.forward();

      }
    }
    if (scrollBottomBarController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!context.read<BottomAppProvider>().animationController.isAnimating) {

          context.read<BottomAppProvider>().setBottom(false);
          context.read<BottomAppProvider>().showBars(true);
          context.read<BottomAppProvider>().animationController.reverse();
      }
    }
  });
}
