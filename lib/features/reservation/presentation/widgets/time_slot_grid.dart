import 'package:flutter/material.dart';
import 'package:jellomark/features/reservation/domain/entities/available_slot.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<AvailableSlot> slots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;
  final bool isLoading;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    this.selectedTime,
    required this.onTimeSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '예약 가능한 시간이 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: SemanticColors.text.secondary,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isSelected = slot.startTime == selectedTime;

        return _TimeSlotChip(
          time: slot.startTime,
          available: slot.available,
          isSelected: isSelected,
          onTap: slot.available ? () => onTimeSelected(slot.startTime) : null,
        );
      }).toList(),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String time;
  final bool available;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotChip({
    required this.time,
    required this.available,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = SemanticColors.button.primary;
      textColor = Colors.white;
      borderColor = SemanticColors.button.primary;
    } else if (available) {
      backgroundColor = Colors.white;
      textColor = SemanticColors.text.primary;
      borderColor = SemanticColors.border.glass;
    } else {
      backgroundColor = SemanticColors.background.inputDisabled;
      textColor = SemanticColors.text.disabled;
      borderColor = SemanticColors.background.inputDisabled;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
