class DoctorModel {
  final int id;
  final String name;
  final String? sipNumber;
  final String? specialization;
  final String? phone;
  final String? hospitalClinic;

  DoctorModel({
    required this.id,
    required this.name,
    this.sipNumber,
    this.specialization,
    this.phone,
    this.hospitalClinic,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sipNumber: json['sip_number'],
      specialization: json['specialization'],
      phone: json['phone'],
      hospitalClinic: json['hospital_clinic'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sip_number': sipNumber,
        'specialization': specialization,
        'phone': phone,
        'hospital_clinic': hospitalClinic,
      };
}

class DoctorListResponse {
  final List<DoctorModel> doctors;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  DoctorListResponse({
    required this.doctors,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory DoctorListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] ?? {};

    List<DoctorModel> doctors = [];
    if (data is List) {
      doctors = data.map((e) => DoctorModel.fromJson(e)).toList();
    }

    return DoctorListResponse(
      doctors: doctors,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      perPage: meta['per_page'] ?? 15,
      total: meta['total'] ?? doctors.length,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
}

class CreateDoctorRequest {
  final String name;
  final String? sipNumber;
  final String? specialization;
  final String? phone;
  final String? hospitalClinic;

  CreateDoctorRequest({
    required this.name,
    this.sipNumber,
    this.specialization,
    this.phone,
    this.hospitalClinic,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (sipNumber != null) 'sip_number': sipNumber,
        if (specialization != null) 'specialization': specialization,
        if (phone != null) 'phone': phone,
        if (hospitalClinic != null) 'hospital_clinic': hospitalClinic,
      };
}
