// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;
import 'package:pomelo/ui/example/example_page.dart' as _i1;
import 'package:pomelo/ui/example/js_engine_test_page.dart' as _i4;
import 'package:pomelo/ui/favorite/favorite_page.dart' as _i2;
import 'package:pomelo/ui/home/home_page.dart' as _i3;
import 'package:pomelo/ui/log/log_page.dart' as _i5;
import 'package:pomelo/ui/music/search_page.dart' as _i6;
import 'package:pomelo/ui/my/my_page.dart' as _i7;
import 'package:pomelo/ui/root/root_page.dart' as _i8;
import 'package:pomelo/ui/statistics/statistics_page.dart' as _i9;

/// generated route for
/// [_i1.Ex1DetailView]
class Ex1DetailRoute extends _i10.PageRouteInfo<void> {
  const Ex1DetailRoute({List<_i10.PageRouteInfo>? children})
    : super(Ex1DetailRoute.name, initialChildren: children);

  static const String name = 'Ex1DetailRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i1.Ex1DetailView();
    },
  );
}

/// generated route for
/// [_i1.Ex2DetailView]
class Ex2DetailRoute extends _i10.PageRouteInfo<void> {
  const Ex2DetailRoute({List<_i10.PageRouteInfo>? children})
    : super(Ex2DetailRoute.name, initialChildren: children);

  static const String name = 'Ex2DetailRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i1.Ex2DetailView();
    },
  );
}

/// generated route for
/// [_i1.ExListPage]
class ExListRoute extends _i10.PageRouteInfo<void> {
  const ExListRoute({List<_i10.PageRouteInfo>? children})
    : super(ExListRoute.name, initialChildren: children);

  static const String name = 'ExListRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i1.ExListPage();
    },
  );
}

/// generated route for
/// [_i2.FavoritePage]
class FavoriteRoute extends _i10.PageRouteInfo<void> {
  const FavoriteRoute({List<_i10.PageRouteInfo>? children})
    : super(FavoriteRoute.name, initialChildren: children);

  static const String name = 'FavoriteRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i2.FavoritePage();
    },
  );
}

/// generated route for
/// [_i3.HomeView]
class HomeRoute extends _i10.PageRouteInfo<void> {
  const HomeRoute({List<_i10.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomeView();
    },
  );
}

/// generated route for
/// [_i4.JsEngineTestView]
class JsEngineTestRoute extends _i10.PageRouteInfo<void> {
  const JsEngineTestRoute({List<_i10.PageRouteInfo>? children})
    : super(JsEngineTestRoute.name, initialChildren: children);

  static const String name = 'JsEngineTestRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i4.JsEngineTestView();
    },
  );
}

/// generated route for
/// [_i5.LogPage]
class LogRoute extends _i10.PageRouteInfo<void> {
  const LogRoute({List<_i10.PageRouteInfo>? children})
    : super(LogRoute.name, initialChildren: children);

  static const String name = 'LogRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i5.LogPage();
    },
  );
}

/// generated route for
/// [_i6.MusicSearchPage]
class MusicSearchRoute extends _i10.PageRouteInfo<MusicSearchRouteArgs> {
  MusicSearchRoute({
    _i11.Key? key,
    required String keyword,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         MusicSearchRoute.name,
         args: MusicSearchRouteArgs(key: key, keyword: keyword),
         initialChildren: children,
       );

  static const String name = 'MusicSearchRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MusicSearchRouteArgs>();
      return _i6.MusicSearchPage(key: args.key, keyword: args.keyword);
    },
  );
}

class MusicSearchRouteArgs {
  const MusicSearchRouteArgs({this.key, required this.keyword});

  final _i11.Key? key;

  final String keyword;

  @override
  String toString() {
    return 'MusicSearchRouteArgs{key: $key, keyword: $keyword}';
  }
}

/// generated route for
/// [_i7.MyPage]
class MyRoute extends _i10.PageRouteInfo<void> {
  const MyRoute({List<_i10.PageRouteInfo>? children})
    : super(MyRoute.name, initialChildren: children);

  static const String name = 'MyRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i7.MyPage();
    },
  );
}

/// generated route for
/// [_i8.RootPage]
class RootRoute extends _i10.PageRouteInfo<void> {
  const RootRoute({List<_i10.PageRouteInfo>? children})
    : super(RootRoute.name, initialChildren: children);

  static const String name = 'RootRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i8.RootPage();
    },
  );
}

/// generated route for
/// [_i9.StatisticsPage]
class StatisticsRoute extends _i10.PageRouteInfo<void> {
  const StatisticsRoute({List<_i10.PageRouteInfo>? children})
    : super(StatisticsRoute.name, initialChildren: children);

  static const String name = 'StatisticsRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i9.StatisticsPage();
    },
  );
}
