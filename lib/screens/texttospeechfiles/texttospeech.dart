import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';

import 'package:espeech/helper/stringsres.dart';

import 'package:espeech/model/language.dart';

import 'package:espeech/screens/subscription/planspage.dart';
import 'package:espeech/screens/texttospeechfiles/speechAdd.dart';
import 'package:espeech/screens/texttospeechfiles/speechtitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../helper/sessionmanager.dart';
import '../../model/audio.dart';
import '../../model/voices.dart';
import 'newgentexttospeech.dart';

late List<Voices> voicelist;

TextEditingController edttxt = TextEditingController();
String speech = '';
String title = '';
TextEditingController edttitle = TextEditingController();
Map<String, List> datalist = {};

FocusNode focusNode = FocusNode();

class TextToSpeech extends StatefulWidget {
  final bool isBack;

  const TextToSpeech({
    Key? key,
    required this.isBack,
  }) : super(key: key);

  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

class _TextToSpeechState extends State<TextToSpeech>
    with TickerProviderStateMixin {
  late Directory? _downloadsDirectory;
  late TextStyle lblstyle;
  Language? selectedlanguage;
  Voices? selectedvoice;
  Audio? predefinedaudio;
  File? decodedAudioFile;
  late String decodedAudioText;
  AudioPlayer audioPlayer = AudioPlayer();

  final _formKey = GlobalKey<FormState>();
  bool isloading = false;
  bool gettingdata = false;

  late String ttsid, basetext, basetextmain;
  int cursorPosition = 0;
  int baseoffset = 0;
  int extendoffset = 0;
  bool issetcursor = true;
  bool isfullscreen = false;

  GlobalKey btnKey = GlobalKey();
  bool keyboardvisibility = false;


  @override
  void initState() {
    super.initState();

    decodedAudioText = '';


    voicelist = [];
    ttsid = '';
    basetext = '';
    basetextmain = "";
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  updateSpeech(String sp) {
    setState(() {
      speech = sp;
    });
  }

  appabar() {
    return PreferredSize(
        preferredSize: Size.fromHeight(Constant.appbarHeight),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: -MediaQuery.of(context).size.width * (1),
            top: -MediaQuery.of(context).size.width * (2.749),
            child: Container(
              width: MediaQuery.of(context).size.width * (3),
              decoration: const BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: ColorsRes.shadowcolor,
                      blurRadius: 10,
                      spreadRadius: 0.0,
                    )
                  ],
                  shape: BoxShape.circle),
              height: MediaQuery.of(context).size.width * (3),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              color: Colors.white,
              height: Constant.appbarHeight,
              width: MediaQuery.of(context).size.width,
              child: AppBar(
                  elevation: 8,
                  shadowColor: Colors.black38,
                  centerTitle: true,
                  title: SvgPicture.asset(
                    "${Constant.svgpath}homelogo.svg",
                  ),
                  backgroundColor: ColorsRes.bgcolor,
                  leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_outlined,
                          color: ColorsRes.black),
                      onPressed: () {
                        clearCurrentVoice(true);
                        Navigator.of(context).pop();
                      })),
            ),
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    lblstyle = Theme.of(context)
        .textTheme
        .caption!
        .merge(const TextStyle(color: ColorsRes.darktext));

    return WillPopScope(
      onWillPop: () async {
        ttsid = '';
        basetext = '';
        basetextmain = "";
        edttxt.clear();
        edttitle.clear();
        speech = "";
        title = "";

        return true;
      },
      child: WillPopScope(
        onWillPop: () async {
          clearCurrentVoice(true);
          return true;
        },
        child: Scaffold(
          backgroundColor: ColorsRes.white,
          appBar: appabar(),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 30.0, end: 30.0, top: 30, bottom: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 9.0),
                              child: Text(StringsRes.lang_lbl,
                                  style: const TextStyle(
                                      color: ColorsRes.black,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17.0),
                                  textAlign: TextAlign.left),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Container(
                              height: 42,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(17)),
                                  color: ColorsRes.bgcolor),
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 18.0),
                                  child: Row(
                                    children: [
                                      if (selectedlanguage != null)
                                        Container(
                                          alignment: Alignment.center,
                                          color: ColorsRes.white,
                                          width: 26,
                                          height: 26,
                                          child: SvgPicture.network(
                                            selectedlanguage!.flag,
                                            width: 18,
                                            height: 12,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      SizedBox(
                                          width: selectedlanguage == null
                                              ? 0
                                              : 15),
                                      Expanded(
                                        child: Text(
                                            selectedlanguage == null
                                                ? StringsRes.selectlanguage
                                                : selectedlanguage!.name,
                                            style: TextStyle(
                                                color: ColorsRes.black
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14.0),
                                            textAlign: TextAlign.left),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  if (Constant.languagelist.isEmpty) return;

                                  FocusScope.of(context).unfocus();
                                  openLangSelectionDialog();
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 9.0),
                              child: Text(StringsRes.voice_lbl,
                                  style: const TextStyle(
                                      color: ColorsRes.black,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17.0),
                                  textAlign: TextAlign.left),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Container(
                              height: 42,
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(17)),
                                  color: ColorsRes.bgcolor),
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 18.0),
                                  child: Row(
                                    children: [
                                      if (selectedvoice != null)
                                        Container(
                                          alignment: Alignment.center,
                                          color: ColorsRes.white,
                                          width: 26,
                                          height: 26,
                                          child: SvgPicture.network(
                                            selectedvoice!.flag,
                                            width: 18,
                                            height: 12,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      SizedBox(
                                          width:
                                              selectedvoice == null ? 0 : 15),
                                      Expanded(
                                        child: Text(
                                            selectedvoice == null
                                                ? StringsRes.selectvoice
                                                : selectedvoice!.displayName,
                                            style: TextStyle(
                                                color: ColorsRes.black
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: 14.0),
                                            textAlign: TextAlign.left),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  if (selectedlanguage == null) {
                                    FocusScope.of(context).unfocus();
                                    openLangSelectionDialog();
                                  } else {
                                    if (voicelist.isEmpty) {
                                      return getVoiceData();
                                    }
                                    FocusScope.of(context).unfocus();
                                    openVoiceSelectionDialog();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            InkWell(
                              onTap: () {
                                if (selectedlanguage == null ||
                                    selectedvoice == null) {
                                  if (selectedlanguage == null) {
                                    FocusScope.of(context).unfocus();
                                    openLangSelectionDialog();
                                  } else {
                                    getVoiceData();
                                    FocusScope.of(context).unfocus();
                                    openVoiceSelectionDialog();
                                  }
                                } else {
                                  Constant.goToNextPage(
                                      const SpeechTitle(), context, false);
                                }
                              },
                              child: Container(
                                height: 52,
                                width: double.maxFinite,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsetsDirectional.only(
                                    start: 18.0),
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    color: ColorsRes.bgcolor),
                                child: Text(
                                  title.isEmpty ? StringsRes.title_lbl : title,
                                  style: TextStyle(
                                      color: ColorsRes.black.withOpacity(0.7),
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 15.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            InkWell(
                              child: Container(
                                width: double.maxFinite,
                                height: 156,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    color: ColorsRes.bgcolor),
                                child: SingleChildScrollView(
                                  padding:
                                      const EdgeInsetsDirectional.all(17.0),
                                  scrollDirection: Axis.vertical,
                                  child: Text(
                                    speech.isEmpty
                                        ? StringsRes.wr_txt_lbl
                                        : speech,
                                    style: TextStyle(
                                        color: ColorsRes.black.withOpacity(0.7),
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 15.0),
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (selectedlanguage == null ||
                                    selectedvoice == null) {
                                  if (selectedlanguage == null) {
                                    FocusScope.of(context).unfocus();
                                    openLangSelectionDialog();
                                  } else {
                                    getVoiceData();
                                    FocusScope.of(context).unfocus();
                                    openVoiceSelectionDialog();
                                  }
                                } else {
                                  Constant.goToNextPage(
                                      SpeechAdd(
                                          updateParent: updateSpeech,
                                          selectedVoice: selectedvoice),
                                      context,
                                      false);
                                }
                              },
                            ),
                          ],
                        ),
                      )),
                      if (Constant.session!
                          .getData(SessionManager.keyActiveSubscription)
                          .trim()
                          .isEmpty)
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(
                                    "${StringsRes.noteFreeChar_lbl} ${Constant.freeTierCharacters} ${StringsRes.noteFreeChar_lbl1}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: ColorsRes.red,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0)))),
                      if (ttsid.trim().isEmpty)
                        InkWell(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.maxFinite,
                              height: 54,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  boxShadow: selectedlanguage == null ||
                                          selectedvoice == null ||
                                          title.isEmpty ||
                                          speech.isEmpty
                                      ? null
                                      : [
                                          const BoxShadow(
                                              color: ColorsRes.circleBtnShadow,
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                              spreadRadius: 0)
                                        ],
                                  gradient: selectedlanguage == null ||
                                          selectedvoice == null ||
                                          title.isEmpty ||
                                          speech.isEmpty
                                      ? null
                                      : const LinearGradient(
                                          begin:
                                              Alignment(0, 0.00930662266910076),
                                          end: Alignment(1, 1),
                                          colors: [
                                              ColorsRes.gradient1,
                                              ColorsRes.gradient2
                                            ]),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  color: selectedlanguage == null ||
                                          selectedvoice == null ||
                                          title.isEmpty ||
                                          speech.isEmpty
                                      ? ColorsRes.btnColor
                                      : null),
                              child: Text(StringsRes.synthesizetext,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .merge(TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedlanguage == null ||
                                                  selectedvoice == null ||
                                                  title.isEmpty ||
                                                  speech.isEmpty
                                              ? ColorsRes.black.withOpacity(0.4)
                                              : ColorsRes.white,
                                          letterSpacing: 0.5)),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          onTap: () {
                            sythesizeProcess();
                          },
                        )
                    ],
                  ),
                ),
              ),
              if (gettingdata || isloading) DesignConfig.loaderWidget()
            ],
          ),
        ),
      ),
    );
  }

  openLangSelectionDialog() {
    showGeneralDialog(
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, anim1, anim2) {
        return LanguageDialog(
            currlang: selectedlanguage,
            onSelectedLangListChanged: (langs) {
              if ((selectedlanguage == null ||
                      selectedlanguage!.languageCode != langs.languageCode) ||
                  (selectedlanguage != null && selectedvoice == null)) {
                setState(() {
                  selectedlanguage = langs;
                  selectedvoice = null;
                  voicelist.clear();
                  decodedAudioText = '';
                  ttsid = '';
                  basetext = '';
                  basetextmain = "";
                });
                getVoiceData();
              }
            });
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1.0), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  openVoiceSelectionDialog() {
    showGeneralDialog(
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, anim1, anim2) {
        return voiceDialog(
            currlang: selectedlanguage,
            currvoice: selectedvoice,
            callbackfun: openLangSelectionDialog,
            onSelectedVoiceChanged: (langs) {
              if (selectedvoice == null ||
                  selectedvoice!.voice != langs.voice) {
                decodedAudioFile = null;
                decodedAudioText = '';
                setState(() {
                  selectedvoice = langs;
                });
                getPredefinedVoice();
              }
            });
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }

  getVoiceData() async {
    setState(() {
      gettingdata = true;
    });
    Map<String, String?> parameter = {
      Constant.language: selectedlanguage!.languageCode
    };

    var response = await Constant.sendApiRequest(
        Constant.apiGetVoices, parameter, true, context);

    var getdata = json.decode(response);
    voicelist.clear();
    ttsid = '';
    basetext = '';
    basetextmain = "";
    if (!getdata[Constant.error]) {
      List list = getdata['data'];

      voicelist.addAll(list.map((model) => Voices.fromJson(model)).toList());
    }

    gettingdata = false;

    if (mounted) setState(() {});
    openVoiceSelectionDialog();
  }

  getPredefinedVoice() async {
    setState(() {
      gettingdata = true;
    });
    Map<String, String?> parameter = {
      Constant.language: selectedvoice!.language,
      Constant.voice: selectedvoice!.voice,
      Constant.provider: selectedvoice!.provider,
    };

    var response = await Constant.sendApiRequest(
        Constant.apiGetPredefinedTts, parameter, true, context);

    var getdata = json.decode(response);
    predefinedaudio = null;
    if (!getdata[Constant.error]) {
      predefinedaudio = Audio.fromJson(getdata['data']);
      String basetext =
          Constant.getBase64ConvertedText(predefinedaudio!.base64);
      decodedAudioText = "data:audio/mpeg;base64,$basetext";
    }
    gettingdata = false;
    if (mounted) setState(() {});
  }

  Future<void> sythesizeProcess() async {
    if (isloading) return;
    if (selectedlanguage == null) {
      FocusScope.of(context).unfocus();
      openLangSelectionDialog();

      return;
    }
    if (selectedvoice == null) {
      getVoiceData();
      FocusScope.of(context).unfocus();
      openVoiceSelectionDialog();
      return;
    }
    if (!isloading && edttxt.text.trim().isEmpty) {
      Constant.showSnackBarMsg(context, StringsRes.enterttext, 1);
      return;
    }

    if (Constant.session!
            .getData(SessionManager.keyActiveSubscription)
            .trim()
            .isEmpty &&
        Constant.isFreeTierAllow == "true" &&
        speech.length > 100) {
      freeCharacterBottomSheet();
    } else {
      if (_formKey.currentState!.validate() && !isloading) {
        bool checkinternet = await Constant.checkInternet();
        if (!checkinternet) {
          Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork, 1);
        } else {
          ttsid = '';
          basetext = '';
          basetextmain = "";
          setState(() {
            isloading = true;
          });

          //
          Map<String, String?> parameter = {
            Constant.provider: selectedvoice!.provider,
            Constant.voice: selectedvoice!.voice,
            Constant.language: selectedvoice!.language,
            Constant.userId: Constant.session!.getData(SessionManager.keyId),
            Constant.title: edttitle.text,
            Constant.text: edttxt.text,
            Constant.isFreeCharAllow: Constant.session!
                        .getData(SessionManager.keyActiveSubscription)
                        .trim()
                        .isEmpty &&
                    Constant.isFreeTierAllow == "true"
                ? "true"
                : "false",
          };

          var response = await Constant.sendApiRequest(
              Constant.apiSynthesizeText, parameter, true, context);

          Map getdata = json.decode(response);

          Constant.showSnackBarMsg(
              context, getdata[Constant.message].toString(), 1);
          bool isupcomingdialog = false;

          if (!getdata[Constant.error]) {
            ttsid = getdata['data']["tts_id"].toString();

            basetextmain = getdata['data']["base_b4"];
            basetext =
                Constant.getBase64ConvertedText(getdata['data']["base_b4"]);

            Constant.goToNextPage(
                NewGenTextToSpeech(
                    ttsid: ttsid,
                    basetextmain: basetextmain,
                    basetext: basetext,
                    selectedvoice: selectedvoice,
                    selectedlanguage: selectedlanguage),
                context,
                false);
            Future.delayed(const Duration(seconds: 1), () {
              clearCurrentVoice(true);
            });
          } else if (getdata.containsKey(Constant.upcoming) &&
              getdata[Constant.upcoming]) {
            isupcomingdialog = true;
          }

          setState(() {
            isloading = false;
          });

          if (isupcomingdialog) {
            showUpcomingDialog();
          }
        }
      }
    }
  }

  freeCharacterBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(children: [
              Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    color: ColorsRes.white,
                  ),
                  padding: EdgeInsetsDirectional.all(22),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        child: Icon(
                          Icons.close,
                          color: ColorsRes.black,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    bottomsheetLabel(StringsRes.lbloops),
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                          "${StringsRes.bottomFreeChar_lbl} ${Constant.freeTierCharacters} ${StringsRes.bottomFreeChar_lbl}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ColorsRes.darktext.withOpacity(0.7),
                              fontSize: 15)),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 20,
                            left: MediaQuery.of(context).size.width / 5,
                            right: MediaQuery.of(context).size.width / 5),
                        child: InkWell(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 54,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  const BoxShadow(
                                      color: ColorsRes.circleBtnShadow,
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                      spreadRadius: 0)
                                ],
                                gradient: const LinearGradient(
                                    begin: Alignment(0, 0.00930662266910076),
                                    end: Alignment(1, 1),
                                    colors: [
                                      ColorsRes.gradient1,
                                      ColorsRes.gradient2
                                    ]),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Text(StringsRes.subscriptions,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .merge(TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ColorsRes.white,
                                          letterSpacing: 0.5)),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Constant.goToNextPage(
                                const PlansPage(
                                  appbar: true,
                                  isBack: true,
                                ),
                                context,
                                false);
                          },
                        )),
                  ]))
            ]);
          });
        });
  }

  Widget bottomsheetLabel(String labelName) => Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 20.0),
        child: getHeading(labelName),
      );

  Widget getHeading(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.subtitle1!.copyWith(
          fontWeight: FontWeight.bold, color: ColorsRes.darktext, fontSize: 20),
    );
  }

  clearCurrentVoice(bool cleareditbox) {
    ttsid = '';
    basetext = '';
    basetextmain = "";
    if (cleareditbox) {
      edttxt.clear();
      edttitle.clear();
      speech = "";
      title = "";
    }
    setState(() {});
  }

  voiceModeulationWidget() {
    datalist = {};
    if (Constant.taglist.containsKey(selectedvoice!.provider)) {
      datalist = Constant.taglist[selectedvoice!.provider]!;
    }

    if (datalist.isEmpty) return Container();
    String clearvoice = 'Clear voice';
    datalist[clearvoice] = ['Clear voice'];

    return PopupMenuButton(
      offset: const Offset(-30, 0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: SvgPicture.asset("${Constant.svgpath}filter.svg"),
      itemBuilder: (BuildContext bc) {
        return datalist.entries.map((entry) {
          String title =
              Constant.setFirstLetterUppercase(entry.key.replaceAll("_", " "));
          return PopupMenuItem(
            value: entry.key,
            padding:
                const EdgeInsets.only(left: 20, right: 10, top: 0, bottom: 0),
            child: Text(title,
                style: title == clearvoice
                    ? Theme.of(context).textTheme.subtitle1!.merge(
                        const TextStyle(
                            color: ColorsRes.red,
                            fontWeight: FontWeight.normal))
                    : Theme.of(context).textTheme.headline6!.merge(
                        const TextStyle(
                            color: ColorsRes.mainsubtextcolor,
                            fontWeight: FontWeight.normal))),
          );
        }).toList();
      },
      onSelected: (value) {
        if (value == clearvoice) {
          String text = edttxt.text;
          String newstr = text.replaceAll(RegExp('\\<[^>]*>'), "");
          edttxt.text = newstr;
          cursorPosition = edttxt.text.length;
          baseoffset = cursorPosition;
          extendoffset = cursorPosition;
          setState(() {});
        } else {
          List listitems = datalist[value]!;

          String title = Constant.setFirstLetterUppercase(
              value.toString().replaceAll("_", " "));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              issetcursor = false;
              return AlertDialog(
                  title: Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1.0, color: ColorsRes.subtextcolor),
                      ),
                    ),
                    child: Text(title,
                        style: const TextStyle(
                            color: ColorsRes.mainsubtextcolor,
                            fontWeight: FontWeight.bold)),
                  ),
                  shape:
                      DesignConfig.setRoundedBorder(ColorsRes.grey, 15, false),
                  content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(listitems.length, (index) {
                        return GestureDetector(
                            onTap: () {
                              String starttag = listitems[index]['start_tag'];
                              String endtag = listitems[index]['end_tag'];

                              String tagstring = starttag + endtag;

                              insertTag(tagstring, starttag, endtag);

                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                listitems[index]['title'],
                                style: const TextStyle(
                                    color: ColorsRes.mainsubtextcolor),
                              ),
                            ));
                      })));
            },
          ).then((value) {
            issetcursor = true;
          });
        }
      },
    );
  }

  void insertTag(String content, String startTag, String endTag) {
    var text = edttxt.text;

    var indexStart = baseoffset;
    var indexEnd = extendoffset;
    text = text.substring(0, indexStart) +
        startTag +
        text.substring(indexStart, indexEnd) +
        endTag +
        text.substring(indexEnd, text.length);
    edttxt.text = "";
    edttxt.text = text;
    cursorPosition = extendoffset + content.length;
    baseoffset = cursorPosition;
    extendoffset = cursorPosition;
    setState(() {});
  }

  void showUpcomingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(StringsRes.plans),
          content: Text(StringsRes.upcomingplanstartmsg),
          actions: [
            TextButton(
              child: Text(StringsRes.lblcancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(StringsRes.lblstart),
              onPressed: () async {
                Navigator.of(context).pop();
                convertUpcomingToActivePlan();
              },
            ),
          ],
        );
      },
    );
  }

  convertUpcomingToActivePlan() async {
    setState(() {
      gettingdata = true;
    });
    Map<String, String?> parameter = {};
    var response = await Constant.sendApiRequest(
        Constant.apiConvertActive, parameter, true, context);
    var getdata = json.decode(response);

    Constant.showSnackBarMsg(context, getdata[Constant.message], 1);

    if (!getdata[Constant.error]) {
      await Constant.getUserInfo(context);
    }
    setState(() {
      gettingdata = false;
    });
  }
}

