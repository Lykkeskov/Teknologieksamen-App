// lib/pages/home_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bluetooth_page.dart';
import 'exercise_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int intervalMinutes = 30;
  String selectedPattern = 'Lang buzz';
  bool timerRunning = false;
  Duration remaining = const Duration(minutes: 25);
  Timer? countdownTimer;

  void toggleTimer() {
    if (timerRunning) {
      countdownTimer?.cancel();
    } else {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remaining.inSeconds > 0) {
            remaining = remaining - const Duration(seconds: 1);
          } else {
            timer.cancel();
            timerRunning = false;
            showExercisePage(); // Når tiden løber ud
          }
        });
      });
    }

    setState(() {
      timerRunning = !timerRunning;
    });
  }

  void showExercisePage() {
    Get.to(() => const ExercisePage());
    setState(() {
      remaining = Duration(minutes: intervalMinutes);
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StepCue'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(() => const BluetoothPage());
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.bluetooth, color: Colors.blue),
                SizedBox(width: 8),
                Text('Forbundet', style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Tid til næste påmindelse', style: TextStyle(fontSize: 18)),
            Text(
              '${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleTimer,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(timerRunning ? 'Stop' : 'Start', style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const ExercisePage());
              },
              icon: const Icon(Icons.directions_walk),
              label: const Text('Vis øvelser'),
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Vibrationsmønster', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ToggleButtons(
              isSelected: [
                selectedPattern == 'Kort buzz',
                selectedPattern == 'Lang buzz',
                selectedPattern == 'Puls buzz',
              ],
              onPressed: (index) {
                setState(() {
                  selectedPattern = ['Kort buzz', 'Lang buzz', 'Puls buzz'][index];
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Kort buzz')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Lang buzz')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Puls buzz')),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Interval', style: TextStyle(fontSize: 18)),
            Slider(
              value: intervalMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$intervalMinutes minutter',
              onChanged: (value) {
                setState(() {
                  intervalMinutes = value.toInt();
                  if (!timerRunning) {
                    remaining = Duration(minutes: intervalMinutes);
                  }
                });
              },
              activeColor: Colors.blue,
            ),
            Text('$intervalMinutes minutter', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
