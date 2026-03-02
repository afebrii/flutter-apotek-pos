import '../../../data/models/responses/doctor_model.dart';

abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final String? search;
  final DoctorModel? selectedDoctor;

  DoctorLoaded({
    required this.doctors,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
    this.search,
    this.selectedDoctor,
  });

  DoctorLoaded copyWith({
    List<DoctorModel>? doctors,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? search,
    DoctorModel? selectedDoctor,
    bool clearSelection = false,
  }) {
    return DoctorLoaded(
      doctors: doctors ?? this.doctors,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      search: search ?? this.search,
      selectedDoctor: clearSelection ? null : (selectedDoctor ?? this.selectedDoctor),
    );
  }
}

class DoctorLoadingMore extends DoctorState {
  final List<DoctorModel> doctors;
  final int currentPage;
  final int lastPage;
  final String? search;
  final DoctorModel? selectedDoctor;

  DoctorLoadingMore({
    required this.doctors,
    required this.currentPage,
    required this.lastPage,
    this.search,
    this.selectedDoctor,
  });
}

class DoctorCreating extends DoctorState {}

class DoctorCreated extends DoctorState {
  final DoctorModel doctor;

  DoctorCreated({required this.doctor});
}

class DoctorCreateError extends DoctorState {
  final String message;

  DoctorCreateError({required this.message});
}

class DoctorError extends DoctorState {
  final String message;

  DoctorError({required this.message});
}
