import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isElevated;
  final double scaleDurationMillis;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isElevated = true,
    this.scaleDurationMillis = 800,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: scaleDurationMillis.toInt()),
      curve: isElevated ? Curves.easeInOut : Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: isElevated
              ? ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor ??
                        Theme.of(context).colorScheme.primary,
                    foregroundColor: foregroundColor ??
                        Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 0,
                  ),
                  child: child,
                )
              : TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: child!,
                ),
        );
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: isElevated ? 18 : 16,
          fontWeight: isElevated ? FontWeight.bold : FontWeight.w600,
          color: foregroundColor ??
              (isElevated ? null : Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
