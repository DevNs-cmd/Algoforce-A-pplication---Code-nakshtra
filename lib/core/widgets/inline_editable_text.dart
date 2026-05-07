import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_text.dart';

class InlineEditableText extends StatefulWidget {
  const InlineEditableText({
    super.key,
    required this.value,
    required this.onSubmitted,
    this.style,
    this.keyboardType,
    this.decoration,
  });

  final String value;
  final ValueChanged<String> onSubmitted;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final InputDecoration? decoration;

  @override
  State<InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<InlineEditableText> {
  late final FocusNode _focusNode;
  late TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocus);
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant InlineEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: _editing
          ? Shortcuts(
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.escape):
                    _CancelInlineEditIntent(),
              },
              child: Actions(
                actions: {
                  _CancelInlineEditIntent:
                      CallbackAction<_CancelInlineEditIntent>(
                        onInvoke: (_) {
                          _cancel();
                          return null;
                        },
                      ),
                },
                child: TextField(
                  key: const ValueKey('edit'),
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType: widget.keyboardType,
                  style: widget.style ?? AppText.body(),
                  decoration:
                      widget.decoration ?? const InputDecoration(isDense: true),
                  onSubmitted: (_) => _save(),
                ),
              ),
            )
          : GestureDetector(
              key: const ValueKey('view'),
              onTap: () {
                setState(() => _editing = true);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _focusNode.requestFocus(),
                );
              },
              child: Text(widget.value, style: widget.style ?? AppText.body()),
            ),
    );
  }

  void _handleFocus() {
    if (_editing && !_focusNode.hasFocus) {
      _save();
    }
  }

  void _save() {
    final value = _controller.text.trim();
    widget.onSubmitted(value);
    if (mounted) {
      setState(() => _editing = false);
    }
  }

  void _cancel() {
    _controller.text = widget.value;
    setState(() => _editing = false);
    _focusNode.unfocus();
  }
}

class _CancelInlineEditIntent extends Intent {
  const _CancelInlineEditIntent();
}
