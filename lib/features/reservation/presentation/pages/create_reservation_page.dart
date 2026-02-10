import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellomark/features/beautishop/domain/entities/service_menu.dart';
import 'package:jellomark/features/reservation/domain/entities/create_reservation_params.dart';
import 'package:jellomark/features/reservation/presentation/providers/available_slots_provider.dart';
import 'package:jellomark/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_calendar.dart';
import 'package:jellomark/features/reservation/presentation/widgets/reservation_summary_card.dart';
import 'package:jellomark/features/reservation/presentation/widgets/time_slot_grid.dart';
import 'package:jellomark/shared/theme/app_gradients.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class CreateReservationPage extends ConsumerStatefulWidget {
  final String shopId;
  final List<ServiceMenu> treatments;

  const CreateReservationPage({
    super.key,
    required this.shopId,
    required this.treatments,
  });

  @override
  ConsumerState<CreateReservationPage> createState() =>
      _CreateReservationPageState();
}

class _CreateReservationPageState
    extends ConsumerState<CreateReservationPage> {
  static const int _memoMaxLength = 200;

  ServiceMenu? _selectedTreatment;
  String? _selectedDate;
  String? _selectedTime;
  late DateTime _displayedMonth;
  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _selectedTreatment != null &&
      _selectedDate != null &&
      _selectedTime != null;

  String _formatYearMonth(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _onTreatmentChanged(ServiceMenu? treatment) {
    setState(() {
      _selectedTreatment = treatment;
      _selectedDate = null;
      _selectedTime = null;
    });

    ref.read(availableSlotsNotifierProvider.notifier).reset();

    if (treatment != null) {
      ref.read(availableDatesNotifierProvider.notifier).loadDates(
            widget.shopId,
            treatment.id,
            _formatYearMonth(_displayedMonth),
          );
    } else {
      ref.read(availableDatesNotifierProvider.notifier).reset();
    }
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _displayedMonth = month;
      _selectedDate = null;
      _selectedTime = null;
    });

    ref.read(availableSlotsNotifierProvider.notifier).reset();

    if (_selectedTreatment != null) {
      ref.read(availableDatesNotifierProvider.notifier).loadDates(
            widget.shopId,
            _selectedTreatment!.id,
            _formatYearMonth(month),
          );
    }
  }

  void _onDateSelected(String date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });

    if (_selectedTreatment != null) {
      ref.read(availableSlotsNotifierProvider.notifier).loadSlots(
            widget.shopId,
            _selectedTreatment!.id,
            date,
          );
    }
  }

  void _onTimeSelected(String time) {
    setState(() => _selectedTime = time);
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    final memo = _memoController.text.trim();
    final params = CreateReservationParams(
      shopId: widget.shopId,
      treatmentId: _selectedTreatment!.id,
      reservationDate: _selectedDate!,
      startTime: _selectedTime!,
      memo: memo.isEmpty ? null : memo,
    );

    await ref
        .read(createReservationNotifierProvider.notifier)
        .createReservation(params);
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createReservationNotifierProvider);
    final datesState = ref.watch(availableDatesNotifierProvider);
    final slotsState = ref.watch(availableSlotsNotifierProvider);

    ref.listen<CreateReservationState>(
      createReservationNotifierProvider,
      (previous, next) {
        if (next.isSuccess) {
          Navigator.of(context).pop(true);
        }
        if (next.error != null && previous?.error != next.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!)),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: SemanticColors.special.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('예약하기'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: SemanticColors.special.transparent,
        foregroundColor: SemanticColors.text.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.softWhiteGradient,
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTreatmentDropdown(),
                  if (_selectedTreatment != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionLabel('날짜 선택'),
                    const SizedBox(height: 8),
                    _buildCalendarSection(datesState),
                  ],
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 24),
                    _buildSectionLabel('시간 선택'),
                    const SizedBox(height: 8),
                    TimeSlotGrid(
                      slots: slotsState.slots,
                      selectedTime: _selectedTime,
                      onTimeSelected: _onTimeSelected,
                      isLoading: slotsState.isLoading,
                    ),
                    if (slotsState.error != null)
                      _buildErrorMessage(slotsState.error!),
                  ],
                  if (_selectedTime != null) ...[
                    const SizedBox(height: 24),
                    ReservationSummaryCard(
                      treatmentName: _selectedTreatment!.name,
                      treatmentPrice: _selectedTreatment!.price,
                      durationMinutes: _selectedTreatment!.durationMinutes,
                      date: _selectedDate!,
                      time: _selectedTime!,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildMemoField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(createState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: SemanticColors.text.primary,
      ),
    );
  }

  Widget _buildTreatmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('시술 선택'),
        const SizedBox(height: 8),
        DropdownButtonFormField<ServiceMenu>(
          initialValue: _selectedTreatment,
          decoration: InputDecoration(
            hintText: '시술을 선택해주세요',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: SemanticColors.border.glass),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: SemanticColors.border.glass),
            ),
          ),
          items: widget.treatments.map((treatment) {
            return DropdownMenuItem(
              value: treatment,
              child: Text(
                '${treatment.name} - ${_formatPrice(treatment.price)}원',
              ),
            );
          }).toList(),
          onChanged: _onTreatmentChanged,
        ),
      ],
    );
  }

  Widget _buildCalendarSection(AvailableDatesState datesState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SemanticColors.border.glass),
      ),
      child: Column(
        children: [
          ReservationCalendar(
            displayedMonth: _displayedMonth,
            availableDates: datesState.dates.toSet(),
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
            onMonthChanged: _onMonthChanged,
            isLoading: datesState.isLoading,
          ),
          if (datesState.error != null)
            _buildErrorMessage(datesState.error!),
          if (!datesState.isLoading && datesState.dates.isEmpty && _selectedTreatment != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '이번 달 예약 가능한 날짜가 없습니다',
                style: TextStyle(
                  fontSize: 13,
                  color: SemanticColors.text.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: SemanticColors.state.error,
        ),
      ),
    );
  }

  Widget _buildMemoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('메모 (선택사항)'),
        const SizedBox(height: 8),
        TextField(
          controller: _memoController,
          maxLength: _memoMaxLength,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '요청사항을 입력해주세요',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: SemanticColors.border.glass),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: SemanticColors.border.glass),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(CreateReservationState state) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: state.isLoading || !_isFormValid ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: SemanticColors.button.primary,
          foregroundColor: SemanticColors.button.secondaryText,
          disabledBackgroundColor: SemanticColors.background.inputDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SemanticColors.indicator.loading,
                ),
              )
            : const Text(
                '예약하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
