import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../helper/TTSProvider.dart';
import '../../model/tts.dart';

class ttsDetails extends StatefulWidget {
  final TTS ttsList;
  final int index;

  const ttsDetails({
    Key? key,
    required this.ttsList,
    required this.index,
  }) : super(key: key);

  @override
  _ttsDetailsState createState() => _ttsDetailsState();
}

class _ttsDetailsState extends State<ttsDetails> {
  String currplayid = "0";
  AudioPlayer audioPlayer = AudioPlayer();
  Directory? _downloadsDirectory;
  bool isloading = false;

  @override
  void initState() {
    super.initState();

    audioPlayerStateListener();
  }

  @override
  void dispose() {
    currplayid = "0";
    audioPlayer.dispose();

    super.dispose();
  }

  audioPlayerStateListener() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      if (mounted && currplayid != '0') setState(() {});
    });
  }

  Future<void> downloadTtf(TTS tts, bool isplay, int index) async {
    String name = "${tts.id}_${tts.provider}";
    String basetext = Constant.getBase64ConvertedText(tts.base64);

    if (isplay) {


      bool isnewstart = false;
      if (currplayid == tts.id) {
        if (audioPlayer.state == PlayerState.PLAYING) {
          await audioPlayer.pause();
        } else if (audioPlayer.state == PlayerState.PAUSED) {
          await audioPlayer.resume();
        } else {
          isnewstart = true;
        }
      } else {
        if (audioPlayer.state == PlayerState.PLAYING ||
            audioPlayer.state == PlayerState.PAUSED) {
          await audioPlayer.stop();
        }
        isnewstart = true;
      }

      if (isnewstart) {
        String data = "data:audio/mpeg;base64,$basetext";
        await audioPlayer.play(data, isLocal: true);
      }
      currplayid = tts.id;
      setState(() {});
    } else {
      setState(() {
        isloading = true;
      });
      var systemTempDir = _downloadsDirectory!.path;
      File file = File("$systemTempDir/$name.mp3");


      file.writeAsBytesSync(base64Decode(basetext));

      OpenFile.open(file.path);
      setState(() {
        isloading = false;
      });

      Constant.showSnackBarMsg(context, StringsRes.downloaded, 1);
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

  Future<void> deleteTts() async {
    setState(() {
      isloading = true;
    });
    Map<String, String?> parameter = {
      Constant.ttsId: widget.ttsList.id,
    };
    var response = await Constant.sendApiRequest(
        Constant.apiDeleteTts, parameter, true, context);
    var getdata = json.decode(response);
    if (mounted) {
      Constant.showSnackBarMsg(context, getdata[Constant.message], 1);
    }
    if (!getdata[Constant.error]) {
      if (mounted) {
        context.read<TTSProvider>().removeIdTtsList(widget.ttsList.id);
      }
      Navigator.of(context).pop();

    }
    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
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
            downloadTtf(widget.ttsList, false, widget.index);
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
            downloadTtf(widget.ttsList, true, widget.index);
          });
        },
      ),
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
          deleteTts();
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    String newstr = widget.ttsList.text.replaceAll(RegExp('\\<[^>]*>'), "");
    return Scaffold(
      backgroundColor: ColorsRes.white,
      appBar: DesignConfig.setAppBar(context, 0, "", true, Constant.appbarHeight),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 30.0, end: 30.0, top: 30, bottom: 30.0),
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(StringsRes.lang_lbl,
                          style: const TextStyle(
                              color: ColorsRes.black,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0),
                          textAlign: TextAlign.left),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        height: 42,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(17)),
                            color: ColorsRes.bgcolor),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 18.0),
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                color: ColorsRes.white,
                                width: 26,
                                height: 26,
                                child: SvgPicture.network(
                                  widget.ttsList.language,
                                  width: 18,
                                  height: 12,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                //flex: 6,
                                child: Text(widget.ttsList.language,
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
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Text(StringsRes.voice_lbl,
                          style: const TextStyle(
                              color: ColorsRes.black,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0),
                          textAlign: TextAlign.left),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        height: 42,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(17)),
                            color: ColorsRes.bgcolor),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 18.0),
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                color: ColorsRes.white,
                                width: 26,
                                height: 26,
                                child: SvgPicture.network(
                                  widget.ttsList.voice,
                                  width: 18,
                                  height: 12,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                //flex: 6,
                                child: Text(widget.ttsList.voice,
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
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                     Container(
                          width: double.maxFinite,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsetsDirectional.only(
                              start: 18.0, top: 15, bottom: 15),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              color: ColorsRes.bgcolor),
                          child: Text(
                            widget.ttsList.title,
                            style: TextStyle(
                                color: ColorsRes.black.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0),
                          ),
                        ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                            start: 18.0, top: 15.0, bottom: 15),
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: ColorsRes.bgcolor),
                        child: Text(
                          newstr,
                          style: TextStyle(
                              color: ColorsRes.black.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 15.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                style: const TextStyle(
                                    color: ColorsRes.nospeechmsgcolor,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 10.0),
                                text:
                                    "${Constant.formatDateString(widget.ttsList.createdOn).split(',')[0]},",
                              ),
                              TextSpan(
                                style: const TextStyle(
                                    color: ColorsRes.nospeechmsgcolor,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 10.0),
                                text: Constant.formatDateString(
                                        widget.ttsList.createdOn)
                                    .split(',')[1],
                              )
                            ]))),
                      )
                    ],
                  ),
                )),
                btnsWidget(),
                const SizedBox(height: kToolbarHeight + 15),
              ],
            ),
          ),
          if (isloading) DesignConfig.loaderWidget()
        ],
      ),
    );
  }
}
