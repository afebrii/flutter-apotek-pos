import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/models/responses/shift_model.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';
import '../bloc/shift_state.dart';

class CloseShiftDialog extends StatefulWidget {
  final ShiftModel currentShift;
  final VoidCallback onSuccess;

  const CloseShiftDialog({
    super.key,
    required this.currentShift,
    required this.onSuccess,
  });

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final _cashController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final cashText = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cash = double.tryParse(cashText) ?? 0;

    if (cash < 0) {
      context.showErrorSnackBar('Kas akhir tidak valid');
      return;
    }

    context.read<ShiftBloc>().add(
          ShiftClose(
            CloseShiftRequest(
              actualCash: cash,
              notes: _notesController.text.isNotEmpty
                  ? _notesController.text
                  : null,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final expectedCash = widget.currentShift.expectedCashAmount;

    return BlocListener<ShiftBloc, ShiftState>(
      listener: (context, state) {
        if (state is ShiftClosed) {
          final diff = state.shift.differenceAmount;
          String message = 'Shift berhasil ditutup';
          if (diff != 0) {
            message += '. Selisih: ${diff.currencyFormatRp}';
          }
          context.showSuccessSnackBar(message);
          Navigator.pop(context);
          widget.onSuccess();
        } else if (state is ShiftError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.access_time_filled,
                          color: AppColors.warning,
                          size: 28,
                        ),
                      ),
                      const SpaceWidth(16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tutup Shift',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SpaceHeight(4),
                            Text(
                              'Masukkan kas akhir',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(24),

                  // Shift summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Modal Awal',
                          widget.currentShift.openingCashAmount.currencyFormatRp,
                        ),
                        const Divider(height: 16),
                        _buildSummaryRow(
                          'Kas Diharapkan',
                          expectedCash.currencyFormatRp,
                          valueColor: AppColors.primary,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SpaceHeight(16),

                  // Cash input
                  CustomTextField(
                    controller: _cashController,
                    label: 'Kas Akhir Aktual (Rp)',
                    hint: 'Masukkan jumlah kas',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  const SpaceHeight(16),

                  // Notes input
                  CustomTextField(
                    controller: _notesController,
                    label: 'Catatan (Opsional)',
                    hint: 'Contoh: Shift selesai normal',
                    maxLines: 2,
                    prefixIcon: const Icon(Icons.notes),
                  ),
                  const SpaceHeight(24),

                  // Buttons
                  BlocBuilder<ShiftBloc, ShiftState>(
                    builder: (context, state) {
                      final isLoading = state is ShiftLoading;
                      return Row(
                        children: [
                          Expanded(
                            child: Button.outlined(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              label: 'Batal',
                            ),
                          ),
                          const SpaceWidth(16),
                          Expanded(
                            child: Button.filled(
                              onPressed: isLoading ? null : _onSubmit,
                              label: 'Tutup Shift',
                              color: AppColors.warning,
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
