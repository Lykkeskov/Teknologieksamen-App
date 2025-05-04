import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'control_page.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  void startScan() async {
    setState(() {
      scanResults.clear();
      isScanning = true;
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    // Lyt til resultater i stedet for at bruge listen direkte på startScan
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    // Stop scanning efter timeout
    Future.delayed(const Duration(seconds: 4), () {
      FlutterBluePlus.stopScan();
      setState(() {
        isScanning = false;
      });
    });
  }


  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Forbundet til ${device.name.isNotEmpty ? device.name : device.id}')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ControlPage(device: device)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunne ikke oprette forbindelse: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth-enheder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isScanning ? null : startScan,
          ),
        ],
      ),
      body: isScanning && scanResults.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (context, index) {
          final result = scanResults[index];
          return ListTile(
            title: Text(result.device.name.isNotEmpty
                ? result.device.name
                : 'Ukendt enhed'),
            subtitle: Text(result.device.id.toString()),
            trailing: const Icon(Icons.bluetooth),
              onTap: () async {
                await FlutterBluePlus.stopScan();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text("Forbinder til enhed..."),
                      ],
                    ),
                  ),
                );

                try {
                  await result.device.connect(timeout: const Duration(seconds: 10));
                } catch (e) {
                  // Ignorer fejl hvis allerede forbundet
                  if (e.toString().contains('already connected') == false) {
                    Navigator.pop(context); // Luk loading-dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kunne ikke forbinde: $e')),
                    );
                    return;
                  }
                }

                Navigator.pop(context); // Luk loading-dialog

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ControlPage(device: result.device),
                  ),
                );
              }
          );
        },
      ),
    );
  }
}
