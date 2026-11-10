import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/core_exports.dart';

/// Search box with a clear button. [onChanged] fires 400 ms after the user stops typing
/// (and immediately on submit / clear) so we don't call the API on every key press.
class AppSearchField extends StatefulWidget {
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);
  Timer? _debounce;
  String _lastSent = '';

  @override
  void initState() {
    super.initState();
    _lastSent = widget.initialValue.trim();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _send(String value) {
    _debounce?.cancel();
    final v = value.trim();
    if (v == _lastSent) return;
    _lastSent = v;
    widget.onChanged(v);
  }

  void _onChanged(String value) {
    setState(() {}); // show/hide the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _send(value));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      onSubmitted: _send,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  _send('');
                },
              ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
