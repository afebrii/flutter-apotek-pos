import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';

class ReceiptSettingsPage extends StatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  State<ReceiptSettingsPage> createState() => _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends State<ReceiptSettingsPage> {
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
        _headerController.text =
            prefs.getString('receipt_header') ?? 'APOTEK SEHAT';
        _addressController.text = prefs.getString('store_address') ?? '';
        _phoneController.text = prefs.getString('store_phone') ?? '';
        _footerController.text =
            prefs.getString('receipt_footer') ?? 'Terima kasih atas kunjungan Anda';
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
        // Save to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final logoDir = Directory('${appDir.path}/logo');
        if (!await logoDir.exists()) {
          await logoDir.create(recursive: true);
        }

        final fileName = 'receipt_logo_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedPath = '${logoDir.path}/$fileName';

        // Copy file to app directory
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Struk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
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
                : const Text(
                    'Simpan',
                    style: TextStyle(color: AppColors.white),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
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

                  // Content section
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

                  // Footer section
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

                  // Paper size section
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
                            onChanged: (v) =>
                                setState(() => _paperSize = v ?? '58mm'),
                          ),
                          const Divider(),
                          _buildRadioTile(
                            title: '80mm (Lebar)',
                            subtitle: 'Cocok untuk printer thermal 80mm',
                            value: '80mm',
                            groupValue: _paperSize,
                            onChanged: (v) =>
                                setState(() => _paperSize = v ?? '80mm'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preview button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showReceiptPreview(),
                      icon: const Icon(Icons.preview),
                      label: const Text('Pratinjau Struk'),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
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
              // Logo preview
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
              // Upload buttons
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

  void _showReceiptPreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: _paperSize == '58mm' ? 220 : 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              if (_showLogo)
                _logoPath != null && File(_logoPath!).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(_logoPath!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Icon(
                        Icons.local_pharmacy,
                        size: 40,
                        color: AppColors.primary,
                      ),
              const SizedBox(height: 8),
              Text(
                _headerController.text.isEmpty
                    ? 'APOTEK SEHAT'
                    : _headerController.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (_showAddress && _addressController.text.isNotEmpty)
                Text(
                  _addressController.text,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              if (_showPhone && _phoneController.text.isNotEmpty)
                Text(
                  'Telp: ${_phoneController.text}',
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),

              const Divider(height: 16),

              // Transaction info
              if (_showDateTime)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('26/12/2024', style: TextStyle(fontSize: 10)),
                    Text('14:30', style: TextStyle(fontSize: 10)),
                  ],
                ),
              if (_showCashier)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kasir:', style: TextStyle(fontSize: 10)),
                    Text('Admin', style: TextStyle(fontSize: 10)),
                  ],
                ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No:', style: TextStyle(fontSize: 10)),
                  Text('TRX-001', style: TextStyle(fontSize: 10)),
                ],
              ),

              const Divider(height: 16),

              // Sample items
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Paracetamol 500mg',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Text('2x', style: TextStyle(fontSize: 10)),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Rp 10.000', style: TextStyle(fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Vitamin C 1000mg',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Text('1x', style: TextStyle(fontSize: 10)),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Rp 25.000', style: TextStyle(fontSize: 10)),
                ],
              ),

              const Divider(height: 16),

              // Total
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp 35.000',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tunai', style: TextStyle(fontSize: 10)),
                  Text('Rp 50.000', style: TextStyle(fontSize: 10)),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kembali', style: TextStyle(fontSize: 10)),
                  Text('Rp 15.000', style: TextStyle(fontSize: 10)),
                ],
              ),

              if (_showThankYou) ...[
                const Divider(height: 16),
                Text(
                  _footerController.text.isEmpty
                      ? 'Terima kasih atas kunjungan Anda'
                      : _footerController.text,
                  style: const TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
