import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ReservationCalendar extends StatelessWidget {
  static const List<String> _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  final DateTime displayedMonth;
  final Set<String> availableDates;
  final String? selectedDate;
  final ValueChanged<String> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final bool isLoading;

  const ReservationCalendar({
    super.key,
    required this.displayedMonth,
    required this.availableDates,
    this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthHeader(),
        const SizedBox(height: 12),
        _buildWeekdayHeader(),
        const SizedBox(height: 4),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildDayGrid(),
      ],
    );
  }

  Widget _buildMonthHeader() {
    final year = displayedMonth.year;
    final month = displayedMonth.month;
    final now = DateTime.now();
    final canGoPrevious =
        year > now.year || (year == now.year && month > now.month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: canGoPrevious
              ? () => onMonthChanged(
                  DateTime(year, month - 1))
              : null,
          icon: const Icon(Icons.chevron_left),
          iconSize: 24,
        ),
        Text(
          '$year년 $month월',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: SemanticColors.text.primary,
          ),
        ),
        IconButton(
          onPressed: () =>
              onMonthChanged(DateTime(year, month + 1)),
          icon: const Icon(Icons.chevron_right),
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _weekdays.map((day) {
        final color = day == '일'
            ? Colors.red.shade300
            : day == '토'
                ? Colors.blue.shade300
                : SemanticColors.text.secondary;
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayGrid() {
    final year = displayedMonth.year;
    final month = displayedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    final cells = <Widget>[];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    final today = DateTime.now();
    final todayString = _formatDate(today);

    for (int day = 1; day <= lastDay.day; day++) {
      final dateString = _formatDate(DateTime(year, month, day));
      final isPast = dateString.compareTo(todayString) < 0;
      final isAvailable = availableDates.contains(dateString);
      final isSelected = dateString == selectedDate;
      final isToday = dateString == todayString;

      cells.add(_buildDayCell(
        day: day,
        dateString: dateString,
        isPast: isPast,
        isAvailable: isAvailable,
        isSelected: isSelected,
        isToday: isToday,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  Widget _buildDayCell({
    required int day,
    required String dateString,
    required bool isPast,
    required bool isAvailable,
    required bool isSelected,
    required bool isToday,
  }) {
    final enabled = !isPast && isAvailable;

    Color backgroundColor;
    Color textColor;
    Border? border;

    if (isSelected) {
      backgroundColor = SemanticColors.button.primary;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = Colors.transparent;
      textColor = enabled
          ? SemanticColors.text.primary
          : SemanticColors.text.disabled;
      border = Border.all(color: SemanticColors.button.primary, width: 1.5);
    } else if (enabled) {
      backgroundColor = Colors.transparent;
      textColor = SemanticColors.text.primary;
    } else {
      backgroundColor = Colors.transparent;
      textColor = SemanticColors.text.disabled;
    }

    return GestureDetector(
      onTap: enabled ? () => onDateSelected(dateString) : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
