import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class OperatingHoursCard extends StatelessWidget {
  final Map<String, String> operatingHours;
  final String? notice;

  const OperatingHoursCard({
    super.key,
    required this.operatingHours,
    this.notice,
  });

  static const List<String> _daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];

  String get _todayDay {
    final weekday = DateTime.now().weekday;
    return _daysOfWeek[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '영업시간',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...operatingHours.entries.map((entry) => _buildDayRow(entry.key, entry.value)),
          if (notice != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: SemanticColors.icon.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notice!,
                    style: TextStyle(
                      fontSize: 13,
                      color: SemanticColors.text.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayRow(String day, String hours) {
    final isToday = day == _todayDay;
    final isClosed = hours == '휴무';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? SemanticColors.special.todayHighlight : SemanticColors.state.open,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              hours,
              style: TextStyle(
                fontSize: 14,
                color: isClosed ? SemanticColors.state.closed : SemanticColors.state.open,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
