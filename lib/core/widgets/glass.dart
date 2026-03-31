import 'dart:ui';

import 'package:flutter/material.dart';

// 毛玻璃效果
class Glass extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const Glass({
    required this.child,
    this.blurSigma = 10.0,
    this.opacity = 0.3,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}
