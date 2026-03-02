import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../data/models/responses/user_model.dart';

// ============================================
// Profile Content Panel
// ============================================
class ProfileContentPanel extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileContentPanel({super.key, this.onProfileUpdated});

  @override
  State<ProfileContentPanel> createState() => _ProfileContentPanelState();
}

class _ProfileContentPanelState extends State<ProfileContentPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserModel? _user;
  bool _isLoading = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthLocalDatasource().getUser();
    if (mounted && user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthRemoteDatasource().updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      result.fold(
        (error) {
          if (mounted) context.showErrorSnackBar(error);
        },
        (user) async {
          await AuthLocalDatasource().saveUser(user);
          if (mounted) {
            setState(() => _user = user);
            context.showSnackBar('Profil berhasil diperbarui');
            widget.onProfileUpdated?.call();
          }
        },
      );
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      context.showErrorSnackBar('Konfirmasi password tidak cocok');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      context.showErrorSnackBar('Password minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthRemoteDatasource().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      result.fold(
        (error) => context.showErrorSnackBar(error),
        (message) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          setState(() => _isChangingPassword = false);
          context.showSnackBar(message);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Profil Saya'),
          const SizedBox(height: 24),

          // Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _user?.name.isNotEmpty == true
                        ? _user!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _user?.name ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getRoleLabel(_user?.role),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Profile form
          Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Profil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        suffixIcon: Icon(Icons.lock_outline, size: 18),
                      ),
                      readOnly: true,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'No. Telepon (Opsional)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Change password section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ubah Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (!_isChangingPassword)
                        TextButton(
                          onPressed: () {
                            setState(() => _isChangingPassword = true);
                          },
                          child: const Text('Ubah'),
                        ),
                    ],
                  ),
                  if (_isChangingPassword) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password Saat Ini',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureCurrentPassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureNewPassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _currentPasswordController.clear();
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();
                              setState(() => _isChangingPassword = false);
                            },
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Klik "Ubah" untuk mengubah password Anda',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'owner':
        return 'Pemilik';
      case 'cashier':
        return 'Kasir';
      default:
        return 'User';
    }
  }
}

// ============================================
// Store Content Panel
// ============================================
class StoreContentPanel extends StatefulWidget {
  const StoreContentPanel({super.key});

  @override
  State<StoreContentPanel> createState() => _StoreContentPanelState();
}

class _StoreContentPanelState extends State<StoreContentPanel> {
  StoreModel? _store;
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    // First load from local storage for quick display
    final localUser = await AuthLocalDatasource().getUser();
    if (mounted) {
      setState(() {
        _user = localUser;
        _store = localUser?.store;
      });
    }

