import 'package:flutter/material.dart';

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
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    // _daysOfWeek: 0 = 월, 6 = 일
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
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notice!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
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
                color: isToday ? Colors.pink[600] : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              hours,
              style: TextStyle(
                fontSize: 14,
                color: isClosed ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
