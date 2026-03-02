# Tablet View Implementation Guide - Apotek POS

Dokumentasi step-by-step untuk mengimplementasikan tablet view pada aplikasi Apotek POS, berdasarkan pola dari Jago POS app.

---

## Overview

Tablet view menggunakan pendekatan **split-screen layout** dimana:
- **Phone**: Layout single-column dengan bottom sheet untuk cart
- **Tablet**: Layout split-screen (65% produk | 35% cart)

---

## Phase 1: Core Utilities & Responsive Foundation

### Step 1.1: Buat ScreenSize Utility

**File:** `lib/core/utils/screen_size.dart`

```dart
import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class ScreenSize {
  // Breakpoints
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  // Device Detection
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= phoneMaxWidth;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return DeviceType.phone;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Responsive Value Helper
  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }

  // Grid Columns
  static int gridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 3, desktop: 4);
  }

  static int posGridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 4, desktop: 5);
  }

  // Responsive Padding
  static double responsivePadding(BuildContext context) {
    return responsive(context, phone: 16.0, tablet: 24.0, desktop: 32.0);
  }

  // Responsive Font Size
  static double fontSize(BuildContext context, {double base = 14}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.1,
      desktop: base * 1.2,
    );
  }

  // Responsive Spacing
  static double spacing(BuildContext context, {double base = 16}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.25,
      desktop: base * 1.5,
    );
  }
}
```

### Step 1.2: Buat ResponsiveWidget

**File:** `lib/core/widgets/responsive_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ScreenSize.isDesktop(context)) {
          return desktop ?? tablet ?? phone;
        }
        if (ScreenSize.isTablet(context)) {
          return tablet ?? phone;
        }
        return phone;
      },
    );
  }
}
```

### Step 1.3: Buat ResponsiveLayout Builder

**File:** `lib/core/widgets/responsive_layout.dart`

```dart
import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveLayout({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ScreenSize.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}
```

---

## Phase 2: POS Page Tablet Layout (Priority Utama)

### Step 2.1: Restructure POS Page

**File:** `lib/presentation/pos/pages/pos_page.dart`

Ubah untuk menggunakan ResponsiveWidget:

```dart
import '../../../core/widgets/responsive_widget.dart';
import '../widgets/pos_phone_layout.dart';
import '../widgets/pos_tablet_layout.dart';

class POSPage extends StatelessWidget {
  const POSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      phone: POSPhoneLayout(),
      tablet: POSTabletLayout(),
    );
  }
}
```

### Step 2.2: Buat POS Phone Layout

**File:** `lib/presentation/pos/widgets/pos_phone_layout.dart`

Layout untuk phone dengan:
- Full screen product grid (2 kolom)
- Bottom sticky cart summary bar
- Tap untuk buka bottom sheet cart detail

```dart
class POSPhoneLayout extends StatelessWidget {
  // Existing POS layout code moved here
  // - AppBar with search
  // - Category tabs
  // - Product grid (2 columns)
  // - Bottom cart summary bar
  // - Bottom sheet for full cart view
}
```

### Step 2.3: Buat POS Tablet Layout

**File:** `lib/presentation/pos/widgets/pos_tablet_layout.dart`

Layout split-screen:

```dart
class POSTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kasir')),
      body: Row(
        children: [
          // Left Panel - Products (65%)
          Expanded(
            flex: 65,
            child: Column(
              children: [
                // Search Bar
                _buildSearchBar(),
                // Category Tabs
                _buildCategoryTabs(),
                // Product Grid (4 columns)
                Expanded(
                  child: _buildProductGrid(),
                ),
              ],
            ),
          ),

          // Vertical Divider
          const VerticalDivider(width: 1),

          // Right Panel - Cart (35%)
          Expanded(
            flex: 35,
            child: _buildCartPanel(),
          ),
        ],
      ),
    );
  }
}
```

### Step 2.4: Buat Cart Panel Widget (Tablet)

**File:** `lib/presentation/pos/widgets/cart_panel_widget.dart`

Widget cart yang selalu visible di tablet:

```dart
class CartPanelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.shopping_cart),
              SizedBox(width: 8),
              Text('Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              // Clear cart button
            ],
          ),
        ),
        Divider(height: 1),

        // Cart Items List
        Expanded(
          child: BlocBuilder<CheckoutBloc, CheckoutState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return _buildEmptyCart();
              }
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  return _buildCartItem(state.items[index]);
                },
              );
            },
          ),
        ),

        // Summary & Checkout Button
        _buildCartSummary(),
      ],
    );
  }
}
```

---

## Phase 3: Dashboard Tablet Layout

### Step 3.1: Restructure Dashboard Page

**File:** `lib/presentation/dashboard/pages/dashboard_page.dart`

```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      phone: DashboardPhoneLayout(),
      tablet: DashboardTabletLayout(),
    );
  }
}
```

### Step 3.2: Dashboard Phone Layout

**File:** `lib/presentation/dashboard/widgets/dashboard_phone_layout.dart`

- Single column layout
- 2x2 grid untuk summary cards
- Scrollable content

### Step 3.3: Dashboard Tablet Layout

**File:** `lib/presentation/dashboard/widgets/dashboard_tablet_layout.dart`

Split layout (60% | 40%):

