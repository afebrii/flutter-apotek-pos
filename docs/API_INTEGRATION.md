# Apotek POS - API Integration Documentation

Dokumentasi integrasi API antara Laravel Backend dan Flutter App.

**Base URL:** `https://apotek.jagofullstack.com/api/v1`

**Last Updated:** 2026-01-10

---

## Table of Contents
1. [Authentication](#1-authentication)
2. [Dashboard](#2-dashboard)
3. [Shift Management](#3-shift-management)
4. [Products](#4-products)
5. [Categories](#5-categories)
6. [Units](#6-units)
7. [Payment Methods](#7-payment-methods)
8. [Doctors](#8-doctors)
9. [Store & Settings](#9-store--settings)
10. [Customers](#10-customers)
11. [Sales](#11-sales)
12. [Reports](#12-reports)
13. [Xendit Payment](#13-xendit-payment)
14. [Integration Status](#14-integration-status)
15. [Flutter Implementation Guide](#15-flutter-implementation-guide)

---

## 1. Authentication

### Login
```
POST /login
```
**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)",
  "device_name": "string (required)"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "cashier",
      "phone": "081234567890",
      "store_id": 1
    },
    "token": "1|abc123..."
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Logout
```
POST /logout
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "message": "Logout successful"
}
```
**Flutter Status:** ✅ Integrated

---

### Get Profile
```
GET /me
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "cashier",
    "phone": "081234567890",
    "is_active": true,
    "store": {
      "id": 1,
      "name": "Apotek Sehat",
      "address": "Jl. Sehat No. 1",
      "phone": "021-1234567"
    }
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Update Profile
```
PUT /profile
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "name": "string (required)",
  "phone": "string (optional)"
}
```
**Flutter Status:** ✅ Integrated

---

### Change Password
```
PUT /change-password
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "current_password": "string (required)",
  "password": "string (required, min:6)",
  "password_confirmation": "string (required)"
}
```
**Flutter Status:** ✅ Integrated

---

## 2. Dashboard

### Get Dashboard Summary
```
GET /dashboard/summary
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "today_sales": {
      "count": 15,
      "total": 2500000
    },
    "low_stock_products": 5,
    "expiring_soon": 3,
    "expired_products": 1,
    "active_shift": {
      "id": 1,
      "opening_cash": 500000,
      "expected_cash": 750000,
      "opening_time": "2026-01-10T08:00:00+07:00"
    }
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Get Low Stock Products
```
GET /dashboard/low-stock
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "OBT001",
      "name": "Paracetamol 500mg",
      "category": "Obat Bebas",
      "unit": "Tablet",
      "total_stock": 5,
      "min_stock": 10
    }
  ]
}
```
**Flutter Status:** ✅ Integrated

---

### Get Expiring Batches
```
GET /dashboard/expiring
Authorization: Bearer {token}
```
**Response:**
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
        "code": "OBT001"
      },
      "unit": "Tablet",
      "stock": 50,
      "expired_date": "2026-02-01",
      "days_until_expiry": 22,
      "is_expired": false
    }
  ]
}
```
**Flutter Status:** ✅ Integrated

---

## 3. Shift Management

### Get Current Shift
```
GET /shift/current
Authorization: Bearer {token}
```
**Response (if active):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "opening_cash": 500000,
    "expected_cash": 750000,
    "opening_time": "2026-01-10T08:00:00+07:00",
    "status": "open"
  }
}
```
**Response (if no active shift):**
```json
{
  "success": false,
  "message": "No active shift found"
}
```
**Flutter Status:** ✅ Integrated

---

### Open Shift
```
POST /shift/open
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "opening_cash": "numeric (required, min:0)",
  "notes": "string (optional)"
}
```
**Flutter Status:** ✅ Integrated

---

### Close Shift
```
POST /shift/close
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "actual_cash": "numeric (required, min:0)",
  "notes": "string (optional)"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Shift closed successfully",
  "data": {
    "id": 1,
    "opening_cash": 500000,
    "expected_cash": 750000,
    "actual_cash": 740000,
    "difference": -10000,
    "opening_time": "2026-01-10T08:00:00+07:00",
    "closing_time": "2026-01-10T20:00:00+07:00"
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Get Shift Summary ⚠️ NEW
```
GET /shift/summary
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "shift": {
      "id": 1,
      "opening_cash": 500000,
      "expected_cash": 750000,
      "opening_time": "2026-01-10T08:00:00+07:00",
      "duration": "4h 30m ago"
    },
    "sales": {
      "total_transactions": 15,
      "total_sales": 2500000,
      "cancelled_count": 1,
      "average_transaction": 166666.67
    },
    "cash_flow": {
      "opening_cash": 500000,
      "cash_sales": 200000,
      "non_cash_sales": 50000,
      "expected_cash": 750000
    },
    "payment_methods": [
      {
        "name": "Cash",
        "is_cash": true,
        "count": 10,
        "total": 200000
      },
      {
        "name": "QRIS",
        "is_cash": false,
        "count": 5,
        "total": 50000
      }
    ]
  }
}
```
**Flutter Status:** ❌ Not Integrated

---

### Get Shift Sales ⚠️ NEW
```
GET /shift/sales
Authorization: Bearer {token}
```
**Query Parameters:**
- `per_page`: int (default: 20)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "invoice_number": "INV-20260110-0001",
      "customer": "Umum",
      "total": 50000,
      "status": "completed",
      "payment_method": "Cash",
      "time": "10:30"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 20,
    "total": 15
  }
}
```
**Flutter Status:** ❌ Not Integrated

---

## 4. Products

### Get Products
```
GET /products
Authorization: Bearer {token}
```
**Query Parameters:**
- `search`: string (search by name, code, barcode, generic_name, kfa_code)
- `category_id`: int
- `requires_prescription`: boolean
- `per_page`: int (default: 15)
- `page`: int

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "OBT001",
      "barcode": "8991234567890",
      "kfa_code": "93001234",
      "name": "Paracetamol 500mg",
      "generic_name": "Paracetamol",
      "image": "https://...",
      "category": {
        "id": 1,
        "name": "Obat Bebas",
        "category_type": {
          "id": 1,
          "name": "Obat",
          "code": "OBT",
          "color": "#22C55E"
        }
      },
      "base_unit": {
        "id": 1,
        "name": "Tablet"
      },
      "purchase_price": 5000,
      "selling_price": 8000,
      "total_stock": 100,
      "min_stock": 10,
      "requires_prescription": false,
      "is_low_stock": false,
      "batches": [
        {
          "id": 1,
          "batch_number": "BTH-001",
          "expired_date": "2027-01-01",
          "stock": 100,
          "selling_price": 8000
        }
      ]
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 15,
    "total": 150
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Get Product Detail
```
GET /products/{id}
Authorization: Bearer {token}
```
**Response:** Same as above with additional fields:
- `description`
- `max_stock`
- `rack_location`
- `is_active`
- `unit_conversions` array

**Flutter Status:** ✅ Integrated

---

### Search by Barcode
```
POST /products/barcode
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "barcode": "8991234567890"
}
```
**Flutter Status:** ✅ Integrated

---

## 5. Categories

### Get Categories
```
GET /categories
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Obat Bebas",
      "type": "medicine",
      "category_type": {
        "id": 1,
        "name": "Obat",
        "code": "OBT",
        "color": "#22C55E",
        "requires_prescription": false,
        "is_narcotic": false
      },
      "requires_prescription": false,
      "is_narcotic": false,
      "products_count": 50
    }
  ]
}
```
**Flutter Status:** ✅ Integrated

---

### Get Category Types
```
GET /category-types
Authorization: Bearer {token}
```
**Flutter Status:** ✅ Integrated

---

## 6. Units ⚠️ NEW

### Get Units
```
GET /units
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Tablet",
      "code": "TAB"
    },
    {
      "id": 2,
      "name": "Kapsul",
      "code": "KAP"
    },
    {
      "id": 3,
      "name": "Botol",
      "code": "BTL"
    }
  ]
}
```
**Flutter Status:** ❌ Not Integrated

---

## 7. Payment Methods

### Get Payment Methods
```
GET /payment-methods
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Cash",
      "code": "CASH",
      "is_cash": true
    },
    {
      "id": 2,
      "name": "QRIS",
      "code": "QRIS",
      "is_cash": false
    }
  ]
}
```
**Flutter Status:** ✅ Integrated

---

## 8. Doctors ⚠️ NEW

### Get Doctors
```
GET /doctors
Authorization: Bearer {token}
```
**Query Parameters:**
- `search`: string (search by name, sip_number, specialization, hospital_clinic)
- `per_page`: int (default: 15)
- `page`: int

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "dr. John Doe, Sp.PD",
      "sip_number": "SIP-12345",
      "specialization": "Penyakit Dalam",
      "phone": "081234567890",
      "hospital_clinic": "RS Sehat"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 10
  }
}
```
**Flutter Status:** ❌ Not Integrated

---

### Get Doctor Detail
```
GET /doctors/{id}
Authorization: Bearer {token}
```
**Flutter Status:** ❌ Not Integrated

---

### Create Doctor
```
POST /doctors
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "name": "string (required)",
  "sip_number": "string (optional)",
  "specialization": "string (optional)",
  "phone": "string (optional)",
  "hospital_clinic": "string (optional)"
}
```
**Flutter Status:** ❌ Not Integrated

---

## 9. Store & Settings ⚠️ NEW

### Get Store Info
```
GET /store
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Apotek Sehat",
    "code": "APT001",
    "address": "Jl. Sehat No. 1",
    "phone": "021-1234567",
    "email": "info@apoteksehat.com",
    "sia_number": "SIA-12345",
    "sipa_number": "SIPA-67890",
    "pharmacist_name": "Apt. Jane Doe, S.Farm",
    "pharmacist_sipa": "SIPA-67890",
    "logo": "https://...",
    "receipt_footer": "Terima kasih atas kunjungan Anda"
  }
}
```
**Flutter Status:** ❌ Not Integrated

---

### Get Settings
```
GET /settings
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "general": {
      "app_name": "Apotek POS",
      "currency": "IDR",
      "currency_symbol": "Rp",
      "timezone": "Asia/Jakarta",
      "date_format": "d/m/Y"
    },
    "pos": {
      "tax_rate": "0",
      "default_discount": "0",
      "allow_negative_stock": "false",
      "require_prescription_verification": "true"
    },
    "receipt": {
      "receipt_header": "",
      "receipt_footer": "Terima kasih atas kunjungan Anda",
      "show_logo": "true",
      "paper_size": "80mm"
    },
    "notification": {
      "low_stock_threshold": "10",
      "expiry_warning_days": "30"
    }
  }
}
```
**Flutter Status:** ❌ Not Integrated

---

## 10. Customers

### Get Customers
```
GET /customers
Authorization: Bearer {token}
```
**Query Parameters:**
- `search`: string
- `per_page`: int (default: 15)
- `page`: int

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Customer",
      "phone": "081234567890",
      "email": "john@customer.com",
      "address": "Jl. Customer No. 1",
      "points": 100,
      "birth_date": "1990-01-01"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 50
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Get Customer Detail
```
GET /customers/{id}
Authorization: Bearer {token}
```
**Flutter Status:** ✅ Integrated

---

### Create Customer
```
POST /customers
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "name": "string (required)",
  "phone": "string (optional)",
  "email": "email (optional)",
  "address": "string (optional)",
  "birth_date": "date (optional)"
}
```
**Flutter Status:** ✅ Integrated

---

## 11. Sales

### Get Sales
```
GET /sales
Authorization: Bearer {token}
```
**Query Parameters:**
- `date`: date (Y-m-d)
- `status`: string (completed, pending, cancelled, returned)
- `per_page`: int (default: 15)
- `page`: int

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "invoice_number": "INV-20260110-0001",
      "date": "2026-01-10",
      "customer": {
        "id": 1,
        "name": "John Customer"
      },
      "subtotal": 100000,
      "discount": 5000,
      "tax": 0,
      "total": 95000,
      "status": "completed"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 100
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Get Sale Detail
```
GET /sales/{id}
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "invoice_number": "INV-20260110-0001",
    "date": "2026-01-10",
    "customer": {...},
    "cashier": {...},
    "items": [
      {
        "id": 1,
        "product": {...},
        "batch_number": "BTH-001",
        "unit": "Tablet",
        "quantity": 10,
        "price": 8000,
        "discount": 0,
        "subtotal": 80000
      }
    ],
    "payments": [...],
    "subtotal": 100000,
    "discount": 5000,
    "tax": 0,
    "total": 95000,
    "status": "completed",
    "paid_amount": 100000,
    "change_amount": 5000,
    "notes": null
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Create Sale
```
POST /sales
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "customer_id": "int (optional)",
  "items": [
    {
      "product_id": "int (required)",
      "batch_id": "int (required)",
      "unit_id": "int (optional)",
      "quantity": "int (required, min:1)",
      "price": "numeric (required)",
      "discount": "numeric (optional)"
    }
  ],
  "discount": "numeric (optional)",
  "tax": "numeric (optional)",
  "payments": [
    {
      "payment_method_id": "int (required)",
      "amount": "numeric (required)",
      "reference_number": "string (optional)"
    }
  ],
  "notes": "string (optional)"
}
```
**Flutter Status:** ✅ Integrated

