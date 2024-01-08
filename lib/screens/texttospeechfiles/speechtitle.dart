import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/screens/texttospeechfiles/texttospeech.dart';

import 'package:flutter/material.dart';

class SpeechTitle extends StatefulWidget {
  const SpeechTitle({
    Key? key,
  }) : super(key: key);

  @override
  _SpeechTitleState createState() => _SpeechTitleState();
}

class _SpeechTitleState extends State<SpeechTitle>
    with TickerProviderStateMixin {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isloading = false, isgetduration = true;

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
    if (edttitle.text.isNotEmpty) {
      controller!.forward();
    }
    edttitle.addListener(() {
      if (edttitle.text.length == 1) {
        controller!.forward();
      }
      if (edttitle.text.isEmpty) {
        controller!.reverse();
      }
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
    return Scaffold(
        backgroundColor: ColorsRes.white,
        resizeToAvoidBottomInset: true,
        appBar: DesignConfig.setAppBar(context, 0, StringsRes.speech_title_lbl,
            false, Constant.appbarHeight),
        floatingActionButton: btmAddBtn(),
        body: SizedBox(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 50,
                    alignment: Alignment.center,
                    height: 52,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
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
                        setState(() {
                          title = value;
                        });
                      },
                      decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsetsDirectional.only(start: 20.0),
                          border: InputBorder.none,
                          counterText: ''),
                      keyboardType: TextInputType.text,
                      controller: edttitle,
                    ),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 45, bottom: 52),
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                        start: 10.0, end: 10.0, top: 4.5, bottom: 4.5),
                    height: sizeAnimation!.value,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        //color: colorAnimation!.value,
                        gradient: LinearGradient(
                            begin: Alignment(0, 0.00930662266910076),
                            end: Alignment(1, 1),
                            colors: [
                              ColorsRes.gradient1,
                              ColorsRes.gradient2
                            ])),
                    child: Text("${title.isEmpty ? "1" : title.length}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 10.0),
                        textAlign: TextAlign.left),
                  ),
                ),
              ),
            ],
          ),
        ));
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
