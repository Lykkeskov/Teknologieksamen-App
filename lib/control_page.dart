import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ControlPage extends StatefulWidget {
  final BluetoothDevice device;

  const ControlPage({Key? key, required this.device}) : super(key: key);

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _listenToConnectionState();
  }

  void _listenToConnectionState() {
    widget.device.connectionState.listen((state) {
      setState(() {
        _connectionState = state;
      });
    });

    widget.device.connectionState.first.then((state) {
      setState(() {
        _connectionState = state;
      });
    });
  }

  Future<void> _disconnect() async {
    try {
      await widget.device.disconnect();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved afbrydelse: $e')),
      );
    }
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnected = _connectionState == BluetoothConnectionState.connected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Styring'),
        actions: [
          if (isConnected)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _disconnect,
              tooltip: 'Afbryd forbindelse',
            )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              size: 80,
              color: isConnected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              isConnected ? 'Forbundet til enhed' : 'Ikke forbundet',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            if (!isConnected)
              ElevatedButton(
                onPressed: () async {
                  try {
                    await widget.device.connect();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kunne ikke forbinde: $e')),
                    );
                  }
                },
                child: const Text("Forbind igen"),
              ),
          ],
        ),
      ),
    );
  }
}
