import 'package:flutter/material.dart';
import 'package:inteli_rehab/core/constants/app_colors.dart';
import 'package:inteli_rehab/core/constants/app_strings.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  IconData _iconFor(String key) {
    switch (key) {
      case 'reminder':
        return Icons.alarm_rounded;
      case 'assigned':
        return Icons.assignment_turned_in_rounded;
      case 'improved':
        return Icons.trending_up_rounded;
      case 'battery':
        return Icons.battery_alert_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String key) {
    switch (key) {
      case 'reminder':
        return AppColors.tealCore;
      case 'assigned':
        return AppColors.emerald.shade600;
      case 'improved':
        return const Color(0xFF16A34A);
      case 'battery':
        return AppColors.rose.shade600;
      default:
        return AppColors.slate.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.slate.shade900,
            ),
          ),
          const SizedBox(height: 12),
          ...AppConstants.notifications.map((n) {
            final color = _colorFor(n['icon']!);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_iconFor(n['icon']!), size: 17, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title']!,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          n['subtitle']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate.shade500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n['time']!,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.slate.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
