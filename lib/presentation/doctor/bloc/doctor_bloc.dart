import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/doctor_remote_datasource.dart';
import '../../../data/models/responses/doctor_model.dart';
import 'doctor_event.dart';
import 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorRemoteDatasource _datasource;

  DoctorBloc({DoctorRemoteDatasource? datasource})
      : _datasource = datasource ?? DoctorRemoteDatasource(),
        super(DoctorInitial()) {
    on<DoctorFetch>(_onFetch);
    on<DoctorLoadMore>(_onLoadMore);
    on<DoctorSearch>(_onSearch);
    on<DoctorCreate>(_onCreate);
    on<DoctorSelect>(_onSelect);
    on<DoctorClearSelection>(_onClearSelection);
    on<DoctorReset>(_onReset);
  }

  Future<void> _onFetch(DoctorFetch event, Emitter<DoctorState> emit) async {
    emit(DoctorLoading());

    final result = await _datasource.getDoctors(
      search: event.search,
      page: event.page,
    );

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(DoctorError(message: error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(DoctorLoaded(
          doctors: response.doctors,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: event.search,
        ));
      } else {
        emit(DoctorError(message: 'Gagal memuat data dokter'));
      }
    }
  }

  Future<void> _onLoadMore(DoctorLoadMore event, Emitter<DoctorState> emit) async {
    final currentState = state;
    if (currentState is! DoctorLoaded) return;
    if (!currentState.hasNextPage) return;

    emit(DoctorLoadingMore(
      doctors: currentState.doctors,
      currentPage: currentState.currentPage,
      lastPage: currentState.lastPage,
      search: currentState.search,
      selectedDoctor: currentState.selectedDoctor,
    ));

    final result = await _datasource.getDoctors(
      search: currentState.search,
      page: currentState.currentPage + 1,
    );

    if (result.isLeft()) {
      emit(DoctorLoaded(
        doctors: currentState.doctors,
        currentPage: currentState.currentPage,
        lastPage: currentState.lastPage,
        hasNextPage: currentState.hasNextPage,
        search: currentState.search,
        selectedDoctor: currentState.selectedDoctor,
      ));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        final allDoctors = [...currentState.doctors, ...response.doctors];
        emit(DoctorLoaded(
          doctors: allDoctors,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: currentState.search,
          selectedDoctor: currentState.selectedDoctor,
        ));
      } else {
        emit(DoctorLoaded(
          doctors: currentState.doctors,
          currentPage: currentState.currentPage,
          lastPage: currentState.lastPage,
          hasNextPage: currentState.hasNextPage,
          search: currentState.search,
          selectedDoctor: currentState.selectedDoctor,
        ));
      }
    }
  }

  Future<void> _onSearch(DoctorSearch event, Emitter<DoctorState> emit) async {
    DoctorModel? selectedDoctor;
    if (state is DoctorLoaded) {
      selectedDoctor = (state as DoctorLoaded).selectedDoctor;
    }

    emit(DoctorLoading());

    final result = await _datasource.getDoctors(
      search: event.query.isEmpty ? null : event.query,
      page: 1,
    );

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(DoctorError(message: error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(DoctorLoaded(
          doctors: response.doctors,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: event.query.isEmpty ? null : event.query,
          selectedDoctor: selectedDoctor,
        ));
      } else {
        emit(DoctorError(message: 'Gagal memuat data dokter'));
      }
    }
  }

  Future<void> _onCreate(DoctorCreate event, Emitter<DoctorState> emit) async {
    final previousState = state;
    emit(DoctorCreating());

    final result = await _datasource.createDoctor(event.request);

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(DoctorCreateError(message: error));
      // Restore previous state
      if (previousState is DoctorLoaded) {
        emit(previousState);
      }
    } else {
      final doctor = result.fold((l) => null, (r) => r);
      if (doctor != null) {
        emit(DoctorCreated(doctor: doctor));
        // Refresh list after creating
        add(DoctorFetch());
      } else {
        emit(DoctorCreateError(message: 'Gagal menambahkan dokter'));
        if (previousState is DoctorLoaded) {
          emit(previousState);
        }
      }
    }
  }

  void _onSelect(DoctorSelect event, Emitter<DoctorState> emit) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;
      DoctorModel? doctor;

      if (event.doctorId != null) {
        doctor = currentState.doctors.firstWhere(
          (d) => d.id == event.doctorId,
          orElse: () => DoctorModel(
            id: event.doctorId!,
            name: event.doctorName ?? '',
          ),
        );
      }

      emit(currentState.copyWith(selectedDoctor: doctor));
    }
  }

  void _onClearSelection(DoctorClearSelection event, Emitter<DoctorState> emit) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;
      emit(currentState.copyWith(clearSelection: true));
    }
  }

  void _onReset(DoctorReset event, Emitter<DoctorState> emit) {
    emit(DoctorInitial());
  }
}
