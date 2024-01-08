import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/model/plans.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class CurrentPlanInfo extends StatefulWidget {
  const CurrentPlanInfo({Key? key}) : super(key: key);

  @override
  _CurrentPlanInfoState createState() => _CurrentPlanInfoState();
}

class _CurrentPlanInfoState extends State<CurrentPlanInfo> {
  late Plans currpageplan = Constant.currsubscriptionPlan!;
  bool isactive = true;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    await Constant.getUserInfo(context);
    currpageplan = Constant.currsubscriptionPlan!;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.bgcolor,
      appBar: Constant.currsubscriptionPlan == null &&
              Constant.upcomingsubscriptionPlan == null
          ? DesignConfig.setAppBar(
              context, 0, StringsRes.currentplaninfo, false, Constant.appbarHeight)
          : null,
      body: Constant.currsubscriptionPlan == null &&
              Constant.upcomingsubscriptionPlan == null
          ? Center(
              child: Text(StringsRes.noactiveplanfound,
                  style: Theme.of(context).textTheme.headline6!.merge(
                      const TextStyle(
                          color: ColorsRes.appcolor, letterSpacing: 0.5))),
            )
          : Container(
              decoration: DesignConfig.gradientBg(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios_outlined,
                            color: ColorsRes.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              isactive
                                  ? StringsRes.activeplan
                                  : StringsRes.upcomingplan,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .merge(const TextStyle(
                                    color: ColorsRes.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ))),
                          Text(currpageplan.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .merge(const TextStyle(
                                      color: ColorsRes.white,
                                      letterSpacing: 0.3,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.normal))),
                          const SizedBox(height: 10),
                          Text(StringsRes.time_period_lbl,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .merge(const TextStyle(
                                      color: ColorsRes.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5))),
                          Text("${currpageplan.tenure} ${StringsRes.lblmonths}",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .merge(const TextStyle(
                                      color: ColorsRes.white,
                                      letterSpacing: 0.3,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15))),
                          const SizedBox(height: 25),
                        ]),
                  ),
                  Expanded(
                    child: PageView(

                        onPageChanged: (int page) {
                          if (page == 0) {
                            isactive = true;
                            currpageplan = Constant.currsubscriptionPlan!;
                          } else {
                            currpageplan = Constant.upcomingsubscriptionPlan!;
                            isactive = false;
                          }
                          setState(() {});
                        },
                        children: [
                          if (Constant.currsubscriptionPlan != null)
                            activeplaInfoWidget(StringsRes.activeplan,
                                Constant.currsubscriptionPlan),
                          if (Constant.upcomingsubscriptionPlan != null)
                            activeplaInfoWidget(StringsRes.upcomingplan,
                                Constant.upcomingsubscriptionPlan),
                        ]),
                  ),
                ],
              ),
            ),
    );
  }

  activeplaInfoWidget(String title, var data) {
    return Container(
      decoration: DesignConfig.decorationRoundedSide(
          ColorsRes.white, true, true, false, false, 35),
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: ListView(shrinkWrap: true, children: [
        Text(
          StringsRes.planduration,
          style: Theme.of(context).textTheme.subtitle1!.merge(const TextStyle(
              color: ColorsRes.appcolor,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
              fontSize: 17)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              StringsRes.startfrom,
              style: const TextStyle(
                  color: ColorsRes.appcolor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
            const Spacer(),
            Text(StringsRes.expireson,
                style: const TextStyle(
                    color: ColorsRes.appcolor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ],
        ),
        Row(
          children: [
            Text(Jiffy(data.startsFrom, "yyyy-MM-dd").format("dd-MM-yyyy"),
                style: const TextStyle(
                    color: ColorsRes.mainsubtextcolor,
                    fontWeight: FontWeight.w400,
                    fontSize: 13.5)),
            const Spacer(),
            Text(Jiffy(data.expiresOn, "yyyy-MM-dd").format("dd-MM-yyyy"),
                style: const TextStyle(
                    color: ColorsRes.mainsubtextcolor,
                    fontWeight: FontWeight.w400,
                    fontSize: 13.5)),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          StringsRes.charactersusage,
          style: Theme.of(context).textTheme.subtitle1!.merge(const TextStyle(
              color: ColorsRes.appcolor,
              letterSpacing: 0.5,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 20),
        DesignConfig.characterUsageWidget(
            'overall.svg',
            StringsRes.overallcharacter,
            "${Constant.numberFormattor(data.remainingCharacters)}/${Constant.numberFormattor(data.noOfCharacters)}",
            context,
            false),
        DesignConfig.characterUsageWidget(
            'google.svg',
            StringsRes.lblgoogle,
            "${Constant.numberFormattor(data.remainingGoogle)}/${Constant.numberFormattor(data.google)}",
            context,
            false),
        DesignConfig.characterUsageWidget(
            'aws.svg',
            StringsRes.lblaws,
            "${Constant.numberFormattor(data.remainingAws)}/${Constant.numberFormattor(data.aws)}",
            context,
            false),
        DesignConfig.characterUsageWidget(
            'ibm.svg',
            StringsRes.lblibm,
            "${Constant.numberFormattor(data.remainingIbm)}/${Constant.numberFormattor(data.ibm)}",
            context,
            false),
        DesignConfig.characterUsageWidget(
            'azure.svg',
            StringsRes.lblazure,
            "${Constant.numberFormattor(data.remainingAzure)}/${Constant.numberFormattor(data.azure)}",
            context,
            false),
      ]),
    );
  }
}
