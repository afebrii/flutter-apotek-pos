# API Integration Guide for Flutter

Dokumentasi integrasi API Apotek POS untuk tim Flutter.

## Base Configuration

```
Base URL: http://YOUR_SERVER_IP:8000/api/v1
Content-Type: application/json
Accept: application/json
```

## Authentication

### Login

Endpoint untuk autentikasi user dan mendapatkan token.

```
POST /login
```

**Request Body:**
```json
{
  "email": "admin@apotek.com",
  "password": "password",
  "device_name": "Flutter POS App"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 6,
      "name": "Administrator",
      "email": "admin@apotek.com",
      "role": "owner",
      "phone": "081234567899",
      "store_id": 1
    },
    "token": "1|mkefljCWoLQIbZdN7z29gQzgLf1WzNycvkJI5AMG2cd153b9"
  }
}
```

**Response Error (422):**
```json
{
  "message": "The provided credentials are incorrect.",
  "errors": {
    "email": ["The provided credentials are incorrect."]
  }
}
```

**Flutter Implementation:**
```dart
class AuthService {
  final Dio _dio;

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
      'device_name': 'Flutter POS App',
    });
    return AuthResponse.fromJson(response.data);
  }
}
```

---

### Logout

```
POST /logout
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

### Get Current User

```
GET /me
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 6,
    "name": "Administrator",
    "email": "admin@apotek.com",
    "role": "owner",
    "phone": "081234567899",
    "is_active": true,
    "store": {
      "id": 1,
      "name": "Apotek Sehat Sejahtera",
      "address": "Jl. Kesehatan No. 123, Jakarta Pusat"
    }
  }
}
```

---

## Dashboard

### Get Dashboard Summary

```
GET /dashboard/summary
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "today_sales": {
      "count": 5,
      "total": "1250000.00"
    },
    "low_stock_products": 3,
    "expiring_soon": 2,
    "expired_products": 0,
    "active_shift": {
      "id": 5,
      "opening_cash": "500000.00",
      "expected_cash": "750000.00",
      "opening_time": "2025-12-26T08:27:04+00:00"
    }
  }
}
```

> **Note:** `active_shift` akan `null` jika belum ada shift yang dibuka.

---

### Get Low Stock Products

```
GET /dashboard/low-stock
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "OB001",
      "name": "Paracetamol 500mg",
      "category": "Obat Demam",
      "unit": "Tablet",
      "total_stock": 50,
      "min_stock": 100
    }
  ]
}
```

---

### Get Expiring Batches

```
GET /dashboard/expiring
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "batch_number": "BTH-001",
      "product": {
        "id": 1,
        "name": "Paracetamol 500mg",
        "code": "OB001"
      },
      "unit": "Tablet",
      "stock": 50,
      "expired_date": "2025-01-15",
      "days_until_expiry": 20,
      "is_expired": false
    }
  ]
}
```

---

## Cashier Shift

### Get Current Shift

```
GET /shift/current
Authorization: Bearer {token}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "id": 5,
    "opening_cash": "500000.00",
    "expected_cash": "750000.00",
    "opening_time": "2025-12-26T08:27:04+00:00",
    "status": "open"
  }
}
```

**Response Not Found (404):**
```json
{
  "success": false,
  "message": "No active shift found"
}
```

---

### Open Shift

```
POST /shift/open
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "opening_cash": 500000,
  "notes": "Shift pagi"
}
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "Shift opened successfully",
  "data": {
    "id": 5,
    "opening_cash": "500000.00",
    "opening_time": "2025-12-26T08:27:04+00:00"
  }
}
```

**Response Error (422) - Already has active shift:**
```json
{
  "success": false,
  "message": "You already have an active shift"
}
```

---

### Close Shift

```
POST /shift/close
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "actual_cash": 750000,
  "notes": "Shift selesai, tidak ada selisih"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Shift closed successfully",
  "data": {
    "id": 5,
    "opening_cash": "500000.00",
    "expected_cash": "750000.00",
    "actual_cash": "750000.00",
    "difference": "0.00",
    "opening_time": "2025-12-26T08:27:04+00:00",
    "closing_time": "2025-12-26T16:00:00+00:00"
  }
}
```

---

## Products

### List Products

```
GET /products
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| search | string | Cari berdasarkan nama, code, barcode, generic_name, kfa_code |
| category_id | integer | Filter berdasarkan kategori |
| requires_prescription | boolean | Filter obat resep |
| per_page | integer | Jumlah data per halaman (default: 15) |
| page | integer | Nomor halaman |

