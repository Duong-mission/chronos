import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ChronosCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final bool showNeon;
  final double? width;
  final double? height;

  const ChronosCard({
    super.key,
    required this.child,
    this.padding = 20.0,
    this.borderRadius = 40.0, // Tương đương rounded-[2.5rem] (40px)
    this.color,
    this.gradient,
    this.showNeon = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Nếu showNeon = true, áp dụng hiệu ứng phát sáng từ AppColors
        boxShadow: showNeon ? AppColors.neonShadow : null,
      ),
      child: ClipRRect(
        // Bo góc cho cả phần filter mờ
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          // Hiệu ứng backdrop-blur-md trong React
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              // Màu nền trong suốt nhẹ để thấy hiệu ứng mờ phía sau
              color: color ?? AppColors.cardDark.withOpacity(0.7),
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              // Viền mờ border-white/10
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}