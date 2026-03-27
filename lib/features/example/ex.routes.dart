import 'package:fluxy/fluxy.dart';
import 'package:pomelo/features/example/ex.view.dart';

final exRoutes = FxRoute.group(
  prefix: "/ex",
  guards: [],
  routes: [
    FxRoute(path: "/1", builder: (p, a) => Ex1View()),
    FxRoute(path: "/2", builder: (p, a) => Ex2View()),
  ],
);
