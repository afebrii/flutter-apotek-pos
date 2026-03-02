# Implementation Plan: Apotek POS App

## Overview

Dokumen ini berisi step-by-step implementasi aplikasi Apotek POS menggunakan arsitektur yang sama dengan Flutter Jago POS App. Fokus awal adalah untuk tampilan **Phone** dengan dukungan responsif untuk tablet di masa depan.

### Referensi
- **Arsitektur:** Flutter Jago POS App (`/Users/bahri/development/saasritel/flutter_jago_pos_app`)
- **Backend API:** Apotek Backend (`docs/api-flutter-integration.md`)

### Tech Stack
- **State Management:** Flutter BLoC + Freezed
- **HTTP Client:** http package (sesuai Jago POS) atau Dio
- **Local Storage:** SharedPreferences + SQLite (sqflite)
- **Error Handling:** dartz (Either type)
- **UI:** Material 3 + Google Fonts (Quicksand)

---

## Phase 1: Project Setup & Core Structure

### Step 1.1: Setup Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^9.0.0
  freezed_annotation: ^2.4.4

  # Network
  http: ^1.2.2

  # Local Storage
  shared_preferences: ^2.5.1
  sqflite: ^2.4.2

  # Functional Programming
  dartz: ^0.10.1

  # UI
  flutter_svg: ^2.0.17
  google_fonts: ^6.2.1
  cached_network_image: ^3.4.1

  # Utils
  intl: ^0.20.2
  connectivity_plus: ^6.1.0
  permission_handler: ^11.4.0

  # Hardware (Phase later)
  # print_bluetooth_thermal: ^1.1.6
  # mobile_scanner: ^6.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.8
  json_serializable: ^6.8.0
```

### Step 1.2: Buat Folder Structure

```
lib/
├── core/
│   ├── assets/
│   │   └── assets.dart
│   ├── components/
│   │   ├── buttons.dart
│   │   ├── custom_text_field.dart
│   │   ├── custom_dropdown.dart
│   │   ├── search_input.dart
│   │   ├── spaces.dart
│   │   └── loading_indicator.dart
│   ├── constants/
│   │   ├── colors.dart
│   │   └── variables.dart
│   ├── extensions/
│   │   ├── build_context_ext.dart
│   │   ├── int_ext.dart
│   │   ├── double_ext.dart
│   │   └── string_ext.dart
│   ├── utils/
│   │   ├── app_logger.dart
│   │   └── screen_size.dart
│   └── widgets/
│       └── responsive_layout.dart
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   ├── auth_remote_datasource.dart
│   │   ├── product_remote_datasource.dart
│   │   ├── category_remote_datasource.dart
│   │   ├── customer_remote_datasource.dart
│   │   ├── sale_remote_datasource.dart
│   │   ├── shift_remote_datasource.dart
│   │   ├── dashboard_remote_datasource.dart
│   │   └── db_local_datasource.dart
│   └── models/
│       ├── requests/
│       │   ├── login_request_model.dart
│       │   └── sale_request_model.dart
│       └── responses/
│           ├── auth_response_model.dart
│           ├── user_model.dart
│           ├── product_model.dart
│           ├── category_model.dart
│           ├── customer_model.dart
│           ├── sale_model.dart
│           ├── shift_model.dart
│           └── dashboard_model.dart
├── presentation/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── login/
│   │   │   │   ├── login_bloc.dart
│   │   │   │   ├── login_event.dart
│   │   │   │   └── login_state.dart
│   │   │   └── logout/
│   │   │       ├── logout_bloc.dart
│   │   │       ├── logout_event.dart
│   │   │       └── logout_state.dart
│   │   └── pages/
│   │       ├── splash_page.dart
│   │       └── login_page.dart
│   ├── home/
│   │   ├── bloc/
│   │   │   ├── checkout/
│   │   │   └── online_checker/
│   │   ├── pages/
│   │   │   └── home_page.dart
│   │   └── widgets/
│   │       └── drawer_widget.dart
│   ├── pos/
│   │   ├── bloc/
│   │   │   ├── product/
│   │   │   └── category/
│   │   ├── pages/
│   │   │   └── pos_page.dart
│   │   └── widgets/
│   │       ├── pos_phone_layout.dart
│   │       ├── product_card.dart
│   │       ├── cart_item_widget.dart
│   │       └── category_chip.dart
│   ├── checkout/
│   │   ├── pages/
│   │   │   ├── checkout_page.dart
│   │   │   └── payment_page.dart
│   │   └── widgets/
│   │       └── payment_method_card.dart
│   ├── shift/
│   │   ├── bloc/
│   │   │   ├── shift_bloc.dart
│   │   │   ├── shift_event.dart
│   │   │   └── shift_state.dart
│   │   └── pages/
│   │       └── shift_dialog.dart
│   ├── transaction/
│   │   ├── bloc/
│   │   └── pages/
│   │       ├── transaction_list_page.dart
│   │       └── transaction_detail_page.dart
│   ├── dashboard/
│   │   ├── bloc/
│   │   └── pages/
│   │       └── dashboard_page.dart
│   └── customer/
│       ├── bloc/
│       └── pages/
│           └── customer_page.dart
└── main.dart
```

### Step 1.3: Buat Core Constants

**File: `lib/core/constants/colors.dart`**
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Apotek theme - Green/Medical)
  static const Color primary = Color(0xFF00897B);      // Teal
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  // Secondary Colors
  static const Color secondary = Color(0xFF26A69A);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
  static const Color background = Color(0xFFF5F5F5);

  // Special (Pharmacy)
  static const Color prescription = Color(0xFFE91E63);  // Obat resep
  static const Color lowStock = Color(0xFFFF9800);
  static const Color expired = Color(0xFFF44336);
}
```

