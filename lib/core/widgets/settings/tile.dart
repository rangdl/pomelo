import 'package:flutter/material.dart';

enum SettingsTileType { simpleTile, switchTile, navigationTile }

class RxSettingsTile extends StatelessWidget {
  RxSettingsTile({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,

    this.initialValue = true,
    this.onToggle,
    this.tileType = SettingsTileType.simpleTile,
  });

  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  final bool? initialValue;
  final Function(bool value)? onToggle;
  late final SettingsTileType tileType;

  RxSettingsTile.switchTile({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.initialValue = true,
    this.onTap,
    this.onToggle,
  }) {
    tileType = SettingsTileType.switchTile;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(title: title, subtitle: subtitle, trailing: trailing);
  }

  Widget buildTrailing() {
    return Row(
      children: [
        ?trailing,
        if (tileType == SettingsTileType.switchTile)
          Switch(value: initialValue ?? true, onChanged: onToggle),
      ],
    );
  }
}
