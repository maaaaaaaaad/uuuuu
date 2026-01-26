import 'package:flutter/material.dart';
import 'package:jellomark/shared/theme/app_shadows.dart';
import 'package:jellomark/shared/theme/semantic_colors.dart';

class GlassSearchBar extends StatefulWidget {
  final String hintText;
  final String? locationText;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const GlassSearchBar({
    super.key,
    this.hintText = '검색',
    this.locationText,
    this.onTap,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  bool get isInputMode => controller != null;

  @override
  State<GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends State<GlassSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChange() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onClear() {
    widget.controller?.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isInputMode ? null : widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: SemanticColors.background.inputTranslucent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused
                ? SemanticColors.border.focus
                : SemanticColors.border.glass,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: AppShadows.card3D,
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: SemanticColors.icon.secondary),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
            ..._buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isInputMode) {
      return TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: SemanticColors.text.hint, fontSize: 16),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 16),
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      );
    }
    return Text(
      widget.hintText,
      style: TextStyle(color: SemanticColors.text.hint, fontSize: 16),
    );
  }

  List<Widget> _buildTrailing() {
    if (widget.isInputMode && _hasText) {
      return [
        GestureDetector(
          onTap: _onClear,
          child: Icon(
            Icons.clear,
            color: SemanticColors.icon.secondary,
            size: 20,
          ),
        ),
      ];
    }
    if (widget.locationText != null) {
      return [
        Icon(Icons.location_on, color: SemanticColors.icon.secondary, size: 18),
        const SizedBox(width: 4),
        Text(
          widget.locationText!,
          style: TextStyle(color: SemanticColors.icon.primary, fontSize: 14),
        ),
      ];
    }
    return [];
  }
}
