import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/search_input.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/datasources/doctor_remote_datasource.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../widgets/doctor_list_item.dart';
import '../widgets/add_doctor_dialog.dart';

class DoctorListPage extends StatelessWidget {
  final bool selectionMode;

  const DoctorListPage({
    super.key,
    this.selectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorBloc(
        datasource: DoctorRemoteDatasource(),
      )..add(DoctorFetch()),
      child: _DoctorListContent(selectionMode: selectionMode),
    );
  }
}

class _DoctorListContent extends StatefulWidget {
  final bool selectionMode;

  const _DoctorListContent({
    required this.selectionMode,
  });

  @override
  State<_DoctorListContent> createState() => _DoctorListContentState();
}

class _DoctorListContentState extends State<_DoctorListContent> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DoctorBloc>().add(DoctorLoadMore());
    }
  }

  void _onSearch(String query) {
    context.read<DoctorBloc>().add(DoctorSearch(query));
  }

  void _showAddDoctorDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<DoctorBloc>(),
        child: const AddDoctorDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? 'Pilih Dokter' : 'Dokter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddDoctorDialog,
          ),
        ],
      ),
      body: BlocConsumer<DoctorBloc, DoctorState>(
        listener: (context, state) {
          if (state is DoctorCreated) {
            context.showSuccessSnackBar('Dokter berhasil ditambahkan');
            if (widget.selectionMode) {
              Navigator.pop(context, state.doctor);
            }
          } else if (state is DoctorCreateError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.white,
                child: SearchInput(
                  controller: _searchController,
                  hintText: 'Cari nama, SIP, atau spesialisasi...',
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _onSearch(value);
                      }
                    });
                  },
                  onSubmitted: _onSearch,
                  onClear: () => _onSearch(''),
                ),
              ),

              // Doctor list
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDoctorDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildContent(DoctorState state) {
    if (state is DoctorLoading) {
      return const LoadingPage(message: 'Memuat dokter...');
    }

    if (state is DoctorError) {
      return ErrorState(
        message: state.message,
        onRetry: () => context.read<DoctorBloc>().add(DoctorFetch()),
      );
    }

    if (state is DoctorLoaded || state is DoctorLoadingMore) {
      final doctors = state is DoctorLoaded
          ? state.doctors
          : (state as DoctorLoadingMore).doctors;

      if (doctors.isEmpty) {
        return const EmptyState(
          icon: Icons.person_search,
          title: 'Tidak ada dokter',
          subtitle: 'Tambahkan dokter baru dengan tombol +',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<DoctorBloc>().add(DoctorFetch());
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: doctors.length + (state is DoctorLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= doctors.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final doctor = doctors[index];
            return DoctorListItem(
              doctor: doctor,
              onTap: widget.selectionMode
                  ? () => Navigator.pop(context, doctor)
                  : null,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
