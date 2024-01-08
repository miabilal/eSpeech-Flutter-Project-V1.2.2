import 'dart:convert';

import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/model/plans.dart';
import 'package:espeech/screens/subscription/subscribepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_svg/svg.dart';

late Plans selectedplan;

class PlansPage extends StatefulWidget {
  final bool appbar;
  final bool isBack;

  const PlansPage({Key? key, required this.appbar, required this.isBack})
      : super(key: key);

  @override
  _PlansPageState createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> with TickerProviderStateMixin {
  late List<Plans> planlist;
  bool isloading = true;
  PageController pagecontroller = PageController();
  int currpage = 0;
  final ScrollController _controller = ScrollController();

  final ScrollController _controller1 = ScrollController();
  bool islistclick = false;
  double testpos = 0;
  bool _showAppbar = true;
  List<Map<String, dynamic>> _tabs = [];
  TabController? _tc;

  @override
  void initState() {
    super.initState();
    myScroll();

    planlist = [];
    getPlanList();

    initializePaystack();
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller1.removeListener(() {});
    pagecontroller.removeListener(() {});

    super.dispose();
  }

  initializePaystack() async {
    final plugin = PaystackPlugin();
    if (!plugin.sdkInitialized) {
      await plugin.initialize(publicKey: Constant.paystackKey);
    }
  }

  getPlanList() async {
    Map<String, String?> parameter = {};

    var response = await Constant.sendApiRequest(
        Constant.apiGetPlans, parameter, true, context);

    var getdata = json.decode(response);
    planlist.clear();
    if (!getdata[Constant.error]) {
      List list = getdata['data'];

      for (var element in list) {
        Plans plans = Plans.fromJson(element);
        if (plans.tenurelist.isNotEmpty) {
          planlist.add(plans);
        }
      }

      this._addInitailTab();
    }
    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
  }

  void myScroll() async {
    _controller1.addListener(() {
      if (_controller1.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showAppbar) {
          _showAppbar = false;
        }
      }
      testpos = _controller1.offset;

      if (_controller1.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showAppbar) {
          _showAppbar = true;
        }
      }
      setState(() {});
    });
  }

  //add tab bar category title
  _addInitailTab() async {
    setState(() {
      for (int i = 0; i < planlist.length; i++) {
        _tabs.add({
          'text': planlist[i].title,
        });
      }

      _tc = TabController(
        vsync: this,
        length: _tabs.length,
      )..addListener(() {
          setState(() {
            currpage = _tc!.index;
          });
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    hideAppbarAndBottomBarOnScroll(_controller1, context);
    return Scaffold(
        backgroundColor: ColorsRes.white,
        body: SafeArea(
          top: false,
          bottom: false,
          child: NestedScrollView(
              controller: _controller1,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  new SliverList(
                      delegate: new SliverChildListDelegate([
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: Constant.appbarHeight,
                        child: DesignConfig.setAppBar(
                          context,
                          0,
                          "",
                          widget.isBack,
                          Constant.appbarHeight,
                        )),
                  ])),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: SliverSafeArea(
                        top: false,
                        bottom: false,
                        sliver: SliverAppBar(
                          toolbarHeight: 0,
                          pinned: true,
                          bottom: tabBarData(),
                          backgroundColor: ColorsRes.white,
                          elevation: 0,
                          floating: true,
                        )),
                  ),
                ];
              },
              body: isloading
                  ? const Center(child: CircularProgressIndicator())
                  : planlist.isEmpty
                      ? Center(
                          child: Text(
                            StringsRes.noDataFound,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .merge(const TextStyle(letterSpacing: 0.5)),
                          ),
                        )
                      : TabBarView(
                          controller: _tc,
                          children:
                              List<Widget>.generate(_tc!.length, (int index) {
                            Plans plan = planlist[index];
                            int colorindex = index % 6;
                            return Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, top: 15, bottom: 10),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  Container(
                                    height: 200,
                                    decoration: DesignConfig.boxGradient(
                                        Constant.colorlist1[colorindex],
                                        Constant.colorlist2[colorindex],
                                        30),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Stack(
                                      children: [
                                        SvgPicture.asset(
                                          Constant.svgpath + "design.svg",
                                          width: double.maxFinite,
                                          height: double.maxFinite,
                                          fit: BoxFit.cover,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Align(
                                              alignment: Alignment.center,
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 20),
                                                  Text(
                                                    "${Constant.currencysymbol} ${plan.selectedtenure!.price}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .merge(const TextStyle(
                                                            color: ColorsRes
                                                                .white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            letterSpacing:
                                                                0.5)),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "/${plan.selectedtenure!.title.toLowerCase()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption!
                                                        .merge(const TextStyle(
                                                            color: ColorsRes
                                                                .white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            letterSpacing:
                                                                0.5)),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Container(
                                              decoration: DesignConfig
                                                  .decorationRoundedSide(
                                                      Constant.colorlist1[
                                                              colorindex]
                                                          .withOpacity(0.7),
                                                      false,
                                                      false,
                                                      true,
                                                      true,
                                                      30),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 18),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                  canvasColor: Constant
                                                      .colorlist1[colorindex],
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton<Tenure>(
                                                    icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: ColorsRes.white,
                                                    ),
                                                    isExpanded: true,
                                                    isDense: true,
                                                    alignment:
                                                        Alignment.center,
                                                    value:
                                                        plan.selectedtenure,
                                                    onChanged:
                                                        (Tenure? newValue) {
                                                      planlist[index]
                                                              .selectedtenure =
                                                          newValue!;
                                                      setState(() {});
                                                    },
                                                    items: plan.tenurelist
                                                        .map((Tenure user) {
                                                      return DropdownMenuItem<
                                                          Tenure>(
                                                        value: user,
                                                        child: Text(
                                                          user.title,
                                                          textAlign: TextAlign
                                                              .center,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .subtitle1!
                                                              .merge(const TextStyle(
                                                                  color: ColorsRes
                                                                      .white)),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  planInfoWidget(plan.noOfCharacters,
                                      StringsRes.planOverallchr),
                                  planInfoWidget(
                                      plan.google, StringsRes.planGooglechr),
                                  planInfoWidget(
                                      plan.aws, StringsRes.planAmazonchr),
                                  planInfoWidget(
                                      plan.ibm, StringsRes.planIbmchr),
                                  planInfoWidget(plan.azure,
                                      StringsRes.planMicrosoftchr),
                                  const SizedBox(height: 30),
                                  GestureDetector(
                                      onTap: () {
                                        selectedplan = plan;
                                        Constant.goToNextPage(
                                            SubscribePage(
                                                colorindex: colorindex),
                                            context,
                                            false);
                                      },
                                      child: Container(
                                          decoration: DesignConfig
                                              .boxDecorationGradient(15),
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Text(
                                            StringsRes.lblsubscribe,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .merge(const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: ColorsRes.white,
                                                    letterSpacing: 0.5)),
                                          ))),
                                ],
                              ),
                            );
                          }))),
        ));
  }

  tabBarData() {
    if (!isloading) {
      return PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: Container(
          width: double.maxFinite,
          height: 60,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 0, right: 0, top: 15),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: DesignConfig.boxDecoration(ColorsRes.bgcolor, 0),
          child: TabBar(
            isScrollable: true,
            unselectedLabelColor: ColorsRes.black,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: ColorsRes.black),
            tabs: _tabs
                .map((tab) => AnimatedContainer(
                    height: 32,
                    duration: const Duration(milliseconds: 600),
                    padding: EdgeInsetsDirectional.only(top: 5.0, bottom: 5.0),
                    child: Tab(
                      text: tab['text'],
                    )))
                .toList(),
            labelColor: ColorsRes.white,
            controller: _tc,
          ),
        ),
      );
    }
  }

  planInfoWidget(String number, String title) {
    return ListTile(
      leading: getIcon(number),
      dense: true,
      title: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.subtitle2!.merge(const TextStyle(
              color: ColorsRes.darktext, fontWeight: FontWeight.bold)),
          text: number,
          children: <TextSpan>[
            TextSpan(
              text: " $title",
              style: const TextStyle(
                  color: ColorsRes.darktext, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  getIcon(String number) {
    return number.trim().isEmpty || number.trim() == '0'
        ? const Icon(Icons.close_outlined, color: ColorsRes.red)
        : const Icon(Icons.check, color: ColorsRes.green);
  }
}
