class XenditStatusResponse {
  final bool success;
  final XenditStatusData data;

  XenditStatusResponse({
    required this.success,
    required this.data,
  });

  factory XenditStatusResponse.fromJson(Map<String, dynamic> json) {
    return XenditStatusResponse(
      success: json['success'] ?? false,
      data: XenditStatusData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.toJson(),
      };
}

class XenditStatusData {
  final bool enabled;
  final List<XenditPaymentMethod> paymentMethods;

  XenditStatusData({
    required this.enabled,
    required this.paymentMethods,
  });

  factory XenditStatusData.fromJson(Map<String, dynamic> json) {
    return XenditStatusData(
      enabled: json['enabled'] ?? false,
      paymentMethods: json['payment_methods'] != null
          ? (json['payment_methods'] as List)
              .map((e) => XenditPaymentMethod.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'payment_methods': paymentMethods.map((e) => e.toJson()).toList(),
      };
}

class XenditPaymentMethod {
  final String code;
  final String name;
  final String icon;

  XenditPaymentMethod({
    required this.code,
    required this.name,
    required this.icon,
  });

  factory XenditPaymentMethod.fromJson(Map<String, dynamic> json) {
    return XenditPaymentMethod(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'icon': icon,
      };
}
