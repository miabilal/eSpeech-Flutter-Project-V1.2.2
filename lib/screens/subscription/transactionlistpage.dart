import 'dart:convert';
import 'dart:io';

import 'package:espeech/helper/colorsres.dart';
import 'package:espeech/helper/constant.dart';
import 'package:espeech/helper/designconfig.dart';
import 'package:espeech/helper/sessionmanager.dart';
import 'package:espeech/helper/stringsres.dart';
import 'package:espeech/model/plans.dart';
import 'package:espeech/model/transaction.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jiffy/jiffy.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({Key? key}) : super(key: key);

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  int offset = 0;
  int perPageLimit = 5;
  int total = 100;
  bool isloading = true, isloadmore = true, isfirstload = false;
  String nodatamsg = '';
  List<Transaction> transactionlist = [];
  List<Transaction> tempList = [];
  ScrollController controller = ScrollController();
  List<File> files = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    files.clear();
    controller.addListener(_scrollListener);
    loadMore();
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isloadmore = true;
          if (offset < total) loadMore();
        });
      }
    }
  }

  Future<void> loadMore() async {
    bool checkinternet = await Constant.checkInternet();
    if (!checkinternet) {
      Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork, 1);
      return;
    }

    Map<String, String?> parameter = {
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
      Constant.offset: offset.toString(),
      Constant.limit: perPageLimit.toString(),
    };

    var response = await Constant.sendApiRequest(
        Constant.apiGetTransactions, parameter, true, context);

    var getdata = json.decode(response);
    isfirstload = false;
    if (!getdata[Constant.error]) {
      total = getdata["total"];

      if ((offset) < total) {
        tempList.clear();
        var data = getdata["data"];
        tempList =
            (data as List).map((data) => Transaction.fromJson(data)).toList();

        transactionlist.addAll(tempList);

        offset = offset + perPageLimit;
      } else {
        nodatamsg = getdata[Constant.message];
        isloadmore = false;
      }
    } else {
      isloadmore = false;
      nodatamsg = getdata[Constant.message];
    }

    setState(() {
      isloading = false;
    });
  }

  Future<void> _refresh() {
    if (mounted) {
      setState(() {
        isloading = true;
        offset = 0;
        total = 100;
        transactionlist.clear();
      });
    }

    return loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DesignConfig.setAppBar(
          context, 0, StringsRes.transactions, true, Constant.appbarHeight),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : nodatamsg.trim().isNotEmpty
              ? Center(
                  child: Text(
                    nodatamsg,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                )
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: ColorsRes.appcolor,
                        height: 20,
                      );
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controller,
                    itemCount: (offset < total)
                        ? transactionlist.length + 1
                        : transactionlist.length,
                    itemBuilder: (context, index) {
                      Color statuscolor = ColorsRes.grey;
                      if (index != transactionlist.length) {
                        statuscolor =
                            Constant.statusColor(transactionlist[index].status);
                      }

                      return (index == transactionlist.length && isloadmore)
                          ? const Center(child: CircularProgressIndicator())
                          : ListTile(
                              dense: true,
                              onTap: () {
                                planInfo(
                                    transactionlist[index].subscriptiondetail!,
                                    transactionlist[index]);
                              },
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(StringsRes.trans_id_lbl,
                                                textAlign: TextAlign.end,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .merge(TextStyle(
                                                        color: ColorsRes.black
                                                            .withOpacity(0.8),
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Text(transactionlist[index].txnId,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .merge(const TextStyle(
                                                      color: ColorsRes
                                                          .mainsubtextcolor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ))),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(StringsRes.amt_lbl,
                                                textAlign: TextAlign.end,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .merge(TextStyle(
                                                        color: ColorsRes.black
                                                            .withOpacity(0.8),
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Text(transactionlist[index].amount,
                                                textAlign: TextAlign.end,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .merge(const TextStyle(
                                                        color: ColorsRes
                                                            .mainsubtextcolor,
                                                        fontWeight:
                                                            FontWeight.w500))),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            '${transactionlist[index].createdOn.split(" ")[0]} | ${transactionlist[index].createdOn.split(" ")[1]} ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption!
                                                .merge(const TextStyle(
                                                    color: ColorsRes.black,
                                                    fontWeight:
                                                        FontWeight.w400))),
                                      ),
                                      const Spacer(),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 5),
                                            decoration:
                                                DesignConfig.boxDecoration(
                                                    statuscolor
                                                        .withOpacity(0.2),
                                                    30),
                                            child: Text(
                                                Constant
                                                    .setFirstLetterUppercase(
                                                        transactionlist[index]
                                                            .status),
                                                style: TextStyle(
                                                    color: statuscolor,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              leading: getPayTypeImage(transactionlist[index]
                                  .paymentMethod
                                  .toLowerCase()),
                            );
                    },
                  ),
                ),
    );
  }

  void planInfo(Plans planinfo, Transaction transaction) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStater) {
            return AlertDialog(
              title: Text(planinfo.title),
              content: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "${Jiffy(planinfo.startsFrom, "yyyy-MM-dd").format("dd-MM-yyyy")} To ${Jiffy(planinfo.expiresOn, "yyyy-MM-dd").format("dd-MM-yyyy")}",
                        style: Theme.of(context).textTheme.subtitle1!.merge(
                            const TextStyle(
                                color: ColorsRes.subtextcolor,
                                decoration: TextDecoration.underline))),
                    DesignConfig.characterUsageWidget(
                        'overall.svg',
                        StringsRes.overallcharacter,
                        "${Constant.numberFormattor(planinfo.remainingCharacters!)}/${Constant.numberFormattor(planinfo.noOfCharacters)}",
                        context,
                        true),
                    DesignConfig.characterUsageWidget(
                        'google.svg',
                        StringsRes.lblgoogle,
                        "${Constant.numberFormattor(planinfo.remainingGoogle!)}/${Constant.numberFormattor(planinfo.google)}",
                        context,
                        true),
                    DesignConfig.characterUsageWidget(
                        'aws.svg',
                        StringsRes.lblaws,
                        "${Constant.numberFormattor(planinfo.remainingAws!)}/${Constant.numberFormattor(planinfo.aws)}",
                        context,
                        true),
                    DesignConfig.characterUsageWidget(
                        'ibm.svg',
                        StringsRes.lblibm,
                        "${Constant.numberFormattor(planinfo.remainingIbm!)}/${Constant.numberFormattor(planinfo.ibm)}",
                        context,
                        true),
                    DesignConfig.characterUsageWidget(
                        'azure.svg',
                        StringsRes.lblazure,
                        "${Constant.numberFormattor(planinfo.remainingAzure!)}/${Constant.numberFormattor(planinfo.azure)}",
                        context,
                        true),
                    if (transaction.paymentMethod == "bank" &&
                        transaction.status == "pending" &&
                        transaction.attachList!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            StringsRes.your_receipt,
                            style: const TextStyle(color: ColorsRes.darktext),
                          ),
                        ),
                      ),
                    if (transaction.paymentMethod == "bank" &&
                        transaction.status == "pending" &&
                        transaction.attachList!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 20.0, end: 20.0),
                                height: transaction.attachList!.isNotEmpty
                                    ? 100.0
                                    : 0,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                        transaction.attachList!.length, (i) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: i == 0 ? 0 : 10),
                                        child: Image.network(
                                          transaction.attachList![i],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return Constant.defaultImage(
                                                100, 100);
                                          },
                                          loadingBuilder: (BuildContext context,
                                              Widget? child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child!;
                                            }
                                            return Constant.defaultImage(
                                                100, 100);
                                          },
                                        ),
                                      );
                                    })))),
                      ),
                    if (transaction.paymentMethod == "bank" &&
                        transaction.status == "pending")
                      Padding(
                        padding: const EdgeInsets.only(top: 13.0),
                        child: InkWell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 2),
                            decoration: BoxDecoration(
                                color: ColorsRes.gradient1.withOpacity(0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0))),
                            child: Text(
                              StringsRes.choose_bank_rece_lbl,
                              style: const TextStyle(color: ColorsRes.darktext),
                            ),
                          ),
                          onTap: () {
                            _imgFromGallery(setStater);
                          },
                        ),
                      ),
                    if (transaction.paymentMethod == "bank" &&
                        transaction.status == "pending")
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                            padding: const EdgeInsetsDirectional.only(
                                start: 20.0, end: 20.0, top: 10),
                            height: files.isNotEmpty ? 90.0 : 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(files.length, (i) {
                                return InkWell(
                                  child: Stack(
                                    alignment: AlignmentDirectional.topEnd,
                                    children: [
                                      Image.file(
                                        files[i],
                                        width: 90,
                                        height: 90,
                                      ),
                                      Container(
                                          color: ColorsRes.darktext,
                                          child: const Icon(
                                            Icons.clear,
                                            size: 12,
                                          ))
                                    ],
                                  ),
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        files.removeAt(i);
                                      });
                                    }
                                  },
                                );
                              }),
                            )),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (transaction.paymentMethod == "bank" &&
                              transaction.status == "pending")
                            Expanded(
                              child: InkWell(
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: const BoxDecoration(
                                      color: ColorsRes.darktext,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0))),
                                  child: Text(
                                    StringsRes.upload_rece_lbl,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: ColorsRes.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  sendBankProof(planinfo.id, setStater);
                                },
                              ),
                            ),
                          Expanded(
                            child: InkWell(
                              child: Container(
                                height: 50,
                                margin: const EdgeInsetsDirectional.only(
                                    start: 20.0),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: const BoxDecoration(
                                    color: ColorsRes.darktext,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0))),
                                child: Text(
                                  StringsRes.lblok,
                                  style:
                                      const TextStyle(color: ColorsRes.white),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                files.clear();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  sendBankProof(String subscriptionId, StateSetter state) async {
    bool checkinternet = await Constant.checkInternet();
    if (!checkinternet) {
      Constant.showSnackBarMsg(context, StringsRes.lblchecknetwork, 1);

      return;
    }
    state(() {
      isloading = true;
    });

    Map<String, String?> parameter = {
      Constant.subscriptionId: subscriptionId,
      Constant.userId: Constant.session!.getData(SessionManager.keyId),
    };

    Map<String, List<File>> apifilelist = {};
    var response;

    apifilelist[Constant.recipets] = files;

    response = await Constant.postApiFile(
        Constant.apiUploadReceipts, apifilelist, context, parameter, 2);

    var getdata = json.decode(response);

    files.clear();
    Constant.showSnackBarMsg(context, getdata[Constant.message], 1);

    state(() {
      isloading = false;
    });
  }

  _imgFromGallery(StateSetter state) async {
    var result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      state(() {});
    } else {
      // User canceled the picker
    }
  }

  getPayTypeImage(String type) {
    String image = '';
    if (type == Constant.paytypeStripe) {
      image = "stripe.svg";
    } else if (type == Constant.paytypePaystack) {
      image = "paystack.svg";
    } else if (type == Constant.paytypeRazorpay) {
      image = "razorpay.svg";
    } else if (type == Constant.paytypeBankTransfer) {
      image = "banktransfer.svg";
    } else if (type == Constant.paytypePaytm) {
      image = "paytm.svg";
    }
    return SvgPicture.asset(
      Constant.svgpath + image,
      fit: BoxFit.scaleDown,
      width: 50,
    );
  }
}
