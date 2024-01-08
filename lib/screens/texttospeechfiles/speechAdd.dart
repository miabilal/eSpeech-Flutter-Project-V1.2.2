import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/screens/texttospeechfiles/texttospeech.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import '../../helper/constant.dart';
import '../../model/voices.dart';

class SpeechAdd extends StatefulWidget {
  final Function? updateParent;
  final Voices? selectedVoice;

  const SpeechAdd({
    Key? key,
    this.updateParent,
    this.selectedVoice,
  }) : super(key: key);

  @override
  _SpeechAddState createState() => _SpeechAddState();
}

class _SpeechAddState extends State<SpeechAdd> with TickerProviderStateMixin {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isloading = false, isgetduration = true;
  int duration = 0, mainduration = 0;
  int cursorPosition = 0;
  int baseoffset = 0;
  int extendoffset = 0;
  bool issetcursor = true;
  bool keyboardvisibility = false;
  bool isBlur = false;
  AnimationController? controller;
  Animation? sizeAnimation;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    sizeAnimation = Tween<double>(begin: 0, end: 25)
        .animate(CurvedAnimation(curve: Curves.bounceOut, parent: controller!));

    controller!.addListener(() {
      setState(() {});
    });
    if (edttxt.text.isNotEmpty) {
      controller!.forward();
    }
    edttxt.addListener(() {
      if (edttxt.text.length == 1) {
        controller!.forward();
      }
      if (edttxt.text.isEmpty) {
        controller!.reverse();
      }
      if (WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
        //Keyboard is visible.

        bool isupdate = false;
        if (!keyboardvisibility) {
          keyboardvisibility = true;
          isupdate = true;
        }
        int pos = edttxt.selection.base.offset;
        if (issetcursor && pos != -1) {
          cursorPosition = pos;
          baseoffset = edttxt.selection.baseOffset;
          extendoffset = edttxt.selection.extentOffset;
          isupdate = true;
        }
        if (isupdate) {
          setState(() {});
        }
      } else {
        //Keyboard is not visible.
        if (keyboardvisibility) {
          keyboardvisibility = false;
          setState(() {});
        }
      }

      widget.updateParent!(edttxt.text);
    });



    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ColorsRes.white,
          floatingActionButton: btmAddBtn(),
          appBar: DesignConfig.setAppBar(
              context, 0, StringsRes.speech_lbl, false, Constant.appbarHeight),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      alignment: Alignment.center,
                      padding:
                          const EdgeInsetsDirectional.only(start: 30, end: 30),
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height * .6,
                      child: Stack(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * .55,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: ColorsRes.bgcolor),
                            child: TextFormField(
                              autofocus: true,
                              style: TextStyle(
                                  color: ColorsRes.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14.0),
                              cursorColor: ColorsRes.black,
                              onChanged: (value) {
                                speech = value;
                                widget.updateParent!(value);
                              },
                              onSaved: ((String? val) {
                                widget.updateParent!(val);
                                speech = val!;
                              }),
                              maxLines: null,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsetsDirectional.all(25.0),
                                filled: true,
                                fillColor: ColorsRes.bgcolor,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        width: 0.0, style: BorderStyle.none)),
                              ),
                              keyboardType: TextInputType.multiline,
                              controller: edttxt,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, top: 12),
                            child: Container(
                              height: sizeAnimation!.value,
                              padding: const EdgeInsetsDirectional.only(
                                  start: 10.0,
                                  end: 10.0,
                                  top: 4.5,
                                  bottom: 4.5),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7)),
                                  gradient: LinearGradient(
                                      begin: Alignment(0, 0.00930662266910076),
                                      end: Alignment(1, 1),
                                      colors: [
                                        ColorsRes.gradient1,
                                        ColorsRes.gradient2
                                      ])),
                              child: Text(
                                "${speech.isEmpty ? "1" : speech.length}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 10.0),
                              ),
                            ),
                          ),
                        ),
                      ])),
                ),
              ),
              if (widget.selectedVoice != null) voiceModeulationWidget(),
            ],
          ),
        ),
        if (isBlur)
          Container(
            color: Colors.black.withOpacity(0.3),
            height: MediaQuery.of(context).size.height,
            width: double.maxFinite,
          )
      ],
    );
  }

  voiceModeulationWidget() {
    datalist = {};
    if (Constant.taglist.containsKey(widget.selectedVoice!.provider)) {
      datalist = Constant.taglist[widget.selectedVoice!.provider]!;
    }

    if (datalist.isEmpty) return Container();
    String clearvoice = 'Clear voice';
    datalist[clearvoice] = ['Clear voice'];

    return BackdropFilter(
        filter:
            ImageFilter.blur(sigmaX: isBlur ? 2 : 0, sigmaY: isBlur ? 2 : 0),
        child: Align(
          alignment: Alignment.centerRight,
          child: PopupMenuButton(
            offset: const Offset(-30, 0),
            elevation: 0,
            color: ColorsRes.white,
            onCanceled: () {
              setState(() {
                isBlur = false;
              });
            },
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(33))),
            child: Container(
                width: 20,
                height: 79,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        topLeft: Radius.circular(30)),
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
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                              //alignment: Alignment.center,
                              width: 4.5,
                              height: 4.5,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle)),
                        ),
                      );
                    })),
            itemBuilder: (BuildContext bc) {
              return datalist.entries.map((entry) {
                String title = Constant.setFirstLetterUppercase(
                    entry.key.replaceAll("_", " "));
                String img;
                setState(() {
                  isBlur = true;
                });

                if (title == StringsRes.say_as_lbl) {
                  img = "say_as.svg";
                } else if (title == StringsRes.emphasis_lbl) {
                  img = "emphasis.svg";
                } else if (title == StringsRes.vol_lbl) {
                  img = "volume.svg";
                } else if (title == StringsRes.speed_lbl) {
                  img = "speed.svg";
                } else if (title == StringsRes.pitch_lbl) {
                  img = "pitch.svg";
                } else if (title == StringsRes.pauses_lbl) {
                  img = "pauses.svg";
                } else if (title == StringsRes.clear_voi_lbl) {
                  img = "clearvoice.svg";
                } else {
                  img = "clearvoice.svg";
                }

                return PopupMenuItem(
                  value: entry.key,
                  padding: const EdgeInsets.only(
                      left: 20, right: 10, top: 0, bottom: 0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 15.0),
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: ColorsRes.proBgIcColor,
                                shape: BoxShape.circle),
                            child: SvgPicture.asset(
                              Constant.svgpath + img,
                              height: 20,
                              width: 20,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 13,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 15),
                          child: Text(title,
                              style: const TextStyle(
                                  color: ColorsRes.black,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14.0),
                              textAlign: TextAlign.left),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();
            },
            onSelected: (value) {
              isBlur = false;
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
                        shape: DesignConfig.setRoundedBorder(
                            ColorsRes.grey, 15, false),
                        content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(listitems.length, (index) {
                              return GestureDetector(
                                  onTap: () {
                                    String starttag =
                                        listitems[index]['start_tag'];
                                    String endtag = listitems[index]['end_tag'];

                                    String tagstring = starttag + endtag;

                                    insertTag(tagstring, starttag, endtag);

                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
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
          ),
        ));
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
    text.substring(indexEnd, text.length);
    edttxt.text = "";
    edttxt.text = text;
    cursorPosition = extendoffset + content.length;
    baseoffset = cursorPosition;
    extendoffset = cursorPosition;
    setState(() {});
  }

  btmAddBtn() {
    return InkWell(
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
            Icons.check,
            size: 24,
            color: ColorsRes.white,
          )),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
