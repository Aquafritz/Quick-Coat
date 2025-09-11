// ignore_for_file: unnecessary_null_comparison, unreachable_switch_default, unused_element_parameter

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ToastType { success, error, info, warning }

class Toastify {
  static void show(
    BuildContext context, {
    required String message,
    String? description,
    Icon? icon,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    icon ??= _defaultIcon(type);
    final backgroundColor = _backgroundColor(type);

    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: 50,
            right: 20,
            child: _ToastWidget(
              message: message,
              description: description,
              icon: icon ?? _defaultIcon(type),
              backgroundColor: backgroundColor,
              maxWidth: 300,
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static Icon _defaultIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Icon(Icons.check_circle_outline, color: Colors.white);
      case ToastType.error:
        return const Icon(Icons.error_outline, color: Colors.white);
      case ToastType.warning:
        return const Icon(Icons.warning_outlined, color: Colors.white);
      case ToastType.info:
      default:
        return const Icon(Icons.info_outline, color: Colors.white);
    }
  }

  static Color _backgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
      default:
        return Colors.blue;
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? description;
  final Icon icon;
  final Color backgroundColor;
  final double maxWidth;

  const _ToastWidget({
    super.key,
    required this.message,
    this.description,
    required this.icon,
    required this.backgroundColor,
    this.maxWidth = 300,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.message,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.description!,
                          style: GoogleFonts.roboto(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
