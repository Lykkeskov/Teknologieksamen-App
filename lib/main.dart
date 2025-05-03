import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';  // Using relative import

void main() async {
  // Initialize Flutter Blue Plus
  WidgetsFlutterBinding.ensureInitialized();

  // Check adapter availability
  try {
    // Wait for Bluetooth to initialize
    await FlutterBluePlus.adapterState.first;
  } catch (e) {
    print("Error initializing Bluetooth: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // Changed to GetMaterialApp for GetX
      title: 'BLE Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BleController controller = Get.put(BleController());
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    // Listen to Bluetooth adapter state changes
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        isBluetoothOn = state == BluetoothAdapterState.on;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE SCANNER"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GetBuilder<BleController>(
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bluetooth status indicator
                if (!isBluetoothOn)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bluetooth_disabled, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Bluetooth is turned off",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Stream builder for scan results
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResultsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data![index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                title: Text(data.device.platformName.isNotEmpty
                                    ? data.device.platformName
                                    : "Unknown Device"),
                                subtitle: Text(data.device.remoteId.toString()),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${data.rssi} dBm"),
                                    Icon(Icons.signal_cellular_alt,
                                        color: _getSignalColor(data.rssi)),
                                  ],
                                ),
                                onTap: () => controller.connectToDevice(data.device),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bluetooth_searching,
                                  size: 80,
                                  color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "No Devices Found",
                                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap SCAN button below to search for BLE devices",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),

                // Scan button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton.icon(
                    onPressed: isBluetoothOn
                        ? () => controller.scanDevices()
                        : null,  // Disable button if Bluetooth is off
                    icon: Icon(Icons.bluetooth_searching),
                    label: Text("SCAN FOR DEVICES"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to color-code signal strength
  Color _getSignalColor(int rssi) {
    if (rssi >= -70) return Colors.green;
    if (rssi >= -85) return Colors.orange;
    return Colors.red;
  }
}