import 'package:espeech/screens/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helper/BottomAppProvider.dart';
import 'helper/TTSProvider.dart';
import 'helper/colorsres.dart';
import 'helper/constant.dart';
import 'helper/sessionmanager.dart';
import 'helper/stringsres.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  //print('notification==Handling a background message ${message.messageId}');
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late final FirebaseMessaging _messaging;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  setNotificationConfig();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  SystemUiOverlayStyle systemUiOverlayStyle =
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp(sharedPreferences: prefs));
  });
}

setNotificationConfig() async {
  _messaging = FirebaseMessaging.instance;
//  NotificationSettings settings =
  await _messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: (
            int id,
            String? title,
            String? body,
            String? payload,
          ) async {});

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      //debugPrint('notification payload: $payload');
    }
  });

  // For handling the received notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //print("notification-msg-1=>${message.from}===${message.data}");
    var data = message.data;

    showFirebaseNotification(data['title'], data['body'], '');
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> showFirebaseNotification(
    String title, String body, String payloaddata) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'com.wrteamespeech',
    'eSpeech',
    playSound: true,
    enableVibration: true,
    importance: Importance.max,
    priority: Priority.high,
  );
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails();

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin
      .show(0, title, body, platformChannelSpecifics, payload: payloaddata);
}

class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({
    Key? key,
    required this.sharedPreferences,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState(sharedPreferences);
  }
}

class MyAppState extends State<MyApp> {
  final SharedPreferences _sharedPreferences;

  MyAppState(this._sharedPreferences);

  @override
  initState() {
    super.initState();
    Constant.session =
        SessionManager(prefs: _sharedPreferences, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return SessionManager(prefs: _sharedPreferences, context: context);
          },
        ),
        ChangeNotifierProvider<BottomAppProvider>(
            create: (context) => BottomAppProvider()),
        ChangeNotifierProvider<TTSProvider>(
            create: (context) => TTSProvider()),
      ],
      child: Consumer<SessionManager>(
        builder: (BuildContext context, value, Widget? child) {
          Constant.session = Provider.of<SessionManager>(context);

          //print("myid->${Constant.session!.getData(SessionManager.keyId)}");

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: StringsRes.mainappname,
            theme: ThemeData(
              fontFamily: 'RedHatDisplay',
              iconTheme: const IconThemeData(
                color: ColorsRes.white,
              ),
              primarySwatch: ColorsRes.appcolorMaterial,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(elevation: 0)
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