    // Then fetch fresh data from API
    final result = await AuthRemoteDatasource().getMe();
    result.fold(
      (error) {
        // If API fails, just use local data
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      (user) async {
        // Update local storage with fresh data
        await AuthLocalDatasource().saveUser(user);
        if (mounted) {
          setState(() {
            _user = user;
            _store = user.store;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_store == null) {
      return _buildNoStoreInfo();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Informasi Toko'),
          const SizedBox(height: 24),
          _buildStoreHeader(),
          const SizedBox(height: 16),
          _buildStoreDetails(),
          if (_user?.role != 'admin' && _user?.role != 'owner') ...[
            const SizedBox(height: 24),
            _buildInfoBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildNoStoreInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Toko',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Akun Anda belum terhubung dengan toko',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.store,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                _store?.name ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreDetails() {
    return Card(
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'ID Toko',
            value: '${_store?.id ?? '-'}',
          ),
          const Divider(height: 1),
          _buildInfoRow(
            icon: Icons.store_outlined,
            label: 'Nama Toko',
            value: _store?.name ?? '-',
          ),
          const Divider(height: 1),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: _store?.address ?? 'Belum diatur',
          ),
          const Divider(height: 1),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Telepon',
            value: _store?.phone ?? 'Belum diatur',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hubungi admin untuk mengubah informasi toko',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.info.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Printer Content Panel
// ============================================
class PrinterContentPanel extends StatefulWidget {
  const PrinterContentPanel({super.key});

  @override
  State<PrinterContentPanel> createState() => _PrinterContentPanelState();
}

class _PrinterContentPanelState extends State<PrinterContentPanel> {
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
    _connectionSubscription = _printerService.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          _isConnecting = state == PrinterConnectionState.connecting;
          _isConnected = state == PrinterConnectionState.connected;
          _isScanning = state == PrinterConnectionState.scanning;
        });
      }
    });

    _savedPrinter = await _printerService.getSavedPrinter();
    _isConnected = await _printerService.checkConnection();

    if (mounted) setState(() {});
    await _scanDevices();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final results = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();
      return results.values.every((s) => s.isGranted || s.isLimited);
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _scanDevices() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    final isOn = await _printerService.isBluetoothAvailable();
    if (!isOn) {
      if (mounted) {
        context.showErrorSnackBar('Bluetooth tidak aktif');
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

  Future<void> _onSwitchChanged(BluetoothInfo device, bool value) async {
    if (value) {
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

  Future<void> _printTestPage() async {
    setState(() => _isPrinting = true);
    final success = await _printerService.printTestPage();
    if (mounted) {
      setState(() => _isPrinting = false);
      if (success) {
        context.showSnackBar('Test print berhasil');
      } else {
        context.showErrorSnackBar('Gagal print');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildConnectionStatus(),
        if (_savedPrinter != null) _buildSavedPrinter(),
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
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Printer',
                  style: TextStyle(fontSize: 12, color: statusColor),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.print, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Printer Tersimpan',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
              ],
            ),
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
        ],
      ),
    );
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

// ============================================
// Receipt Content Panel
// ============================================
class ReceiptContentPanel extends StatefulWidget {
  const ReceiptContentPanel({super.key});

  @override
  State<ReceiptContentPanel> createState() => _ReceiptContentPanelState();
}

class _ReceiptContentPanelState extends State<ReceiptContentPanel> {
  final _headerController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _footerController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _showLogo = true;
  bool _showAddress = true;
  bool _showPhone = true;
  bool _showCashier = true;
  bool _showDateTime = true;
  bool _showThankYou = true;
  String _paperSize = '58mm';
  String? _logoPath;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _headerController.text = prefs.getString('receipt_header') ?? 'APOTEK SEHAT';
        _addressController.text = prefs.getString('store_address') ?? '';
        _phoneController.text = prefs.getString('store_phone') ?? '';
        _footerController.text = prefs.getString('receipt_footer') ?? 'Terima kasih atas kunjungan Anda';
        _showLogo = prefs.getBool('receipt_show_logo') ?? true;
        _showAddress = prefs.getBool('receipt_show_address') ?? true;
        _showPhone = prefs.getBool('receipt_show_phone') ?? true;
        _showCashier = prefs.getBool('receipt_show_cashier') ?? true;
        _showDateTime = prefs.getBool('receipt_show_datetime') ?? true;
        _showThankYou = prefs.getBool('receipt_show_thankyou') ?? true;
        _paperSize = prefs.getString('receipt_paper_size') ?? '58mm';
        _logoPath = prefs.getString('receipt_logo_path');
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('receipt_header', _headerController.text);
    await prefs.setString('store_address', _addressController.text);
    await prefs.setString('store_phone', _phoneController.text);
    await prefs.setString('receipt_footer', _footerController.text);
    await prefs.setBool('receipt_show_logo', _showLogo);
    await prefs.setBool('receipt_show_address', _showAddress);
    await prefs.setBool('receipt_show_phone', _showPhone);
    await prefs.setBool('receipt_show_cashier', _showCashier);
    await prefs.setBool('receipt_show_datetime', _showDateTime);
    await prefs.setBool('receipt_show_thankyou', _showThankYou);
    await prefs.setString('receipt_paper_size', _paperSize);
    if (_logoPath != null) {
      await prefs.setString('receipt_logo_path', _logoPath!);
    } else {
      await prefs.remove('receipt_logo_path');
    }

    if (mounted) {
      setState(() => _isSaving = false);
      context.showSnackBar('Pengaturan struk berhasil disimpan');
    }
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 85,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final logoDir = Directory('${appDir.path}/logo');
        if (!await logoDir.exists()) {
          await logoDir.create(recursive: true);
        }

        final fileName = 'receipt_logo_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedPath = '${logoDir.path}/$fileName';

        await File(image.path).copy(savedPath);

        setState(() {
          _logoPath = savedPath;
        });

        if (mounted) {
          context.showSnackBar('Logo berhasil dipilih');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Gagal memilih logo: $e');
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _logoPath = null;
    });
    context.showSnackBar('Logo dihapus');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengaturan Struk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Header Struk'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _headerController,
                          decoration: const InputDecoration(
                            labelText: 'Judul/Nama Toko',
                            hintText: 'APOTEK SEHAT',
                            prefixIcon: Icon(Icons.title),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Alamat Toko',
                            hintText: 'Jl. Kesehatan No. 123, Jakarta',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon',
                            hintText: '021-1234567',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchTile(
                          title: 'Tampilkan Logo',
                          subtitle: 'Logo toko di bagian atas struk',
                          value: _showLogo,
                          onChanged: (v) => setState(() => _showLogo = v),
                        ),
                        if (_showLogo) ...[
                          const SizedBox(height: 12),
                          _buildLogoUploader(),
                        ],
                        _buildSwitchTile(
                          title: 'Tampilkan Alamat',
                          subtitle: 'Alamat toko di header',
                          value: _showAddress,
                          onChanged: (v) => setState(() => _showAddress = v),
                        ),
                        _buildSwitchTile(
                          title: 'Tampilkan Telepon',
                          subtitle: 'Nomor telepon toko',
                          value: _showPhone,
                          onChanged: (v) => setState(() => _showPhone = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Konten Struk'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Tampilkan Nama Kasir',
                          subtitle: 'Nama kasir yang melayani',
                          value: _showCashier,
                          onChanged: (v) => setState(() => _showCashier = v),
                        ),
                        _buildSwitchTile(
                          title: 'Tampilkan Tanggal & Waktu',
                          subtitle: 'Tanggal dan jam transaksi',
                          value: _showDateTime,
                          onChanged: (v) => setState(() => _showDateTime = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Footer Struk'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _footerController,
                          decoration: const InputDecoration(
                            labelText: 'Pesan Footer',
                            hintText: 'Terima kasih atas kunjungan Anda',
                            prefixIcon: Icon(Icons.message_outlined),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        _buildSwitchTile(
                          title: 'Tampilkan Ucapan Terima Kasih',
                          subtitle: 'Pesan di bagian bawah struk',
                          value: _showThankYou,
                          onChanged: (v) => setState(() => _showThankYou = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Ukuran Kertas'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildRadioTile(
                          title: '58mm (Standar)',
                          subtitle: 'Cocok untuk printer thermal 58mm',
                          value: '58mm',
                          groupValue: _paperSize,
                          onChanged: (v) => setState(() => _paperSize = v ?? '58mm'),
                        ),
                        const Divider(),
                        _buildRadioTile(
                          title: '80mm (Lebar)',
                          subtitle: 'Cocok untuk printer thermal 80mm',
                          value: '80mm',
                          groupValue: _paperSize,
                          onChanged: (v) => setState(() => _paperSize = v ?? '80mm'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoUploader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: _logoPath != null && File(_logoPath!).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_logoPath!),
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Icon(
                        Icons.local_pharmacy,
                        size: 40,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Logo Toko',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Format: PNG/JPG, ukuran maks 300x300px',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickLogo,
                            icon: const Icon(Icons.upload, size: 16),
                            label: Text(
                              _logoPath != null ? 'Ganti' : 'Upload',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        if (_logoPath != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _removeLogo,
                            icon: const Icon(Icons.delete_outline),
                            iconSize: 20,
                            color: AppColors.error,
                            tooltip: 'Hapus logo',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.info,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips: Gunakan logo dengan background putih atau transparan untuk hasil cetak terbaik pada printer thermal.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// About Content Panel
// ============================================
class AboutContentPanel extends StatelessWidget {
  const AboutContentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_pharmacy,
              size: 50,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Apotek POS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Point of Sale untuk Apotek',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                _buildInfoItem(
                  icon: Icons.info_outline,
                  label: 'Versi Aplikasi',
                  value: '1.0.0',
                ),
                const Divider(height: 1),
                _buildInfoItem(
                  icon: Icons.build_outlined,
                  label: 'Build Number',
                  value: '1',
                ),
                const Divider(height: 1),
                _buildInfoItem(
                  icon: Icons.phone_android,
                  label: 'Platform',
                  value: 'Flutter',
                ),
                const Divider(height: 1),
                _buildInfoItem(
                  icon: Icons.storage_outlined,
                  label: 'Backend',
                  value: 'Laravel',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(Icons.point_of_sale, 'Point of Sale'),
                  _buildFeatureItem(Icons.inventory_2, 'Manajemen Produk'),
                  _buildFeatureItem(Icons.people, 'Manajemen Pelanggan'),
                  _buildFeatureItem(Icons.access_time, 'Manajemen Shift'),
                  _buildFeatureItem(Icons.receipt_long, 'Riwayat Transaksi'),
                  _buildFeatureItem(Icons.bar_chart, 'Laporan Penjualan'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '© ${DateTime.now().year} Apotek POS',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
