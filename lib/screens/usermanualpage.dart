import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/screens/currentplaninfo.dart';
import 'package:espeech/screens/subscription/planspage.dart';
import 'package:espeech/screens/subscription/subscriptionlistpage.dart';
import 'package:espeech/screens/subscription/transactionlistpage.dart';
import 'package:espeech/screens/termsconditionactivity.dart';
import 'package:espeech/screens/texttospeechfiles/savedttslist.dart';
import 'package:espeech/screens/texttospeechfiles/texttospeech.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profilePage.dart';

class UserManualPage extends StatefulWidget {
  Function goToPage;

  UserManualPage({
    Key? key,
    required this.goToPage,
  }) : super(key: key);

  @override
  _UserManualPageState createState() => _UserManualPageState();
}

class _UserManualPageState extends State<UserManualPage>
    with TickerProviderStateMixin {
  double testpos = 0;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(() {});

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    hideAppbarAndBottomBarOnScroll(_controller, context);
    return Scaffold(
        body: CustomScrollView(
            controller: _controller,
            shrinkWrap: true,
            slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: false,
            pinned: false,
            centerTitle: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedContainer(
                  height: Constant.appbarHeight,
                  duration: const Duration(milliseconds: 500),
                  child: DesignConfig.setAppBar(context, 0, "", false, Constant.appbarHeight)),
            ),
            expandedHeight: Constant.appbarHeight,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  profileHeader(),
                  menuWidget(),
                ]);
              },
              childCount: 1,
            ),
          ),
        ]));
  }

  menuWidget() {
    return Padding(
      padding:
          EdgeInsets.only(top: 40),
      child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            setMenu('dr_text_to_speech.svg', StringsRes.texttospeech,
                onClickAction: () {
              Constant.goToNextPage(
                  const TextToSpeech(
                    isBack: true,
                  ),
                  context,
                  false);
            }),
            setMenu('dr.plans.svg', StringsRes.plans,
                onClickAction: () => Constant.goToNextPage(
                    const PlansPage(
                      appbar: true,
                      isBack: true,
                    ),
                    context,
                    false)),
            setMenu('dr.transactions.svg', StringsRes.transactions,
                onClickAction: () => Constant.goToNextPage(
                    const TransactionListPage(), context, false)),
            setMenu('dr.subs.svg', StringsRes.subscriptions,
                onClickAction: () => Constant.goToNextPage(
                    const SubscriptionListPage(), context, false)),
            setMenu('dr_saved.svg', StringsRes.savedtexttospeech,
                onClickAction: () => Constant.goToNextPage(
                    const SavedTtsList(
                      isBack: true,
                    ),
                    context,
                    false)),
            setMenu('dr.terms.svg', StringsRes.termsandcondition,
                onClickAction: () => Constant.goToNextPage(
                    TermsConditionPage(StringsRes.termsandcondition,
                        Constant.typetermscondition),
                    context,
                    false)),
            setMenu('dr.privacy.svg', StringsRes.privacyPolicy,
                onClickAction: () => Constant.goToNextPage(
                    TermsConditionPage(
                        StringsRes.privacyPolicy, Constant.typeprivacypolicy),
                    context,
                    false)),
            setMenu('dr.aboutus.svg', StringsRes.aboutus,
                onClickAction: () => Constant.goToNextPage(
                    TermsConditionPage(
                        StringsRes.aboutus, Constant.typeaboutus),
                    context,
                    false)),
            setMenu('dr.currentplan.svg', StringsRes.currentplaninfo,
                onClickAction: () => Constant.goToNextPage(
                    const CurrentPlanInfo(), context, false)),
            setMenu('dr.logout.svg', StringsRes.logout, onClickAction: () {
              logOutDailog();
            }),
          ]),
    );
  }

  logOutDailog() async {
    await DesignConfig.dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          content: Text(
            StringsRes.logout_lbl,
            style: Theme.of(this.context)
                .textTheme
                .subtitle1!
                .copyWith(color: ColorsRes.darktext),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(
                  StringsRes.no_lbl,
                  style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                      color: ColorsRes.darktext, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }),
            TextButton(
                child: Text(
                  StringsRes.yes_lbl,
                  style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                      color: ColorsRes.darktext, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Constant.session!.logoutUser(context);
                })
          ],
        );
      });
    }));
  }

  setMenu(
    String image,
    String title, {
    required Function onClickAction,
  }) {
    return ListTile(
      leading: circularIcon(image),
      title: Text(
        title,
        style: setTextStyle(),
      ),
      onTap: () {
        onClickAction();
      },
    );
  }

  setTextStyle() {
    return Theme.of(context).textTheme.subtitle1!.merge(const TextStyle(
          color: ColorsRes.black,
          fontWeight: FontWeight.w500,
          fontSize: 14.0,
          fontStyle: FontStyle.normal,
        ));
  }

  circularIcon(String img) {
    return CircleAvatar(
        radius: 20,
        backgroundColor: ColorsRes.proBgIcColor,
        child: SvgPicture.asset(Constant.svgpath + img,
            height: 27, width: 27, fit: BoxFit.fill));
  }

  profileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 00),
      child: GestureDetector(
        onTap: () {
          Constant.goToNextPage(const ProfilePage(), context, false);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 40),
              width: 54,
              height: 55,
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
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
                          width: 48,
                          height: 49,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Constant.defaultImage(48, 49);
                          },
                          loadingBuilder: (BuildContext context, Widget? child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child!;
                            return Constant.defaultImage(48, 49);
                          },
                        )
                      : Constant.defaultImage(48, 49)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${Constant.setFirstLetterUppercase(Constant.getSession(context)!.getData(SessionManager.keyFirstName))} ${Constant.setFirstLetterUppercase(Constant.getSession(context)!.getData(SessionManager.keyLastName))}",
                      style: Theme.of(context).textTheme.headline6!.merge(
                            const TextStyle(
                                color: ColorsRes.maintextcolor,
                                fontWeight: FontWeight.bold),
                          )),
                  Text(
                      Constant.getSession(context)!
                          .getData(SessionManager.keyEmail),
                      style: Theme.of(context).textTheme.subtitle1!.merge(
                            const TextStyle(
                                color: ColorsRes.mainsubtextcolor,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5),
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
