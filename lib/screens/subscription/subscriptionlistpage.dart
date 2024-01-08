import 'dart:convert';

import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/model/plans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jiffy/jiffy.dart';

class SubscriptionListPage extends StatefulWidget {
  const SubscriptionListPage({Key? key}) : super(key: key);

  @override
  _SubscriptionListPageState createState() => _SubscriptionListPageState();
}

class _SubscriptionListPageState extends State<SubscriptionListPage> {
  int offset = 0;
  int perPageLimit = 5;
  int total = 100;
  bool isloading = false, isloadmore = true, isfirstload = false;
  List<Plans> transactionlist = [];
  ScrollController controller = ScrollController();
  String nodatamsg = '';

  @override
  void initState() {
    super.initState();

    controller.addListener(_scrollListener);
    loadMore();
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (transactionlist.length < total) loadMore();
    }
  }

  Future<void> loadMore() async {
    if (!isloadmore) return;
    bool checkinternet = await Constant.checkInternet();
    if (!checkinternet) {
      Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork,1);

      return;
    }

    if (offset == 0) {
      transactionlist = [];
      nodatamsg = '';
      isfirstload = true;
    }
    setState(() {
      isloading = true;
      isloadmore = false;
    });
    Map<String, String?> parameter = {
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
      Constant.offset: offset.toString(),
      Constant.limit: perPageLimit.toString(),
    };

    var response = await Constant.sendApiRequest(
        Constant.apiGetSubscriptions, parameter, true, context);

    var getdata = json.decode(response);
    isfirstload = false;
    if (!getdata[Constant.error]) {
      List list = getdata['data'];
      total = getdata['total'];
      transactionlist.addAll(
          list.map((model) => Plans.fromSubscriptionJson(model)).toList());
      if (transactionlist.length < total) {
        offset = offset + perPageLimit;
        isloadmore = true;
      }
    } else {
      isloadmore = false;
      if (offset == 0) {
        nodatamsg = getdata[Constant.message];
      }
    }

    isloading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.white,
      appBar:
          DesignConfig.setAppBar(context, 0, StringsRes.subscriptions, true, Constant.appbarHeight),
      body: isfirstload
          ? const Center(child: CircularProgressIndicator())
          : nodatamsg.trim().isNotEmpty
              ? Center(
                  child: Text(
                    nodatamsg,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  controller: controller,
                  itemCount: isloadmore
                      ? transactionlist.length + 1
                      : transactionlist.length,
                  itemBuilder: (context, index) {
                    if (index == transactionlist.length && isloadmore) {
                      Future.delayed(const Duration(milliseconds: 800), () {
                        loadMore();
                      });
                    }

                    int colorindex = 0;
                    if (index != transactionlist.length) {
                      colorindex = index % 6;
                    }
                    return (index == transactionlist.length)
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                            onTap: () {
                              planInfo(transactionlist[index]);
                            },
                            child: Container(
                              height: 200,
                              decoration: DesignConfig.boxGradient(
                                  Constant.colorlist1[colorindex],
                                  Constant.colorlist2[colorindex],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: DesignConfig.boxDecoration(
                                            Constant.colorlist2[colorindex]
                                                .withOpacity(0.5),
                                            20),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 20),
                                        child: Text(
                                            transactionlist[index].title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .merge(const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorsRes.white,
                                                    letterSpacing: 0.5)),
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          children: [
                                            Text(
                                              "${Constant.currencysymbol} ${transactionlist[index].price}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .merge(const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5)),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "/ ${transactionlist[index].tenure} ${StringsRes.lblmonths}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .merge(const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                          decoration: DesignConfig
                                              .decorationRoundedSide(
                                                  Constant
                                                      .colorlist1[colorindex]
                                                      .withOpacity(0.7),
                                                  false,
                                                  false,
                                                  true,
                                                  true,
                                                  30),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 18),
                                          child: Row(children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              decoration:
                                                  DesignConfig.boxDecoration(
                                                      Constant.statusColor(
                                                          transactionlist[index]
                                                              .status),
                                                      20),
                                              child: Text(
                                                Constant
                                                    .setFirstLetterUppercase(
                                                        transactionlist[index]
                                                            .status),
                                                style: const TextStyle(
                                                    color: ColorsRes.white,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5),
                                              ),
                                            ),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                    transactionlist[index]
                                                                .status ==
                                                            'expired'
                                                        ? StringsRes.expiredon
                                                        : StringsRes.expireson,
                                                    style: TextStyle(
                                                        color: ColorsRes.white
                                                            .withOpacity(0.7))),
                                                Text(
                                                    '${transactionlist[index].expiresOn}',
                                                    style: TextStyle(
                                                        color: ColorsRes.white
                                                            .withOpacity(0.7))),
                                              ],
                                            ),
                                          ]))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                  },
                ),
    );
  }

  void planInfo(Plans planinfo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(planinfo.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "${Jiffy(planinfo.startsFrom, "yyyy-MM-dd").format("dd-MM-yyyy")} To ${Jiffy(planinfo.expiresOn, "yyyy-MM-dd").format("dd-MM-yyyy")}",
                style: Theme.of(context).textTheme.subtitle1!.merge(
                    const TextStyle(
                        color: ColorsRes.subtextcolor,
                        decoration: TextDecoration.underline))),
            DesignConfig.characterUsageWidget(
                'overall.svg',
                StringsRes.overallcharacter,
                "${Constant.numberFormattor(planinfo.remainingCharacters!)}/${Constant.numberFormattor(planinfo.noOfCharacters)}",
                context,
                true),
            DesignConfig.characterUsageWidget(
                'google.svg',
                StringsRes.lblgoogle,
                "${Constant.numberFormattor(planinfo.remainingGoogle!)}/${Constant.numberFormattor(planinfo.google)}",
                context,
                true),
            DesignConfig.characterUsageWidget(
                'aws.svg',
                StringsRes.lblaws,
                "${Constant.numberFormattor(planinfo.remainingAws!)}/${Constant.numberFormattor(planinfo.aws)}",
                context,
                true),
            DesignConfig.characterUsageWidget(
                'ibm.svg',
                StringsRes.lblibm,
                "${Constant.numberFormattor(planinfo.remainingIbm!)}/${Constant.numberFormattor(planinfo.ibm)}",
                context,
                true),
            DesignConfig.characterUsageWidget(
                'azure.svg',
                StringsRes.lblazure,
                "${Constant.numberFormattor(planinfo.remainingAzure!)}/${Constant.numberFormattor(planinfo.azure)}",
                context,
                true),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(StringsRes.lblok),
          ),
        ],
      ),
    );
  }
}
