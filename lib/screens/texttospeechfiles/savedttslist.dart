import 'dart:convert';
import 'dart:io';
import 'package:espeech/helper/BottomAppProvider.dart';
import 'package:espeech/helper/TTSProvider.dart';
import 'package:espeech/screens/texttospeechfiles/texttospeech.dart';
import 'package:espeech/screens/texttospeechfiles/ttsDetails.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/model/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedTtsList extends StatefulWidget {
  final bool isBack;

  const SavedTtsList({Key? key, required this.isBack}) : super(key: key);

  @override
  _savedttslistState createState() => _savedttslistState();
}

class _savedttslistState extends State<SavedTtsList>
    with SingleTickerProviderStateMixin {
  AudioPlayer audioPlayer = AudioPlayer();
  int offset = 0;
  int perPage = 10;

  int total = 0;
  bool isloading = true, isloadmore = true;
  List<TTS> tempList = [];
  List<TTS> ttsList = [];
  ScrollController controller = ScrollController();
  String nodatamsg = '';
  String currplayid = "0";
  bool checkRefresh = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late AnimationController animationController = AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin
    duration: const Duration(milliseconds: 500),
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    controller.addListener(_scrollListener);

    audioPlayerStateListener();
    context.read<TTSProvider>().clearTtsList();
    getTTS();
  }

  audioPlayerStateListener() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (mounted && currplayid != '0') setState(() {});
    });
  }

  Future<bool> _requestPermissions() async {
    var permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      permission = await Permission.storage.status;
    }
    return permission == PermissionStatus.granted;
  }

  double testpos = 0;

  @override
  void dispose() {
    controller.removeListener(() {});

    currplayid = "0";
    audioPlayer.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isloadmore = true;
          if (offset < total) getTTS();
        });
      }
    }
  }

  Future<void> getTTS() async {
    bool checkinternet = await Constant.checkInternet();
    if (!checkinternet) {
      Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork, 1);
      return;
    }
    Map<String, String?> parameter = {
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
      Constant.offset: offset.toString(),
      Constant.limit: perPage.toString(),
    };

    var response = await Constant.sendApiRequest(
        Constant.apiGetSavedTts, parameter, true, context);

    var getdata = json.decode(response);

    if (!getdata[Constant.error]) {
      total = getdata["total"];

      if ((offset) < total) {
        tempList.clear();
        var data = getdata["data"];

        tempList = (data as List).map((data) => TTS.fromJson(data)).toList();

        if (mounted) {
          ttsList.addAll(tempList);
          context.read<TTSProvider>().setTtsList(ttsList);
        }

        offset = offset + perPage;
      } else {
        nodatamsg = getdata[Constant.message];
        isloadmore = false;
      }
      if (mounted) {
        setState(() {
          checkRefresh = false;
        });
      }
    } else {
      isloadmore = false;
      nodatamsg = getdata[Constant.message];
    }

    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    hideAppbarAndBottomBarOnScroll(controller, context);
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: ColorsRes.white,
        floatingActionButton: btmAddBtn(),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          // strokeWidth: 0,
          // notificationPredicate: !checkRefresh ? (_) => true : (_) => false,
          edgeOffset: Constant.appbarHeight,
          child: CustomScrollView(
              controller: controller,
              physics: AlwaysScrollableScrollPhysics(),
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
                        child: DesignConfig.setAppBar(context, 0, "",
                            widget.isBack, Constant.appbarHeight)),
                  ),
                  expandedHeight: Constant.appbarHeight,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return checkRefresh
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height -
                                  (Constant.appbarHeight +
                                      Constant.bottomNavigationHeight))
                          : !isloading
                              ? nodatamsg.trim().isNotEmpty
                                  ? noDataWidget()
                                  : listWidget()
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height -
                                      (Constant.appbarHeight +
                                          Constant.bottomNavigationHeight),
                                  child: Center(
                                      child: DesignConfig.loaderWidget()));
                    },
                    childCount: 1,
                  ),
                ),
              ]),
        ));
  }

  noDataWidget() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: widget.isBack ? 30 : Constant.bottomNavigationHeight + 30,
          start: 80,
          end: 80),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SvgPicture.asset("${Constant.svgpath}speech_not_available.svg"),
        const SizedBox(height: 35),
        Text(StringsRes.lbloops,
            style: Theme.of(context).textTheme.headline5!.merge(const TextStyle(
                  color: ColorsRes.black,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                )),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Text(StringsRes.lblnosavedspeechmsg,
            style: Theme.of(context).textTheme.subtitle1!.merge(const TextStyle(
                  color: ColorsRes.nospeechmsgcolor,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                )),
            textAlign: TextAlign.center),
        const SizedBox(height: 45),
        Text(StringsRes.lbladdbtninfo,
            style:
                Theme.of(context).textTheme.bodyMedium!.merge(const TextStyle(
                      color: ColorsRes.nospeechmsgcolor,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    )),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsetsDirectional.only(start: 50),
            child: SvgPicture.asset("${Constant.svgpath}arrow.svg")),
      ]),
    );
  }

  btmAddBtn() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.only(
          bottom: widget.isBack
              ? 20
              : Provider.of<BottomAppProvider>(context).isShowBar
                  ? 85
                  : 0),
      child: InkWell(
        child: Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: ColorsRes.circleBtnShadow,
                      offset: Offset(0, 3),
                      blurRadius: 6,
                      spreadRadius: 0)
                ],
                gradient: LinearGradient(
                    begin: Alignment(0, 0.00930662266910076),
                    end: Alignment(1, 1),
                    colors: [ColorsRes.gradient1, ColorsRes.gradient2])),
            child: const Icon(
              Icons.add,
              color: ColorsRes.white,
              size: 24,
            )),
        onTap: () {
          Constant.goToNextPage(
              const TextToSpeech(isBack: false), context, false);
        },
      ),
    );
  }

  Future<void> _refresh() {
    if (mounted) {
      setState(() {
        offset = 0;
        total = 100;
        checkRefresh = true;
        // isloading = false;
        // nodatamsg = '';
        context.read<TTSProvider>().clearTtsList();
      });
    }

    return getTTS();
  }

  listWidget() {
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 15),
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: Constant.bottomNavigationHeight),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: (offset < total)
            ? Provider.of<TTSProvider>(context).ttsList.length + 1
            : Provider.of<TTSProvider>(context).ttsList.length,
        itemBuilder: (context, index) {
          // TTS data = Provider.of<TTSProvider>(context).ttsList[index];
          Color? back;
          int pos = index % 4;
          if (pos == 0) {
            back = ColorsRes.back1;
          } else if (pos == 1) {
            back = ColorsRes.back2;
          } else if (pos == 2) {
            back = ColorsRes.back3;
          } else if (pos == 3) {
            back = ColorsRes.back4;
          }

          return (index == Provider.of<TTSProvider>(context).ttsList.length &&
                  isloadmore)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0)
                      if (Provider.of<TTSProvider>(context).ttsList.isNotEmpty)
                        Text(StringsRes.listOfSpeeLbl,
                            style: const TextStyle(
                                color: ColorsRes.black,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 18.0),
                            textAlign: TextAlign.left),
                    const SizedBox(
                      height: 23,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            border: index == 0
                                ? Border.all(
                                    color: ColorsRes.borderColor, width: 1)
                                : null,
                            color: back),
                        child: InkWell(
                          onTap: () {
                            Constant.goToNextPage(
                                ttsDetails(
                                  ttsList: Provider.of<TTSProvider>(context)
                                      .ttsList[index],
                                  index: index,
                                ),
                                context,
                                false);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: index == 0 ? 0 : 15,
                                left: 15,
                                bottom: 15,
                                right: index == 0 ? 0 : 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (index == 0)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                        alignment: Alignment.center,
                                        width: 46,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(11.0),
                                              bottomLeft:
                                                  Radius.circular(12.0)),
                                          border: Border.all(
                                              color: ColorsRes.borderColor,
                                              width: 1),
                                          color: ColorsRes.borderColor,
                                        ),
                                        child: Text(StringsRes.new_lbl,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 10.0),
                                            textAlign: TextAlign.left)),
                                  ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      end: 15.0),
                                  child: Text(
                                      Provider.of<TTSProvider>(context)
                                          .ttsList[index]
                                          .title,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                      textAlign: TextAlign.left),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 8.0, end: 15.0),
                                  child: Text(
                                      Provider.of<TTSProvider>(context)
                                          .ttsList[index]
                                          .text
                                          .replaceAll(RegExp('\\<[^>]*>'), ""),
                                      style: const TextStyle(
                                          color: ColorsRes.nospeechmsgcolor,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 12.0),
                                      textAlign: TextAlign.left),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      top: 10.0, end: index == 0 ? 15.0 : 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${StringsRes.lang_lbl1} : ${Provider.of<TTSProvider>(context).ttsList[index].language}   |   ${StringsRes.char_lbl} : ${Provider.of<TTSProvider>(context).ttsList[index].usedCharacters}",
                                          style: const TextStyle(
                                              color: ColorsRes.nospeechmsgcolor,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 10.0),
                                          textAlign: TextAlign.left),
                                      RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                          style: const TextStyle(
                                              color: ColorsRes.nospeechmsgcolor,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 10.0),
                                          text:
                                              "${Constant.formatDateString(Provider.of<TTSProvider>(context).ttsList[index].createdOn).split(',')[0]},",
                                        ),
                                        TextSpan(
                                          style: const TextStyle(
                                              color: ColorsRes.nospeechmsgcolor,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 10.0),
                                          text: Constant.formatDateString(
                                                  Provider.of<TTSProvider>(
                                                          context)
                                                      .ttsList[index]
                                                      .createdOn)
                                              .split(',')[1],
                                        )
                                      ]))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
