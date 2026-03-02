import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../home/pages/home_page.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      context.showErrorSnackBar('Email dan password harus diisi');
      return;
    }

    context.read<LoginBloc>().add(
          LoginSubmitted(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: isTablet ? AppColors.primary : AppColors.background,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.showSuccessSnackBar('Login berhasil');
            context.pushAndRemoveUntil(
              const HomePage(),
              (route) => false,
            );
          } else if (state is LoginError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: SafeArea(
          child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SpaceHeight(24),

              // Title
              const Text(
                'Apotek POS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(8),
              const Text(
                'Silakan login untuk melanjutkan',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(40),

              // Email field
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Masukkan email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SpaceHeight(16),

              // Password field
              PasswordTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Masukkan password',
                onSubmitted: (_) => _onLogin(),
              ),
              const SpaceHeight(32),

              // Login button
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return Button.filled(
                    onPressed: state is LoginLoading ? null : _onLogin,
                    label: 'Login',
                    icon: Icons.login,
                    isLoading: state is LoginLoading,
                    height: 52,
                  );
                },
              ),
              const SpaceHeight(24),

              // Version info
              const Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 5,
          child: Container(
            color: AppColors.primary,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy,
                        size: 72,
                        color: AppColors.white,
                      ),
                    ),
                    const SpaceHeight(24),
                    const Text(
                      'Apotek POS',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SpaceHeight(8),
                    Text(
                      'Sistem Point of Sale Apotek Modern',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SpaceHeight(32),
                    // Features list
                    _buildFeatureItem(Icons.inventory_2_outlined, 'Manajemen Stok & Batch'),
                    const SpaceHeight(12),
                    _buildFeatureItem(Icons.point_of_sale_outlined, 'Transaksi Cepat & Akurat'),
                    const SpaceHeight(12),
                    _buildFeatureItem(Icons.receipt_long_outlined, 'Laporan Lengkap'),
                    const SpaceHeight(12),
                    _buildFeatureItem(Icons.print_outlined, 'Cetak Struk Bluetooth'),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right side - Login form
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SpaceHeight(8),
                        const Text(
                          'Silakan login untuk melanjutkan ke sistem',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SpaceHeight(48),

                        // Email field
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Masukkan email anda',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        const SpaceHeight(20),

                        // Password field
                        PasswordTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Masukkan password anda',
                          onSubmitted: (_) => _onLogin(),
                        ),
                        const SpaceHeight(36),

                        // Login button
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            return Button.filled(
                              onPressed: state is LoginLoading ? null : _onLogin,
                              label: 'Login',
                              icon: Icons.login,
                              isLoading: state is LoginLoading,
                              height: 56,
                            );
                          },
                        ),
                        const SpaceHeight(32),

                        // Version info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Versi 1.0.0',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