**Example:**
```
GET /products?search=paracetamol&per_page=10&page=1
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "code": "OB001",
        "barcode": "8991234567001",
        "kfa_code": null,
        "name": "Paracetamol 500mg",
        "generic_name": "Paracetamol",
        "category": {
          "id": 4,
          "name": "Obat Demam"
        },
        "base_unit": {
          "id": 1,
          "name": "Tablet"
        },
        "purchase_price": "150.00",
        "selling_price": "500.00",
        "total_stock": 258,
        "min_stock": 100,
        "requires_prescription": false,
        "is_low_stock": false
      }
    ],
    "first_page_url": "http://127.0.0.1:8000/api/v1/products?page=1",
    "last_page": 3,
    "next_page_url": "http://127.0.0.1:8000/api/v1/products?page=2",
    "per_page": 15,
    "total": 15
  },
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 15,
    "total": 15
  }
}
```

---

### Get Product Detail

```
GET /products/{id}
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "code": "OB001",
    "barcode": "8991234567001",
    "kfa_code": null,
    "name": "Paracetamol 500mg",
    "generic_name": "Paracetamol",
    "description": "Obat penurun demam dan pereda nyeri",
    "category": {
      "id": 4,
      "name": "Obat Demam"
    },
    "base_unit": {
      "id": 1,
      "name": "Tablet"
    },
    "purchase_price": "150.00",
    "selling_price": "500.00",
    "total_stock": 258,
    "min_stock": 100,
    "max_stock": 500,
    "rack_location": "A-01",
    "requires_prescription": false,
    "is_active": true,
    "is_low_stock": false,
    "batches": [
      {
        "id": 1,
        "batch_number": "BTH-001",
        "expired_date": "2026-06-15",
        "stock": 100,
        "purchase_price": "150.00",
        "selling_price": "500.00"
      },
      {
        "id": 2,
        "batch_number": "BTH-002",
        "expired_date": "2026-09-20",
        "stock": 158,
        "purchase_price": "150.00",
        "selling_price": "500.00"
      }
    ],
    "unit_conversions": [
      {
        "id": 1,
        "unit": {
          "id": 2,
          "name": "Strip"
        },
        "conversion_value": 10,
        "selling_price": "4500.00"
      },
      {
        "id": 2,
        "unit": {
          "id": 3,
          "name": "Box"
        },
        "conversion_value": 100,
        "selling_price": "45000.00"
      }
    ]
  }
}
```

---

### Search by Barcode

```
POST /products/barcode
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "barcode": "8991234567001"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "code": "OB001",
    "barcode": "8991234567001",
    "kfa_code": null,
    "name": "Paracetamol 500mg",
    "generic_name": "Paracetamol",
    "category": {
      "id": 4,
      "name": "Obat Demam"
    },
    "base_unit": {
      "id": 1,
      "name": "Tablet"
    },
    "selling_price": "500.00",
    "total_stock": 258,
    "requires_prescription": false,
    "batches": [
      {
        "id": 1,
        "batch_number": "BTH-001",
        "expired_date": "2026-06-15",
        "stock": 100,
        "selling_price": "500.00"
      }
    ]
  }
}
```

**Response Not Found (404):**
```json
{
  "success": false,
  "message": "Product not found"
}
```

---

## Categories

### List Categories

```
GET /categories
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 4,
      "name": "Obat Demam",
      "description": null,
      "products_count": 4
    },
    {
      "id": 6,
      "name": "Obat Flu & Pilek",
      "description": null,
      "products_count": 3
    }
  ]
}
```

---

## Customers

### List Customers

