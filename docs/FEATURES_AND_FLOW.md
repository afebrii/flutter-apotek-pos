# Fitur dan Alur Aplikasi Flutter Apotek POS

Dokumentasi lengkap mengenai fitur-fitur dan alur kerja aplikasi Apotek POS.

---

## Daftar Isi

1. [Overview Aplikasi](#overview-aplikasi)
2. [Fitur Utama](#fitur-utama)
3. [Alur Kerja (User Flow)](#alur-kerja-user-flow)
4. [Detail Fitur](#detail-fitur)
5. [Role & Permission](#role--permission)
6. [Integrasi Payment Gateway](#integrasi-payment-gateway)

---

## Overview Aplikasi

**Flutter Apotek POS** adalah aplikasi Point of Sale (kasir) yang didesain khusus untuk apotek dengan fitur-fitur seperti:

- Sistem kasir dengan manajemen shift
- Manajemen produk obat dengan tracking stok dan kadaluarsa
- Dashboard analytics
- Laporan penjualan
- Integrasi pembayaran digital (Xendit)
- Support untuk printer thermal Bluetooth
- Responsive design (Phone & Tablet)

### Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.10+ |
| **State Management** | flutter_bloc |
| **Network** | http package |
| **Local Storage** | shared_preferences, sqflite |
| **Printer** | print_bluetooth_thermal, esc_pos_utils_plus |
| **Payment Gateway** | Xendit (via webview) |

---

## Fitur Utama

### 1. Authentication
- Login dengan email/password
- Auto-login dengan token tersimpan
- Logout dengan konfirmasi

### 2. Shift Management
- Buka shift dengan input modal awal
- Tutup shift dengan ringkasan transaksi
- Tracking transaksi per shift

### 3. Point of Sale (Kasir)
- Browse produk berdasarkan kategori
- Pencarian produk
- Keranjang belanja
- Checkout dengan multiple payment method
- Print struk via Bluetooth

### 4. Manajemen Produk
- List produk dengan filter kategori
- Detail produk (stok, harga, batch, kadaluarsa)
- Tracking multi-batch per produk

### 5. Manajemen Pelanggan
- Daftar pelanggan
- Tambah pelanggan baru
- Pilih pelanggan saat checkout

### 6. Dashboard & Analytics
- Ringkasan penjualan hari ini
- Total transaksi
- Produk terlaris
- Stok rendah alert
- Produk kadaluarsa alert

### 7. Laporan
- Laporan penjualan harian
- Filter berdasarkan periode
- Export data

### 8. Stock Management
- Monitoring stok rendah
- Alert produk mendekati kadaluarsa
- Multi-unit support (tablet, strip, box, dll)

### 9. Settings
- Profil pengguna
- Pengaturan printer
- Pengaturan struk
- Info toko

---

## Alur Kerja (User Flow)

### Flow 1: Login → Buka Shift → Kasir

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Splash     │────▶│    Login     │────▶│    Home     │
│  Screen     │     │    Page      │     │    Page     │
└─────────────┘     └──────────────┘     └──────┬──────┘
                                                │
                    ┌──────────────────────────┘
                    │
                    ▼
        ┌─────────────────────┐
        │   Shift Belum Buka? │
        │   (Dialog Muncul)   │
        └──────────┬──────────┘
                   │
                   ▼
        ┌─────────────────────┐     ┌─────────────┐
        │   Open Shift        │────▶│  POS Page   │
        │   (Input Modal)     │     │  (Kasir)    │
        └─────────────────────┘     └─────────────┘
```

### Flow 2: Proses Checkout

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  POS Page   │────▶│   Pilih      │────▶│  Tambah ke  │
│  (Kasir)    │     │   Produk     │     │  Keranjang  │
└─────────────┘     └──────────────┘     └──────┬──────┘
                                                │
                    ┌──────────────────────────┘
                    │
                    ▼
        ┌─────────────────────┐
        │   Checkout Page     │
        │   - Review Items    │
        │   - Pilih Customer  │
        │   - Pilih Dokter    │
        └──────────┬──────────┘
                   │
                   ▼
        ┌─────────────────────┐
        │   Payment Page      │
        │   - Pilih Metode    │
        │   - Input Nominal   │
        │   - Hitung Kembalian│
        └──────────┬──────────┘
                   │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
  ┌────────────┐    ┌────────────┐
  │   Cash     │    │  Digital   │
  │  Payment   │    │  (Xendit)  │
  └─────┬──────┘    └─────┬──────┘
        │                 │
        │                 ▼
        │          ┌────────────┐
        │          │  Webview   │
        │          │  Payment   │
        │          └─────┬──────┘
        │                │
        ▼                ▼
        ┌─────────────────────┐
        │    Invoice Page     │
        │    - Detail Struk   │
        │    - Print Button   │
        └─────────────────────┘
```

### Flow 3: Tutup Shift

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Home Page  │────▶│  Shift Info  │────▶│ Close Shift │
│             │     │   Widget     │     │   Dialog    │
└─────────────┘     └──────────────┘     └──────┬──────┘
                                                │
                                                ▼
                                    ┌─────────────────────┐
                                    │   Summary Dialog    │
                                    │   - Total Penjualan │
                                    │   - Jumlah Transaksi│
                                    │   - Modal Akhir     │
                                    └──────────┬──────────┘
                                               │
                                               ▼
                                    ┌─────────────────────┐
                                    │  Konfirmasi Tutup   │
                                    └─────────────────────┘
```

---

## Detail Fitur

### 1. Authentication

**Login Page** (`lib/presentation/auth/pages/login_page.dart`)
- Form input email dan password
- Validasi input
- Handle error (wrong credentials, network error)
- Simpan token ke local storage

**Splash Page** (`lib/presentation/auth/pages/splash_page.dart`)
- Cek token tersimpan
- Auto-login jika token valid
- Redirect ke Login jika tidak ada token

### 2. Shift Management

**Open Shift Dialog** (`lib/presentation/shift/widgets/open_shift_dialog.dart`)
- Input modal awal (starting cash)
- Catatan opsional
- Validasi minimum modal

**Close Shift Dialog** (`lib/presentation/shift/widgets/close_shift_dialog.dart`)
- Ringkasan shift:
  - Waktu buka - tutup
  - Total penjualan per metode pembayaran
  - Jumlah transaksi
  - Total omzet
- Input modal akhir untuk validasi
- Catatan opsional

### 3. Point of Sale

**POS Page** (`lib/presentation/pos/pages/pos_page.dart`)
- Grid produk dengan gambar, nama, harga
- Filter kategori (chips)
- Search bar
- Cart panel (sidebar di tablet, bottom sheet di phone)

**Komponen:**
- `CategoryChip` - Filter kategori
- `CartItemWidget` - Item di keranjang
- `CartPanelWidget` - Panel keranjang (tablet)
- `CartBottomSheet` - Bottom sheet keranjang (phone)

**Layout Responsive:**
- `POSTabletLayout` - Layout untuk tablet (2 kolom)
- `POSPhoneLayout` - Layout untuk phone (1 kolom)

### 4. Checkout

**Checkout Page** (`lib/presentation/pos/pages/checkout_page.dart`)
- Review item yang dibeli
- Edit quantity
- Pilih customer (opsional)
- Pilih dokter (untuk resep)
- Subtotal, diskon, total

**Payment Page** (`lib/presentation/pos/pages/payment_page.dart`)
- Pilih metode pembayaran:
  - Cash
  - Debit (BCA, Mandiri, BRI, BNI)
  - E-wallet (GoPay, OVO, Dana, ShopeePay, LinkAja)
  - QRIS
  - Transfer
- Input nominal bayar
- Kalkulasi kembalian otomatis

### 5. Invoice/Struk

**Invoice Page** (`lib/presentation/pos/pages/invoice_page.dart`)
- Preview struk
- Detail toko
- List item yang dibeli
- Total, bayar, kembalian
- Tombol print
- Tombol selesai

### 6. Xendit Payment

**Xendit Payment Page** (`lib/presentation/xendit/pages/xendit_payment_page.dart`)
- WebView untuk halaman pembayaran Xendit
- Auto-check status pembayaran
- Callback saat pembayaran berhasil/gagal

### 7. Dashboard

**Dashboard Page** (`lib/presentation/dashboard/pages/dashboard_page.dart`)
- Summary cards:
  - Penjualan hari ini
  - Jumlah transaksi
  - Rata-rata per transaksi
- List produk stok rendah
- List produk mendekati kadaluarsa
- Quick access ke halaman detail

### 8. Transaction History

**Transaction History Page** (`lib/presentation/transaction/pages/transaction_history_page.dart`)
- List transaksi dengan filter tanggal
- Search by invoice number
- Status pembayaran
- Detail per transaksi

**Transaction Detail Page** (`lib/presentation/transaction/pages/transaction_detail_page.dart`)
- Detail lengkap transaksi
- Item yang dibeli
- Info pembayaran
- Opsi reprint struk

### 9. Product Management

**Product List Page** (`lib/presentation/product/pages/product_list_page.dart`)
- Grid/list produk
- Filter kategori
- Search
- Quick view stok

**Product Detail Page** (`lib/presentation/product/pages/product_detail_page.dart`)
- Info lengkap produk
- Batch dan stok per batch
- Tanggal kadaluarsa
- History penjualan

### 10. Customer Management

**Customer List Page** (`lib/presentation/customer/pages/customer_list_page.dart`)
- Daftar pelanggan
- Search
- Add new customer

**Add Customer Dialog** (`lib/presentation/customer/widgets/add_customer_dialog.dart`)
- Form input: nama, phone, alamat
- Validasi input

### 11. Reports

**Report Page** (`lib/presentation/report/pages/report_page.dart`)
- Filter periode (hari ini, minggu ini, bulan ini, custom)
- Chart penjualan
- Top selling products
- Summary per kategori

### 12. Stock Alerts

**Low Stock Page** (`lib/presentation/stock/pages/low_stock_page.dart`)
- List produk dengan stok di bawah minimum
- Quick link ke detail produk

**Expiring Page** (`lib/presentation/stock/pages/expiring_page.dart`)
- List batch yang mendekati kadaluarsa
- Filter berdasarkan periode
- Status: akan expired, sudah expired

### 13. Settings

**Settings Page** (`lib/presentation/settings/pages/settings_page.dart`)
Menu pengaturan:
- Profil pengguna
- Pengaturan toko
- Pengaturan struk
- Pengaturan printer
- About

**Printer Settings Page** (`lib/presentation/settings/pages/printer_settings_page.dart`)
- Scan printer Bluetooth
- Pair dan connect
- Test print

**Receipt Settings Page** (`lib/presentation/settings/pages/receipt_settings_page.dart`)
- Logo toko
- Header/footer struk
- Info tambahan

---

## Role & Permission

Aplikasi mendukung multiple user roles:

| Role | Akses |
|------|-------|
| **Admin** | Semua fitur |
| **Kasir** | POS, Transaction History, limited Settings |
| **Viewer** | Dashboard, Reports (read-only) |

---

## Integrasi Payment Gateway

### Xendit Integration

Aplikasi terintegrasi dengan Xendit untuk pembayaran digital:

**Flow Pembayaran Xendit:**
1. User pilih metode pembayaran digital
2. Aplikasi create invoice ke server
3. Server forward ke Xendit API
4. User redirect ke halaman Xendit (WebView)
5. User melakukan pembayaran
6. Xendit callback ke server
7. Aplikasi polling status pembayaran
8. Jika berhasil, transaksi dicatat

**Metode yang Didukung:**
- QRIS
- E-wallet (OVO, Dana, GoPay, ShopeePay, LinkAja)
- Virtual Account

**API Endpoints:**
```
POST /api/v1/xendit/sale        - Create invoice
GET  /api/v1/xendit/status      - Check Xendit integration status
GET  /api/v1/xendit/invoice/:id - Get invoice detail
GET  /api/v1/xendit/check/:id   - Check payment status
POST /api/v1/xendit/cancel/:id  - Cancel invoice
```

---

## Print Struk

### Printer Bluetooth Thermal

Aplikasi mendukung printer thermal Bluetooth 58mm/80mm:

**Supported Printers:**
- Generic ESC/POS thermal printers
- Epson TM series
- Xprinter
- Dan printer thermal lain yang support ESC/POS

**Setup:**
1. Buka Settings → Printer Settings
2. Aktifkan Bluetooth di HP
3. Scan printer
4. Pilih dan pair printer
5. Test print

**Printer Service** (`lib/core/services/printer_service.dart`)
- Connect/disconnect printer
- Print receipt dengan format ESC/POS
- Handle printer errors

---

## Responsive Design

Aplikasi didesain responsive untuk berbagai ukuran layar:

### Phone Layout
- Single column view
- Bottom navigation untuk cart
- Full-screen pages

### Tablet Layout
- Split view (master-detail)
- Sidebar untuk cart
- More information density

**Breakpoint:**
- Phone: < 600dp
- Tablet: >= 600dp

**Responsive Layout Widget** (`lib/core/widgets/responsive_layout.dart`)
```dart
ResponsiveLayout(
  phoneLayout: PhoneLayout(),
  tabletLayout: TabletLayout(),
)
```

---

## Diagram Entity Relationship

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    User      │     │    Shift     │     │    Sale      │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │     │ id           │     │ id           │
│ name         │◄────┤ user_id      │◄────┤ shift_id     │
│ email        │     │ opened_at    │     │ customer_id  │
│ role         │     │ closed_at    │     │ doctor_id    │
└──────────────┘     │ starting_cash│     │ total        │
                     │ ending_cash  │     │ payment_method│
                     └──────────────┘     │ created_at   │
                                          └──────┬───────┘
                                                 │
                     ┌───────────────────────────┘
                     │
                     ▼
              ┌──────────────┐     ┌──────────────┐
              │  Sale Item   │     │   Product    │
              ├──────────────┤     ├──────────────┤
              │ id           │     │ id           │
              │ sale_id      │     │ name         │
              │ product_id   │────▶│ barcode      │
              │ quantity     │     │ category_id  │
              │ price        │     │ price        │
              │ subtotal     │     │ stock        │
              └──────────────┘     └──────────────┘
```

---

## Summary API Endpoints

| Module | Endpoints |
|--------|-----------|
| **Auth** | `/login`, `/logout`, `/me`, `/profile` |
| **Shift** | `/shift/current`, `/shift/open`, `/shift/close`, `/shift/summary` |
| **Products** | `/products`, `/products/barcode` |
| **Categories** | `/categories`, `/category-types` |
| **Customers** | `/customers` |
| **Sales** | `/sales` |
| **Dashboard** | `/dashboard/summary`, `/dashboard/low-stock`, `/dashboard/expiring` |
| **Reports** | `/reports/sales` |
| **Doctors** | `/doctors` |
| **Xendit** | `/xendit/status`, `/xendit/sale`, `/xendit/invoice`, `/xendit/check` |

---

*Dokumentasi ini terakhir diperbarui: Januari 2025*
