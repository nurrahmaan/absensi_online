import 'package:flutter/material.dart';

void showTopNotification(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
  Color? backgroundColor,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _TopNotificationWidget(
      message: message,
      isError: isError,
      icon: icon,
      backgroundColor: backgroundColor,
      onDismissed: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback onDismissed;

  const _TopNotificationWidget({
    required this.message,
    this.isError = false,
    this.icon,
    this.backgroundColor,
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
            begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    Icon notifIcon = Icon(
      widget.icon ??
          (widget.isError ? Icons.error : Icons.check_circle), // default icon
      color: Colors.white,
    );

    Color bgColor = widget.backgroundColor ??
        (widget.isError
            ? Colors.red.withOpacity(0.85)
            : Colors.green.withOpacity(0.85));

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      children: [
                        notifIcon,
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.left,
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
