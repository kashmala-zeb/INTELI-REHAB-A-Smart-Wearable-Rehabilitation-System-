import 'package:flutter/material.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';

/// Displays a local asset illustration for an exercise.
/// Falls back to a gradient + Material icon if the asset is missing,
/// so the layout never breaks even when assets/images/*.png aren't bundled.
class ExerciseImage extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  final double size;

  const ExerciseImage({
    super.key,
    required this.assetPath,
    required this.fallbackIcon,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: assetPath.isNotEmpty
          ? Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tealCore.withValues(alpha: 0.10),
            AppColors.tealCore.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: size * 0.42,
          color: AppColors.tealCore,
        ),
      ),
    );
  }
}
