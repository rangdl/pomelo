import 'package:flutter/material.dart';

class RxSettingsSection extends StatelessWidget {
  final Widget? title;
  final List<Widget> children;

  const RxSettingsSection({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        if (title != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 18,
              bottom: 5 * scaleFactor,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                // color: theme.themeData.titleTextColor,
                fontSize: 13,
              ),
              child: title!,
            ),
          ),
        buildTileList(),
      ],
    );
  }

  Widget buildTileList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: children.length,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final child = children[index];
        return child;
      },
    );
  }
}
