import 'dart:convert';

import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TermsConditionPage extends StatefulWidget {
  String title, type;

  TermsConditionPage(this.title, this.type, {Key? key}) : super(key: key);

  @override
  TermsData createState() {
    return TermsData(title, type);
  }
}

class TermsData extends State<TermsConditionPage> {
  String title, type;

  TermsData(this.title, this.type);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorsRes.white,
      appBar: DesignConfig.setAppBar(context,0,title,true,Constant.appbarHeight),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: FutureBuilder<String>(
              future: getTermsData(),
              builder: (context, snapshot) {

                if (snapshot.hasData) {
                  return Html(
                    data: snapshot.data,
                    style: {
                      "body": Style(color: ColorsRes.darktext),
                    },
                    onLinkTap: (url, context, attributes, element) async {
                      await launchUrlString(url!);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                return const Padding(
                    padding: EdgeInsets.all(5),
                    child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }

  Future<String> getTermsData() async {
    Map<String, String> body = {
      Constant.variable: type,
    };
    var response = await Constant.sendApiRequest(
        Constant.apiGetSettings, body, true, context);
    final res = json.decode(response);
    bool error = res['error'];
    if (error) {
      return StringsRes.noDataFound;
    } else {
      return res['data'][type];
    }
  }
}
