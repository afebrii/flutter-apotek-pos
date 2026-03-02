import '../../../data/models/responses/doctor_model.dart';

abstract class DoctorEvent {}

class DoctorFetch extends DoctorEvent {
  final String? search;
  final int page;

  DoctorFetch({this.search, this.page = 1});
}

class DoctorLoadMore extends DoctorEvent {}

class DoctorSearch extends DoctorEvent {
  final String query;

  DoctorSearch(this.query);
}

class DoctorCreate extends DoctorEvent {
  final CreateDoctorRequest request;

  DoctorCreate(this.request);
}

class DoctorSelect extends DoctorEvent {
  final int? doctorId;
  final String? doctorName;

  DoctorSelect({this.doctorId, this.doctorName});
}

class DoctorClearSelection extends DoctorEvent {}

class DoctorReset extends DoctorEvent {}
