import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/buttons.dart';
import '../../../data/models/responses/doctor_model.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';

class AddDoctorDialog extends StatefulWidget {
  const AddDoctorDialog({super.key});

  @override
  State<AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sipNumberController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hospitalClinicController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _sipNumberController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _hospitalClinicController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = CreateDoctorRequest(
        name: _nameController.text.trim(),
        sipNumber: _sipNumberController.text.trim().isEmpty
            ? null
            : _sipNumberController.text.trim(),
        specialization: _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        hospitalClinic: _hospitalClinicController.text.trim().isEmpty
            ? null
            : _hospitalClinicController.text.trim(),
      );

      context.read<DoctorBloc>().add(DoctorCreate(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorBloc, DoctorState>(
      listener: (context, state) {
        if (state is DoctorCreating) {
          setState(() => _isLoading = true);
        } else if (state is DoctorCreated) {
          setState(() => _isLoading = false);
          Navigator.pop(context, state.doctor);
        } else if (state is DoctorCreateError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tambah Dokter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name field (required)
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nama Dokter *',
                    hint: 'Contoh: dr. John Doe, Sp.PD',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),

                  // SIP Number
                  CustomTextField(
                    controller: _sipNumberController,
                    label: 'Nomor SIP',
                    hint: 'Contoh: SIP-12345',
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  const SizedBox(height: 16),

                  // Specialization
                  CustomTextField(
                    controller: _specializationController,
                    label: 'Spesialisasi',
                    hint: 'Contoh: Penyakit Dalam',
                    prefixIcon: const Icon(Icons.medical_services_outlined),
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Nomor Telepon',
                    hint: 'Contoh: 081234567890',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Hospital/Clinic
                  CustomTextField(
                    controller: _hospitalClinicController,
                    label: 'Rumah Sakit / Klinik',
                    hint: 'Contoh: RS Sehat',
                    prefixIcon: const Icon(Icons.local_hospital_outlined),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Button.outlined(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          label: 'Batal',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Button.filled(
                          onPressed: _isLoading ? null : _submit,
                          label: _isLoading ? 'Menyimpan...' : 'Simpan',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
