import 'package:flutter/material.dart';
import 'dart:ui';

void showTopNotification(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
  String? title,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _TopNotificationWidget(
      title: title,
      message: message,
      isError: isError,
      icon: icon,
      backgroundColor: backgroundColor,
      duration: duration,
      onDismissed: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final String? title;
  final bool isError;
  final IconData? icon;
  final Color? backgroundColor;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopNotificationWidget({
    required this.message,
    this.title,
    this.isError = false,
    this.icon,
    this.backgroundColor,
    this.duration = const Duration(seconds: 3),
    required this.onDismissed,
  });

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(widget.duration, () async {
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifIcon = Icon(
      widget.icon ??
          (widget.isError ? Icons.error_outline : Icons.check_circle_outline),
      color: Colors.white,
      size: 32, // lebih besar
    );

    final notifTitle = widget.title ?? (widget.isError ? "Error" : "Success");

    final bgColor = widget.backgroundColor ??
        (widget.isError
            ? Colors.redAccent.withOpacity(0.95)
            : Colors.greenAccent.shade700.withOpacity(0.95));

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      notifIcon,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notifTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
