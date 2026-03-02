import 'dart:async';
import 'dart:convert';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  static const String _savedPrinterKey = 'saved_bluetooth_printer';

  BluetoothInfo? _connectedDevice;
  bool _isConnecting = false;
  bool _isConnected = false;

  // Stream controllers
  final _connectionStateController = StreamController<PrinterConnectionState>.broadcast();

  Stream<PrinterConnectionState> get connectionState => _connectionStateController.stream;

  BluetoothInfo? get connectedDevice => _connectedDevice;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  /// Initialize printer service and auto-connect if saved printer exists
  Future<void> initialize() async {
    AppLogger.info('Initializing printer service...', tag: 'PrinterService');
    await autoConnect();
  }

  /// Auto-connect to saved printer
  Future<bool> autoConnect() async {
    final savedPrinter = await getSavedPrinter();
    if (savedPrinter != null) {
      AppLogger.info('Found saved printer: ${savedPrinter.name}', tag: 'PrinterService');
      return await connect(savedPrinter);
    }
    return false;
  }

  /// Check if Bluetooth is available
  Future<bool> isBluetoothAvailable() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      AppLogger.error('PrinterService', error: e);
      return false;
    }
  }

  /// Get paired Bluetooth devices
  Future<List<BluetoothInfo>> getPairedDevices() async {
    AppLogger.info('Getting paired devices...', tag: 'PrinterService');
    _connectionStateController.add(PrinterConnectionState.scanning);

    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      AppLogger.info('Found ${devices.length} paired devices', tag: 'PrinterService');
      _connectionStateController.add(PrinterConnectionState.disconnected);
      return devices;
    } catch (e) {
      AppLogger.error('Get paired devices error', tag: 'PrinterService', error: e);
      _connectionStateController.add(PrinterConnectionState.error);
      return [];
    }
  }

  /// Connect to a Bluetooth device
  Future<bool> connect(BluetoothInfo device) async {
    if (_isConnecting) return false;

    _isConnecting = true;
    _connectionStateController.add(PrinterConnectionState.connecting);
    AppLogger.info('Connecting to ${device.name}...', tag: 'PrinterService');

    try {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );

      if (result) {
        _connectedDevice = device;
        _isConnected = true;
        _connectionStateController.add(PrinterConnectionState.connected);
        await savePrinter(device);
        AppLogger.info('Connected to ${device.name}', tag: 'PrinterService');
        _isConnecting = false;
        return true;
      } else {
        _connectionStateController.add(PrinterConnectionState.error);
        AppLogger.warning('Failed to connect to ${device.name}', tag: 'PrinterService');
        _isConnecting = false;
        return false;
      }
    } catch (e) {
      AppLogger.error('Connect error', tag: 'PrinterService', error: e);
      _connectionStateController.add(PrinterConnectionState.error);
      _isConnecting = false;
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    AppLogger.info('Disconnecting...', tag: 'PrinterService');
    try {
      await PrintBluetoothThermal.disconnect;
      _connectedDevice = null;
      _isConnected = false;
      _connectionStateController.add(PrinterConnectionState.disconnected);
    } catch (e) {
      AppLogger.error('Disconnect error', tag: 'PrinterService', error: e);
    }
  }

  /// Check connection status
  Future<bool> checkConnection() async {
    try {
      _isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!_isConnected) {
        _connectedDevice = null;
        _connectionStateController.add(PrinterConnectionState.disconnected);
      }
      return _isConnected;
    } catch (e) {
      AppLogger.error('Check connection error', tag: 'PrinterService', error: e);
      return false;
    }
  }

  /// Save printer to local storage
  Future<void> savePrinter(BluetoothInfo device) async {
    final prefs = await SharedPreferences.getInstance();
    final printerData = {
      'name': device.name,
      'macAddress': device.macAdress,
    };
    await prefs.setString(_savedPrinterKey, jsonEncode(printerData));
    AppLogger.info('Saved printer: ${device.name}', tag: 'PrinterService');
  }

  /// Get saved printer from local storage
  Future<BluetoothInfo?> getSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final printerJson = prefs.getString(_savedPrinterKey);

    if (printerJson != null) {
      try {
        final data = jsonDecode(printerJson);
        return BluetoothInfo(
          name: data['name'] ?? '',
          macAdress: data['macAddress'] ?? '',
        );
      } catch (e) {
        AppLogger.error('Get saved printer error', tag: 'PrinterService', error: e);
      }
    }
    return null;
  }

  /// Remove saved printer from local storage
  Future<void> removeSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedPrinterKey);
    await disconnect();
    AppLogger.info('Removed saved printer', tag: 'PrinterService');
  }

  /// Get paper size from settings
  Future<PaperSize> _getPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    final paperSize = prefs.getString('receipt_paper_size') ?? '58mm';
    return paperSize == '80mm' ? PaperSize.mm80 : PaperSize.mm58;
  }

  /// Print receipt
  Future<bool> printReceipt({
    required String storeName,
    String? storeAddress,
    String? storePhone,
    String? cashierName,
    required String transactionNo,
    required DateTime transactionDate,
    required List<PrintReceiptItem> items,
    required double subtotal,
    double discount = 0,
    required double total,
    required double paid,
    required double change,
    required String paymentMethod,
    String? customerName,
    String? footerMessage,
  }) async {
    // Check connection first
    final connected = await checkConnection();
    if (!connected) {
      AppLogger.warning('Printer not connected', tag: 'PrinterService');
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final showAddress = prefs.getBool('receipt_show_address') ?? true;
      final showPhone = prefs.getBool('receipt_show_phone') ?? true;
      final showCashier = prefs.getBool('receipt_show_cashier') ?? true;
      final showDateTime = prefs.getBool('receipt_show_datetime') ?? true;
      final showThankYou = prefs.getBool('receipt_show_thankyou') ?? true;
      final customFooter = prefs.getString('receipt_footer') ?? 'Terima kasih atas kunjungan Anda';

      final paperSize = await _getPaperSize();
      final profile = await CapabilityProfile.load();
      final generator = Generator(paperSize, profile);
      List<int> bytes = [];

      // Header - Store name
      bytes += generator.text(
        storeName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      // Address
      if (showAddress && storeAddress != null && storeAddress.isNotEmpty) {
        bytes += generator.text(
          storeAddress,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      // Phone
      if (showPhone && storePhone != null && storePhone.isNotEmpty) {
        bytes += generator.text(
          'Telp: $storePhone',
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.hr();

      // Transaction info
      if (showDateTime) {
        final dateStr = '${transactionDate.day.toString().padLeft(2, '0')}/${transactionDate.month.toString().padLeft(2, '0')}/${transactionDate.year}';
        final timeStr = '${transactionDate.hour.toString().padLeft(2, '0')}:${transactionDate.minute.toString().padLeft(2, '0')}';
        bytes += generator.text('$dateStr  $timeStr');
      }

      bytes += generator.text('No: $transactionNo');

      if (showCashier && cashierName != null && cashierName.isNotEmpty) {
        bytes += generator.text('Kasir: $cashierName');
      }

      if (customerName != null && customerName.isNotEmpty) {
        bytes += generator.text('Pelanggan: $customerName');
      }

      bytes += generator.hr();

      // Items
      for (final item in items) {
        bytes += generator.text(item.name);
        bytes += generator.row([
          PosColumn(
            text: '  ${item.qty}x ${_formatCurrency(item.price)}',
            width: 8,
          ),
          PosColumn(
            text: _formatCurrency(item.subtotal),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.hr();

      // Subtotal
      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 6),
        PosColumn(
          text: _formatCurrency(subtotal),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Discount
      if (discount > 0) {
        bytes += generator.row([
          PosColumn(text: 'Diskon', width: 6),
          PosColumn(
            text: '-${_formatCurrency(discount)}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      // Total
      bytes += generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: _formatCurrency(total),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      // Payment
      bytes += generator.row([
        PosColumn(text: paymentMethod, width: 6),
        PosColumn(
          text: _formatCurrency(paid),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Change
      bytes += generator.row([
        PosColumn(text: 'Kembali', width: 6),
        PosColumn(
          text: _formatCurrency(change),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Footer
      if (showThankYou) {
        bytes += generator.hr();
        bytes += generator.text(
          footerMessage ?? customFooter,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      // Cut
      bytes += generator.feed(3);
      bytes += generator.cut();

      // Print
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      AppLogger.info('Receipt printed: $result', tag: 'PrinterService');
      return result;
    } catch (e) {
      AppLogger.error('Print receipt error', tag: 'PrinterService', error: e);
      return false;
    }
  }

  /// Print test page
  Future<bool> printTestPage() async {
    final connected = await checkConnection();
    if (!connected) return false;

    try {
      final paperSize = await _getPaperSize();
      final profile = await CapabilityProfile.load();
      final generator = Generator(paperSize, profile);
      List<int> bytes = [];

      bytes += generator.text(
        'TEST PRINT',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.hr();
      bytes += generator.text(
        'Apotek POS',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Printer Connected!',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      final now = DateTime.now();
      bytes += generator.text(
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.feed(3);
      bytes += generator.cut();

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      AppLogger.info('Test page printed: $result', tag: 'PrinterService');
      return result;
    } catch (e) {
      AppLogger.error('Print test page error', tag: 'PrinterService', error: e);
      return false;
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  void dispose() {
    _connectionStateController.close();
  }
}

/// Printer connection states
enum PrinterConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// Receipt item model
class PrintReceiptItem {
  final String name;
  final int qty;
  final double price;
  final double subtotal;

  PrintReceiptItem({
    required this.name,
    required this.qty,
    required this.price,
    required this.subtotal,
  });
}