```
GET /customers
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| search | string | Cari berdasarkan nama, phone, email |
| per_page | integer | Jumlah data per halaman (default: 15) |
| page | integer | Nomor halaman |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "name": "Umum",
        "phone": null,
        "email": null,
        "address": null,
        "points": 0,
        "birth_date": null
      },
      {
        "id": 2,
        "name": "Ahmad Suparjo",
        "phone": "081234567001",
        "email": "ahmad.suparjo@email.com",
        "address": "Jl. Merdeka No. 10, Jakarta Pusat",
        "points": 150,
        "birth_date": "1985-03-15"
      }
    ]
  },
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 11
  }
}
```

---

### Get Customer Detail

```
GET /customers/{id}
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "Ahmad Suparjo",
    "phone": "081234567001",
    "email": "ahmad.suparjo@email.com",
    "address": "Jl. Merdeka No. 10, Jakarta Pusat",
    "points": 150,
    "birth_date": "1985-03-15"
  }
}
```

---

### Create Customer

```
POST /customers
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "Budi Santoso",
  "phone": "081234567890",
  "email": "budi@email.com",
  "address": "Jl. Sudirman No. 100",
  "birth_date": "1990-05-20"
}
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "Customer created successfully",
  "data": {
    "id": 12,
    "name": "Budi Santoso",
    "phone": "081234567890",
    "email": "budi@email.com"
  }
}
```

---

## Sales

### List Sales

```
GET /sales
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| date | date (Y-m-d) | Filter berdasarkan tanggal |
| status | string | Filter: pending, completed, cancelled |
| per_page | integer | Jumlah data per halaman (default: 15) |
| page | integer | Nomor halaman |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "invoice_number": "INV-20251226-0001",
        "date": "2025-12-26",
        "customer": {
          "id": 2,
          "name": "Ahmad Suparjo"
        },
        "subtotal": "50000.00",
        "discount": "0.00",
        "tax": "0.00",
        "total": "50000.00",
        "status": "completed"
      }
    ]
  },
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 5
  }
}
```

---

### Get Sale Detail

```
GET /sales/{id}
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "invoice_number": "INV-20251226-0001",
    "date": "2025-12-26",
    "customer": {
      "id": 2,
      "name": "Ahmad Suparjo",
      "phone": "081234567001"
    },
    "cashier": {
      "id": 6,
      "name": "Administrator"
    },
    "items": [
      {
        "id": 1,
        "product": {
          "id": 1,
          "name": "Paracetamol 500mg",
          "code": "OB001"
        },
        "batch_number": "BTH-001",
        "unit": "Tablet",
        "quantity": 10,
        "price": "500.00",
        "discount": "0.00",
        "subtotal": "5000.00"
      }
    ],
    "payments": [
      {
        "id": 1,
        "payment_method": {
          "id": 1,
          "name": "Cash"
        },
        "amount": "50000.00",
        "reference": null
      }
    ],
    "subtotal": "50000.00",
    "discount": "0.00",
    "tax": "0.00",
    "total": "50000.00",
    "status": "completed",
    "paid_amount": "50000.00",
    "change_amount": "0.00",
    "notes": null
  }
}
```

---

### Create Sale

> **Important:** User harus memiliki shift aktif sebelum membuat penjualan.

```
POST /sales
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "customer_id": 2,
  "items": [
    {
      "product_id": 1,
      "batch_id": 1,
      "unit_id": null,
      "quantity": 10,
      "price": 500,
      "discount": 0
    },
    {
      "product_id": 2,
      "batch_id": 3,
      "unit_id": null,
      "quantity": 5,
      "price": 2500,
      "discount": 500
    }
  ],
  "discount": 1000,
  "tax": 0,
  "payments": [
    {
      "payment_method_id": 1,
      "amount": 20000,
      "reference_number": null
    }
  ],
  "notes": "Pembelian reguler"
}
```

