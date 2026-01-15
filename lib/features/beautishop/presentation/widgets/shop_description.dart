import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class ShopDescription extends StatefulWidget {
  final String description;
  final int maxLines;

  const ShopDescription({
    super.key,
    required this.description,
    this.maxLines = 3,
  });

  @override
  State<ShopDescription> createState() => _ShopDescriptionState();
}

class _ShopDescriptionState extends State<ShopDescription> {
  bool _isExpanded = false;
  bool _hasOverflow = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '샵 소개',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(
                text: widget.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: SemanticColors.state.open,
                ),
              );

              final textPainter = TextPainter(
                text: textSpan,
                maxLines: widget.maxLines,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              _hasOverflow = textPainter.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: SemanticColors.state.open,
                    ),
                    maxLines: _isExpanded ? null : widget.maxLines,
                    overflow: _isExpanded ? null : TextOverflow.ellipsis,
                  ),
                  if (_hasOverflow) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? '접기' : '더보기',
                        style: TextStyle(
                          fontSize: 14,
                          color: SemanticColors.text.highlight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
