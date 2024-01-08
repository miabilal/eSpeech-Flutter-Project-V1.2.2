import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/model/language.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../helper/TTSProvider.dart';
import '../../helper/sessionmanager.dart';
import '../../model/tts.dart';
import '../../model/voices.dart';

class NewGenTextToSpeech extends StatefulWidget {
  final String ttsid;
  final String basetextmain;
  final String basetext;
  final Voices? selectedvoice;
  final Language? selectedlanguage;

  const NewGenTextToSpeech({
    Key? key,
    required this.ttsid,
    required this.basetextmain,
    required this.basetext,
    required this.selectedvoice,
    required this.selectedlanguage,
  }) : super(key: key);

  @override
  _NewGenTextToSpeechState createState() => _NewGenTextToSpeechState();
}

class _NewGenTextToSpeechState extends State<NewGenTextToSpeech> {
  late Directory? _downloadsDirectory;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isloading = false, isgetduration = true;
  int duration = 0, mainduration = 0;

  @override
  void initState() {
    super.initState();

    audioPlayerStateListener();
  }

  getDurationofAudio() async {
    duration = await audioPlayer.getDuration();

    mainduration = duration;

    if (duration <= 0 && isgetduration) {
      Future.delayed(const Duration(seconds: 1), () {
        playAudio();
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  playAudio() async {
    String data = "data:audio/mpeg;base64,${widget.basetext}";
    await audioPlayer.play(data, isLocal: true);
  }

  audioPlayerStateListener() {
    Future.delayed(Duration.zero, () {
      playAudio();
      getDurationofAudio();
    });
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.COMPLETED) {
        duration = 0;
        Future.delayed(const Duration(seconds: 1), () {
          duration = mainduration;

          if (mounted) setState(() {});
        });
      }
      if (mounted) setState(() {});
    });

    audioPlayer.onAudioPositionChanged.listen((Duration p) async {
      duration = mainduration - p.inMilliseconds;

      if (mainduration == 0) mainduration = await audioPlayer.getDuration();

      if (mounted) setState(() {});
    });
  }

  setLangLbl() {
    return Text(StringsRes.lang_lbl,
        style: const TextStyle(
            color: ColorsRes.black,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 20.0),
        textAlign: TextAlign.left);
  }

  setLangBox() {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(17)),
          color: ColorsRes.bgcolor),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 18.0),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              color: ColorsRes.white,
              width: 26,
              height: 26,
              child: SvgPicture.network(
                widget.selectedlanguage!.flag,
                width: 18,
                height: 12,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              //flex: 6,
              child: Text(widget.selectedlanguage!.name,
                  style: TextStyle(
                      color: ColorsRes.black.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 15.0),
                  textAlign: TextAlign.left),
            )
          ],
        ),
      ),
    );
  }

  setVoiLbl() {
    return Text(StringsRes.voice_lbl,
        style: const TextStyle(
            color: ColorsRes.black,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 20.0),
        textAlign: TextAlign.left);
  }

  setVoiBox() {
    return Container(
      height: 42,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(17)),
          color: ColorsRes.bgcolor),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 18.0),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              color: ColorsRes.white,
              width: 26,
              height: 26,
              child: SvgPicture.network(
                widget.selectedvoice!.flag,
                width: 18,
                height: 12,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(widget.selectedvoice!.displayName,
                  style: TextStyle(
                      color: ColorsRes.black.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 15.0),
                  textAlign: TextAlign.left),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.white,
      appBar: DesignConfig.setAppBar(context, 0, "", true, Constant.appbarHeight),
      body: Stack(children: [
        Column(children: [
          Container(
              color: ColorsRes.white,
              padding: const EdgeInsets.only(bottom: 10, left: 30, right: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    setLangLbl(),
                    const SizedBox(
                      height: 6,
                    ),
                    setLangBox(),
                    const SizedBox(
                      height: 9,
                    ),
                    setVoiLbl(),
                    const SizedBox(
                      height: 6,
                    ),
                    setVoiBox()
                  ])),
          Lottie.asset('${Constant.lottiepath}waves.json'),
          Text(durationToString(Duration(milliseconds: duration)),
              style: Theme.of(context).textTheme.headline5!.merge(
                  const TextStyle(
                      color: ColorsRes.mainsubtextcolor,
                      fontWeight: FontWeight.bold))),
          const Spacer(),
          btnsWidget(),
          const SizedBox(height: kToolbarHeight + 15),
        ]),
        if (isloading) DesignConfig.loaderWidget()
      ]),
    );
  }

  String durationToString(Duration duration) => (duration.inMilliseconds / 1000)
      .toStringAsFixed(2)
      .replaceFirst('.', ':')
      .padLeft(5, '0');

  voiceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorsRes.white,
            shape: BoxShape.circle,
            border: Border.all(color: ColorsRes.white),
          ),
          width: 26,
          height: 26,
          child: ClipOval(
            child: SvgPicture.network(
              widget.selectedvoice!.flag,
              width: 25,
              height: 25,
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
            child: Text(widget.selectedvoice!.displayName,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.subtitle1!.merge(
                    const TextStyle(
                        color: ColorsRes.white, letterSpacing: 0.5)))),
      ],
    );
  }

  languageWidget() {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorsRes.white),
          ),
          width: 26,
          height: 26,
          child: ClipOval(
            child: SvgPicture.network(
              widget.selectedlanguage!.flag,
              width: 25,
              height: 25,
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
            child: Text(
          widget.selectedlanguage!.name,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.subtitle1!.merge(
              const TextStyle(color: ColorsRes.white, letterSpacing: 0.5)),
        )),
      ],
    );
  }

  Future<void> initDownloadsDirectoryState() async {
    final isPermissionStatusGranted = await _requestPermissions();
    if (isPermissionStatusGranted) {
      try {
        if (Platform.isAndroid) {
          _downloadsDirectory =
              (await DownloadsPathProvider.downloadsDirectory)!;
        } else {
          _downloadsDirectory = await getApplicationDocumentsDirectory();
        }
      } on PlatformException {}

      if (!mounted) return;
      setState(() {});
    } else {
      initDownloadsDirectoryState();
    }
  }

  Future<bool> _requestPermissions() async {
    var permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      await Permission.storage.request();
      permission = await Permission.storage.status;
    }
    return permission == PermissionStatus.granted;
  }

  @override
  void dispose() {
    isgetduration = false;
    audioPlayer.dispose();
    super.dispose();
  }

  btnsWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        child: Container(
            decoration: DesignConfig.boxDecorationGradient(15),
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset("${Constant.svgpath}download_speech.svg")),
        onTap: () {
          initDownloadsDirectoryState().whenComplete(() {
            downloadTtf(false);
          });
        },
      ),
      const SizedBox(width: 10),
      GestureDetector(
        child: Container(
            decoration: DesignConfig.boxDecorationGradient(15),
            padding: const EdgeInsets.all(15),
            child: audioPlayer.state == PlayerState.PLAYING
                ? SvgPicture.asset("${Constant.svgpath}pause.svg")
                : SvgPicture.asset("${Constant.svgpath}play.svg")),
        onTap: () {
          initDownloadsDirectoryState().whenComplete(() {
            downloadTtf(true);
          });
        },
      ),
      const SizedBox(width: 10),
      if (Constant.session!
          .getData(SessionManager.keyActiveSubscription)
          .trim()
          .isNotEmpty)
        GestureDetector(
          child: Container(
              decoration: DesignConfig.boxDecorationGradient(15),
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset("${Constant.svgpath}save_speech.svg")),
          onTap: () {
            saveTts();
          },
        ),
      if (Constant.session!
          .getData(SessionManager.keyActiveSubscription)
          .trim()
          .isNotEmpty)
        const SizedBox(width: 10),
      GestureDetector(
        child: Container(
            decoration: DesignConfig.boxDecorationGradient(15),
            padding: const EdgeInsets.all(15),
            child: const Icon(
              Icons.delete,
              color: ColorsRes.white,
            )),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    ]);
  }

  Future<void> saveTts() async {
    if (isloading) return;
    setState(() {
      isloading = true;
    });
    Map<String, String?> parameter = {
      Constant.ttsId: widget.ttsid,
      Constant.base64: widget.basetextmain,
    };
    var response = await Constant.sendApiRequest(
        Constant.apiSaveTts, parameter, true, context);
    var getdata = json.decode(response);
    context.read<TTSProvider>().clearTtsList();
    getTTS();

    Constant.showSnackBarMsg(context, getdata[Constant.message], 1);

    setState(() {
      isloading = false;
    });
  }

  Future<void> getTTS() async {
    bool checkinternet = await Constant.checkInternet();
    if (!checkinternet) {
      Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork, 1);
      return;
    }
    Map<String, String?> parameter = {
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
    };

    var response = await Constant.sendApiRequest(
        Constant.apiGetSavedTts, parameter, true, context);

    var getdata = json.decode(response);

    if (!getdata[Constant.error]) {
      var data = getdata["data"];

      List<TTS> tempList =
          (data as List).map((data) => TTS.fromJson(data)).toList();

      if (mounted) {
        context.read<TTSProvider>().setTtsList(tempList);
      }
    } else {
      print("else error");
    }
  }

  Future<void> downloadTtf(bool isplay) async {
    if (isloading) return;
    String name = "${widget.ttsid}_${widget.selectedvoice!.provider}";
    if (isplay) {
      if (audioPlayer.state == PlayerState.PLAYING) {
        await audioPlayer.pause();
      } else if (audioPlayer.state == PlayerState.PAUSED) {
        await audioPlayer.resume();
      } else {
        playAudio();
      }
    } else {
      setState(() {
        isloading = true;
      });
      var systemTempDir = _downloadsDirectory!.path;

      File file = File("$systemTempDir/$name.mp3");
      final decodedBytes = base64Decode(widget.basetext);
      file.writeAsBytesSync(decodedBytes);

      OpenFile.open(file.path);
      setState(() {
        isloading = false;
      });
      Constant.showSnackBarMsg(context, StringsRes.downloaded, 1);
    }
  }
}