---

### Void Sale ⚠️ NEW
```
POST /sales/{id}/void
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "reason": "string (required)"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Transaksi berhasil dibatalkan",
  "data": {
    "id": 1,
    "invoice_number": "INV-20260110-0001",
    "status": "cancelled"
  }
}
```
**Notes:**
- Only same-day completed sales can be voided
- Stock is automatically restored
- Shift cash is adjusted if cash payment

**Flutter Status:** ❌ Not Integrated

---

### Get Receipt ⚠️ NEW
```
GET /sales/{id}/receipt
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "store": {
      "name": "Apotek Sehat",
      "address": "Jl. Sehat No. 1",
      "phone": "021-1234567",
      "sia_number": "SIA-12345",
      "pharmacist_name": "Apt. Jane Doe",
      "pharmacist_sipa": "SIPA-67890",
      "receipt_footer": "Terima kasih"
    },
    "sale": {
      "id": 1,
      "invoice_number": "INV-20260110-0001",
      "date": "10/01/2026",
      "time": "10:30",
      "cashier": "John Doe",
      "customer": "Umum"
    },
    "items": [
      {
        "name": "Paracetamol 500mg",
        "quantity": 10,
        "unit": "Tablet",
        "price": 8000,
        "discount": 0,
        "subtotal": 80000
      }
    ],
    "summary": {
      "subtotal": 100000,
      "discount": 5000,
      "tax": 0,
      "total": 95000,
      "paid_amount": 100000,
      "change_amount": 5000
    },
    "payments": [
      {
        "method": "Cash",
        "amount": 100000
      }
    ]
  }
}
```
**Flutter Status:** ❌ Not Integrated

