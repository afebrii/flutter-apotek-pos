class CustomerModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final int points;
  final String? birthDate;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.points = 0,
    this.birthDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      points: json['points'] ?? 0,
      birthDate: json['birth_date'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'points': points,
        'birth_date': birthDate,
      };
}

class CustomerListResponse {
  final List<CustomerModel> customers;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  CustomerListResponse({
    required this.customers,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] ?? data;

    List<CustomerModel> customers = [];
    if (data != null) {
      final customerList = data['data'] ?? data;
      if (customerList is List) {
        customers = customerList.map((e) => CustomerModel.fromJson(e)).toList();
      }
    }

    return CustomerListResponse(
      customers: customers,
      currentPage: meta?['current_page'] ?? 1,
      lastPage: meta?['last_page'] ?? 1,
      perPage: meta?['per_page'] ?? 15,
      total: meta?['total'] ?? customers.length,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
}
