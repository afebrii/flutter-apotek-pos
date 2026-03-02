class StoreModel {
  final int id;
  final String name;
  final String? code;
  final String? address;
  final String? phone;
  final String? email;
  final String? siaNumber;
  final String? sipaNumber;
  final String? pharmacistName;
  final String? pharmacistSipa;
  final String? logo;
  final String? receiptFooter;

  StoreModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.phone,
    this.email,
    this.siaNumber,
    this.sipaNumber,
    this.pharmacistName,
    this.pharmacistSipa,
    this.logo,
    this.receiptFooter,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      siaNumber: json['sia_number'],
      sipaNumber: json['sipa_number'],
      pharmacistName: json['pharmacist_name'],
      pharmacistSipa: json['pharmacist_sipa'],
      logo: json['logo'],
      receiptFooter: json['receipt_footer'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'address': address,
        'phone': phone,
        'email': email,
        'sia_number': siaNumber,
        'sipa_number': sipaNumber,
        'pharmacist_name': pharmacistName,
        'pharmacist_sipa': pharmacistSipa,
        'logo': logo,
        'receipt_footer': receiptFooter,
      };
}

class SettingsModel {
  final GeneralSettings general;
  final PosSettings pos;
  final ReceiptSettings receipt;
  final NotificationSettings notification;

  SettingsModel({
    required this.general,
    required this.pos,
    required this.receipt,
    required this.notification,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      general: GeneralSettings.fromJson(json['general'] ?? {}),
      pos: PosSettings.fromJson(json['pos'] ?? {}),
      receipt: ReceiptSettings.fromJson(json['receipt'] ?? {}),
      notification: NotificationSettings.fromJson(json['notification'] ?? {}),
    );
  }
}

class GeneralSettings {
  final String appName;
  final String currency;
  final String currencySymbol;
  final String timezone;
  final String dateFormat;

  GeneralSettings({
    required this.appName,
    required this.currency,
    required this.currencySymbol,
    required this.timezone,
    required this.dateFormat,
  });

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      appName: json['app_name'] ?? 'Apotek POS',
      currency: json['currency'] ?? 'IDR',
      currencySymbol: json['currency_symbol'] ?? 'Rp',
      timezone: json['timezone'] ?? 'Asia/Jakarta',
      dateFormat: json['date_format'] ?? 'd/m/Y',
    );
  }
}

class PosSettings {
  final String taxRate;
  final String defaultDiscount;
  final bool allowNegativeStock;
  final bool requirePrescriptionVerification;

  PosSettings({
    required this.taxRate,
    required this.defaultDiscount,
    required this.allowNegativeStock,
    required this.requirePrescriptionVerification,
  });

  factory PosSettings.fromJson(Map<String, dynamic> json) {
    return PosSettings(
      taxRate: json['tax_rate']?.toString() ?? '0',
      defaultDiscount: json['default_discount']?.toString() ?? '0',
      allowNegativeStock: json['allow_negative_stock'] == 'true' ||
          json['allow_negative_stock'] == true,
      requirePrescriptionVerification:
          json['require_prescription_verification'] == 'true' ||
              json['require_prescription_verification'] == true,
    );
  }

  double get taxRateValue => double.tryParse(taxRate) ?? 0;
  double get defaultDiscountValue => double.tryParse(defaultDiscount) ?? 0;
}

class ReceiptSettings {
  final String receiptHeader;
  final String receiptFooter;
  final bool showLogo;
  final String paperSize;

  ReceiptSettings({
    required this.receiptHeader,
    required this.receiptFooter,
    required this.showLogo,
    required this.paperSize,
  });

  factory ReceiptSettings.fromJson(Map<String, dynamic> json) {
    return ReceiptSettings(
      receiptHeader: json['receipt_header'] ?? '',
      receiptFooter: json['receipt_footer'] ?? 'Terima kasih atas kunjungan Anda',
      showLogo: json['show_logo'] == 'true' || json['show_logo'] == true,
      paperSize: json['paper_size'] ?? '80mm',
    );
  }
}

class NotificationSettings {
  final int lowStockThreshold;
  final int expiryWarningDays;

  NotificationSettings({
    required this.lowStockThreshold,
    required this.expiryWarningDays,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      lowStockThreshold: int.tryParse(json['low_stock_threshold']?.toString() ?? '10') ?? 10,
      expiryWarningDays: int.tryParse(json['expiry_warning_days']?.toString() ?? '30') ?? 30,
    );
  }
}
