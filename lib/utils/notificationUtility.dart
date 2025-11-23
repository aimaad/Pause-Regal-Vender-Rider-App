import 'dart:io';

import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/ui/screen/main/main_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

backgroundMessage(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class NotificationUtility {
  late BuildContext context;
  NotificationUtility({required this.context});
  void initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/notification_icon');
    

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );

    //Android 13 or higher
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationPayload(notificationResponse.payload!);

            break;
          case NotificationResponseType.selectedNotificationAction:
            print("notification-action-id--->${notificationResponse.actionId}==${notificationResponse.payload}");

            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundMessage,
    );
    _requestPermissionsForIos();
  }

  selectNotificationPayload(String? payload) async {
    print("payload:$payload");
    if (payload != null) {
      List<String> pay = payload.split(",");
      
      if (pay[0] == "products") {
      } else if (pay[0] == "wallet") {
        Navigator.of(context).pushNamed(Routes.wallet);
      } else if (pay[0] == "place_order" || pay[0] == "order") {
        
        Navigator.of(context).popUntil(
          (route) => route.isFirst, 
        );
      } else {
        
        Navigator.of(context).popUntil(
          (route) => route.isFirst, 
        );
      }
    }
  }

  Future<void> _requestPermissionsForIos() async {
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions();
    }
  }

  Future<void> onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {}

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    //print("initialMessage"+initialMessage.toString());
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    // handle background notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (streamController != null && !streamController!.isClosed) {
        streamController!.sink.add("1");
      }
      print("data:onMessage");
      print("data notification*********************************${message.data}");
      var data = message.data;
      print("data notification*********************************$data");
      var title = data['title'].toString();
      var body = data['body'].toString();
      var type = data['type'].toString();
      var image = data['image'].toString();
      var id = data['type_id'] ?? '';

      if (image != 'null' && image != '') {
        generateImageNotification(title, body, image, type, id);
      } else {
        generateSimpleNotification(title, body, type, id);
      }
    });
  }

  static Future<void> onBackgroundMessage(RemoteMessage remoteMessage) async {
    print("type2:${remoteMessage.data['type'].toString()}");
    //perform any background task if needed here
    if (streamController != null && !streamController!.isClosed) {
      streamController!.sink.add("1");
    }
  }

// notification type is move to screen
  Future<void> _handleMessage(RemoteMessage message) async {
    if (streamController != null && !streamController!.isClosed) {
      streamController!.sink.add("1");
    }
    if (message.data['type'] == "products") {
      //getProduct(id, 0, 0, true);
    } else if (message.data['type'] == "wallet") {
      Navigator.of(context).pushNamed(Routes.wallet);
    } else if (message.data['type'] == 'place_order' || message.data['type'] == 'order') {
      print("message:${message.data['type']}");
      
    } else {
      
    }
  }

  DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
    categoryIdentifier: "",
  );

  Future<void> generateImageNotification(String title, String msg, String image, String type, String? id) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.wrteam.erestroSingleVenderRider', //channel id
      'eRestro Singlevendor Rider', //channel name
      channelDescription: 'eRestro Singlevendor Rider', //channel description
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation, icon: "@drawable/notification_icon",
    );
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(sound: 'notification.aiff');
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: "$type,${id!}");
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(String title, String msg, String type, String? id) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'com.wrteam.erestroSingleVenderRider', //channel id
        'eRestro Singlevendor Rider', //channel name
        channelDescription: 'eRestro Singlevendor Rider', //channel description
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        icon: "@drawable/notification_icon");
        const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(sound: 'notification.aiff');
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: "$type,${id!}");
  }
}
