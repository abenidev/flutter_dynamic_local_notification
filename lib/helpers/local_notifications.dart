import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class LocalNotificationshelper {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //permissions

  static Future<bool> isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted =
          await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;

      return granted;
    }
    return false;
  }

  static Future<bool> requestExactAlarmPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final bool? isExactAlarmPermissionEnabled = await androidImplementation?.requestExactAlarmsPermission();

    return isExactAlarmPermissionEnabled ?? false;
  }

  static Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return true;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission = await androidImplementation?.requestNotificationsPermission();

      return grantedNotificationPermission ?? false;
    } else {
      return false;
    }
  }

  //init localTimezones
  static Future<void> configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  //initialize the plugin
  static Future init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        onNotificationTap(notificationResponse);
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            // selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            // if (notificationResponse.actionId == navigationActionId) {
            // selectNotificationStream.add(notificationResponse.payload);
            // }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  //ontap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    debugPrint('${notificationResponse.id} || ${notificationResponse.payload}');
  }

  //show simple notification
  static Future showSimpleNotification({required int id, required String title, required String body, required String payload}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'simple notification',
      'Simple Notification',
      channelDescription: 'simple notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  //show periodic notification
  static Future showPeriodicNotification({required int id, required String title, required String body, required String payload}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'periodic notification',
      'Periodic Notification',
      channelDescription: 'Periodic notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
    );
  }

  //schedule notification
  static Future showScheduledNotification({required int id, required String title, required String body, required String payload, int delaySecond = 5}) async {
    tz.Location localTime = tz.local;
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'Zoned Schedule once notification',
      'Zoned Schedule once Notification',
      channelDescription: 'Zoned Schedule once notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(localTime).add(Duration(seconds: delaySecond)),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  //
  static tz.TZDateTime _nextInstanceOfTimeByHour({required int hour, int minute = 0}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //
  static tz.TZDateTime _nextInstanceOfTimeByDayAndHour({required int day, required int hour, int minute = 0}) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTimeByHour(hour: hour, minute: minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //schedule daily notification
  // hour ---> midnight: 0 ----> 23
  static Future showScheduledDailyNotification({required int id, required String title, required String body, required String payload, int hour = 10, int minute = 0}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'Daily notification',
      'Daily Notification',
      channelDescription: 'Daily notifications for your collections',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTimeByHour(hour: hour, minute: minute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  //schedule weekly notification
  // day ---> monday: 1 ---> sunday: 7
  // hour ---> midnight: 0 ----> 23
  static Future showScheduledWeeklyNotification(
      {required int id, required String title, required String body, required String payload, int day = 1, int hour = 10, int minute = 0}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'Weekly notification',
      'Weekly Notification',
      channelDescription: 'Weekly notifications for your collections',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTimeByDayAndHour(day: day, hour: hour, minute: minute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  //cancel Notification by notification id
  static Future cancelNotificationByNotificationId(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  //cancel all notifications
  static Future cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  //
}