**Field Description:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| customer_id | integer | No | ID customer, null untuk umum |
| items | array | Yes | Daftar item yang dibeli |
| items.*.product_id | integer | Yes | ID produk |
| items.*.batch_id | integer | Yes | ID batch (FEFO - First Expired First Out) |
| items.*.unit_id | integer | No | ID unit jika bukan base unit |
| items.*.quantity | integer | Yes | Jumlah |
| items.*.price | decimal | Yes | Harga satuan |
| items.*.discount | decimal | No | Diskon per item |
| discount | decimal | No | Diskon total transaksi |
| tax | decimal | No | Pajak |
| payments | array | Yes | Daftar pembayaran |
| payments.*.payment_method_id | integer | Yes | ID metode pembayaran |
| payments.*.amount | decimal | Yes | Jumlah pembayaran |
| payments.*.reference_number | string | No | Nomor referensi (untuk non-cash) |
| notes | string | No | Catatan |

**Response Success (201):**
```json
{
  "success": true,
  "message": "Sale created successfully",
  "data": {
    "id": 6,
    "invoice_number": "INV-20251226-0006",
    "total": "16500.00",
    "change": "3500.00"
  }
}
```

**Response Error (422) - No Active Shift:**
```json
{
  "success": false,
  "message": "Please open a shift before creating sales"
}
```

**Response Error (422) - Validation:**
```json
{
  "message": "The items field is required.",
  "errors": {
    "items": ["The items field is required."]
  }
}
```

---

## Payment Methods

Untuk mendapatkan daftar payment methods, gunakan query langsung atau tambahkan endpoint baru. Berikut ID standar:

| ID | Name | Code | Is Cash |
|----|------|------|---------|
| 1 | Cash | CASH | true |
| 2 | Debit Card | DEBIT | false |
| 3 | Credit Card | CREDIT | false |
| 4 | QRIS | QRIS | false |
| 5 | Transfer Bank | TRANSFER | false |

---

## Error Handling

### Standard Error Response

```json
{
  "message": "Error message here",
  "errors": {
    "field_name": ["Validation error message"]
  }
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | OK - Request berhasil |
| 201 | Created - Data berhasil dibuat |
| 401 | Unauthorized - Token tidak valid/expired |
| 404 | Not Found - Data tidak ditemukan |
| 422 | Unprocessable Entity - Validasi gagal |
| 500 | Internal Server Error - Error di server |

### Handling 401 Unauthorized

Jika response 401, redirect ke login screen dan hapus token yang tersimpan.

```dart
dio.interceptors.add(InterceptorsWrapper(
  onError: (error, handler) {
    if (error.response?.statusCode == 401) {
      // Clear token & redirect to login
      AuthService.logout();
      Get.offAllNamed('/login');
    }
    return handler.next(error);
  },
));
```

---

## Flutter Setup Recommendations

### 1. Dependencies (pubspec.yaml)

```yaml
dependencies:
  dio: ^5.4.0
  get_storage: ^2.1.1
  get: ^4.6.6  # atau provider/riverpod
```

### 2. API Client Setup

```dart
class ApiClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://YOUR_SERVER_IP:8000/api/v1',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}
```

### 3. Token Storage

```dart
class TokenStorage {
  static final _storage = GetStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write('token', token);
    ApiClient.setToken(token);
  }

  static String? getToken() {
    return _storage.read('token');
  }

  static Future<void> clearToken() async {
    await _storage.remove('token');
    ApiClient.clearToken();
  }
}
```

### 4. App Flow

```
1. App Start
   ├── Check saved token
   │   ├── Token exists → Validate with GET /me
   │   │   ├── Valid → Go to Dashboard
   │   │   └── Invalid (401) → Go to Login
   │   └── No token → Go to Login
   │
2. After Login
   ├── Save token
   ├── Check active shift (GET /shift/current)
   │   ├── Has shift → Go to POS Screen
   │   └── No shift → Show Open Shift Dialog
   │
3. POS Flow
   ├── Search/Scan Product
   ├── Add to Cart
   ├── Select Customer (optional)
   ├── Apply Discount (optional)
   ├── Checkout
   │   ├── Select Payment Method(s)
   │   ├── Create Sale (POST /sales)
   │   └── Show Receipt
   │
4. End of Day
   └── Close Shift (POST /shift/close)
```

---

## Testing Credentials

```
Email: admin@apotek.com
Password: password
```

---

## Contact

Jika ada pertanyaan atau butuh endpoint tambahan, hubungi tim backend.
