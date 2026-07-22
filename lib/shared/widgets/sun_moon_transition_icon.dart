import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

/// A dynamic widget that smoothly transitions between a Sun icon and a Moon icon
/// depending on whether it is day or night (or a custom override).
class SunMoonTransitionIcon extends StatefulWidget {
  final double size;
  final bool? isNightOverride;
  final bool isOutlined;
  final bool showGlow;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const SunMoonTransitionIcon({
    super.key,
    this.size = 40.0,
    this.isNightOverride,
    this.isOutlined = false,
    this.showGlow = false,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<SunMoonTransitionIcon> createState() => _SunMoonTransitionIconState();
}

class _SunMoonTransitionIconState extends State<SunMoonTransitionIcon>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late bool _isNight;
  late AnimationController _tapController;
  late Animation<double> _tapScaleAnimation;

  @override
  void initState() {
    super.initState();
    _isNight = widget.isNightOverride ?? AppDateUtils.isNight();

    // Periodically update time status every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (widget.isNightOverride == null) {
        final newIsNight = AppDateUtils.isNight();
        if (newIsNight != _isNight && mounted) {
          setState(() {
            _isNight = newIsNight;
          });
        }
      }
    });

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _tapScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant SunMoonTransitionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNightOverride != oldWidget.isNightOverride) {
      setState(() {
        _isNight = widget.isNightOverride ?? AppDateUtils.isNight();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });

    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Toggle preview if no custom onTap provided
      setState(() {
        _isNight = !_isNight;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isNight ? '🌙 Night mode preview' : '☀️ Day mode preview',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final IconData iconData;
    final Color iconColor;
    final String keyString;

    if (_isNight) {
      keyString = 'moon_icon_${widget.isOutlined}';
      iconData = widget.isOutlined
          ? Icons.nights_stay_outlined
          : Icons.nights_stay_rounded;
      iconColor = isDarkMode
          ? const Color(0xFFC7D2FE) // Soft lavender blue in dark mode
          : const Color(0xFF5B21B6); // Deep violet indigo in light mode
    } else {
      keyString = 'sun_icon_${widget.isOutlined}';
      iconData = widget.isOutlined
          ? Icons.wb_sunny_outlined
          : Icons.wb_sunny_rounded;
      iconColor = Colors.amber.shade600;
    }

    Widget childWidget = AnimatedSwitcher(
      duration: widget.animationDuration,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInBack,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isMoon = (child.key as ValueKey<String>?)?.value.startsWith('moon') ?? false;

        return RotationTransition(
          turns: Tween<double>(
            begin: isMoon ? -0.25 : 0.25,
            end: 0.0,
          ).animate(animation),
          child: ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      child: Icon(
        iconData,
        key: ValueKey(keyString),
        size: widget.size,
        color: iconColor,
      ),
    );

    if (widget.showGlow) {
      final glowColor = _isNight
          ? (isDarkMode ? Colors.indigo.withValues(alpha: 0.3) : Colors.deepPurple.withValues(alpha: 0.15))
          : Colors.amber.withValues(alpha: 0.25);

      childWidget = Container(
        padding: EdgeInsets.all(widget.size * 0.15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: glowColor,
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: widget.size * 0.4,
              spreadRadius: widget.size * 0.1,
            ),
          ],
        ),
        child: childWidget,
      );
    }

    return ScaleTransition(
      scale: _tapScaleAnimation,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(widget.size),
        child: Tooltip(
          message: _isNight ? 'Night time (Tap to preview day)' : 'Day time (Tap to preview night)',
          child: childWidget,
        ),
      ),
    );
  }
}
