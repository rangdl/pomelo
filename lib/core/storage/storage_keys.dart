/// 全局持久化 Key 常量
///
/// 集中管理所有通过 [Settings] 持久化的键名，
/// 避免各模块散落魔法字符串和重复定义。
///
/// 各模块通过 `import 'package:pomelo/core/storage/storage_keys.dart'`
/// 引用对应常量，而非自行声明字符串。
library;

/// Settings Key 常量集合
class StorageKeys {
  StorageKeys._();

  // ======================== audio_player ========================
  static const audioPlayerState = 'audio_player_state';

  // ======================== log ========================
  static const logStorageLevel = 'log_storage_level';

  // ======================== music_local ========================
  static const musicLocalDirectories = 'music_local_directories';

  // ======================== music_lx ========================
  static const musicLxMetadataPluginPath = 'music_lx_metadata_plugin_path';
  static const musicLxSourcePluginPaths = 'music_lx_source_plugin_paths';

  // ======================== music_lx_server ========================
  static const musicLxServerConfig = 'music_lx_server_config';

  // ======================== music_subsonic ========================
  static const musicSubsonicAccounts = 'music_subsonic_accounts';

  // ======================== music (UI 选中态) ========================
  static const musicSelectedSource = 'music_selected_source';
  static const musicSelectedLibrary = 'music_selected_library';

  // ======================== my ========================
  static const myThemeMode = 'my_theme_mode';
  static const myLyricFontSize = 'my_lyric_font_size';
  static const myAutoPlay = 'my_auto_play';
}