---

## 12. Reports

### Get Sales Report
```
GET /reports/sales
Authorization: Bearer {token}
```
**Query Parameters (required):**
- `start_date`: date (Y-m-d)
- `end_date`: date (Y-m-d)

**Response:**
```json
{
  "success": true,
  "data": {
    "period": {
      "start_date": "2026-01-01",
      "end_date": "2026-01-10"
    },
    "summary": {
      "total_transactions": 150,
      "total_sales": 15000000,
      "total_discount": 500000,
      "average_transaction": 100000
    },
    "daily_sales": [
      {
        "date": "2026-01-01",
        "transactions": 15,
        "total": 1500000
      }
    ],
    "top_products": [
      {
        "id": 1,
        "name": "Paracetamol 500mg",
        "code": "OBT001",
        "total_qty": 500,
        "total_sales": 4000000
      }
    ],
    "payment_methods": [
      {
        "name": "Cash",
        "count": 100,
        "total": 10000000
      }
    ]
  }
}
```
**Flutter Status:** ✅ Integrated

---

## 13. Xendit Payment

### Get Xendit Status
```
GET /xendit/status
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "enabled": true,
    "payment_methods": [
      {"code": "QRIS", "name": "QRIS", "icon": "qris"},
      {"code": "GOPAY", "name": "GoPay", "icon": "gopay"},
      {"code": "OVO", "name": "OVO", "icon": "ovo"},
      {"code": "DANA", "name": "DANA", "icon": "dana"},
      {"code": "SHOPEEPAY", "name": "ShopeePay", "icon": "shopeepay"},
      {"code": "LINKAJA", "name": "LinkAja", "icon": "linkaja"}
    ]
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Create Sale with Xendit Payment
```
POST /xendit/sale
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "customer_id": "int (optional)",
  "items": [...],
  "discount": "numeric (optional)",
  "tax": "numeric (optional)",
  "notes": "string (optional)",
  "payment_method_code": "string (required: QRIS|GOPAY|OVO|DANA|SHOPEEPAY|LINKAJA)"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Invoice Xendit berhasil dibuat",
  "data": {
    "sale_id": 1,
    "invoice_number": "INV-20260110-0001",
    "total": 95000,
    "xendit": {
      "transaction_id": 1,
      "external_id": "INV-20260110-0001-XEN",
      "invoice_url": "https://checkout.xendit.co/...",
      "status": "pending",
      "expires_at": "2026-01-10T11:30:00+07:00"
    }
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Create Invoice for Existing Sale
```
POST /xendit/invoice
Authorization: Bearer {token}
```
**Request Body:**
```json
{
  "sale_id": "int (required)",
  "payment_method_code": "string (optional)"
}
```
**Flutter Status:** ✅ Integrated

---

### Check Payment Status
```
GET /xendit/check/{transaction_id}
Authorization: Bearer {token}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "status": "PAID",
    "is_paid": true,
    "is_expired": false,
    "paid_at": "2026-01-10T10:35:00+07:00",
    "payment_method": "QRIS",
    "payment_channel": "QRIS",
    "sale_id": 1
  }
}
```
**Flutter Status:** ✅ Integrated

---

### Cancel Payment
```
POST /xendit/cancel/{transaction_id}
Authorization: Bearer {token}
```
**Flutter Status:** ✅ Integrated

---

### Get Xendit Transactions ⚠️ NEW
```
GET /xendit/transactions
Authorization: Bearer {token}
```
**Query Parameters:**
- `status`: string
- `date`: date
- `per_page`: int (default: 15)

**Flutter Status:** ❌ Not Integrated

---

## 14. Integration Status

### Summary Table

| Feature | Endpoints | Flutter Status | Priority |
|---------|-----------|----------------|----------|
| Authentication | 5/5 | ✅ Complete | - |
| Dashboard | 3/3 | ✅ Complete | - |
| Shift Management | 3/5 | ⚠️ Partial | High |
| Products | 3/3 | ✅ Complete | - |
| Categories | 2/2 | ✅ Complete | - |
| Units | 0/1 | ❌ Missing | Medium |
| Payment Methods | 1/1 | ✅ Complete | - |
| Doctors | 0/3 | ❌ Missing | High |
| Store & Settings | 0/2 | ❌ Missing | High |
| Customers | 3/3 | ✅ Complete | - |
| Sales | 3/5 | ⚠️ Partial | High |
| Reports | 1/1 | ✅ Complete | - |
| Xendit | 5/8 | ⚠️ Partial | Low |

**Total:** 27/42 endpoints integrated (64%)

---

### Missing Endpoints to Implement

#### High Priority
1. **GET /shift/summary** - Shift summary untuk closing
2. **GET /shift/sales** - List transaksi dalam shift
3. **POST /sales/{id}/void** - Void transaksi
4. **GET /sales/{id}/receipt** - Data receipt untuk print
5. **GET /store** - Info toko untuk receipt
6. **GET /settings** - Settings aplikasi
7. **GET /doctors** - List dokter untuk resep

#### Medium Priority
1. **GET /units** - List satuan
2. **GET /doctors/{id}** - Detail dokter
3. **POST /doctors** - Tambah dokter

#### Low Priority
1. **GET /xendit/transactions** - List transaksi Xendit
2. **GET /xendit/settings** - Settings Xendit
3. **POST /xendit/settings/test** - Test koneksi Xendit

---

## 15. Flutter Implementation Guide

### File Structure untuk New Features

```
lib/data/
├── datasources/
│   ├── unit_remote_datasource.dart        # NEW
│   ├── doctor_remote_datasource.dart      # NEW
│   └── store_remote_datasource.dart       # NEW
├── models/
│   ├── unit_model.dart                    # NEW
│   ├── doctor_model.dart                  # NEW
│   ├── store_model.dart                   # NEW
│   ├── settings_model.dart                # NEW
│   └── shift_summary_model.dart           # NEW
```

### Contoh Implementasi Unit Datasource

```dart
// lib/data/datasources/unit_remote_datasource.dart
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../models/unit_model.dart';
import '../../core/constants/variables.dart';

class UnitRemoteDatasource {
  Future<Either<String, List<UnitModel>>> getUnits() async {
    try {
      final token = await AuthLocalDatasource().getToken();
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/v1/units'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final units = (data['data'] as List)
            .map((e) => UnitModel.fromJson(e))
            .toList();
        return Right(units);
      } else {
        return Left('Failed to fetch units');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
```

### Contoh Model Unit

```dart
// lib/data/models/unit_model.dart
class UnitModel {
  final int id;
  final String name;
  final String code;

  UnitModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}
```

### Update Shift Datasource

Tambahkan method berikut ke `shift_remote_datasource.dart`:

```dart
Future<Either<String, ShiftSummaryModel>> getShiftSummary() async {
  try {
    final token = await AuthLocalDatasource().getToken();
    final response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/v1/shift/summary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Right(ShiftSummaryModel.fromJson(data['data']));
    } else {
      return Left('No active shift');
    }
  } catch (e) {
    return Left(e.toString());
  }
}

Future<Either<String, List<ShiftSaleModel>>> getShiftSales({int perPage = 20}) async {
  // Implementation similar to above
}
```

### Update Sale Datasource

Tambahkan method berikut ke `sale_remote_datasource.dart`:

```dart
Future<Either<String, bool>> voidSale(int saleId, String reason) async {
  try {
    final token = await AuthLocalDatasource().getToken();
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/v1/sales/$saleId/void'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode == 200) {
      return const Right(true);
    } else {
      final data = jsonDecode(response.body);
      return Left(data['message'] ?? 'Failed to void sale');
    }
  } catch (e) {
    return Left(e.toString());
  }
}

Future<Either<String, ReceiptModel>> getReceipt(int saleId) async {
  // Implementation for receipt
}
```

---

## Error Handling

Semua API response menggunakan format yang konsisten:

**Success Response:**
```json
{
  "success": true,
  "data": {...},
  "message": "Optional success message"
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description"
}
```

**Validation Error (422):**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

---

## Changelog

### 2026-01-10
- Added `/shift/summary` endpoint
- Added `/shift/sales` endpoint
- Added `/units` endpoint
- Added `/doctors` endpoints (index, show, store)
- Added `/store` endpoint
- Added `/settings` endpoint
- Added `/sales/{id}/void` endpoint
- Added `/sales/{id}/receipt` endpoint

---

**Generated by Claude Code**
