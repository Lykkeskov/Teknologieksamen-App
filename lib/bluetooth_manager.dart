import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as mobile_ble;
import 'package:win_ble/win_ble.dart' as win_ble;
import 'package:win_ble/win_file.dart';

class BluetoothDevice {
  final String id;
  final String name;

  BluetoothDevice({required this.id, required this.name});
}

class BluetoothManager {
  bool _isInitialized = false;
  bool _isScanning = false;
  
  final List<BluetoothDevice> _discoveredDevices = [];
  final _deviceStreamController = StreamController<List<BluetoothDevice>>.broadcast();
  
  Stream<List<BluetoothDevice>> get deviceStream => _deviceStreamController.stream;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (Platform.isWindows) {
      try {
        // Get proper server path for Windows BLE
        final serverPath = await WinFile.getFileFromAsset('winble/winble.exe');
        
        // Initialize Windows BLE with server path
        await win_ble.WinBle.initialize(serverPath: serverPath);
        _setupWindowsListeners();
        _isInitialized = true;
        print('Windows BLE initialized successfully');
      } catch (e) {
        print('Error initializing Windows BLE: $e');
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      try {
        _setupMobileListeners();
        _isInitialized = true;
        print('Mobile BLE initialized successfully');
      } catch (e) {
        print('Error initializing Mobile BLE: $e');
      }
    } else {
      print('Bluetooth not supported on this platform');
    }
  }
  
  void _setupWindowsListeners() {
    // Listen for scan results
    win_ble.WinBle.scanResult.listen((device) {
      final newDevice = BluetoothDevice(
        id: device.address,
        name: device.name.isNotEmpty ? device.name : 'Unknown Device',
      );
      
      // Check if device already exists in our list
      final existingIndex = _discoveredDevices.indexWhere((d) => d.id == newDevice.id);
      if (existingIndex >= 0) {
        _discoveredDevices[existingIndex] = newDevice;
      } else {
        _discoveredDevices.add(newDevice);
      }
      
      _deviceStreamController.add(_discoveredDevices);
      print('Found Windows device: ${newDevice.name}, ${newDevice.id}');
    });
  }
  
  void _setupMobileListeners() {
    mobile_ble.FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        final newDevice = BluetoothDevice(
          id: result.device.id.toString(),
          name: result.device.name.isNotEmpty ? result.device.name : 'Unknown Device',
        );
        
        // Check if device already exists in our list
        final existingIndex = _discoveredDevices.indexWhere((d) => d.id == newDevice.id);
        if (existingIndex >= 0) {
          _discoveredDevices[existingIndex] = newDevice;
        } else {
          _discoveredDevices.add(newDevice);
        }
        
        print('Found Mobile device: ${newDevice.name}, ${newDevice.id}');
      }
      
      _deviceStreamController.add(_discoveredDevices);
    });
  }
  
  Future<void> startScan() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_isScanning) return;
    
    _isScanning = true;
    
    if (Platform.isWindows) {
      await _startWindowsScan();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _startMobileScan();
    }
  }
  
  Future<void> stopScan() async {
    if (!_isScanning) return;
    
    _isScanning = false;
    
    if (Platform.isWindows) {
      await _stopWindowsScan();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await mobile_ble.FlutterBluePlus.stopScan();
    }
  }
  
  Future<void> _startWindowsScan() async {
    try {
      // For Win_BLE, we scan by specific method:
      await win_ble.WinBle.startScanning();
      print('Windows BLE scan started');
    } catch (e) {
      print('Error starting Windows BLE scan: $e');
      _isScanning = false;
    }
  }
  
  Future<void> _stopWindowsScan() async {
    try {
      await win_ble.WinBle.stopScanning();
      print('Windows BLE scan stopped');
    } catch (e) {
      print('Error stopping Windows BLE scan: $e');
    }
  }
  
  Future<void> _startMobileScan() async {
    try {
      // Check Bluetooth availability
      if (await mobile_ble.FlutterBluePlus.isOn == false) {
        print('Bluetooth is turned off');
        _isScanning = false;
        return;
      }
      
      // Start scanning
      await mobile_ble.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
      print('Mobile BLE scan started');
    } catch (e) {
      print('Error starting Mobile BLE scan: $e');
      _isScanning = false;
    }
  }
  
  void dispose() {
    stopScan();
    _deviceStreamController.close();
  }
}