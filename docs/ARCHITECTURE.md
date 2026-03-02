# Arsitektur Kode Flutter Apotek POS

Dokumentasi arsitektur dan struktur kode aplikasi Flutter Apotek POS.

---

## Daftar Isi

1. [Overview Arsitektur](#overview-arsitektur)
2. [Struktur Folder](#struktur-folder)
3. [Layer Architecture](#layer-architecture)
4. [State Management (BLoC)](#state-management-bloc)
5. [Data Flow](#data-flow)
6. [Dependency Injection](#dependency-injection)
7. [Code Generation](#code-generation)
8. [Best Practices](#best-practices)

---

## Overview Arsitektur

Aplikasi ini menggunakan **Clean Architecture** yang dimodifikasi dengan pattern **BLoC (Business Logic Component)** untuk state management.

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Pages     │  │   Widgets   │  │   BLoC (State Mgmt) │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌─────────────────────┐  ┌───────────────────────────────┐ │
│  │   Remote Datasource │  │       Local Datasource        │ │
│  │   (API Calls)       │  │   (SharedPrefs, SQLite)       │ │
│  └─────────────────────┘  └───────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                      Models                              ││
│  │  (Request Models, Response Models, Entity Models)       ││
│  └─────────────────────────────────────────────────────────┘│
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       Core Layer                             │
│  ┌───────────┐  ┌────────────┐  ┌────────────┐  ┌────────┐ │
│  │ Constants │  │ Extensions │  │ Components │  │ Utils  │ │
│  └───────────┘  └────────────┘  └────────────┘  └────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Struktur Folder

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                        # Core utilities & shared code
│   ├── constants/
│   │   ├── colors.dart          # Definisi warna tema
│   │   └── variables.dart       # API endpoints & constants
│   ├── extensions/
│   │   ├── build_context_ext.dart   # Navigator extensions
│   │   ├── int_ext.dart             # Currency formatting
│   │   ├── double_ext.dart          # Number formatting
│   │   ├── string_ext.dart          # String utilities
│   │   └── date_time_ext.dart       # Date formatting
│   ├── components/
│   │   ├── buttons.dart         # Reusable button widgets
│   │   ├── custom_text_field.dart
│   │   ├── custom_dropdown.dart
│   │   ├── search_input.dart
│   │   ├── spaces.dart          # SizedBox shortcuts
│   │   └── loading_indicator.dart
│   ├── services/
│   │   └── printer_service.dart # Bluetooth printer service
│   ├── utils/
│   │   └── screen_size.dart     # Screen size helper
│   └── widgets/
│       └── responsive_layout.dart   # Phone/Tablet layout
│
├── data/                        # Data layer
│   ├── datasources/
│   │   ├── auth_local_datasource.dart    # Token & user storage
│   │   ├── auth_remote_datasource.dart   # Auth API
│   │   ├── product_remote_datasource.dart
│   │   ├── category_remote_datasource.dart
│   │   ├── customer_remote_datasource.dart
│   │   ├── sale_remote_datasource.dart
│   │   ├── shift_remote_datasource.dart
│   │   ├── dashboard_remote_datasource.dart
│   │   ├── transaction_remote_datasource.dart
│   │   ├── report_remote_datasource.dart
│   │   ├── doctor_remote_datasource.dart
│   │   └── store_remote_datasource.dart
│   └── models/
│       ├── requests/            # Request body models
│       │   ├── sale_request_model.dart
│       │   └── customer_request_model.dart
│       └── responses/           # API response models
│           ├── auth_response_model.dart
│           ├── user_model.dart
│           ├── product_model.dart
│           ├── category_model.dart
│           ├── customer_model.dart
│           ├── sale_model.dart
│           ├── shift_model.dart
│           ├── dashboard_model.dart
│           ├── transaction_model.dart
│           ├── report_model.dart
│           ├── doctor_model.dart
│           ├── store_model.dart
│           ├── receipt_model.dart
│           ├── shift_summary_model.dart
│           └── unit_model.dart
│
└── presentation/                # UI layer
    ├── auth/
    │   ├── bloc/
    │   │   ├── login/
    │   │   │   ├── login_bloc.dart
    │   │   │   ├── login_event.dart
    │   │   │   └── login_state.dart
    │   │   └── logout/
    │   │       ├── logout_bloc.dart
    │   │       ├── logout_event.dart
    │   │       └── logout_state.dart
    │   └── pages/
    │       ├── login_page.dart
    │       └── splash_page.dart
    │
    ├── home/
    │   ├── pages/
    │   │   └── home_page.dart
    │   └── widgets/
    │       ├── drawer_widget.dart
    │       ├── home_phone_layout.dart
    │       └── home_tablet_layout.dart
    │
    ├── shift/
    │   ├── bloc/
    │   │   ├── shift_bloc.dart
    │   │   ├── shift_event.dart
    │   │   └── shift_state.dart
    │   └── widgets/
    │       ├── shift_info_widget.dart
    │       ├── open_shift_dialog.dart
    │       └── close_shift_dialog.dart
    │
    ├── pos/
    │   ├── bloc/
    │   │   ├── product/
    │   │   │   ├── product_bloc.dart
    │   │   │   ├── product_event.dart
    │   │   │   └── product_state.dart
    │   │   ├── category/
    │   │   │   ├── category_bloc.dart
    │   │   │   ├── category_event.dart
    │   │   │   └── category_state.dart
    │   │   ├── checkout/
    │   │   │   ├── checkout_bloc.dart
    │   │   │   ├── checkout_event.dart
    │   │   │   ├── checkout_state.dart
    │   │   │   └── cart_item_model.dart
    │   │   └── sale/
    │   │       ├── sale_bloc.dart
    │   │       ├── sale_event.dart
    │   │       └── sale_state.dart
    │   ├── pages/
    │   │   ├── pos_page.dart
    │   │   ├── checkout_page.dart
    │   │   ├── payment_page.dart
    │   │   └── invoice_page.dart
    │   └── widgets/
    │       ├── pos_phone_layout.dart
    │       ├── pos_tablet_layout.dart
    │       ├── checkout_phone_layout.dart
    │       ├── checkout_tablet_layout.dart
    │       ├── category_chip.dart
    │       ├── cart_item_widget.dart
    │       ├── cart_panel_widget.dart
    │       ├── cart_fab.dart
    │       ├── cart_bottom_sheet.dart
    │       └── checkout_item_widget.dart
    │
    ├── customer/
    │   ├── bloc/
    │   │   ├── customer_bloc.dart
    │   │   ├── customer_event.dart
    │   │   └── customer_state.dart
    │   ├── pages/
    │   │   └── customer_list_page.dart
    │   └── widgets/
    │       └── add_customer_dialog.dart
    │
    ├── product/
    │   ├── bloc/
    │   │   ├── product_management_bloc.dart
    │   │   ├── product_management_event.dart
    │   │   └── product_management_state.dart
    │   ├── pages/
    │   │   ├── product_list_page.dart
    │   │   └── product_detail_page.dart
    │   └── widgets/
    │       └── product_list_item.dart
    │
    ├── transaction/
    │   ├── bloc/
    │   │   ├── transaction_bloc.dart
    │   │   ├── transaction_event.dart
    │   │   └── transaction_state.dart
    │   ├── pages/
    │   │   ├── transaction_history_page.dart
    │   │   └── transaction_detail_page.dart
    │   └── widgets/
    │       ├── history_phone_layout.dart
    │       ├── history_tablet_layout.dart
    │       ├── transaction_list_item.dart
    │       └── transaction_detail_panel.dart
    │
    ├── dashboard/
    │   ├── bloc/
    │   │   ├── dashboard_bloc.dart
    │   │   ├── dashboard_event.dart (jika ada)
    │   │   └── dashboard_state.dart
    │   ├── pages/
    │   │   └── dashboard_page.dart
    │   └── widgets/
    │       ├── dashboard_phone_layout.dart
    │       ├── dashboard_tablet_layout.dart
    │       ├── summary_card.dart
    │       └── expiring_list.dart
    │
    ├── report/
    │   ├── bloc/
    │   │   ├── report_bloc.dart
    │   │   ├── report_event.dart
    │   │   └── report_state.dart
    │   └── pages/
    │       └── report_page.dart
    │
    ├── stock/
    │   └── pages/
    │       ├── low_stock_page.dart
    │       └── expiring_page.dart
    │
    ├── doctor/
    │   └── pages/
    │       └── doctor_list_page.dart
    │
    ├── store/
    │   └── pages/
    │       └── store_info_page.dart
    │
    ├── settings/
    │   ├── pages/
    │   │   ├── settings_page.dart
    │   │   ├── profile_page.dart
    │   │   ├── store_settings_page.dart
    │   │   ├── printer_settings_page.dart
    │   │   ├── receipt_settings_page.dart
    │   │   └── about_page.dart
    │   └── widgets/
    │       ├── settings_phone_layout.dart
    │       └── settings_tablet_layout.dart
    │
    └── xendit/
        └── pages/
            └── xendit_payment_page.dart
```

---

## Layer Architecture

### 1. Core Layer

Layer ini berisi kode yang digunakan di seluruh aplikasi.

#### Constants

```dart
// lib/core/constants/colors.dart
class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF66BB6A);
  static const Color error = Color(0xFFE53935);
  // ...
}

// lib/core/constants/variables.dart
class Variables {
  static const String baseUrl = 'https://apotek.server.com';
  static const String apiBaseUrl = '$baseUrl/api/v1';
  static const String login = '$apiBaseUrl/login';
  // ...
}
```

#### Extensions

```dart
// lib/core/extensions/int_ext.dart
extension IntExt on int {
  String get currencyFormat {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }
}

// Usage: 50000.currencyFormat => "Rp 50.000"
```

```dart
// lib/core/extensions/build_context_ext.dart
extension BuildContextExt on BuildContext {
  void push(Widget page) {
    Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  }

  void pushAndRemoveUntil(Widget page, bool Function(Route) predicate) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }
}
```

#### Components (Reusable Widgets)

```dart
// lib/core/components/buttons.dart
class Button {
  static Widget filled({
    required VoidCallback onPressed,
    required String label,
    Color? color,
    double? width,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
        ),
        child: Text(label),
      ),
    );
  }
}
```

### 2. Data Layer

#### Remote Datasource

```dart
// lib/data/datasources/product_remote_datasource.dart
class ProductRemoteDatasource {
  Future<Either<String, List<ProductModel>>> getProducts({
    String? search,
    int? categoryId,
  }) async {
    try {
      final token = await AuthLocalDatasource().getToken();
      final queryParams = <String, String>{};
      if (search != null) queryParams['search'] = search;
      if (categoryId != null) queryParams['category_id'] = '$categoryId';

      final uri = Uri.parse(Variables.products)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['data'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
        return Right(products);
      }
      return Left('Error: ${response.statusCode}');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
```

#### Local Datasource

```dart
// lib/data/datasources/auth_local_datasource.dart
class AuthLocalDatasource {
  static const _tokenKey = 'token';
  static const _userKey = 'user';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

#### Models

```dart
// lib/data/models/responses/product_model.dart
class ProductModel {
  final int id;
  final String name;
  final String? barcode;
  final int price;
  final int stock;
  final CategoryModel? category;
  final List<BatchModel> batches;

  ProductModel({
    required this.id,
    required this.name,
    this.barcode,
    required this.price,
    required this.stock,
    this.category,
    this.batches = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      price: json['price'],
      stock: json['stock'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      batches: json['batches'] != null
          ? (json['batches'] as List)
              .map((e) => BatchModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'stock': stock,
    };
  }
}
```

### 3. Presentation Layer

#### Pages

```dart
// lib/presentation/pos/pages/pos_page.dart
class POSPage extends StatelessWidget {
  const POSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir')),
      body: ResponsiveLayout(
        phoneLayout: const POSPhoneLayout(),
        tabletLayout: const POSTabletLayout(),
      ),
    );
  }
}
```

#### Widgets

```dart
// lib/core/widgets/responsive_layout.dart
class ResponsiveLayout extends StatelessWidget {
  final Widget phoneLayout;
  final Widget tabletLayout;

  const ResponsiveLayout({
    super.key,
    required this.phoneLayout,
    required this.tabletLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return tabletLayout;
        }
        return phoneLayout;
      },
    );
  }
}
```

---

## State Management (BLoC)

### BLoC Pattern Structure

Setiap fitur memiliki 3 file:
1. `*_bloc.dart` - Business logic
2. `*_event.dart` - Input events
3. `*_state.dart` - Output states

### Example: Login BLoC

#### Events
```dart
// lib/presentation/auth/bloc/login/login_event.dart
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}
```

#### States
```dart
// lib/presentation/auth/bloc/login/login_state.dart
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthResponseModel data;
  LoginSuccess(this.data);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}
```

#### BLoC
```dart
// lib/presentation/auth/bloc/login/login_bloc.dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _datasource;

  LoginBloc(this._datasource) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await _datasource.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (error) => emit(LoginError(error)),
      (data) async {
        await AuthLocalDatasource().saveToken(data.token);
        await AuthLocalDatasource().saveUser(data.user);
        emit(LoginSuccess(data));
      },
    );
  }
}
```

### Menggunakan BLoC di UI

```dart
// Di main.dart - Provider setup
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => LoginBloc(AuthRemoteDatasource()),
    ),
    BlocProvider(
      create: (context) => ProductBloc(ProductRemoteDatasource()),
    ),
    // ... other providers
  ],
  child: MaterialApp(...),
)

// Di halaman - Trigger event
ElevatedButton(
  onPressed: () {
    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  },
  child: Text('Login'),
)

// Di halaman - Listen to state
BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {
    if (state is LoginSuccess) {
      context.pushAndRemoveUntil(HomePage(), (route) => false);
    } else if (state is LoginError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: BlocBuilder<LoginBloc, LoginState>(
    builder: (context, state) {
      if (state is LoginLoading) {
        return CircularProgressIndicator();
      }
      return LoginForm();
    },
  ),
)
```

---

## Data Flow

```
User Action → Event → BLoC → Datasource → API/Local → Model → State → UI Update

┌────────┐    ┌───────┐    ┌──────┐    ┌────────────┐    ┌─────┐
│  User  │───▶│ Event │───▶│ BLoC │───▶│ Datasource │───▶│ API │
│ Action │    │       │    │      │    │            │    │     │
└────────┘    └───────┘    └──────┘    └────────────┘    └──┬──┘
                              │                             │
                              │    ┌───────────────────────┘
                              │    │
                              ▼    ▼
                           ┌──────────┐    ┌───────┐    ┌────┐
                           │  State   │───▶│  UI   │───▶│User│
                           │          │    │Update │    │    │
                           └──────────┘    └───────┘    └────┘
```

### Flow Example: Get Products

1. **User** membuka halaman POS
2. **Event** `FetchProducts` di-dispatch
3. **BLoC** menerima event dan memanggil datasource
4. **Datasource** melakukan HTTP request ke API
5. **API** mengembalikan response JSON
6. **Model** di-parse dari JSON
7. **State** `ProductLoaded(products)` di-emit
8. **UI** rebuild dengan data produk

---

## Dependency Injection

Aplikasi ini menggunakan dependency injection sederhana melalui constructor:

```dart
// BLoC menerima datasource melalui constructor
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _datasource;

  ProductBloc(this._datasource) : super(ProductInitial()) {
    // ...
  }
}

// Di main.dart
BlocProvider(
  create: (context) => ProductBloc(ProductRemoteDatasource()),
)
```

---

## Code Generation

### Packages Used
- `freezed` - Immutable classes & union types
- `json_serializable` - JSON serialization
- `build_runner` - Code generation runner

### Generate Code

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Example: Freezed Model

```dart
// sale_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_model.freezed.dart';
part 'sale_model.g.dart';

@freezed
class SaleModel with _$SaleModel {
  const factory SaleModel({
    required int id,
    required String invoiceNumber,
    required int total,
    required int paid,
    required int change,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SaleModel;

  factory SaleModel.fromJson(Map<String, dynamic> json) =>
      _$SaleModelFromJson(json);
}
```

---

## Best Practices

### 1. Separation of Concerns
- UI logic di widgets/pages
- Business logic di BLoC
- Data logic di datasources
- Shared utilities di core

### 2. Immutable State
- State classes bersifat immutable
- Gunakan `copyWith` untuk update state

### 3. Error Handling
- Gunakan `Either<String, T>` dari dartz untuk error handling
- `Left` untuk error, `Right` untuk success

```dart
Future<Either<String, ProductModel>> getProduct(int id) async {
  try {
    // ...
    return Right(product);
  } catch (e) {
    return Left(e.toString());
  }
}
```

### 4. Consistent Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE` atau `camelCase`

### 5. Responsive Design
- Selalu gunakan `ResponsiveLayout` untuk halaman utama
- Test di berbagai ukuran layar

---

## Testing

### Unit Test Structure

```
test/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource_test.dart
│   └── models/
│       └── product_model_test.dart
├── presentation/
│   └── bloc/
│       └── login_bloc_test.dart
└── widget_test.dart
```

### Example Test

```dart
// test/presentation/bloc/login_bloc_test.dart
void main() {
  late LoginBloc loginBloc;
  late MockAuthRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockAuthRemoteDatasource();
    loginBloc = LoginBloc(mockDatasource);
  });

  tearDown(() {
    loginBloc.close();
  });

  test('initial state is LoginInitial', () {
    expect(loginBloc.state, isA<LoginInitial>());
  });

  blocTest<LoginBloc, LoginState>(
    'emits [LoginLoading, LoginSuccess] when login succeeds',
    build: () {
      when(() => mockDatasource.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => Right(mockAuthResponse));
      return loginBloc;
    },
    act: (bloc) => bloc.add(
      LoginSubmitted(email: 'test@test.com', password: 'password'),
    ),
    expect: () => [
      isA<LoginLoading>(),
      isA<LoginSuccess>(),
    ],
  );
}
```

---

*Dokumentasi ini terakhir diperbarui: Januari 2025*