class LanguageDialog extends StatefulWidget {
  LanguageDialog({
    Key? key,
    required this.onSelectedLangListChanged,
    required this.currlang,
  }) : super(key: key);
  Language? currlang;
  ValueChanged<Language> onSelectedLangListChanged;

  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  TextEditingController controller = TextEditingController();
  List<Language> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _searchResult = [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
      shape: DesignConfig.setRoundedSpecificBorder(32, true, false),
      contentPadding:
          const EdgeInsets.only(left: 35, right: 35, top: 30, bottom: 10),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(StringsRes.selectlanguage,
              style: const TextStyle(
                  color: ColorsRes.black,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0),
              textAlign: TextAlign.left),
          const SizedBox(height: 10),
          Container(
              height: 46,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  color: ColorsRes.bgcolor),
              alignment: Alignment.centerLeft,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: StringsRes.sea_lang_lbl,
                  contentPadding: const EdgeInsets.fromLTRB(50, 14, 0, 16),
                  hintStyle: TextStyle(
                    color: ColorsRes.black.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ),
                onChanged: onSearchTextChanged,
              )),
          const SizedBox(height: 12),
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                  child: Column(
                      children: List.generate(
                          _searchResult.isNotEmpty || controller.text.isNotEmpty
                              ? _searchResult.length
                              : Constant.languagelist.length, (index) {
                Language partner;
                if (_searchResult.isNotEmpty || controller.text.isNotEmpty) {
                  partner = _searchResult[index];
                } else {
                  partner = Constant.languagelist[index];
                }

                return InkWell(
                  onTap: () {
                    if (FocusScope.of(context).hasFocus) {
                      FocusScope.of(context).unfocus();
                    }
                    widget.onSelectedLangListChanged(partner);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: DesignConfig.boxDecoration(
                        widget.currlang != null &&
                                widget.currlang!.languageCode ==
                                    partner.languageCode
                            ? ColorsRes.proBgIcColor
                            : ColorsRes.white,
                        17),
                    child: Row(children: [
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: SvgPicture.network(
                          partner.flag,
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Text(partner.name,
                              style: const TextStyle(
                                  color: ColorsRes.nospeechmsgcolor,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16.0),
                              textAlign: TextAlign.left)),
                    ]),
                  ),
                );
              }))),
            ),
          ),
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail in Constant.languagelist) {
      if (userDetail.name.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(userDetail);
      }
    }

    setState(() {});
  }
}

