import 'package:auto_route/auto_route.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'pomelo_icons.dart';

class BackButton extends StatelessWidget {
  final Color? color;
  final IconData icon;
  const BackButton({super.key, this.color, this.icon = PomeloIcons.close});

  @override
  Widget build(BuildContext context) {
    return IconButton.ghost(
      size: const ButtonSize(1.2),
      icon: Icon(icon, color: color),
      // onPressed: () => Navigator.of(context).pop(),
      onPressed: () => context.watchRouter.maybePop(),
    );
  }
}
