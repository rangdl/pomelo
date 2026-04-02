// to store names of routes

// ignore_for_file: unused_element_parameter

part of 'router.dart';

class Routes {
  static const home = _SimpleRoute(pathName: '', name: 'home');
  static const favorite = _SimpleRoute(pathName: 'favorite', name: 'favorite');
  static const statistics = _SimpleRoute(
    pathName: 'statistics',
    name: 'statistics',
  );
  static const my = _SimpleRoute(pathName: 'my', name: 'my');
  static const settings = _SimpleRoute(pathName: 'settings', name: 'settings');
  static const settingsHome = _SimpleRoute(
    pathName: 'home',
    name: 'settingsHome',
    parentRoute: settings,
  );

  static const ex = _SimpleRoute(pathName: 'ex', name: 'ex');
  static const ex1 = _SimpleRoute(
    pathName: 'ex1',
    name: 'ex1',
    parentRoute: ex,
  );
  static const ex2 = _SimpleRoute(
    pathName: 'ex2',
    name: 'ex2',
    parentRoute: ex,
  );
}

// a class to store path

class _SimpleRoute {
  const _SimpleRoute({
    required this.pathName,
    this.pathParamName,
    required this.name,
    this.parentRoute,
  });

  final String pathName;
  final String? pathParamName;
  final String name;
  final _SimpleRoute? parentRoute;

  /// the full path of the route
  String get fullPath {
    return '${parentRoute?.fullPath ?? ''}$localPath';
  }

  /// the local path of the route
  String get localPath =>
      '/$pathName${pathParamName != null ? '/:$pathParamName' : ''}';

  // 带参数跳转路径
  String paramPath(String param) =>
      '/$pathName${pathParamName != null ? '/:$param' : ''}';
}

class Nav {
  final String id;
  final num sort;
  final bool visible;
  final String label;
  final IconData icon;
  final StatefulShellBranch route;

  Nav({
    required this.id,
    required this.sort,
    required this.label,
    required this.icon,
    required this.route,
    this.visible = true,
  });
}
