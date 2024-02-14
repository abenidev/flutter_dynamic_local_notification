import 'package:flutter/material.dart';
import 'package:workman_flutter/constants/app_strings.dart';
import 'package:workman_flutter/helpers/local_notifications.dart';
import 'package:workman_flutter/screens/home_screen.dart';
import 'package:workmanager/workmanager.dart';

//
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(
    (task, inputData) {
      debugPrint("Native called background task: $task");
      switch (task) {
        case simpleNotifTaskName:
          LocalNotificationshelper.showSimpleNotification(
            id: 4,
            title: 'notification from bg work',
            body: 'a simple notification shown from background worker',
            payload: 'payload',
          );
          break;
        case scheduledNotifTaskName:
          LocalNotificationshelper.showScheduledNotification(
            id: 6,
            title: 'scheduled notif from bg work',
            body: 'notification shown from background worker scheduled after 60 sec from workman run',
            payload: 'payload',
            delaySecond: 60,
          );
          break;
      }
      return Future.value(true);
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  //local notifications
  await LocalNotificationshelper.configureLocalTimeZone();
  await LocalNotificationshelper.init();
  await LocalNotificationshelper.isAndroidPermissionGranted();
  await LocalNotificationshelper.requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workman Flutter',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
