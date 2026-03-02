import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/services/printer_service.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final PrinterService _printerService = PrinterService();

  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _savedPrinter;
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isPrinting = false;

  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    // Listen to connection state
    _connectionSubscription = _printerService.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          _isConnecting = state == PrinterConnectionState.connecting;
          _isConnected = state == PrinterConnectionState.connected;
          _isScanning = state == PrinterConnectionState.scanning;
        });
      }
    });

    // Load saved printer
    _savedPrinter = await _printerService.getSavedPrinter();

    // Check current connection
    _isConnected = await _printerService.checkConnection();

    if (mounted) {
      setState(() {});
    }

    // Auto scan devices
    await _scanDevices();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request bluetooth permissions for Android
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      final allGranted = results.values.every(
        (status) => status.isGranted || status.isLimited,
      );

      if (!allGranted && mounted) {
        _showPermissionDialog();
        return false;
      }
      return allGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      if (!status.isGranted && mounted) {
        _showPermissionDialog();
        return false;
      }
      return status.isGranted;
    }
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Diperlukan'),
        content: const Text(
          'Untuk menggunakan printer Bluetooth, aplikasi memerlukan izin Bluetooth dan Lokasi.\n\n'
          'Silakan buka Pengaturan dan izinkan akses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanDevices() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    // Check if bluetooth is on
    final isOn = await _printerService.isBluetoothAvailable();
    if (!isOn) {
      if (mounted) {
        _showBluetoothOffDialog();
      }
      return;
    }

    setState(() {
      _isScanning = true;
      _devices = [];
    });

    final devices = await _printerService.getPairedDevices();

    if (mounted) {
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    }
  }

  void _showBluetoothOffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Bluetooth Mati'),
          ],
        ),
        content: const Text(
          'Bluetooth tidak aktif. Silakan aktifkan Bluetooth untuk mencari printer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnectPrinter() async {
    await _printerService.disconnect();

    if (mounted) {
      setState(() {
        _isConnected = false;
      });
      context.showSnackBar('Printer terputus');
    }
  }

  Future<void> _removeSavedPrinter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Printer Tersimpan?'),
        content: const Text(
          'Printer tidak akan terhubung otomatis saat aplikasi dibuka.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _printerService.removeSavedPrinter();
      if (mounted) {
        setState(() {
          _savedPrinter = null;
          _isConnected = false;
        });
        context.showSnackBar('Printer tersimpan dihapus');
      }
    }
  }

  Future<void> _printTestPage() async {
    setState(() => _isPrinting = true);

    final success = await _printerService.printTestPage();

    if (mounted) {
      setState(() => _isPrinting = false);

      if (success) {
        context.showSnackBar('Test print berhasil');
      } else {
        context.showErrorSnackBar('Gagal print. Pastikan printer terhubung.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Connection status
          _buildConnectionStatus(),

          // Saved printer
          if (_savedPrinter != null) _buildSavedPrinter(),

          // Scan button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isScanning ? null : _scanDevices,
                icon: _isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(_isScanning ? 'Mencari...' : 'Cari Perangkat Bluetooth'),
              ),
            ),
          ),

          // Device list
          Expanded(
            child: _devices.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return _buildDeviceItem(device);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final Color statusColor;
    final String statusText;
    final IconData statusIcon;

    if (_isConnecting) {
      statusColor = AppColors.warning;
      statusText = 'Menghubungkan...';
      statusIcon = Icons.bluetooth_searching;
    } else if (_isConnected) {
      statusColor = AppColors.success;
      statusText = 'Terhubung ke ${_printerService.connectedDevice?.name ?? 'Printer'}';
      statusIcon = Icons.bluetooth_connected;
    } else {
      statusColor = AppColors.grey;
      statusText = 'Tidak terhubung';
      statusIcon = Icons.bluetooth_disabled;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: statusColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Printer',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (_isConnected) ...[
            IconButton(
              onPressed: _isPrinting ? null : _printTestPage,
              icon: _isPrinting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print),
              tooltip: 'Test Print',
            ),
            IconButton(
              onPressed: _disconnectPrinter,
              icon: const Icon(Icons.link_off),
              tooltip: 'Putuskan',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedPrinter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.print,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Printer Tersimpan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _savedPrinter?.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _savedPrinter?.macAdress ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _removeSavedPrinter,
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            tooltip: 'Hapus',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada perangkat ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pastikan printer sudah dipasangkan\ndi pengaturan Bluetooth perangkat Anda',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _scanDevices,
            icon: const Icon(Icons.refresh),
            label: const Text('Cari Ulang'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSwitchChanged(BluetoothInfo device, bool value) async {
    if (value) {
      // Turn ON - Connect and save
      setState(() => _isConnecting = true);

      final success = await _printerService.connect(device);

      if (mounted) {
        setState(() {
          _isConnecting = false;
          if (success) {
            _savedPrinter = device;
            _isConnected = true;
          }
        });

        if (success) {
          context.showSnackBar('Printer ${device.name} dipilih dan tersimpan');
        } else {
          context.showErrorSnackBar('Gagal terhubung ke ${device.name}');
        }
      }
    } else {
      // Turn OFF - Disconnect and remove
      await _printerService.removeSavedPrinter();

      if (mounted) {
        setState(() {
          _savedPrinter = null;
          _isConnected = false;
        });
        context.showSnackBar('Printer ${device.name} dilepas');
      }
    }
  }

  Widget _buildDeviceItem(BluetoothInfo device) {
    final isSelected = _savedPrinter?.macAdress == device.macAdress;
    final isCurrentlyConnected =
        _printerService.connectedDevice?.macAdress == device.macAdress &&
            _isConnected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Printer icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.greyLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.print,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
            ),
            const SizedBox(width: 16),

            // Device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name.isEmpty ? 'Unknown Device' : device.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.macAdress,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  if (isCurrentlyConnected) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Terhubung',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Switch
            if (_isConnecting && isSelected)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Switch(
                value: isSelected,
                onChanged: _isConnecting
                    ? null
                    : (value) => _onSwitchChanged(device, value),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