**File: `lib/core/constants/variables.dart`**
```dart
class Variables {
  // Base URL - Ganti dengan IP server
  static const String baseUrl = 'http://YOUR_SERVER_IP:8000';
  static const String apiBaseUrl = '$baseUrl/api/v1';

  // Auth
  static const String login = '$apiBaseUrl/login';
  static const String logout = '$apiBaseUrl/logout';
  static const String me = '$apiBaseUrl/me';

  // Dashboard
  static const String dashboardSummary = '$apiBaseUrl/dashboard/summary';
  static const String dashboardLowStock = '$apiBaseUrl/dashboard/low-stock';
  static const String dashboardExpiring = '$apiBaseUrl/dashboard/expiring';

  // Shift
  static const String shiftCurrent = '$apiBaseUrl/shift/current';
  static const String shiftOpen = '$apiBaseUrl/shift/open';
  static const String shiftClose = '$apiBaseUrl/shift/close';

  // Products
  static const String products = '$apiBaseUrl/products';
  static const String productBarcode = '$apiBaseUrl/products/barcode';

  // Categories
  static const String categories = '$apiBaseUrl/categories';

  // Customers
  static const String customers = '$apiBaseUrl/customers';

  // Sales
  static const String sales = '$apiBaseUrl/sales';
}
```

### Step 1.4: Buat Core Utils

**File: `lib/core/utils/screen_size.dart`**
```dart
import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class ScreenSize {
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return DeviceType.phone;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.phone;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return getDeviceType(context) != DeviceType.phone;
  }

  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }

  static int gridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 3, desktop: 4);
  }

  static double fontSize(BuildContext context, {required double base}) {
    final multiplier = responsive<double>(
      context,
      phone: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return base * multiplier;
  }
}
```

**File: `lib/core/utils/app_logger.dart`**
```dart
import 'dart:developer' as developer;

class AppLogger {
  static void info(String message, {String? tag}) {
    developer.log('[INFO] $message', name: tag ?? 'APP');
  }

  static void debug(String message, {String? tag}) {
    developer.log('[DEBUG] $message', name: tag ?? 'APP');
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log('[ERROR] $message', name: tag ?? 'APP', error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag}) {
    developer.log('[WARN] $message', name: tag ?? 'APP');
  }

  static void apiRequest(String method, String url, {dynamic body, String? tag}) {
    developer.log('[API REQUEST] $method $url\nBody: $body', name: tag ?? 'API');
  }

  static void apiResponse(String url, int statusCode, String body, {String? tag}) {
    developer.log('[API RESPONSE] $url\nStatus: $statusCode\nBody: $body', name: tag ?? 'API');
  }
}
```

---

## Phase 2: Authentication Module

### Step 2.1: Buat Auth Response Models

**File: `lib/data/models/responses/user_model.dart`**
```dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final int storeId;
  final StoreModel? store;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.storeId,
    this.store,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      storeId: json['store_id'],
      store: json['store'] != null ? StoreModel.fromJson(json['store']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'store_id': storeId,
    'store': store?.toJson(),
  };
}

class StoreModel {
  final int id;
  final String name;
  final String? address;

  StoreModel({
    required this.id,
    required this.name,
    this.address,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
  };
}
```