class voiceDialog extends StatefulWidget {
  voiceDialog({
    Key? key,
    required this.onSelectedVoiceChanged,
    required this.currvoice,
    required this.currlang,
    required this.callbackfun,
  }) : super(key: key);
  Function callbackfun;
  Language? currlang;
  Voices? currvoice;
  ValueChanged<Voices> onSelectedVoiceChanged;

  @override
  _voiceDialogState createState() => _voiceDialogState();
}

class _voiceDialogState extends State<voiceDialog> {
  TextEditingController controller = TextEditingController();
  List<Voices> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _searchResult = [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
      shape: DesignConfig.setRoundedSpecificBorder(25, true, false),
      contentPadding:
          const EdgeInsets.only(left: 35, right: 35, top: 30, bottom: 10),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(StringsRes.selectvoice,
              style: const TextStyle(
                  color: ColorsRes.black,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0),
              textAlign: TextAlign.left),
          const SizedBox(height: 10),
          Container(
              height: 46,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  color: ColorsRes.bgcolor),
              alignment: Alignment.centerLeft,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: StringsRes.sea_voice_lbl,
                  contentPadding: const EdgeInsets.fromLTRB(50, 14, 0, 16),
                  hintStyle: TextStyle(
                    color: ColorsRes.black.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ),
                onChanged: onSearchTextChanged,
              )),
          const SizedBox(height: 12),
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                  child: Column(
                      children: List.generate(
                          _searchResult.isNotEmpty || controller.text.isNotEmpty
                              ? _searchResult.length
                              : voicelist.length, (index) {
                Voices partner;
                if (_searchResult.isNotEmpty || controller.text.isNotEmpty) {
                  partner = _searchResult[index];
                } else {
                  partner = voicelist[index];
                }
                return GestureDetector(
                  onTap: () {
                    if (FocusScope.of(context).hasFocus) {
                      FocusScope.of(context).unfocus();
                    }
                    widget.onSelectedVoiceChanged(partner);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: DesignConfig.boxDecoration(
                        widget.currvoice != null &&
                                widget.currvoice!.voice == partner.voice
                            ? ColorsRes.proBgIcColor
                            : ColorsRes.white,
                        25),
                    child: Row(children: [
                      const SizedBox(width: 5),
                      if (partner.flag.trim().isNotEmpty)
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: SvgPicture.network(
                            partner.flag,
                            height: 25,
                            width: 25,
                            fit: BoxFit.contain,
                          ),
                        ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Text(partner.displayName,
                              style: const TextStyle(
                                  color: ColorsRes.nospeechmsgcolor,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16.0),
                              textAlign: TextAlign.left)),
                    ]),
                  ),
                );
              }))),
            ),
          ),
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail in voicelist) {
      if (userDetail.displayName.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(userDetail);
      }
    }

    setState(() {});
  }
}
