import 'package:flutter/material.dart';

class ShopInfoHeader extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final String? distance;
  final List<String>? tags;
  final String? address;

  const ShopInfoHeader({
    super.key,
    required this.name,
    required this.rating,
    required this.reviewCount,
    this.distance,
    this.tags,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($reviewCount)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (distance != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 2),
                Text(
                  distance!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          if (tags != null && tags!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: tags!.map((tag) => _buildTag(tag)).toList(),
            ),
          ],
          if (address != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.place, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address!,
                    style: TextStyle(
                      fontSize: 14,
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

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12,
          color: Colors.pink[700],
        ),
      ),
    );
  }
}
