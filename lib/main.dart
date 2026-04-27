import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:pomelo/collections/http-override.dart';
import 'package:pomelo/collections/intents.dart';
import 'package:pomelo/collections/routes.dart';
import 'package:pomelo/hooks/configurators/use_has_touch.dart';
import 'package:pomelo/l10n/l10n.dart';
import 'package:pomelo/models/database/database.dart';
import 'package:pomelo/modules/settings/color_scheme_picker_dialog.dart';
import 'package:pomelo/provider/database/database.dart';
import 'package:pomelo/provider/user_preferences/user_preferences_provider.dart';
import 'package:pomelo/services/audio_player/audio_player.dart';
import 'package:pomelo/services/wm_tools/wm_tools.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:smtc_windows/smtc_windows.dart';
import 'package:window_manager/window_manager.dart';

import 'global.dart';
import 'provider/audio_player/audio_player_streams.dart';
import 'services/kv_store/kv_store.dart';
import 'services/logger/logger.dart';
import 'utils/platform.dart';

void main() async {
  // Configure the App Metadata
  await initialize();
  AppLogger.initialize(false);

  AppLogger.runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = BadCertificateAllowlistOverrides();
    // tz.initializeTimeZones();
    MediaKit.ensureInitialized();

    // force High Refresh Rate on some Android devices (like One Plus)
    // if (kIsAndroid) {
    //   await FlutterDisplayMode.setHighRefreshRate();
    // }
    // if (kIsAndroid || kIsDesktop) {
    //   await NewPipeExtractor.init();
    // }
    if (!kIsWeb) {
      MetadataGod.initialize();
    }

    await KVStoreService.initialize();

    if (kIsDesktop) {
      await windowManager.setPreventClose(true);
      // await YtDlp.instance
      //     .setBinaryLocation(
      //       KVStoreService.getYoutubeEnginePath(YoutubeClientEngine.ytDlp) ??
      //           "yt-dlp${kIsWindows ? '.exe' : ''}",
      //     )
      //     .catchError((e, stack) => null);
      // await FlutterDiscordRPC.initialize(Env.discordAppId);
    }

    if (kIsWindows) {
      await SMTCWindows.initialize();
    }

    final database = AppDatabase();
    if (kIsDesktop) {
      // await localNotifier.setup(appName: "Spotube");
      await WindowManagerTools.initialize();
    }

    runApp(
      ProviderScope(
        overrides: [databaseProvider.overrideWith((ref) => database)],
        observers: const [AppLoggerProviderObserver()],
        child: const Pomelo(),
      ),
    );
  });
}

class Pomelo extends HookConsumerWidget {
  const Pomelo({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      userPreferencesProvider.select((s) => s.themeMode),
    );
    final locale = ref.watch(userPreferencesProvider.select((s) => s.locale));
    final accentMaterialColor = ref.watch(
      userPreferencesProvider.select((s) => s.accentColorScheme),
    );
    final router = useMemoized(() => AppRouter(ref), []);
    final hasTouchSupport = useHasTouch();

    ref.listen(audioPlayerStreamListenersProvider, (_, __) {});

    useEffect(() {
      // FlutterNativeSplash.remove();
      // if (kIsMobile) {
      //   HomeWidget.registerInteractivityCallback(glanceBackgroundCallback);
      // }
      return () {
        /// For enabling hot reload for audio player
        if (!kDebugMode) return;
        audioPlayer.dispose();
      };
    }, []);
    return ShadcnApp.router(
      title: 'Pomelo',
      debugShowCheckedModeBanner: false,
      supportedLocales: L10n.all,
      locale: locale.languageCode == "system" ? null : locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        child = ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: hasTouchSupport
                ? {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.invertedStylus,
                  }
                : null,
          ),
          child: child!,
        );

        if (kIsLinux) {
          child = DragToResizeArea(resizeEdgeSize: 2.5, child: child);
        }

        return child;
      },
      scaling: const AdaptiveScaling(1),
      theme: ThemeData(
        radius: .5,
        iconTheme: const IconThemeProperties(),
        colorScheme:
            colorSchemeMap[accentMaterialColor.name]?.call(ThemeMode.light) ??
            LegacyColorSchemes.lightSlate(),
        surfaceOpacity: .8,
        surfaceBlur: 10,
      ),
      darkTheme: ThemeData(
        radius: .5,
        iconTheme: const IconThemeProperties(),
        colorScheme:
            colorSchemeMap[accentMaterialColor.name]?.call(ThemeMode.dark) ??
            LegacyColorSchemes.darkSlate(),
        surfaceOpacity: .8,
        surfaceBlur: 10,
      ),
      materialTheme: material.ThemeData(
        brightness: switch (themeMode) {
          ThemeMode.system => MediaQuery.platformBrightnessOf(context),
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
        },
        splashFactory: material.NoSplash.splashFactory,
        appBarTheme: const material.AppBarTheme(
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      themeMode: themeMode,
      routerConfig: router.config(),
      // builder: BotToastInit(), //1.调用BotToastInit
      shortcuts: {
        ...WidgetsApp.defaultShortcuts.map((key, value) {
          return MapEntry(
            LogicalKeySet.fromSet(key.triggers?.toSet() ?? {}),
            value,
          );
        }),
        LogicalKeySet(LogicalKeyboardKey.space): PlayPauseIntent(ref),
        LogicalKeySet(LogicalKeyboardKey.comma, LogicalKeyboardKey.control):
            NavigationIntent(router, "/settings"),
        LogicalKeySet(
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.browse,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.digit2,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.search,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.digit3,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.lyrics,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.digit4,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.userPlaylists,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.digit5,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.userArtists,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.digit6,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.userAlbums,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.digit7,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.userLocalLibrary,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.digit8,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): HomeTabIntent(
          router,
          tab: HomeTabs.userDownloads,
        ),
        LogicalKeySet(
          LogicalKeyboardKey.keyW,
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
        ): CloseAppIntent(),
      },

      actions: {
        ...WidgetsApp.defaultActions,
        PlayPauseIntent: PlayPauseAction(),
        NavigationIntent: NavigationAction(),
        HomeTabIntent: HomeTabAction(),
        CloseAppIntent: CloseAppAction(),
      },
    );
  }
}
