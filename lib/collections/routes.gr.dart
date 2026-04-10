// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:pomelo/pages/home/home.dart' as _i1;
import 'package:pomelo/pages/root/root_app.dart' as _i3;
import 'package:pomelo/pages/settings/logs.dart' as _i2;
import 'package:pomelo/pages/settings/settings.dart' as _i4;
import 'package:pomelo/pages/test/test.dart' as _i5;

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomePage();
    },
  );
}

/// generated route for
/// [_i2.LogsPage]
class LogsRoute extends _i6.PageRouteInfo<void> {
  const LogsRoute({List<_i6.PageRouteInfo>? children})
    : super(LogsRoute.name, initialChildren: children);

  static const String name = 'LogsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.LogsPage();
    },
  );
}

/// generated route for
/// [_i3.RootAppPage]
class RootAppRoute extends _i6.PageRouteInfo<void> {
  const RootAppRoute({List<_i6.PageRouteInfo>? children})
    : super(RootAppRoute.name, initialChildren: children);

  static const String name = 'RootAppRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.RootAppPage();
    },
  );
}

/// generated route for
/// [_i4.SettingsPage]
class SettingsRoute extends _i6.PageRouteInfo<void> {
  const SettingsRoute({List<_i6.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.SettingsPage();
    },
  );
}

/// generated route for
/// [_i5.TestPage]
class TestRoute extends _i6.PageRouteInfo<void> {
  const TestRoute({List<_i6.PageRouteInfo>? children})
    : super(TestRoute.name, initialChildren: children);

  static const String name = 'TestRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.TestPage();
    },
  );
}
