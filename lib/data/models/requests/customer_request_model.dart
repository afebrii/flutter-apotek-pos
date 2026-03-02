class CustomerRequestModel {
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? birthDate;

  CustomerRequestModel({
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.birthDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (address != null && address!.isNotEmpty) 'address': address,
        if (birthDate != null && birthDate!.isNotEmpty) 'birth_date': birthDate,
      };
}