**File: `lib/data/models/responses/auth_response_model.dart`**
```dart
import 'user_model.dart';

class AuthResponseModel {
  final bool success;
  final String? message;
  final UserModel? user;
  final String? token;

  AuthResponseModel({
    required this.success,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      user: data?['user'] != null ? UserModel.fromJson(data['user']) : null,
      token: data?['token'],
    );
  }
}
```

### Step 2.2: Buat Auth Datasources

**File: `lib/data/datasources/auth_remote_datasource.dart`**
```dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/auth_response_model.dart';
import 'auth_local_datasource.dart';

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
    String email,
    String password,
  ) async {
    try {
      AppLogger.apiRequest('POST', Variables.login, body: {'email': email});

      final response = await http.post(
        Uri.parse(Variables.login),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': 'Flutter Apotek App',
        }),
      );

      AppLogger.apiResponse(Variables.login, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(jsonDecode(response.body));
        return Right(authResponse);
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Validation error');
      } else {
        return const Left('Login failed');
      }
    } catch (e) {
      AppLogger.error('Login error', error: e);
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> logout() async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final response = await http.post(
        Uri.parse(Variables.logout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await AuthLocalDatasource().clearAll();
        return const Right(true);
      }
      return const Left('Logout failed');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> getMe() async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final response = await http.get(
        Uri.parse(Variables.me),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(UserModel.fromJson(data['data']));
      } else if (response.statusCode == 401) {
        return const Left('Unauthorized');
      }
      return const Left('Failed to get user');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
```

**File: `lib/data/datasources/auth_local_datasource.dart`**
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/responses/auth_response_model.dart';
import '../models/responses/user_model.dart';

class AuthLocalDatasource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Future<void> saveAuthData(AuthResponseModel authData) async {
    final prefs = await SharedPreferences.getInstance();
    if (authData.token != null) {
      await prefs.setString(_tokenKey, authData.token!);
    }
    if (authData.user != null) {
      await prefs.setString(_userKey, jsonEncode(authData.user!.toJson()));
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
```

### Step 2.3: Buat Login BLoC

**File: `lib/presentation/auth/bloc/login/login_event.dart`**
```dart
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}
```

**File: `lib/presentation/auth/bloc/login/login_state.dart`**
```dart
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}
```

**File: `lib/presentation/auth/bloc/login/login_bloc.dart`**
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _authRemoteDatasource;

  LoginBloc(this._authRemoteDatasource) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await _authRemoteDatasource.login(
      event.email,
      event.password,
    );

    result.fold(
      (error) => emit(LoginError(error)),
      (authResponse) async {
        if (authResponse.success && authResponse.token != null) {
          await AuthLocalDatasource().saveAuthData(authResponse);
          emit(LoginSuccess());
        } else {
          emit(LoginError(authResponse.message ?? 'Login failed'));
        }
      },
    );
  }
}
```

### Step 2.4: Buat Auth Pages

**File: `lib/presentation/auth/pages/splash_page.dart`**
```dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../pos/pages/pos_page.dart';
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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await AuthLocalDatasource().isLoggedIn();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? const POSPage() : const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_pharmacy,
              size: 100,
              color: AppColors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Apotek POS',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
```

**File: `lib/presentation/auth/pages/login_page.dart`** (Akan dibuat detail di implementasi)

---

## Phase 3: Shift Management Module

### Step 3.1: Buat Shift Models

**File: `lib/data/models/responses/shift_model.dart`**

### Step 3.2: Buat Shift Datasource

**File: `lib/data/datasources/shift_remote_datasource.dart`**

### Step 3.3: Buat Shift BLoC

### Step 3.4: Buat Shift Dialog

---

## Phase 4: Product & Category Module

### Step 4.1: Buat Product Models

**File: `lib/data/models/responses/product_model.dart`**
- ProductModel
- BatchModel
- UnitConversionModel

### Step 4.2: Buat Category Model

**File: `lib/data/models/responses/category_model.dart`**

### Step 4.3: Buat Product & Category Datasources

### Step 4.4: Buat Product & Category BLoCs

### Step 4.5: Buat POS Page dengan Phone Layout

---

## Phase 5: Cart & Checkout Module

### Step 5.1: Buat Checkout BLoC (Cart Management)

**Fitur:**
- Add to cart
- Update quantity
- Remove item
- Calculate total
- Apply discount

### Step 5.2: Buat Cart Widgets

### Step 5.3: Buat Checkout Page

### Step 5.4: Buat Payment Page

---

## Phase 6: Sales/Transaction Module

### Step 6.1: Buat Sale Models

