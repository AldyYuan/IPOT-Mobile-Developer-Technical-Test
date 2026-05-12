import 'package:flutter/material.dart';
import 'package:ipot/shared/theme/app_colors.dart';

class StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const StepperButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = isDestructive ? Colors.redAccent : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: isDestructive ? 0.12 : 1)
              : Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDestructive ? Colors.redAccent : Colors.white,
        ),
      ),
    );
  }
}