```dart
class DashboardTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Column (60%) - Main Stats
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSalesCards(),
                  _buildMonthlyChart(),
                  _buildTopProducts(),
                ],
              ),
            ),
          ),

          // Right Column (40%) - Alerts & Quick Stats
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLowStockAlert(),
                  _buildExpiringAlert(),
                  _buildPaymentMethodsBreakdown(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Phase 4: Transaction History Tablet Layout

### Step 4.1: Split Layout untuk History

**Phone Layout:**
- List transaksi full width
- Tap untuk lihat detail (navigate ke page baru)

**Tablet Layout:**
- Left: List transaksi (40%)
- Right: Detail transaksi selected (60%)
- Master-detail pattern

```dart
class TransactionHistoryTabletLayout extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left - Transaction List
        Expanded(
          flex: 40,
          child: _buildTransactionList(),
        ),
        VerticalDivider(width: 1),
        // Right - Transaction Detail
        Expanded(
          flex: 60,
          child: _selectedTransaction != null
              ? TransactionDetailPanel(transaction: _selectedTransaction!)
              : _buildSelectPrompt(),
        ),
      ],
    );
  }
}
```

---

## Phase 5: Product List Tablet Layout

### Step 5.1: Product Grid Optimization

**Phone:** 2 columns
**Tablet:** 4 columns

```dart
class ProductListTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ScreenSize.responsive(
          context,
          phone: 2,
          tablet: 4,
        ),
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}
```

---

## Phase 6: Report Page Tablet Layout

### Step 6.1: Multi-column Report

**Tablet Layout:**
- Summary cards dalam row (4 columns)
- Charts side-by-side
- Better data visualization

```dart
class ReportTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary Cards - 4 columns
          Row(
            children: [
              Expanded(child: SummaryCard(title: 'Transaksi')),
              SizedBox(width: 16),
              Expanded(child: SummaryCard(title: 'Penjualan')),
              SizedBox(width: 16),
              Expanded(child: SummaryCard(title: 'Diskon')),
              SizedBox(width: 16),
              Expanded(child: SummaryCard(title: 'Rata-rata')),
            ],
          ),

          SizedBox(height: 24),

          // Charts side-by-side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: DailySalesChart()),
              SizedBox(width: 16),
              Expanded(child: PaymentMethodsChart()),
            ],
          ),

          SizedBox(height: 24),

          // Top Products - full width
          TopProductsList(),
        ],
      ),
    );
  }
}
```

---

## Phase 7: Settings & Other Pages

### Step 7.1: Settings Page Tablet

**Tablet Layout:** Two-column settings

```dart
class SettingsTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left - Settings Menu
        Expanded(
          flex: 35,
          child: _buildSettingsMenu(),
        ),
        VerticalDivider(width: 1),
        // Right - Settings Detail
        Expanded(
          flex: 65,
          child: _buildSettingsContent(),
        ),
      ],
    );
  }
}
```

---

## File Structure Summary

```
lib/
├── core/
│   ├── utils/
│   │   └── screen_size.dart          # NEW
│   └── widgets/
│       ├── responsive_widget.dart     # NEW
│       └── responsive_layout.dart     # NEW
│
├── presentation/
│   ├── pos/
│   │   ├── pages/
│   │   │   └── pos_page.dart          # MODIFY
│   │   └── widgets/
│   │       ├── pos_phone_layout.dart  # NEW
│   │       ├── pos_tablet_layout.dart # NEW
│   │       └── cart_panel_widget.dart # NEW
│   │
│   ├── dashboard/
│   │   ├── pages/
│   │   │   └── dashboard_page.dart    # MODIFY
│   │   └── widgets/
│   │       ├── dashboard_phone_layout.dart  # NEW
│   │       └── dashboard_tablet_layout.dart # NEW
│   │
│   ├── transaction/
│   │   ├── pages/
│   │   │   └── transaction_history_page.dart # MODIFY
│   │   └── widgets/
│   │       ├── history_phone_layout.dart     # NEW
│   │       ├── history_tablet_layout.dart    # NEW
│   │       └── transaction_detail_panel.dart # NEW
│   │
│   ├── product/
│   │   └── widgets/
│   │       ├── product_phone_layout.dart  # NEW
│   │       └── product_tablet_layout.dart # NEW
│   │
│   ├── report/
│   │   └── widgets/
│   │       ├── report_phone_layout.dart   # NEW
│   │       └── report_tablet_layout.dart  # NEW
│   │
│   └── settings/
│       └── widgets/
│           ├── settings_phone_layout.dart  # NEW
│           └── settings_tablet_layout.dart # NEW
```

---

## Implementation Priority

| Priority | Page | Effort | Impact |
|----------|------|--------|--------|
| 1 | POS Page | High | Sangat Tinggi |
| 2 | Dashboard | Medium | Tinggi |
| 3 | Transaction History | Medium | Tinggi |
| 4 | Product List | Low | Medium |
| 5 | Report Page | Low | Medium |
| 6 | Settings | Low | Low |

---

## Key Design Patterns

### 1. Split Screen Ratio
- **POS:** 65% (produk) | 35% (cart)
- **Dashboard:** 60% (main) | 40% (sidebar)
- **Transaction:** 40% (list) | 60% (detail)
- **Settings:** 35% (menu) | 65% (content)

### 2. Grid Columns
| Device | Products | Categories | Cards |
|--------|----------|------------|-------|
| Phone | 2 | 2 | 2 |
| Tablet | 4 | 3 | 4 |
| Desktop | 5 | 4 | 4 |

### 3. Padding Scale
| Device | Base Padding |
|--------|-------------|
| Phone | 16px |
| Tablet | 24px |
| Desktop | 32px |

---

## Testing Checklist

- [ ] Phone portrait (< 600px)
- [ ] Phone landscape
- [ ] Tablet portrait (600px - 900px)
- [ ] Tablet landscape (900px - 1024px)
- [ ] Desktop (> 1024px)

---

## Notes

1. **State Management**: Gunakan BLoC yang sama untuk phone dan tablet, hanya UI yang berbeda
2. **Navigation**: Untuk tablet, beberapa navigasi bisa diganti dengan panel selection
3. **Performance**: Lazy load untuk grid items
4. **Orientation**: Test kedua orientasi (portrait & landscape)