**File: `lib/data/models/responses/sale_model.dart`**
- SaleModel
- SaleItemModel
- PaymentModel

### Step 6.2: Buat Sale Request Model

**File: `lib/data/models/requests/sale_request_model.dart`**

### Step 6.3: Buat Sale Datasource

### Step 6.4: Buat Sale BLoC

### Step 6.5: Buat Invoice Page

---

## Phase 7: Customer Module

### Step 7.1: Buat Customer Model

### Step 7.2: Buat Customer Datasource

### Step 7.3: Buat Customer BLoC

### Step 7.4: Buat Customer Pages (List, Add, Search)

---

## Phase 8: Dashboard Module

### Step 8.1: Buat Dashboard Models

- DashboardSummaryModel
- LowStockProductModel
- ExpiringBatchModel

### Step 8.2: Buat Dashboard Datasource

### Step 8.3: Buat Dashboard BLoC

### Step 8.4: Buat Dashboard Page dengan Charts

---

## Phase 9: Transaction History Module

### Step 9.1: Buat Transaction List Page

### Step 9.2: Buat Transaction Detail Page

### Step 9.3: Implementasi Filter & Search

---

## Phase 10: Offline Support (Optional - Future)

### Step 10.1: Setup SQLite Database

### Step 10.2: Buat Local BLoCs

### Step 10.3: Implementasi Sync Mechanism

---

## Phase 11: Hardware Integration (Future)

### Step 11.1: Barcode Scanner Integration

### Step 11.2: Thermal Printer Integration

### Step 11.3: Receipt Printing

---

## Implementation Order (Priority)

| No | Phase | Priority | Dependency |
|----|-------|----------|------------|
| 1 | Project Setup & Core | High | - |
| 2 | Authentication | High | Phase 1 |
| 3 | Shift Management | High | Phase 2 |
| 4 | Product & Category | High | Phase 2 |
| 5 | Cart & Checkout | High | Phase 4 |
| 6 | Sales/Transaction | High | Phase 5 |
| 7 | Customer | Medium | Phase 2 |
| 8 | Dashboard | Medium | Phase 2 |
| 9 | Transaction History | Medium | Phase 6 |
| 10 | Offline Support | Low | Phase 1-9 |
| 11 | Hardware Integration | Low | Phase 6 |

---

## API Endpoints Summary

| Feature | Endpoint | Method |
|---------|----------|--------|
| Login | `/login` | POST |
| Logout | `/logout` | POST |
| Get User | `/me` | GET |
| Dashboard Summary | `/dashboard/summary` | GET |
| Low Stock | `/dashboard/low-stock` | GET |
| Expiring | `/dashboard/expiring` | GET |
| Current Shift | `/shift/current` | GET |
| Open Shift | `/shift/open` | POST |
| Close Shift | `/shift/close` | POST |
| Products | `/products` | GET |
| Product Detail | `/products/{id}` | GET |
| Barcode Search | `/products/barcode` | POST |
| Categories | `/categories` | GET |
| Customers | `/customers` | GET |
| Customer Detail | `/customers/{id}` | GET |
| Create Customer | `/customers` | POST |
| Sales List | `/sales` | GET |
| Sale Detail | `/sales/{id}` | GET |
| Create Sale | `/sales` | POST |

---

## Payment Methods Reference

| ID | Name | Code | Is Cash |
|----|------|------|---------|
| 1 | Cash | CASH | true |
| 2 | Debit Card | DEBIT | false |
| 3 | Credit Card | CREDIT | false |
| 4 | QRIS | QRIS | false |
| 5 | Transfer Bank | TRANSFER | false |

---

## Notes

1. **Fokus Phone First:** Semua UI akan didesain untuk phone terlebih dahulu, dengan responsive support untuk tablet di masa depan.

2. **BLoC Pattern:** Menggunakan flutter_bloc untuk state management yang konsisten dengan Jago POS App.

3. **Shift Required:** User harus open shift sebelum bisa melakukan transaksi penjualan.

4. **FEFO:** First Expired First Out - Sistem batch untuk obat dengan tanggal kadaluarsa.

5. **Obat Resep:** Field `requires_prescription` untuk menandai obat resep yang memerlukan validasi khusus.

---

## Getting Started

Untuk memulai implementasi, jalankan commands berikut setelah setup pubspec.yaml:

```bash
# Install dependencies
flutter pub get

# Generate freezed files (jika menggunakan freezed)
flutter pub run build_runner build --delete-conflicting-outputs
```

Lalu mulai dari Phase 1 dan lanjut secara berurutan.
