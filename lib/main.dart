import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'setNotification.dart';

Future main() async {
  runApp(MyApp());
  // await initializeService();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      home: AlarmScreen(),
    );
  }
}

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    initializeAudioPlayer();
    notificationServices.InitialiseNotifications();

    // WidgetsBinding.instance.addObserver(this);
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   WidgetsBinding.instance.removeObserver(this);
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.inactive ||
  //       state == AppLifecycleState.detached) return;

  //   final isBackGround = state == AppLifecycleState.paused;
  //   if (isBackGround) {
  //     Future.delayed(const Duration(seconds: 12));
  //     Get.snackbar("cdsd", "message");
  //   }
  // }
  //msc golflink

  void initializeAudioPlayer() {
    audioPlayer = AudioPlayer();
    setState(() {});
  }

  void startListeningForAlarm(DateTime selectedDateTime) {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      DateTime now = DateTime.now();

      if ("${selectedDateTime.day}${selectedDateTime.hour}${selectedDateTime.minute}" ==
          "${now.day}${now.hour}${now.minute}") {
        notificationServices.sendNotifications(
            "Alarm", "${selectedDateTime.hour}:${selectedDateTime.minute}");
        playAlarmSound();
        timer.cancel();
      }
    });
  }

  void playAlarmSound() async {
    await audioPlayer.play(UrlSource(
        'https://file-examples.com/storage/fe63e96e0365c0e1e99a842/2017/11/file_example_MP3_700KB.mp3'));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            DateTime? selectedDateTime = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );

            if (selectedDateTime != null) {
              // ignore: use_build_context_synchronously
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (selectedTime != null) {
                selectedDateTime = DateTime(
                  selectedDateTime.year,
                  selectedDateTime.month,
                  selectedDateTime.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                startListeningForAlarm(selectedDateTime);

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alarm set for $selectedDateTime'),
                  ),
                );
              }
            }
          },
          child: const Text('Set Alarm'),
        ),
      ),
    );
  }
}

// // this will be used as notification channel id
// const notificationChannelId = 'my_foreground';

// // this will be used for notification id, So you can update your custom notification with this id.
// const notificationId = 888;

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     notificationChannelId, // id
//     'MY FOREGROUND SERVICE', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.low, // importance must be at low or higher level
//   );

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will be executed when app is in foreground or background in separated isolate
//       onStart: onStart,

//       // auto start service
//       autoStart: true,
//       isForegroundMode: true,

//       notificationChannelId:
//           notificationChannelId, // this must match with notification channel you created above.
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: notificationId,
//     ),
//     iosConfiguration: IosConfiguration(),
//   );
// }

// Future<void> onStart(ServiceInstance service) async {
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // bring to foreground
//   Timer.periodic(const Duration(seconds: 1), (timer) async {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         flutterLocalNotificationsPlugin.show(
//           notificationId,
//           'COOL SERVICE',
//           'Awesome ${DateTime.now()}',
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               notificationChannelId,
//               'MY FOREGROUND SERVICE',
//               icon: 'ic_bg_service_small',
//               ongoing: true,
//             ),
//           ),
//         );
//       }
//     }
//   });
// }
