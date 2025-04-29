import 'package:flutter/material.dart';
import 'bluetooth_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepCue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothScannerPage(),
    );
  }
}

class BluetoothScannerPage extends StatefulWidget {
  const BluetoothScannerPage({super.key});

  @override
  State<BluetoothScannerPage> createState() => _BluetoothScannerPageState();
}

class _BluetoothScannerPageState extends State<BluetoothScannerPage> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  bool _isScanning = false;
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    await _bluetoothManager.initialize();
    _bluetoothManager.deviceStream.listen((devices) {
      setState(() {
        _devices = devices;
      });
    });
  }

  void _toggleScan() async {
    if (_isScanning) {
      await _bluetoothManager.stopScan();
    } else {
      await _bluetoothManager.startScan();
    }
    
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StepCue'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _isScanning ? 'Scanning for devices...' : 'Not scanning',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: _devices.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                        subtitle: Text(device.id),
                        trailing: const Icon(Icons.bluetooth),
                        onTap: () {
                          // Handle device selection
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleScan,
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}