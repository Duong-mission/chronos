import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ChronosHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  const ChronosHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onNotificationTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần chữ bên trái
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          // Phần nút bên phải
          Row(
            children: [
              _HeaderButton(icon: Icons.search, onTap: onSearchTap),
              const SizedBox(width: 8),
              _HeaderButton(
                icon: Icons.notifications_outlined,
                onTap: onNotificationTap,
                hasBadge: true, // Chấm đỏ thông báo
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasBadge;

  const _HeaderButton({required this.icon, this.onTap, this.hasBadge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            if (hasBadge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceDark, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}