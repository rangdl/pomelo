// to store names of routes

part of 'router.dart';

class Routes {
  static const home = _SimpleRoute(pathName: '', name: 'home');
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
}
