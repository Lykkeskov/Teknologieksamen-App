import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  final scanResults = <ScanResult>[].obs;
  bool isScanning = false;

  // This Function will help users to scan nearby BLE devices and get the list of Bluetooth devices.
  Future<void> scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {

      try {
        // Clear previous results
        scanResults.clear();
        update();

        // Check if already scanning
        isScanning = await FlutterBluePlus.isScanning.first;
        if (isScanning) {
          await FlutterBluePlus.stopScan();
        }

        // Listen for scan results
        FlutterBluePlus.scanResults.listen((results) {
          scanResults.value = results;
          update(); // Update GetX state
        });

        // Start scanning
        await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));

        // Make sure to stop scan after timeout
        Future.delayed(Duration(seconds: 15), () async {
          isScanning = await FlutterBluePlus.isScanning.first;
          if (isScanning) {
            await FlutterBluePlus.stopScan();
          }
        });
      } catch (e) {
        print("Error scanning: $e");
      }
    } else {
      print("Bluetooth or location permissions not granted");
    }
  }

  // This function will help user to connect to BLE devices.
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Stop scanning before connecting
      isScanning = await FlutterBluePlus.isScanning.first;
      if (isScanning) {
        await FlutterBluePlus.stopScan();
      }

      // Connect to device
      await device.connect();

      // Listen for connection state changes
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connecting) {
          print("Device connecting to: ${device.platformName}");
        } else if (state == BluetoothConnectionState.connected) {
          print("Device connected: ${device.platformName}");
          // Discover services once connected
          discoverServices(device);
        } else if (state == BluetoothConnectionState.disconnected) {
          print("Device Disconnected");
        }
      });
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  // Discover services on the connected device
  Future<void> discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        print("Service found: ${service.uuid}");
        // You can further process characteristics here
        for (var characteristic in service.characteristics) {
          print("Characteristic found: ${characteristic.uuid}");
        }
      }
    } catch (e) {
      print("Error discovering services: $e");
    }
  }

  // Disconnect from device
  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      print("Error disconnecting: $e");
    }
  }

  // Get current scan results stream
  Stream<List<ScanResult>> get scanResultsStream => FlutterBluePlus.scanResults;

  @override
  void onClose() {
    // Stop scanning when controller is closed
    FlutterBluePlus.stopScan();
    super.onClose();
  }
}