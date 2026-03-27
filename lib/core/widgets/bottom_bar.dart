// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:pomelo/core/layout/rx_layout.dart';

class RxBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  final List<RxTabItem> tabs;
  final bool animate;
  final Color? activeColor;
  final Color? baseColor;

  const RxBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,

    required this.tabs,
    this.animate = true,
    this.activeColor,
    this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = FxTheme.isDarkMode;
    final effectiveActive =
        activeColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBase =
        baseColor ?? (isDark ? Colors.white70 : Colors.black54);

    return Fx.box()
        .wFull()
        .child(
          Fx.row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            gap: 8,

            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: animate
                        ? const Duration(milliseconds: 400)
                        : Duration.zero,
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    // decoration: BoxDecoration(
                    //   color: isActive
                    //       ? effectiveActive.withValues(alpha: 0.1)
                    //       : Colors.transparent,
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isActive ? effectiveActive : effectiveBase,
                          size: 24,
                        ),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive ? effectiveActive : baseColor,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ).opacity(1),
                  ),
                ),
              );
            }).toList(),
          ),
        )
        .glass(10)
        .background(Colors.white.withValues(alpha: .05))
        .opacity(.9)
        .m(8)
        .borderRadius(12);
  }
}
