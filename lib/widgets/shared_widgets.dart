import 'package:flutter/material.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';

class OnboardingScaffold extends StatelessWidget {
  final int step;
  final int totalSteps;
  final List<String> stepLabels;
  final Widget child;
  final VoidCallback? onBack;

  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.stepLabels,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate800, size: 20),
                onPressed: onBack,
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(totalSteps, (index) {
                final isCompleted = index < step;
                final isActive = index == step - 1;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: isCompleted || isActive ? AppColors.teal : AppColors.slate200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Step labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final isActive = index == step - 1;
                return Text(
                  stepLabels[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? AppColors.teal : AppColors.slate400,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          // Main content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.teal;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: AppColors.slate200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: onTap == null ? AppColors.slate400 : Colors.white,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      size: 20,
                      color: onTap == null ? AppColors.slate400 : Colors.white,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.slate200, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.slate600,
          ),
        ),
      ),
    );
  }
}

class SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  const SelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealLight : Colors.white,
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.slate200,
            width: selected ? 1.8 : 1.2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? AppColors.teal : AppColors.slate100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppColors.slate500,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ] else if (selected) ...[
              const SizedBox(width: 12),
              const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.slate500,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.slate800),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            errorMaxLines: 2,
            hintStyle: const TextStyle(color: AppColors.slate400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.teal, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (index >= rating) {
          icon = Icons.star_border_rounded;
        } else if (index > rating - 1 && index < rating) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_rounded;
        }
        return Icon(icon, color: AppColors.amber, size: size);
      }),
    );
  }
}
