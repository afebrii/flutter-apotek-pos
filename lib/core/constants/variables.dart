class Variables {
  // Base URL - Ganti dengan IP server
  // static const String baseUrl = 'https://apotek.jagoflutter.my.id';
  static const String baseUrl = 'http://192.168.1.6:8000';
  static const String apiBaseUrl = '$baseUrl/api/v1';

  // Auth
  static const String login = '$apiBaseUrl/login';
  static const String logout = '$apiBaseUrl/logout';
  static const String me = '$apiBaseUrl/me';
  static const String updateProfile = '$apiBaseUrl/profile';
  static const String changePassword = '$apiBaseUrl/change-password';

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
  static const String categoryTypes = '$apiBaseUrl/category-types';

  // Payment Methods
  static const String paymentMethods = '$apiBaseUrl/payment-methods';

  // Customers
  static const String customers = '$apiBaseUrl/customers';

  // Sales
  static const String sales = '$apiBaseUrl/sales';

  // Reports
  static const String reportSales = '$apiBaseUrl/reports/sales';

  // Shift - Additional endpoints
  static const String shiftSummary = '$apiBaseUrl/shift/summary';
  static const String shiftSales = '$apiBaseUrl/shift/sales';

  // Doctors
  static const String doctors = '$apiBaseUrl/doctors';

  // Store & Settings
  static const String store = '$apiBaseUrl/store';
  static const String settings = '$apiBaseUrl/settings';

  // Units
  static const String units = '$apiBaseUrl/units';

  // Xendit
  static const String xenditStatus = '$apiBaseUrl/xendit/status';
  static const String xenditSale = '$apiBaseUrl/xendit/sale';
  static const String xenditInvoice = '$apiBaseUrl/xendit/invoice';
  static const String xenditCheck = '$apiBaseUrl/xendit/check';
  static const String xenditCancel = '$apiBaseUrl/xendit/cancel';
  static const String xenditTransactions = '$apiBaseUrl/xendit/transactions';

  // Payment Methods (must match backend seeder IDs)
  static const int paymentCash = 1;
  static const int paymentDebitBCA = 2;
  static const int paymentDebitMandiri = 3;
  static const int paymentDebitBRI = 4;
  static const int paymentDebitBNI = 5;
  static const int paymentQris = 6;
  static const int paymentGopay = 7;
  static const int paymentOvo = 8;
  static const int paymentDana = 9;
  static const int paymentShopeepay = 10;
  static const int paymentLinkaja = 11;
  static const int paymentTransfer = 12;
  static const int paymentCredit = 13;
}
