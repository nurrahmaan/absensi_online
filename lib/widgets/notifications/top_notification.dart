import 'package:flutter/material.dart';
import 'dart:ui';

/// Jenis notifikasi yang tersedia
enum NotificationType { success, error, warning, info }

/// Fungsi utama untuk menampilkan notifikasi di atas layar
void showTopNotification(
  BuildContext context,
  String message, {
  NotificationType type = NotificationType.success,
  IconData? icon,
  String? title,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _TopNotificationWidget(
      title: title,
      message: message,
      type: type,
      icon: icon,
      duration: duration,
      onDismissed: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

/// Widget internal notifikasi
class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final String? title;
  final NotificationType type;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopNotificationWidget({
    required this.message,
    this.title,
    this.type = NotificationType.success,
    this.icon,
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
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pilih warna & ikon default berdasarkan type
    Color bgColor;
    String defaultTitle;
    IconData defaultIcon;

    switch (widget.type) {
      case NotificationType.error:
        bgColor = Colors.redAccent.withOpacity(0.95);
        defaultTitle = "Error";
        defaultIcon = Icons.error_outline;
        break;
      case NotificationType.warning:
        bgColor = Colors.orangeAccent.withOpacity(0.95);
        defaultTitle = "Peringatan";
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case NotificationType.info:
        bgColor = Colors.blueAccent.withOpacity(0.95);
        defaultTitle = "Info";
        defaultIcon = Icons.info_outline;
        break;
      case NotificationType.success:
      default:
        bgColor = Colors.green.shade600.withOpacity(0.95);
        defaultTitle = "Berhasil";
        defaultIcon = Icons.check_circle_outline;
    }

    final notifIcon = Icon(
      widget.icon ?? defaultIcon,
      color: Colors.white,
      size: 32,
    );

    final notifTitle = widget.title ?? defaultTitle;

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
                      GestureDetector(
                        onTap: () async {
                          await _controller.reverse();
                          widget.onDismissed();
                        },
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
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
