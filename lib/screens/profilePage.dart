import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/sessionmanager.dart';
import 'auth/loginactivity.dart';
import 'mainactivity.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController edtfname = TextEditingController();
  TextEditingController edtlname = TextEditingController();
  TextEditingController edtmob = TextEditingController();

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  File? profileimagefile;

  @override
  void initState() {
    super.initState();

    setconfig();
  }

  setconfig() async {
    if (Constant.session == null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      SessionManager sessionManager =
          SessionManager(prefs: pref, context: context);
      Constant.session = sessionManager;
      setText();
      setState(() {});
    } else {
      setText();
    }
  }

  setText() {
    edtfname.text = Constant.session!.getData(SessionManager.keyFirstName);
    edtlname.text = Constant.session!.getData(SessionManager.keyLastName);
    edtmob.text = Constant.session!.getData(SessionManager.keyPhone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorsRes.bgcolor,
      appBar: DesignConfig.setAppBar(context, 0, StringsRes.profile, true, Constant.appbarHeight),
      bottomNavigationBar: IntrinsicHeight(
        child: GestureDetector(
          onTap: () async {
            showDialog(
                context: context,
                builder: (context) => const ChangePswDialog());
          },
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "${StringsRes.changePassword} ?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.0,
                color: ColorsRes.appcolor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
          padding: const EdgeInsets.only(
              left: 20, right: 20, top: kToolbarHeight, bottom: 20),
          children: [
            formWidget(),
          ]),
    );
  }

  Widget formWidget() {
    return Form(
        key: _formKey,
        child: Column(children: [
          GestureDetector(
            onTap: () async {
              FilePickerResult? result =
                  await FilePicker.platform.pickFiles(type: FileType.image);

              if (result != null) {
                var val = await ImageCropper().cropImage(
                  sourcePath: result.files.single.path!,
                  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                  compressQuality: 100,
                  maxHeight: 700,
                  maxWidth: 700,
                  compressFormat: ImageCompressFormat.jpg,
                );

                if (val != null) {
                  profileimagefile = File(val.toString());
                  setState(() {});
                }
              } else {
                // User canceled the picker
              }
            },
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorsRes.bgcolor,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorsRes.appcolor),
                  ),
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsetsDirectional.only(bottom: 10),
                  child: ClipOval(
                    child: profileimagefile != null
                        ? Image.file(
                            profileimagefile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Constant.session!
                                .getData(SessionManager.keyImage)
                                .trim()
                                .isEmpty
                            ? Constant.defaultImage(100, 100)
                            : Image.network(
                                Constant.session!
                                    .getData(SessionManager.keyImage),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Constant.defaultImage(100, 100);
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget? child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child!;
                                  return Constant.defaultImage(100, 100);
                                },
                              ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2,
                  top: 80,
                  child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: ColorsRes.maintextcolor,
                      child: Icon(
                        Icons.edit,
                        color: ColorsRes.white,
                        size: 15,
                      )),
                ),
              ],
            ),
          ),
          TextFormField(
            style: const TextStyle(
                color: ColorsRes.black,
                fontWeight: FontWeight.w400,
                fontSize: 14),
            cursorColor: ColorsRes.black,
            decoration: InputDecoration(
              suffixIcon: const Icon(
                Icons.people_outline,
                color: ColorsRes.appcolor,
              ),
              hintText: StringsRes.firstname,
              hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      color: ColorsRes.darktext, letterSpacing: 0.5)),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.black),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.black),
              ),
            ),
            keyboardType: TextInputType.text,
            validator: (val) =>
                val.toString().trim().isEmpty ? StringsRes.firstname : null,
            controller: edtfname,
          ),
          const SizedBox(height: 20),
          TextFormField(
            style: const TextStyle(
                color: ColorsRes.black,
                fontWeight: FontWeight.w400,
                fontSize: 14),
            cursorColor: ColorsRes.black,
            decoration: InputDecoration(
              suffixIcon: const Icon(
                Icons.people_outline,
                color: ColorsRes.appcolor,
              ),
              hintText: StringsRes.lastname,
              hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      color: ColorsRes.darktext, letterSpacing: 0.5)),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.black),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.black),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
                val.toString().trim().isEmpty ? StringsRes.lastname : null,
            controller: edtlname,
          ),
          const SizedBox(height: 20),
          TextFormField(
            style: const TextStyle(
                color: ColorsRes.black,
                fontWeight: FontWeight.w400,
                fontSize: 14),
            cursorColor: ColorsRes.black,
            decoration: InputDecoration(
              suffixIcon: const Icon(
                Icons.phone_android,
                color: ColorsRes.appcolor,
              ),
              hintText: StringsRes.phonenumber,
              hintStyle: Theme.of(context).textTheme.subtitle1!.merge(
                  const TextStyle(
                      color: ColorsRes.darktext, letterSpacing: 0.5)),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.black),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorsRes.black),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (val) => Constant.validateMobile(val!),
            controller: edtmob,
          ),
          const SizedBox(height: 40),
          InkWell(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.maxFinite,
                height: 54,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
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
                      colors: [ColorsRes.gradient1, ColorsRes.gradient2]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(StringsRes.lblupdate,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0),
                    textAlign: TextAlign.center),
              ),
            ),
            onTap: () {
              updateProcess();
            },
          )
        ]));
  }

  updateProcess() async {
    if (_formKey.currentState!.validate() && !isLoading) {
      setState(() {
        isLoading = true;
      });
      Map<String, String?> parameter = {
        Constant.firstName: edtfname.text,
        Constant.lastName: edtlname.text,
        Constant.phone: edtmob.text,
        Constant.userId: Constant.session!.getData(SessionManager.keyId),
      };

      Map<String, List<File>> apifilelist = {};
      var response;

      String profile = Constant.session!.getData(SessionManager.keyImage);

      if (profileimagefile == null) {
        response = await Constant.sendApiRequest(
            Constant.apiUpdateUser, parameter, true, context);
      } else {
        List<File> profileList = [];
        profileList.add(profileimagefile!);
        apifilelist[Constant.image] = profileList;
        response = await Constant.postApiFile(
            Constant.apiUpdateUser, apifilelist, context, parameter, 1);
      }

      var getdata = json.decode(response);

      if (profileimagefile != null) {
        profile = getdata['data'][Constant.image];
      }
      Constant.showSnackBarMsg(context, getdata[Constant.message], 1);
      if (!getdata[Constant.error]) {
        Constant.session!.updateUserData(
          edtfname.text,
          edtmob.text,
          edtlname.text,
          profile,
        );
      }

      setState(() {
        isLoading = false;
      });
      Timer(const Duration(seconds: 1), () async {
        Constant.killPreviousPages(context, MainActivity(from: "main"));
      });
    }
  }
}

