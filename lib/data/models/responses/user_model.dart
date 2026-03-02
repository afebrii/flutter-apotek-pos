class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final int? storeId;
  final bool isActive;
  final StoreModel? store;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.storeId,
    this.isActive = true,
    this.store,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'cashier',
      phone: json['phone'],
      storeId: json['store_id'],
      isActive: json['is_active'] ?? true,
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
        'is_active': isActive,
        'store': store?.toJson(),
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    int? storeId,
    bool? isActive,
    StoreModel? store,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      storeId: storeId ?? this.storeId,
      isActive: isActive ?? this.isActive,
      store: store ?? this.store,
    );
  }
}

class StoreModel {
  final int id;
  final String name;
  final String? address;
  final String? phone;

  StoreModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
      };
}
