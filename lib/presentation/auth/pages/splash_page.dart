import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../home/pages/home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Request permissions first
    await _requestPermissions();

    // Initialize printer service (auto-connect)
    await PrinterService().initialize();

    // Check auth
    await _checkAuth();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Bluetooth permissions (Android 12+)
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();
    } else if (Platform.isIOS) {
      // iOS Bluetooth permission
      await Permission.bluetooth.request();
    }
  }

  Future<void> _checkAuth() async {

    if (!mounted) return;

    final isLoggedIn = await AuthLocalDatasource().isLoggedIn();

    if (isLoggedIn) {
      // Validate token with server
      final result = await AuthRemoteDatasource().getMe();
      result.fold(
        (error) {
          // Token invalid, go to login
          _navigateToLogin();
        },
        (user) {
          // Token valid, save user and go to home
          AuthLocalDatasource().saveUser(user);
          _navigateToHome();
        },
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Apotek POS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Point of Sale System',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