class ChangePswDialog extends StatefulWidget {
  const ChangePswDialog({Key? key}) : super(key: key);

  @override
  ChangePswAlert createState() => ChangePswAlert();
}

class ChangePswAlert extends State<ChangePswDialog> {
  late BuildContext _scaffoldContext;
  bool iserror = false,
      iserrornew = false,
      iserrorcpsw = false,
      isotperr = false,
      isbtnvisible = true;
  late TextEditingController oldpsw, newpsw, cpsw, otp;
  bool isdialogloading = false;
  late String cpswerrtext;

  @override
  initState() {
    oldpsw = TextEditingController();
    otp = TextEditingController();
    newpsw = TextEditingController();
    cpsw = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return openForgotDialog();
  }

  openForgotDialog() {
    return AlertDialog(
      title: Center(
          child: Text(
        StringsRes.changePassword,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
      )),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            obscureText: true,
            controller: oldpsw,
            decoration: InputDecoration(
                hintText: "Enter Old Password",
                errorText: iserror ? 'Enter Old Password' : null,
                errorMaxLines: 3,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.5,
                    color: ColorsRes.black.withOpacity(0.4))),
          ),
          TextField(
            obscureText: true,
            controller: newpsw,
            decoration: InputDecoration(
                hintText: StringsRes.enterNewPassword,
                errorText: iserrornew ? StringsRes.passwordLengthWarning : null,
                errorMaxLines: 3,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.5,
                    color: ColorsRes.black.withOpacity(0.4))),
          ),
          TextField(
            obscureText: true,
            controller: cpsw,
            decoration: InputDecoration(
                hintText: StringsRes.enterConfirmPassword,
                errorText: iserrorcpsw ? cpswerrtext : null,
                errorMaxLines: 3,
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.5,
                    color: ColorsRes.black.withOpacity(0.4))),
          ),
          isdialogloading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : Container(),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            StringsRes.lblcancel,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          onPressed: () {
            Navigator.of(_scaffoldContext).pop();
          },
        ),
        TextButton(
          child: Text(StringsRes.change,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          onPressed: () async {
            iserrornew = false;
            iserrorcpsw = false;
            isotperr = false;
            iserror = false;
            setState(() {
              if (oldpsw.text.trim().isEmpty) {
                iserror = true;
              } else if (newpsw.text.length < 8) {
                iserrornew = true;
              } else if (cpsw.text.isEmpty) {
                iserrorcpsw = true;
                cpswerrtext = StringsRes.enterConfirmPassword;
              } else if (cpsw.text != newpsw.text) {
                iserrorcpsw = true;
                cpswerrtext = StringsRes.confirmPswNotMatch;
              } else {
                isdialogloading = true;
              }
            });

            if (isdialogloading) {
              Map<String, String> body = {
                Constant.email:
                    Constant.session!.getData(SessionManager.keyEmail),
                Constant.oldPassword: oldpsw.text,
                Constant.newPassword: newpsw.text,
              };
              var response = await Constant.sendApiRequest(
                  Constant.apiChangePassword, body, true, context);

              setState(() {
                isdialogloading = false;
              });
              final res = json.decode(response);

              bool error = res['error'];
              Constant.showSnackBarMsg(context, res['message'], 1);
              if (!error) {
                Navigator.of(_scaffoldContext).pop();
                Constant.killPreviousPages(
                    context, LoginActivity(from: "logout"));
              }
            }
          },
        ),
      ],
    );
  }
}
