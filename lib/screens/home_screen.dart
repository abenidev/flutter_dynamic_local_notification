import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workman_flutter/constants/app_strings.dart';
import 'package:workman_flutter/helpers/local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                LocalNotificationshelper.showSimpleNotification(
                  id: 0,
                  title: 'simp',
                  body: 'body',
                  payload: 'payload',
                );
              },
              child: const Text('Simple notif'),
            ),

            const SizedBox(height: 15),

            //
            ElevatedButton(
              onPressed: () {
                Workmanager().registerOneOffTask(simpleNotifTaskId, simpleNotifTaskName);
              },
              child: const Text('Register work now'),
            ),

            const SizedBox(height: 15),

            //
            ElevatedButton(
              onPressed: () {
                Workmanager().registerOneOffTask(simpleNotifTaskId, simpleNotifTaskName, initialDelay: const Duration(seconds: 60));
              },
              child: const Text('Register work after 60 sec'),
            ),

            const SizedBox(height: 15),

            //
            ElevatedButton(
              onPressed: () {
                Workmanager().registerOneOffTask(scheduledNotifTaskId, scheduledNotifTaskName, initialDelay: const Duration(seconds: 60));
              },
              child: const Text('Register work after 60 sec \nand schedule notif after 60 sec'),
            ),
          ],
        ),
      ),
    );
  }
}
