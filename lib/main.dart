// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(BleController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StepCue',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
