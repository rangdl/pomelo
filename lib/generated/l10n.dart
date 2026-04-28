// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Guest`
  String get guest {
    return Intl.message('Guest', name: 'guest', desc: '', args: []);
  }

  /// `Browse`
  String get browse {
    return Intl.message('Browse', name: 'browse', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Library`
  String get library {
    return Intl.message('Library', name: 'library', desc: '', args: []);
  }

  /// `Lyrics`
  String get lyrics {
    return Intl.message('Lyrics', name: 'lyrics', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Filter categories or genres...`
  String get genre_categories_filter {
    return Intl.message(
      'Filter categories or genres...',
      name: 'genre_categories_filter',
      desc: '',
      args: [],
    );
  }

  /// `Genre`
  String get genre {
    return Intl.message('Genre', name: 'genre', desc: '', args: []);
  }

  /// `Personalized`
  String get personalized {
    return Intl.message(
      'Personalized',
      name: 'personalized',
      desc: '',
      args: [],
    );
  }

  /// `Featured`
  String get featured {
    return Intl.message('Featured', name: 'featured', desc: '', args: []);
  }

  /// `New Releases`
  String get new_releases {
    return Intl.message(
      'New Releases',
      name: 'new_releases',
      desc: '',
      args: [],
    );
  }

  /// `Songs`
  String get songs {
    return Intl.message('Songs', name: 'songs', desc: '', args: []);
  }

  /// `Playing {track}`
  String playing_track(Object track) {
    return Intl.message(
      'Playing $track',
      name: 'playing_track',
      desc: '',
      args: [track],
    );
  }

  /// `This will clear the current queue. {track_length} tracks will be removed\nDo you want to continue?`
  String queue_clear_alert(Object track_length) {
    return Intl.message(
      'This will clear the current queue. $track_length tracks will be removed\nDo you want to continue?',
      name: 'queue_clear_alert',
      desc: '',
      args: [track_length],
    );
  }

  /// `Load more`
  String get load_more {
    return Intl.message('Load more', name: 'load_more', desc: '', args: []);
  }

  /// `Playlists`
  String get playlists {
    return Intl.message('Playlists', name: 'playlists', desc: '', args: []);
  }

  /// `Artists`
  String get artists {
    return Intl.message('Artists', name: 'artists', desc: '', args: []);
  }

  /// `Albums`
  String get albums {
    return Intl.message('Albums', name: 'albums', desc: '', args: []);
  }

  /// `Tracks`
  String get tracks {
    return Intl.message('Tracks', name: 'tracks', desc: '', args: []);
  }

  /// `Downloads`
  String get downloads {
    return Intl.message('Downloads', name: 'downloads', desc: '', args: []);
  }

  /// `Filter your playlists...`
  String get filter_playlists {
    return Intl.message(
      'Filter your playlists...',
      name: 'filter_playlists',
      desc: '',
      args: [],
    );
  }

  /// `Liked Tracks`
  String get liked_tracks {
    return Intl.message(
      'Liked Tracks',
      name: 'liked_tracks',
      desc: '',
      args: [],
    );
  }

  /// `All your liked tracks`
  String get liked_tracks_description {
    return Intl.message(
      'All your liked tracks',
      name: 'liked_tracks_description',
      desc: '',
      args: [],
    );
  }

  /// `Playlist`
  String get playlist {
    return Intl.message('Playlist', name: 'playlist', desc: '', args: []);
  }

  /// `Create a playlist`
  String get create_a_playlist {
    return Intl.message(
      'Create a playlist',
      name: 'create_a_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Update playlist`
  String get update_playlist {
    return Intl.message(
      'Update playlist',
      name: 'update_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Playlist Name`
  String get playlist_name {
    return Intl.message(
      'Playlist Name',
      name: 'playlist_name',
      desc: '',
      args: [],
    );
  }

  /// `Name of the playlist`
  String get name_of_playlist {
    return Intl.message(
      'Name of the playlist',
      name: 'name_of_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Public`
  String get public {
    return Intl.message('Public', name: 'public', desc: '', args: []);
  }

  /// `Collaborative`
  String get collaborative {
    return Intl.message(
      'Collaborative',
      name: 'collaborative',
      desc: '',
      args: [],
    );
  }

  /// `Search local tracks...`
  String get search_local_tracks {
    return Intl.message(
      'Search local tracks...',
      name: 'search_local_tracks',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message('Play', name: 'play', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Sort by A-Z`
  String get sort_a_z {
    return Intl.message('Sort by A-Z', name: 'sort_a_z', desc: '', args: []);
  }

  /// `Sort by Z-A`
  String get sort_z_a {
    return Intl.message('Sort by Z-A', name: 'sort_z_a', desc: '', args: []);
  }

  /// `Sort by Artist`
  String get sort_artist {
    return Intl.message(
      'Sort by Artist',
      name: 'sort_artist',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Album`
  String get sort_album {
    return Intl.message(
      'Sort by Album',
      name: 'sort_album',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Duration`
  String get sort_duration {
    return Intl.message(
      'Sort by Duration',
      name: 'sort_duration',
      desc: '',
      args: [],
    );
  }

  /// `Sort Tracks`
  String get sort_tracks {
    return Intl.message('Sort Tracks', name: 'sort_tracks', desc: '', args: []);
  }

  /// `Currently Downloading ({tracks_length})`
  String currently_downloading(Object tracks_length) {
    return Intl.message(
      'Currently Downloading ($tracks_length)',
      name: 'currently_downloading',
      desc: '',
      args: [tracks_length],
    );
  }

  /// `Cancel All`
  String get cancel_all {
    return Intl.message('Cancel All', name: 'cancel_all', desc: '', args: []);
  }

  /// `Filter artists...`
  String get filter_artist {
    return Intl.message(
      'Filter artists...',
      name: 'filter_artist',
      desc: '',
      args: [],
    );
  }

  /// `{followers} Followers`
  String followers(Object followers) {
    return Intl.message(
      '$followers Followers',
      name: 'followers',
      desc: '',
      args: [followers],
    );
  }

  /// `Add artist to blacklist`
  String get add_artist_to_blacklist {
    return Intl.message(
      'Add artist to blacklist',
      name: 'add_artist_to_blacklist',
      desc: '',
      args: [],
    );
  }

  /// `Top Tracks`
  String get top_tracks {
    return Intl.message('Top Tracks', name: 'top_tracks', desc: '', args: []);
  }

  /// `Fans also like`
  String get fans_also_like {
    return Intl.message(
      'Fans also like',
      name: 'fans_also_like',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Artist`
  String get artist {
    return Intl.message('Artist', name: 'artist', desc: '', args: []);
  }

  /// `Blacklisted`
  String get blacklisted {
    return Intl.message('Blacklisted', name: 'blacklisted', desc: '', args: []);
  }

  /// `Following`
  String get following {
    return Intl.message('Following', name: 'following', desc: '', args: []);
  }

  /// `Follow`
  String get follow {
    return Intl.message('Follow', name: 'follow', desc: '', args: []);
  }

  /// `Artist URL copied to clipboard`
  String get artist_url_copied {
    return Intl.message(
      'Artist URL copied to clipboard',
      name: 'artist_url_copied',
      desc: '',
      args: [],
    );
  }

  /// `Added {tracks} tracks to queue`
  String added_to_queue(Object tracks) {
    return Intl.message(
      'Added $tracks tracks to queue',
      name: 'added_to_queue',
      desc: '',
      args: [tracks],
    );
  }

  /// `Filter albums...`
  String get filter_albums {
    return Intl.message(
      'Filter albums...',
      name: 'filter_albums',
      desc: '',
      args: [],
    );
  }

  /// `Synced`
  String get synced {
    return Intl.message('Synced', name: 'synced', desc: '', args: []);
  }

  /// `Plain`
  String get plain {
    return Intl.message('Plain', name: 'plain', desc: '', args: []);
  }

  /// `Shuffle`
  String get shuffle {
    return Intl.message('Shuffle', name: 'shuffle', desc: '', args: []);
  }

  /// `Search tracks...`
  String get search_tracks {
    return Intl.message(
      'Search tracks...',
      name: 'search_tracks',
      desc: '',
      args: [],
    );
  }

  /// `Released`
  String get released {
    return Intl.message('Released', name: 'released', desc: '', args: []);
  }

  /// `Error {error}`
  String error(Object error) {
    return Intl.message('Error $error', name: 'error', desc: '', args: [error]);
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `More actions`
  String get more_actions {
    return Intl.message(
      'More actions',
      name: 'more_actions',
      desc: '',
      args: [],
    );
  }

  /// `Download ({count})`
  String download_count(Object count) {
    return Intl.message(
      'Download ($count)',
      name: 'download_count',
      desc: '',
      args: [count],
    );
  }

  /// `Add ({count}) to Playlist`
  String add_count_to_playlist(Object count) {
    return Intl.message(
      'Add ($count) to Playlist',
      name: 'add_count_to_playlist',
      desc: '',
      args: [count],
    );
  }

  /// `Add ({count}) to Queue`
  String add_count_to_queue(Object count) {
    return Intl.message(
      'Add ($count) to Queue',
      name: 'add_count_to_queue',
      desc: '',
      args: [count],
    );
  }

  /// `Play ({count}) next`
  String play_count_next(Object count) {
    return Intl.message(
      'Play ($count) next',
      name: 'play_count_next',
      desc: '',
      args: [count],
    );
  }

  /// `Album`
  String get album {
    return Intl.message('Album', name: 'album', desc: '', args: []);
  }

  /// `Copied {data} to clipboard`
  String copied_to_clipboard(Object data) {
    return Intl.message(
      'Copied $data to clipboard',
      name: 'copied_to_clipboard',
      desc: '',
      args: [data],
    );
  }

  /// `Add {track} to following Playlists`
  String add_to_following_playlists(Object track) {
    return Intl.message(
      'Add $track to following Playlists',
      name: 'add_to_following_playlists',
      desc: '',
      args: [track],
    );
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Added {track} to queue`
  String added_track_to_queue(Object track) {
    return Intl.message(
      'Added $track to queue',
      name: 'added_track_to_queue',
      desc: '',
      args: [track],
    );
  }

  /// `Add to queue`
  String get add_to_queue {
    return Intl.message(
      'Add to queue',
      name: 'add_to_queue',
      desc: '',
      args: [],
    );
  }

  /// `{track} will play next`
  String track_will_play_next(Object track) {
    return Intl.message(
      '$track will play next',
      name: 'track_will_play_next',
      desc: '',
      args: [track],
    );
  }

  /// `Play next`
  String get play_next {
    return Intl.message('Play next', name: 'play_next', desc: '', args: []);
  }

  /// `Removed {track} from queue`
  String removed_track_from_queue(Object track) {
    return Intl.message(
      'Removed $track from queue',
      name: 'removed_track_from_queue',
      desc: '',
      args: [track],
    );
  }

  /// `Remove from queue`
  String get remove_from_queue {
    return Intl.message(
      'Remove from queue',
      name: 'remove_from_queue',
      desc: '',
      args: [],
    );
  }

  /// `Remove from favorites`
  String get remove_from_favorites {
    return Intl.message(
      'Remove from favorites',
      name: 'remove_from_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Save as favorite`
  String get save_as_favorite {
    return Intl.message(
      'Save as favorite',
      name: 'save_as_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Add to playlist`
  String get add_to_playlist {
    return Intl.message(
      'Add to playlist',
      name: 'add_to_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Remove from playlist`
  String get remove_from_playlist {
    return Intl.message(
      'Remove from playlist',
      name: 'remove_from_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Add to blacklist`
  String get add_to_blacklist {
    return Intl.message(
      'Add to blacklist',
      name: 'add_to_blacklist',
      desc: '',
      args: [],
    );
  }

  /// `Remove from blacklist`
  String get remove_from_blacklist {
    return Intl.message(
      'Remove from blacklist',
      name: 'remove_from_blacklist',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Mini Player`
  String get mini_player {
    return Intl.message('Mini Player', name: 'mini_player', desc: '', args: []);
  }

  /// `Slide to seek forward or backward`
  String get slide_to_seek {
    return Intl.message(
      'Slide to seek forward or backward',
      name: 'slide_to_seek',
      desc: '',
      args: [],
    );
  }

  /// `Shuffle playlist`
  String get shuffle_playlist {
    return Intl.message(
      'Shuffle playlist',
      name: 'shuffle_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Unshuffle playlist`
  String get unshuffle_playlist {
    return Intl.message(
      'Unshuffle playlist',
      name: 'unshuffle_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Previous track`
  String get previous_track {
    return Intl.message(
      'Previous track',
      name: 'previous_track',
      desc: '',
      args: [],
    );
  }

  /// `Next track`
  String get next_track {
    return Intl.message('Next track', name: 'next_track', desc: '', args: []);
  }

  /// `Pause Playback`
  String get pause_playback {
    return Intl.message(
      'Pause Playback',
      name: 'pause_playback',
      desc: '',
      args: [],
    );
  }

  /// `Resume Playback`
  String get resume_playback {
    return Intl.message(
      'Resume Playback',
      name: 'resume_playback',
      desc: '',
      args: [],
    );
  }

  /// `Loop track`
  String get loop_track {
    return Intl.message('Loop track', name: 'loop_track', desc: '', args: []);
  }

  /// `No loop`
  String get no_loop {
    return Intl.message('No loop', name: 'no_loop', desc: '', args: []);
  }

  /// `Repeat playlist`
  String get repeat_playlist {
    return Intl.message(
      'Repeat playlist',
      name: 'repeat_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Queue`
  String get queue {
    return Intl.message('Queue', name: 'queue', desc: '', args: []);
  }

  /// `Alternative track sources`
  String get alternative_track_sources {
    return Intl.message(
      'Alternative track sources',
      name: 'alternative_track_sources',
      desc: '',
      args: [],
    );
  }

  /// `Download track`
  String get download_track {
    return Intl.message(
      'Download track',
      name: 'download_track',
      desc: '',
      args: [],
    );
  }

  /// `{tracks} tracks in queue`
  String tracks_in_queue(Object tracks) {
    return Intl.message(
      '$tracks tracks in queue',
      name: 'tracks_in_queue',
      desc: '',
      args: [tracks],
    );
  }

  /// `Clear all`
  String get clear_all {
    return Intl.message('Clear all', name: 'clear_all', desc: '', args: []);
  }

  /// `Show/Hide UI on hover`
  String get show_hide_ui_on_hover {
    return Intl.message(
      'Show/Hide UI on hover',
      name: 'show_hide_ui_on_hover',
      desc: '',
      args: [],
    );
  }

  /// `Always on top`
  String get always_on_top {
    return Intl.message(
      'Always on top',
      name: 'always_on_top',
      desc: '',
      args: [],
    );
  }

  /// `Exit Mini player`
  String get exit_mini_player {
    return Intl.message(
      'Exit Mini player',
      name: 'exit_mini_player',
      desc: '',
      args: [],
    );
  }

  /// `Download location`
  String get download_location {
    return Intl.message(
      'Download location',
      name: 'download_location',
      desc: '',
      args: [],
    );
  }

  /// `Local library`
  String get local_library {
    return Intl.message(
      'Local library',
      name: 'local_library',
      desc: '',
      args: [],
    );
  }

  /// `Add to library`
  String get add_library_location {
    return Intl.message(
      'Add to library',
      name: 'add_library_location',
      desc: '',
      args: [],
    );
  }

  /// `Remove from library`
  String get remove_library_location {
    return Intl.message(
      'Remove from library',
      name: 'remove_library_location',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Logout of this account`
  String get logout_of_this_account {
    return Intl.message(
      'Logout of this account',
      name: 'logout_of_this_account',
      desc: '',
      args: [],
    );
  }

  /// `Language & Region`
  String get language_region {
    return Intl.message(
      'Language & Region',
      name: 'language_region',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `System Default`
  String get system_default {
    return Intl.message(
      'System Default',
      name: 'system_default',
      desc: '',
      args: [],
    );
  }

  /// `Marketplace Region`
  String get market_place_region {
    return Intl.message(
      'Marketplace Region',
      name: 'market_place_region',
      desc: '',
      args: [],
    );
  }

  /// `Recommendation Country`
  String get recommendation_country {
    return Intl.message(
      'Recommendation Country',
      name: 'recommendation_country',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Layout Mode`
  String get layout_mode {
    return Intl.message('Layout Mode', name: 'layout_mode', desc: '', args: []);
  }

  /// `Override responsive layout mode settings`
  String get override_layout_settings {
    return Intl.message(
      'Override responsive layout mode settings',
      name: 'override_layout_settings',
      desc: '',
      args: [],
    );
  }

  /// `Adaptive`
  String get adaptive {
    return Intl.message('Adaptive', name: 'adaptive', desc: '', args: []);
  }

  /// `Compact`
  String get compact {
    return Intl.message('Compact', name: 'compact', desc: '', args: []);
  }

  /// `Extended`
  String get extended {
    return Intl.message('Extended', name: 'extended', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `Accent Color`
  String get accent_color {
    return Intl.message(
      'Accent Color',
      name: 'accent_color',
      desc: '',
      args: [],
    );
  }

  /// `Sync album color`
  String get sync_album_color {
    return Intl.message(
      'Sync album color',
      name: 'sync_album_color',
      desc: '',
      args: [],
    );
  }

  /// `Uses the dominant color of the album art as the accent color`
  String get sync_album_color_description {
    return Intl.message(
      'Uses the dominant color of the album art as the accent color',
      name: 'sync_album_color_description',
      desc: '',
      args: [],
    );
  }

  /// `Playback`
  String get playback {
    return Intl.message('Playback', name: 'playback', desc: '', args: []);
  }

  /// `Audio Quality`
  String get audio_quality {
    return Intl.message(
      'Audio Quality',
      name: 'audio_quality',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get high {
    return Intl.message('High', name: 'high', desc: '', args: []);
  }

  /// `Low`
  String get low {
    return Intl.message('Low', name: 'low', desc: '', args: []);
  }

  /// `Pre-download and play`
  String get pre_download_play {
    return Intl.message(
      'Pre-download and play',
      name: 'pre_download_play',
      desc: '',
      args: [],
    );
  }

  /// `Instead of streaming audio, download bytes and play instead (Recommended for higher bandwidth users)`
  String get pre_download_play_description {
    return Intl.message(
      'Instead of streaming audio, download bytes and play instead (Recommended for higher bandwidth users)',
      name: 'pre_download_play_description',
      desc: '',
      args: [],
    );
  }

  /// `Skip non-music segments (SponsorBlock)`
  String get skip_non_music {
    return Intl.message(
      'Skip non-music segments (SponsorBlock)',
      name: 'skip_non_music',
      desc: '',
      args: [],
    );
  }

  /// `Blacklisted tracks and artists`
  String get blacklist_description {
    return Intl.message(
      'Blacklisted tracks and artists',
      name: 'blacklist_description',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for the current download to finish`
  String get wait_for_download_to_finish {
    return Intl.message(
      'Please wait for the current download to finish',
      name: 'wait_for_download_to_finish',
      desc: '',
      args: [],
    );
  }

  /// `Desktop`
  String get desktop {
    return Intl.message('Desktop', name: 'desktop', desc: '', args: []);
  }

  /// `Close Behavior`
  String get close_behavior {
    return Intl.message(
      'Close Behavior',
      name: 'close_behavior',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Minimize to tray`
  String get minimize_to_tray {
    return Intl.message(
      'Minimize to tray',
      name: 'minimize_to_tray',
      desc: '',
      args: [],
    );
  }

  /// `Show System tray icon`
  String get show_tray_icon {
    return Intl.message(
      'Show System tray icon',
      name: 'show_tray_icon',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `We know you love Spotube`
  String get u_love_spotube {
    return Intl.message(
      'We know you love Spotube',
      name: 'u_love_spotube',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get check_for_updates {
    return Intl.message(
      'Check for updates',
      name: 'check_for_updates',
      desc: '',
      args: [],
    );
  }

  /// `About Spotube`
  String get about_spotube {
    return Intl.message(
      'About Spotube',
      name: 'about_spotube',
      desc: '',
      args: [],
    );
  }

  /// `Blacklist`
  String get blacklist {
    return Intl.message('Blacklist', name: 'blacklist', desc: '', args: []);
  }

  /// `Please Sponsor/Donate`
  String get please_sponsor {
    return Intl.message(
      'Please Sponsor/Donate',
      name: 'please_sponsor',
      desc: '',
      args: [],
    );
  }

  /// `Open source extensible music streaming platform and app, based on BYOMM (Bring your own music metadata) concept`
  String get spotube_description {
    return Intl.message(
      'Open source extensible music streaming platform and app, based on BYOMM (Bring your own music metadata) concept',
      name: 'spotube_description',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Build Number`
  String get build_number {
    return Intl.message(
      'Build Number',
      name: 'build_number',
      desc: '',
      args: [],
    );
  }

  /// `Founder`
  String get founder {
    return Intl.message('Founder', name: 'founder', desc: '', args: []);
  }

  /// `Repository`
  String get repository {
    return Intl.message('Repository', name: 'repository', desc: '', args: []);
  }

  /// `Bug+Issues`
  String get bug_issues {
    return Intl.message('Bug+Issues', name: 'bug_issues', desc: '', args: []);
  }

  /// `Made with ❤️ in Bangladesh🇧🇩`
  String get made_with {
    return Intl.message(
      'Made with ❤️ in Bangladesh🇧🇩',
      name: 'made_with',
      desc: '',
      args: [],
    );
  }

  /// `Kingkor Roy Tirtho`
  String get kingkor_roy_tirtho {
    return Intl.message(
      'Kingkor Roy Tirtho',
      name: 'kingkor_roy_tirtho',
      desc: '',
      args: [],
    );
  }

  /// `© 2021-{current_year} Kingkor Roy Tirtho`
  String copyright(Object current_year) {
    return Intl.message(
      '© 2021-$current_year Kingkor Roy Tirtho',
      name: 'copyright',
      desc: '',
      args: [current_year],
    );
  }

  /// `License`
  String get license {
    return Intl.message('License', name: 'license', desc: '', args: []);
  }

  /// `Don't worry, any of your credentials won't be collected or shared with anyone`
  String get credentials_will_not_be_shared_disclaimer {
    return Intl.message(
      'Don\'t worry, any of your credentials won\'t be collected or shared with anyone',
      name: 'credentials_will_not_be_shared_disclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Don't know how to do this?`
  String get know_how_to_login {
    return Intl.message(
      'Don\'t know how to do this?',
      name: 'know_how_to_login',
      desc: '',
      args: [],
    );
  }

  /// `Follow along the Step by Step guide`
  String get follow_step_by_step_guide {
    return Intl.message(
      'Follow along the Step by Step guide',
      name: 'follow_step_by_step_guide',
      desc: '',
      args: [],
    );
  }

  /// `{name} Cookie`
  String cookie_name_cookie(Object name) {
    return Intl.message(
      '$name Cookie',
      name: 'cookie_name_cookie',
      desc: '',
      args: [name],
    );
  }

  /// `Please fill in all the fields`
  String get fill_in_all_fields {
    return Intl.message(
      'Please fill in all the fields',
      name: 'fill_in_all_fields',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `Previous`
  String get previous {
    return Intl.message('Previous', name: 'previous', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Step 1`
  String get step_1 {
    return Intl.message('Step 1', name: 'step_1', desc: '', args: []);
  }

  /// `First, Go to`
  String get first_go_to {
    return Intl.message(
      'First, Go to',
      name: 'first_go_to',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get something_went_wrong {
    return Intl.message(
      'Something went wrong',
      name: 'something_went_wrong',
      desc: '',
      args: [],
    );
  }

  /// `Piped Server Instance`
  String get piped_instance {
    return Intl.message(
      'Piped Server Instance',
      name: 'piped_instance',
      desc: '',
      args: [],
    );
  }

  /// `The Piped server instance to use for track matching`
  String get piped_description {
    return Intl.message(
      'The Piped server instance to use for track matching',
      name: 'piped_description',
      desc: '',
      args: [],
    );
  }

  /// `Some of them might not work well. So use at your own risk`
  String get piped_warning {
    return Intl.message(
      'Some of them might not work well. So use at your own risk',
      name: 'piped_warning',
      desc: '',
      args: [],
    );
  }

  /// `Invidious Server Instance`
  String get invidious_instance {
    return Intl.message(
      'Invidious Server Instance',
      name: 'invidious_instance',
      desc: '',
      args: [],
    );
  }

  /// `The Invidious server instance to use for track matching`
  String get invidious_description {
    return Intl.message(
      'The Invidious server instance to use for track matching',
      name: 'invidious_description',
      desc: '',
      args: [],
    );
  }

  /// `Some of them might not work well. So use at your own risk`
  String get invidious_warning {
    return Intl.message(
      'Some of them might not work well. So use at your own risk',
      name: 'invidious_warning',
      desc: '',
      args: [],
    );
  }

  /// `Generate`
  String get generate {
    return Intl.message('Generate', name: 'generate', desc: '', args: []);
  }

  /// `Track {track} already exists`
  String track_exists(Object track) {
    return Intl.message(
      'Track $track already exists',
      name: 'track_exists',
      desc: '',
      args: [track],
    );
  }

  /// `Replace all downloaded tracks`
  String get replace_downloaded_tracks {
    return Intl.message(
      'Replace all downloaded tracks',
      name: 'replace_downloaded_tracks',
      desc: '',
      args: [],
    );
  }

  /// `Skip downloading all downloaded tracks`
  String get skip_download_tracks {
    return Intl.message(
      'Skip downloading all downloaded tracks',
      name: 'skip_download_tracks',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to replace the existing track??`
  String get do_you_want_to_replace {
    return Intl.message(
      'Do you want to replace the existing track??',
      name: 'do_you_want_to_replace',
      desc: '',
      args: [],
    );
  }

  /// `Replace`
  String get replace {
    return Intl.message('Replace', name: 'replace', desc: '', args: []);
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Select up to {count} {type}`
  String select_up_to_count_type(Object count, Object type) {
    return Intl.message(
      'Select up to $count $type',
      name: 'select_up_to_count_type',
      desc: '',
      args: [count, type],
    );
  }

  /// `Select Genres`
  String get select_genres {
    return Intl.message(
      'Select Genres',
      name: 'select_genres',
      desc: '',
      args: [],
    );
  }

  /// `Add Genres`
  String get add_genres {
    return Intl.message('Add Genres', name: 'add_genres', desc: '', args: []);
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `Number of tracks to generate`
  String get number_of_tracks_generate {
    return Intl.message(
      'Number of tracks to generate',
      name: 'number_of_tracks_generate',
      desc: '',
      args: [],
    );
  }

  /// `Acousticness`
  String get acousticness {
    return Intl.message(
      'Acousticness',
      name: 'acousticness',
      desc: '',
      args: [],
    );
  }

  /// `Danceability`
  String get danceability {
    return Intl.message(
      'Danceability',
      name: 'danceability',
      desc: '',
      args: [],
    );
  }

  /// `Energy`
  String get energy {
    return Intl.message('Energy', name: 'energy', desc: '', args: []);
  }

  /// `Instrumentalness`
  String get instrumentalness {
    return Intl.message(
      'Instrumentalness',
      name: 'instrumentalness',
      desc: '',
      args: [],
    );
  }

  /// `Liveness`
  String get liveness {
    return Intl.message('Liveness', name: 'liveness', desc: '', args: []);
  }

  /// `Loudness`
  String get loudness {
    return Intl.message('Loudness', name: 'loudness', desc: '', args: []);
  }

  /// `Speechiness`
  String get speechiness {
    return Intl.message('Speechiness', name: 'speechiness', desc: '', args: []);
  }

  /// `Valence`
  String get valence {
    return Intl.message('Valence', name: 'valence', desc: '', args: []);
  }

  /// `Popularity`
  String get popularity {
    return Intl.message('Popularity', name: 'popularity', desc: '', args: []);
  }

  /// `Key`
  String get key {
    return Intl.message('Key', name: 'key', desc: '', args: []);
  }

  /// `Duration (s)`
  String get duration {
    return Intl.message('Duration (s)', name: 'duration', desc: '', args: []);
  }

  /// `Tempo (BPM)`
  String get tempo {
    return Intl.message('Tempo (BPM)', name: 'tempo', desc: '', args: []);
  }

  /// `Mode`
  String get mode {
    return Intl.message('Mode', name: 'mode', desc: '', args: []);
  }

  /// `Time Signature`
  String get time_signature {
    return Intl.message(
      'Time Signature',
      name: 'time_signature',
      desc: '',
      args: [],
    );
  }

  /// `Short`
  String get short {
    return Intl.message('Short', name: 'short', desc: '', args: []);
  }

  /// `Medium`
  String get medium {
    return Intl.message('Medium', name: 'medium', desc: '', args: []);
  }

  /// `Long`
  String get long {
    return Intl.message('Long', name: 'long', desc: '', args: []);
  }

  /// `Min`
  String get min {
    return Intl.message('Min', name: 'min', desc: '', args: []);
  }

  /// `Max`
  String get max {
    return Intl.message('Max', name: 'max', desc: '', args: []);
  }

  /// `Target`
  String get target {
    return Intl.message('Target', name: 'target', desc: '', args: []);
  }

  /// `Moderate`
  String get moderate {
    return Intl.message('Moderate', name: 'moderate', desc: '', args: []);
  }

  /// `Deselect All`
  String get deselect_all {
    return Intl.message(
      'Deselect All',
      name: 'deselect_all',
      desc: '',
      args: [],
    );
  }

  /// `Select All`
  String get select_all {
    return Intl.message('Select All', name: 'select_all', desc: '', args: []);
  }

  /// `Are you sure?`
  String get are_you_sure {
    return Intl.message(
      'Are you sure?',
      name: 'are_you_sure',
      desc: '',
      args: [],
    );
  }

  /// `Generating your custom playlist...`
  String get generating_playlist {
    return Intl.message(
      'Generating your custom playlist...',
      name: 'generating_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Selected {count} tracks`
  String selected_count_tracks(Object count) {
    return Intl.message(
      'Selected $count tracks',
      name: 'selected_count_tracks',
      desc: '',
      args: [count],
    );
  }

  /// `If you download all Tracks at bulk you're clearly pirating Music & causing damage to the creative society of Music. I hope you are aware of this. Always, try respecting & supporting Artist's hard work`
  String get download_warning {
    return Intl.message(
      'If you download all Tracks at bulk you\'re clearly pirating Music & causing damage to the creative society of Music. I hope you are aware of this. Always, try respecting & supporting Artist\'s hard work',
      name: 'download_warning',
      desc: '',
      args: [],
    );
  }

  /// `BTW, your IP can get blocked on YouTube due excessive download requests than usual. IP block means you can't use YouTube (even if you're logged in) for at least 2-3 months from that IP device. And Spotube doesn't hold any responsibility if this ever happens`
  String get download_ip_ban_warning {
    return Intl.message(
      'BTW, your IP can get blocked on YouTube due excessive download requests than usual. IP block means you can\'t use YouTube (even if you\'re logged in) for at least 2-3 months from that IP device. And Spotube doesn\'t hold any responsibility if this ever happens',
      name: 'download_ip_ban_warning',
      desc: '',
      args: [],
    );
  }

  /// `By clicking 'accept' you agree to following terms:`
  String get by_clicking_accept_terms {
    return Intl.message(
      'By clicking \'accept\' you agree to following terms:',
      name: 'by_clicking_accept_terms',
      desc: '',
      args: [],
    );
  }

  /// `I know I'm pirating Music. I'm bad`
  String get download_agreement_1 {
    return Intl.message(
      'I know I\'m pirating Music. I\'m bad',
      name: 'download_agreement_1',
      desc: '',
      args: [],
    );
  }

  /// `I'll support the Artist wherever I can and I'm only doing this because I don't have money to buy their art`
  String get download_agreement_2 {
    return Intl.message(
      'I\'ll support the Artist wherever I can and I\'m only doing this because I don\'t have money to buy their art',
      name: 'download_agreement_2',
      desc: '',
      args: [],
    );
  }

  /// `I'm completely aware that my IP can get blocked on YouTube & I don't hold Spotube or his owners/contributors responsible for any accidents caused by my current action`
  String get download_agreement_3 {
    return Intl.message(
      'I\'m completely aware that my IP can get blocked on YouTube & I don\'t hold Spotube or his owners/contributors responsible for any accidents caused by my current action',
      name: 'download_agreement_3',
      desc: '',
      args: [],
    );
  }

  /// `Decline`
  String get decline {
    return Intl.message('Decline', name: 'decline', desc: '', args: []);
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `YouTube`
  String get youtube {
    return Intl.message('YouTube', name: 'youtube', desc: '', args: []);
  }

  /// `Channel`
  String get channel {
    return Intl.message('Channel', name: 'channel', desc: '', args: []);
  }

  /// `Likes`
  String get likes {
    return Intl.message('Likes', name: 'likes', desc: '', args: []);
  }

  /// `Dislikes`
  String get dislikes {
    return Intl.message('Dislikes', name: 'dislikes', desc: '', args: []);
  }

  /// `Views`
  String get views {
    return Intl.message('Views', name: 'views', desc: '', args: []);
  }

  /// `Stream URL`
  String get streamUrl {
    return Intl.message('Stream URL', name: 'streamUrl', desc: '', args: []);
  }

  /// `Stop`
  String get stop {
    return Intl.message('Stop', name: 'stop', desc: '', args: []);
  }

  /// `Sort by newest added`
  String get sort_newest {
    return Intl.message(
      'Sort by newest added',
      name: 'sort_newest',
      desc: '',
      args: [],
    );
  }

  /// `Sort by oldest added`
  String get sort_oldest {
    return Intl.message(
      'Sort by oldest added',
      name: 'sort_oldest',
      desc: '',
      args: [],
    );
  }

  /// `Sleep Timer`
  String get sleep_timer {
    return Intl.message('Sleep Timer', name: 'sleep_timer', desc: '', args: []);
  }

  /// `{minutes} Minutes`
  String mins(Object minutes) {
    return Intl.message(
      '$minutes Minutes',
      name: 'mins',
      desc: '',
      args: [minutes],
    );
  }

  /// `{hours} Hours`
  String hours(Object hours) {
    return Intl.message('$hours Hours', name: 'hours', desc: '', args: [hours]);
  }

  /// `{hours} Hour`
  String hour(Object hours) {
    return Intl.message('$hours Hour', name: 'hour', desc: '', args: [hours]);
  }

  /// `Custom Hours`
  String get custom_hours {
    return Intl.message(
      'Custom Hours',
      name: 'custom_hours',
      desc: '',
      args: [],
    );
  }

  /// `Logs`
  String get logs {
    return Intl.message('Logs', name: 'logs', desc: '', args: []);
  }

  /// `Developers`
  String get developers {
    return Intl.message('Developers', name: 'developers', desc: '', args: []);
  }

  /// `You're not logged in`
  String get not_logged_in {
    return Intl.message(
      'You\'re not logged in',
      name: 'not_logged_in',
      desc: '',
      args: [],
    );
  }

  /// `Search Mode`
  String get search_mode {
    return Intl.message('Search Mode', name: 'search_mode', desc: '', args: []);
  }

  /// `Audio Source`
  String get audio_source {
    return Intl.message(
      'Audio Source',
      name: 'audio_source',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `Failed to encrypt`
  String get failed_to_encrypt {
    return Intl.message(
      'Failed to encrypt',
      name: 'failed_to_encrypt',
      desc: '',
      args: [],
    );
  }

  /// `Spotube uses encryption to securely store your data. But failed to do so. So it'll fallback to insecure storage\nIf you're using linux, please make sure you've any secret-service (gnome-keyring, kde-wallet, keepassxc etc) installed`
  String get encryption_failed_warning {
    return Intl.message(
      'Spotube uses encryption to securely store your data. But failed to do so. So it\'ll fallback to insecure storage\nIf you\'re using linux, please make sure you\'ve any secret-service (gnome-keyring, kde-wallet, keepassxc etc) installed',
      name: 'encryption_failed_warning',
      desc: '',
      args: [],
    );
  }

  /// `Querying info...`
  String get querying_info {
    return Intl.message(
      'Querying info...',
      name: 'querying_info',
      desc: '',
      args: [],
    );
  }

  /// `Piped API is down`
  String get piped_api_down {
    return Intl.message(
      'Piped API is down',
      name: 'piped_api_down',
      desc: '',
      args: [],
    );
  }

  /// `The Piped instance {pipedInstance} is currently down\n\nEither change the instance or change the 'API type' to official YouTube API\n\nMake sure to restart the app after change`
  String piped_down_error_instructions(Object pipedInstance) {
    return Intl.message(
      'The Piped instance $pipedInstance is currently down\n\nEither change the instance or change the \'API type\' to official YouTube API\n\nMake sure to restart the app after change',
      name: 'piped_down_error_instructions',
      desc: '',
      args: [pipedInstance],
    );
  }

  /// `You are currently offline`
  String get you_are_offline {
    return Intl.message(
      'You are currently offline',
      name: 'you_are_offline',
      desc: '',
      args: [],
    );
  }

  /// `Your internet connection was restored`
  String get connection_restored {
    return Intl.message(
      'Your internet connection was restored',
      name: 'connection_restored',
      desc: '',
      args: [],
    );
  }

  /// `Use system title bar`
  String get use_system_title_bar {
    return Intl.message(
      'Use system title bar',
      name: 'use_system_title_bar',
      desc: '',
      args: [],
    );
  }

  /// `Crunching results...`
  String get crunching_results {
    return Intl.message(
      'Crunching results...',
      name: 'crunching_results',
      desc: '',
      args: [],
    );
  }

  /// `Search to get results`
  String get search_to_get_results {
    return Intl.message(
      'Search to get results',
      name: 'search_to_get_results',
      desc: '',
      args: [],
    );
  }

  /// `Pitch black dark theme`
  String get use_amoled_mode {
    return Intl.message(
      'Pitch black dark theme',
      name: 'use_amoled_mode',
      desc: '',
      args: [],
    );
  }

  /// `AMOLED Mode`
  String get pitch_dark_theme {
    return Intl.message(
      'AMOLED Mode',
      name: 'pitch_dark_theme',
      desc: '',
      args: [],
    );
  }

  /// `Normalize audio`
  String get normalize_audio {
    return Intl.message(
      'Normalize audio',
      name: 'normalize_audio',
      desc: '',
      args: [],
    );
  }

  /// `Change cover`
  String get change_cover {
    return Intl.message(
      'Change cover',
      name: 'change_cover',
      desc: '',
      args: [],
    );
  }

  /// `Add cover`
  String get add_cover {
    return Intl.message('Add cover', name: 'add_cover', desc: '', args: []);
  }

  /// `Restore defaults`
  String get restore_defaults {
    return Intl.message(
      'Restore defaults',
      name: 'restore_defaults',
      desc: '',
      args: [],
    );
  }

  /// `Download music format`
  String get download_music_format {
    return Intl.message(
      'Download music format',
      name: 'download_music_format',
      desc: '',
      args: [],
    );
  }

  /// `Streaming music format`
  String get streaming_music_format {
    return Intl.message(
      'Streaming music format',
      name: 'streaming_music_format',
      desc: '',
      args: [],
    );
  }

  /// `Download music quality`
  String get download_music_quality {
    return Intl.message(
      'Download music quality',
      name: 'download_music_quality',
      desc: '',
      args: [],
    );
  }

  /// `Streaming music quality`
  String get streaming_music_quality {
    return Intl.message(
      'Streaming music quality',
      name: 'streaming_music_quality',
      desc: '',
      args: [],
    );
  }

  /// `Login with Last.fm`
  String get login_with_lastfm {
    return Intl.message(
      'Login with Last.fm',
      name: 'login_with_lastfm',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get connect {
    return Intl.message('Connect', name: 'connect', desc: '', args: []);
  }

  /// `Disconnect Last.fm`
  String get disconnect_lastfm {
    return Intl.message(
      'Disconnect Last.fm',
      name: 'disconnect_lastfm',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message('Disconnect', name: 'disconnect', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Login with your Last.fm account`
  String get login_with_your_lastfm {
    return Intl.message(
      'Login with your Last.fm account',
      name: 'login_with_your_lastfm',
      desc: '',
      args: [],
    );
  }

  /// `Scrobble to Last.fm`
  String get scrobble_to_lastfm {
    return Intl.message(
      'Scrobble to Last.fm',
      name: 'scrobble_to_lastfm',
      desc: '',
      args: [],
    );
  }

  /// `Go to Album`
  String get go_to_album {
    return Intl.message('Go to Album', name: 'go_to_album', desc: '', args: []);
  }

  /// `Discord Rich Presence`
  String get discord_rich_presence {
    return Intl.message(
      'Discord Rich Presence',
      name: 'discord_rich_presence',
      desc: '',
      args: [],
    );
  }

  /// `Browse All`
  String get browse_all {
    return Intl.message('Browse All', name: 'browse_all', desc: '', args: []);
  }

  /// `Genres`
  String get genres {
    return Intl.message('Genres', name: 'genres', desc: '', args: []);
  }

  /// `Explore Genres`
  String get explore_genres {
    return Intl.message(
      'Explore Genres',
      name: 'explore_genres',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message('Friends', name: 'friends', desc: '', args: []);
  }

  /// `Sorry, unable find lyrics for this track`
  String get no_lyrics_available {
    return Intl.message(
      'Sorry, unable find lyrics for this track',
      name: 'no_lyrics_available',
      desc: '',
      args: [],
    );
  }

  /// `Start a Radio`
  String get start_a_radio {
    return Intl.message(
      'Start a Radio',
      name: 'start_a_radio',
      desc: '',
      args: [],
    );
  }

  /// `How do you want to start the radio?`
  String get how_to_start_radio {
    return Intl.message(
      'How do you want to start the radio?',
      name: 'how_to_start_radio',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to replace the current queue or append to it?`
  String get replace_queue_question {
    return Intl.message(
      'Do you want to replace the current queue or append to it?',
      name: 'replace_queue_question',
      desc: '',
      args: [],
    );
  }

  /// `Endless Playback`
  String get endless_playback {
    return Intl.message(
      'Endless Playback',
      name: 'endless_playback',
      desc: '',
      args: [],
    );
  }

  /// `Delete Playlist`
  String get delete_playlist {
    return Intl.message(
      'Delete Playlist',
      name: 'delete_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this playlist?`
  String get delete_playlist_confirmation {
    return Intl.message(
      'Are you sure you want to delete this playlist?',
      name: 'delete_playlist_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Local Tracks`
  String get local_tracks {
    return Intl.message(
      'Local Tracks',
      name: 'local_tracks',
      desc: '',
      args: [],
    );
  }

  /// `Local`
  String get local_tab {
    return Intl.message('Local', name: 'local_tab', desc: '', args: []);
  }

  /// `Song Link`
  String get song_link {
    return Intl.message('Song Link', name: 'song_link', desc: '', args: []);
  }

  /// `Skip this nonsense`
  String get skip_this_nonsense {
    return Intl.message(
      'Skip this nonsense',
      name: 'skip_this_nonsense',
      desc: '',
      args: [],
    );
  }

  /// `“Freedom of Music”`
  String get freedom_of_music {
    return Intl.message(
      '“Freedom of Music”',
      name: 'freedom_of_music',
      desc: '',
      args: [],
    );
  }

  /// `“Freedom of Music in the palm of your hand”`
  String get freedom_of_music_palm {
    return Intl.message(
      '“Freedom of Music in the palm of your hand”',
      name: 'freedom_of_music_palm',
      desc: '',
      args: [],
    );
  }

  /// `Let's get started`
  String get get_started {
    return Intl.message(
      'Let\'s get started',
      name: 'get_started',
      desc: '',
      args: [],
    );
  }

  /// `Recommended and works best.`
  String get youtube_source_description {
    return Intl.message(
      'Recommended and works best.',
      name: 'youtube_source_description',
      desc: '',
      args: [],
    );
  }

  /// `Feeling free? Same as YouTube but a lot free.`
  String get piped_source_description {
    return Intl.message(
      'Feeling free? Same as YouTube but a lot free.',
      name: 'piped_source_description',
      desc: '',
      args: [],
    );
  }

  /// `Best for South Asian region.`
  String get jiosaavn_source_description {
    return Intl.message(
      'Best for South Asian region.',
      name: 'jiosaavn_source_description',
      desc: '',
      args: [],
    );
  }

  /// `Similar to Piped but with higher availability.`
  String get invidious_source_description {
    return Intl.message(
      'Similar to Piped but with higher availability.',
      name: 'invidious_source_description',
      desc: '',
      args: [],
    );
  }

  /// `Highest Quality: {quality}`
  String highest_quality(Object quality) {
    return Intl.message(
      'Highest Quality: $quality',
      name: 'highest_quality',
      desc: '',
      args: [quality],
    );
  }

  /// `Select Audio Source`
  String get select_audio_source {
    return Intl.message(
      'Select Audio Source',
      name: 'select_audio_source',
      desc: '',
      args: [],
    );
  }

  /// `Automatically append new songs\nto the end of the queue`
  String get endless_playback_description {
    return Intl.message(
      'Automatically append new songs\nto the end of the queue',
      name: 'endless_playback_description',
      desc: '',
      args: [],
    );
  }

  /// `Choose your region`
  String get choose_your_region {
    return Intl.message(
      'Choose your region',
      name: 'choose_your_region',
      desc: '',
      args: [],
    );
  }

  /// `This will help Spotube show you the right content\nfor your location.`
  String get choose_your_region_description {
    return Intl.message(
      'This will help Spotube show you the right content\nfor your location.',
      name: 'choose_your_region_description',
      desc: '',
      args: [],
    );
  }

  /// `Choose your language`
  String get choose_your_language {
    return Intl.message(
      'Choose your language',
      name: 'choose_your_language',
      desc: '',
      args: [],
    );
  }

  /// `Help this project grow`
  String get help_project_grow {
    return Intl.message(
      'Help this project grow',
      name: 'help_project_grow',
      desc: '',
      args: [],
    );
  }

  /// `Spotube is an open-source project. You can help this project grow by contributing to the project, reporting bugs, or suggesting new features.`
  String get help_project_grow_description {
    return Intl.message(
      'Spotube is an open-source project. You can help this project grow by contributing to the project, reporting bugs, or suggesting new features.',
      name: 'help_project_grow_description',
      desc: '',
      args: [],
    );
  }

  /// `Contribute on GitHub`
  String get contribute_on_github {
    return Intl.message(
      'Contribute on GitHub',
      name: 'contribute_on_github',
      desc: '',
      args: [],
    );
  }

  /// `Donate on Open Collective`
  String get donate_on_open_collective {
    return Intl.message(
      'Donate on Open Collective',
      name: 'donate_on_open_collective',
      desc: '',
      args: [],
    );
  }

  /// `Browse Anonymously`
  String get browse_anonymously {
    return Intl.message(
      'Browse Anonymously',
      name: 'browse_anonymously',
      desc: '',
      args: [],
    );
  }

  /// `Enable Connect`
  String get enable_connect {
    return Intl.message(
      'Enable Connect',
      name: 'enable_connect',
      desc: '',
      args: [],
    );
  }

  /// `Control Spotube from other devices`
  String get enable_connect_description {
    return Intl.message(
      'Control Spotube from other devices',
      name: 'enable_connect_description',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get devices {
    return Intl.message('Devices', name: 'devices', desc: '', args: []);
  }

  /// `Select`
  String get select {
    return Intl.message('Select', name: 'select', desc: '', args: []);
  }

  /// `You're being controlled by {client}`
  String connect_client_alert(Object client) {
    return Intl.message(
      'You\'re being controlled by $client',
      name: 'connect_client_alert',
      desc: '',
      args: [client],
    );
  }

  /// `This Device`
  String get this_device {
    return Intl.message('This Device', name: 'this_device', desc: '', args: []);
  }

  /// `Remote`
  String get remote {
    return Intl.message('Remote', name: 'remote', desc: '', args: []);
  }

  /// `Stats`
  String get stats {
    return Intl.message('Stats', name: 'stats', desc: '', args: []);
  }

  /// `and {count} more`
  String and_n_more(Object count) {
    return Intl.message(
      'and $count more',
      name: 'and_n_more',
      desc: '',
      args: [count],
    );
  }

  /// `Recently Played`
  String get recently_played {
    return Intl.message(
      'Recently Played',
      name: 'recently_played',
      desc: '',
      args: [],
    );
  }

  /// `Browse More`
  String get browse_more {
    return Intl.message('Browse More', name: 'browse_more', desc: '', args: []);
  }

  /// `No Title`
  String get no_title {
    return Intl.message('No Title', name: 'no_title', desc: '', args: []);
  }

  /// `Not playing`
  String get not_playing {
    return Intl.message('Not playing', name: 'not_playing', desc: '', args: []);
  }

  /// `Epic failure!`
  String get epic_failure {
    return Intl.message(
      'Epic failure!',
      name: 'epic_failure',
      desc: '',
      args: [],
    );
  }

  /// `Added {tracks_length} tracks to queue`
  String added_num_tracks_to_queue(Object tracks_length) {
    return Intl.message(
      'Added $tracks_length tracks to queue',
      name: 'added_num_tracks_to_queue',
      desc: '',
      args: [tracks_length],
    );
  }

  /// `Spotube has an update`
  String get spotube_has_an_update {
    return Intl.message(
      'Spotube has an update',
      name: 'spotube_has_an_update',
      desc: '',
      args: [],
    );
  }

  /// `Download Now`
  String get download_now {
    return Intl.message(
      'Download Now',
      name: 'download_now',
      desc: '',
      args: [],
    );
  }

  /// `Spotube Nightly {nightlyBuildNum} has been released`
  String nightly_version(Object nightlyBuildNum) {
    return Intl.message(
      'Spotube Nightly $nightlyBuildNum has been released',
      name: 'nightly_version',
      desc: '',
      args: [nightlyBuildNum],
    );
  }

  /// `Spotube v{version} has been released`
  String release_version(Object version) {
    return Intl.message(
      'Spotube v$version has been released',
      name: 'release_version',
      desc: '',
      args: [version],
    );
  }

  /// `Read the latest `
  String get read_the_latest {
    return Intl.message(
      'Read the latest ',
      name: 'read_the_latest',
      desc: '',
      args: [],
    );
  }

  /// `release notes`
  String get release_notes {
    return Intl.message(
      'release notes',
      name: 'release_notes',
      desc: '',
      args: [],
    );
  }

  /// `Pick color scheme`
  String get pick_color_scheme {
    return Intl.message(
      'Pick color scheme',
      name: 'pick_color_scheme',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Choose the device:`
  String get choose_the_device {
    return Intl.message(
      'Choose the device:',
      name: 'choose_the_device',
      desc: '',
      args: [],
    );
  }

  /// `There are multiple device connected.\nChoose the device you want this action to take place`
  String get multiple_device_connected {
    return Intl.message(
      'There are multiple device connected.\nChoose the device you want this action to take place',
      name: 'multiple_device_connected',
      desc: '',
      args: [],
    );
  }

  /// `Nothing found`
  String get nothing_found {
    return Intl.message(
      'Nothing found',
      name: 'nothing_found',
      desc: '',
      args: [],
    );
  }

  /// `The box is empty`
  String get the_box_is_empty {
    return Intl.message(
      'The box is empty',
      name: 'the_box_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `Top Artists`
  String get top_artists {
    return Intl.message('Top Artists', name: 'top_artists', desc: '', args: []);
  }

  /// `Top Albums`
  String get top_albums {
    return Intl.message('Top Albums', name: 'top_albums', desc: '', args: []);
  }

  /// `This week`
  String get this_week {
    return Intl.message('This week', name: 'this_week', desc: '', args: []);
  }

  /// `This month`
  String get this_month {
    return Intl.message('This month', name: 'this_month', desc: '', args: []);
  }

  /// `Last 6 months`
  String get last_6_months {
    return Intl.message(
      'Last 6 months',
      name: 'last_6_months',
      desc: '',
      args: [],
    );
  }

  /// `This year`
  String get this_year {
    return Intl.message('This year', name: 'this_year', desc: '', args: []);
  }

  /// `Last 2 years`
  String get last_2_years {
    return Intl.message(
      'Last 2 years',
      name: 'last_2_years',
      desc: '',
      args: [],
    );
  }

  /// `All time`
  String get all_time {
    return Intl.message('All time', name: 'all_time', desc: '', args: []);
  }

  /// `Powered by {providerName}`
  String powered_by_provider(Object providerName) {
    return Intl.message(
      'Powered by $providerName',
      name: 'powered_by_provider',
      desc: '',
      args: [providerName],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Followers`
  String get profile_followers {
    return Intl.message(
      'Followers',
      name: 'profile_followers',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get birthday {
    return Intl.message('Birthday', name: 'birthday', desc: '', args: []);
  }

  /// `Subscription`
  String get subscription {
    return Intl.message(
      'Subscription',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `Not born`
  String get not_born {
    return Intl.message('Not born', name: 'not_born', desc: '', args: []);
  }

  /// `Hacker`
  String get hacker {
    return Intl.message('Hacker', name: 'hacker', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `No Name`
  String get no_name {
    return Intl.message('No Name', name: 'no_name', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `User Profile`
  String get user_profile {
    return Intl.message(
      'User Profile',
      name: 'user_profile',
      desc: '',
      args: [],
    );
  }

  /// `{count} plays`
  String count_plays(Object count) {
    return Intl.message(
      '$count plays',
      name: 'count_plays',
      desc: '',
      args: [count],
    );
  }

  /// `Streaming fees (hypothetical)`
  String get streaming_fees_hypothetical {
    return Intl.message(
      'Streaming fees (hypothetical)',
      name: 'streaming_fees_hypothetical',
      desc: '',
      args: [],
    );
  }

  /// `Minutes listened`
  String get minutes_listened {
    return Intl.message(
      'Minutes listened',
      name: 'minutes_listened',
      desc: '',
      args: [],
    );
  }

  /// `Streamed songs`
  String get streamed_songs {
    return Intl.message(
      'Streamed songs',
      name: 'streamed_songs',
      desc: '',
      args: [],
    );
  }

  /// `{count} streams`
  String count_streams(Object count) {
    return Intl.message(
      '$count streams',
      name: 'count_streams',
      desc: '',
      args: [count],
    );
  }

  /// `Owned by you`
  String get owned_by_you {
    return Intl.message(
      'Owned by you',
      name: 'owned_by_you',
      desc: '',
      args: [],
    );
  }

  /// `Copied {shareUrl} to clipboard`
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return Intl.message(
      'Copied $shareUrl to clipboard',
      name: 'copied_shareurl_to_clipboard',
      desc: '',
      args: [shareUrl],
    );
  }

  /// `*This is calculated based on average online music streaming platform's per stream\npayout of $0.003 to $0.005. This is a hypothetical\ncalculation to give user insight about how much they\nwould have paid to the artists if they were to listen\ntheir song in different music streaming platform.`
  String get hipotetical_calculation {
    return Intl.message(
      '*This is calculated based on average online music streaming platform\'s per stream\npayout of \$0.003 to \$0.005. This is a hypothetical\ncalculation to give user insight about how much they\nwould have paid to the artists if they were to listen\ntheir song in different music streaming platform.',
      name: 'hipotetical_calculation',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} mins`
  String count_mins(Object minutes) {
    return Intl.message(
      '$minutes mins',
      name: 'count_mins',
      desc: '',
      args: [minutes],
    );
  }

  /// `minutes`
  String get summary_minutes {
    return Intl.message('minutes', name: 'summary_minutes', desc: '', args: []);
  }

  /// `Listened to music`
  String get summary_listened_to_music {
    return Intl.message(
      'Listened to music',
      name: 'summary_listened_to_music',
      desc: '',
      args: [],
    );
  }

  /// `songs`
  String get summary_songs {
    return Intl.message('songs', name: 'summary_songs', desc: '', args: []);
  }

  /// `Streamed overall`
  String get summary_streamed_overall {
    return Intl.message(
      'Streamed overall',
      name: 'summary_streamed_overall',
      desc: '',
      args: [],
    );
  }

  /// `Owed to artists\nthis month`
  String get summary_owed_to_artists {
    return Intl.message(
      'Owed to artists\nthis month',
      name: 'summary_owed_to_artists',
      desc: '',
      args: [],
    );
  }

  /// `artist's`
  String get summary_artists {
    return Intl.message(
      'artist\'s',
      name: 'summary_artists',
      desc: '',
      args: [],
    );
  }

  /// `Music reached you`
  String get summary_music_reached_you {
    return Intl.message(
      'Music reached you',
      name: 'summary_music_reached_you',
      desc: '',
      args: [],
    );
  }

  /// `full albums`
  String get summary_full_albums {
    return Intl.message(
      'full albums',
      name: 'summary_full_albums',
      desc: '',
      args: [],
    );
  }

  /// `Got your love`
  String get summary_got_your_love {
    return Intl.message(
      'Got your love',
      name: 'summary_got_your_love',
      desc: '',
      args: [],
    );
  }

  /// `playlists`
  String get summary_playlists {
    return Intl.message(
      'playlists',
      name: 'summary_playlists',
      desc: '',
      args: [],
    );
  }

  /// `Were on repeat`
  String get summary_were_on_repeat {
    return Intl.message(
      'Were on repeat',
      name: 'summary_were_on_repeat',
      desc: '',
      args: [],
    );
  }

  /// `Total {money}`
  String total_money(Object money) {
    return Intl.message(
      'Total $money',
      name: 'total_money',
      desc: '',
      args: [money],
    );
  }

  /// `Webview not found`
  String get webview_not_found {
    return Intl.message(
      'Webview not found',
      name: 'webview_not_found',
      desc: '',
      args: [],
    );
  }

  /// `No webview runtime is installed in your device.\nIf it's installed make sure it's in the Environment PATH\n\nAfter installing, restart the app`
  String get webview_not_found_description {
    return Intl.message(
      'No webview runtime is installed in your device.\nIf it\'s installed make sure it\'s in the Environment PATH\n\nAfter installing, restart the app',
      name: 'webview_not_found_description',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported platform`
  String get unsupported_platform {
    return Intl.message(
      'Unsupported platform',
      name: 'unsupported_platform',
      desc: '',
      args: [],
    );
  }

  /// `Cache music`
  String get cache_music {
    return Intl.message('Cache music', name: 'cache_music', desc: '', args: []);
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `Cache folder`
  String get cache_folder {
    return Intl.message(
      'Cache folder',
      name: 'cache_folder',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get export {
    return Intl.message('Export', name: 'export', desc: '', args: []);
  }

  /// `Clear cache`
  String get clear_cache {
    return Intl.message('Clear cache', name: 'clear_cache', desc: '', args: []);
  }

  /// `Do you want to clear the cache?`
  String get clear_cache_confirmation {
    return Intl.message(
      'Do you want to clear the cache?',
      name: 'clear_cache_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Export Cached Files`
  String get export_cache_files {
    return Intl.message(
      'Export Cached Files',
      name: 'export_cache_files',
      desc: '',
      args: [],
    );
  }

  /// `Found {count} files`
  String found_n_files(Object count) {
    return Intl.message(
      'Found $count files',
      name: 'found_n_files',
      desc: '',
      args: [count],
    );
  }

  /// `Do you want to export these files to`
  String get export_cache_confirmation {
    return Intl.message(
      'Do you want to export these files to',
      name: 'export_cache_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Exported {filesExported} out of {files} files`
  String exported_n_out_of_m_files(Object filesExported, Object files) {
    return Intl.message(
      'Exported $filesExported out of $files files',
      name: 'exported_n_out_of_m_files',
      desc: '',
      args: [filesExported, files],
    );
  }

  /// `Undo`
  String get undo {
    return Intl.message('Undo', name: 'undo', desc: '', args: []);
  }

  /// `Download all`
  String get download_all {
    return Intl.message(
      'Download all',
      name: 'download_all',
      desc: '',
      args: [],
    );
  }

  /// `Add all to playlist`
  String get add_all_to_playlist {
    return Intl.message(
      'Add all to playlist',
      name: 'add_all_to_playlist',
      desc: '',
      args: [],
    );
  }

  /// `Add all to queue`
  String get add_all_to_queue {
    return Intl.message(
      'Add all to queue',
      name: 'add_all_to_queue',
      desc: '',
      args: [],
    );
  }

  /// `Play all next`
  String get play_all_next {
    return Intl.message(
      'Play all next',
      name: 'play_all_next',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message('Pause', name: 'pause', desc: '', args: []);
  }

  /// `View all`
  String get view_all {
    return Intl.message('View all', name: 'view_all', desc: '', args: []);
  }

  /// `Looks like you haven't added any tracks yet`
  String get no_tracks_added_yet {
    return Intl.message(
      'Looks like you haven\'t added any tracks yet',
      name: 'no_tracks_added_yet',
      desc: '',
      args: [],
    );
  }

  /// `Looks like there are no tracks here`
  String get no_tracks {
    return Intl.message(
      'Looks like there are no tracks here',
      name: 'no_tracks',
      desc: '',
      args: [],
    );
  }

  /// `Looks like you haven't listened to anything yet`
  String get no_tracks_listened_yet {
    return Intl.message(
      'Looks like you haven\'t listened to anything yet',
      name: 'no_tracks_listened_yet',
      desc: '',
      args: [],
    );
  }

  /// `You're not following any artists`
  String get not_following_artists {
    return Intl.message(
      'You\'re not following any artists',
      name: 'not_following_artists',
      desc: '',
      args: [],
    );
  }

  /// `Looks like you haven't added any albums to your favorites yet`
  String get no_favorite_albums_yet {
    return Intl.message(
      'Looks like you haven\'t added any albums to your favorites yet',
      name: 'no_favorite_albums_yet',
      desc: '',
      args: [],
    );
  }

  /// `No logs found`
  String get no_logs_found {
    return Intl.message(
      'No logs found',
      name: 'no_logs_found',
      desc: '',
      args: [],
    );
  }

  /// `YouTube Engine`
  String get youtube_engine {
    return Intl.message(
      'YouTube Engine',
      name: 'youtube_engine',
      desc: '',
      args: [],
    );
  }

  /// `{engine} is not installed`
  String youtube_engine_not_installed_title(Object engine) {
    return Intl.message(
      '$engine is not installed',
      name: 'youtube_engine_not_installed_title',
      desc: '',
      args: [engine],
    );
  }

  /// `{engine} is not installed in your system.`
  String youtube_engine_not_installed_message(Object engine) {
    return Intl.message(
      '$engine is not installed in your system.',
      name: 'youtube_engine_not_installed_message',
      desc: '',
      args: [engine],
    );
  }

  /// `Make sure it's available in the PATH variable or\nset the absolute path to the {engine} executable below`
  String youtube_engine_set_path(Object engine) {
    return Intl.message(
      'Make sure it\'s available in the PATH variable or\nset the absolute path to the $engine executable below',
      name: 'youtube_engine_set_path',
      desc: '',
      args: [engine],
    );
  }

  /// `In macOS/Linux/unix like OS's, setting path on .zshrc/.bashrc/.bash_profile etc. won't work.\nYou need to set the path in the shell configuration file`
  String get youtube_engine_unix_issue_message {
    return Intl.message(
      'In macOS/Linux/unix like OS\'s, setting path on .zshrc/.bashrc/.bash_profile etc. won\'t work.\nYou need to set the path in the shell configuration file',
      name: 'youtube_engine_unix_issue_message',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `File not found`
  String get file_not_found {
    return Intl.message(
      'File not found',
      name: 'file_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Add custom URL`
  String get add_custom_url {
    return Intl.message(
      'Add custom URL',
      name: 'add_custom_url',
      desc: '',
      args: [],
    );
  }

  /// `Edit port`
  String get edit_port {
    return Intl.message('Edit port', name: 'edit_port', desc: '', args: []);
  }

  /// `Default is -1 which indicates random number. If you've firewall configured, setting this is recommended.`
  String get port_helper_msg {
    return Intl.message(
      'Default is -1 which indicates random number. If you\'ve firewall configured, setting this is recommended.',
      name: 'port_helper_msg',
      desc: '',
      args: [],
    );
  }

  /// `Allow {client} to connect?`
  String connect_request(Object client) {
    return Intl.message(
      'Allow $client to connect?',
      name: 'connect_request',
      desc: '',
      args: [client],
    );
  }

  /// `Connection denied. User denied access.`
  String get connection_request_denied {
    return Intl.message(
      'Connection denied. User denied access.',
      name: 'connection_request_denied',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get an_error_occurred {
    return Intl.message(
      'An error occurred',
      name: 'an_error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Copy to clipboard`
  String get copy_to_clipboard {
    return Intl.message(
      'Copy to clipboard',
      name: 'copy_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `View logs`
  String get view_logs {
    return Intl.message('View logs', name: 'view_logs', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `You've no default metadata provider set`
  String get no_default_metadata_provider_selected {
    return Intl.message(
      'You\'ve no default metadata provider set',
      name: 'no_default_metadata_provider_selected',
      desc: '',
      args: [],
    );
  }

  /// `Manage metadata providers`
  String get manage_metadata_providers {
    return Intl.message(
      'Manage metadata providers',
      name: 'manage_metadata_providers',
      desc: '',
      args: [],
    );
  }

  /// `Open Link in Browser?`
  String get open_link_in_browser {
    return Intl.message(
      'Open Link in Browser?',
      name: 'open_link_in_browser',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to open the following link`
  String get do_you_want_to_open_the_following_link {
    return Intl.message(
      'Do you want to open the following link',
      name: 'do_you_want_to_open_the_following_link',
      desc: '',
      args: [],
    );
  }

  /// `It can be unsafe to open links from untrusted sources. Be cautious!\nYou can also copy the link to your clipboard.`
  String get unsafe_url_warning {
    return Intl.message(
      'It can be unsafe to open links from untrusted sources. Be cautious!\nYou can also copy the link to your clipboard.',
      name: 'unsafe_url_warning',
      desc: '',
      args: [],
    );
  }

  /// `Copy Link`
  String get copy_link {
    return Intl.message('Copy Link', name: 'copy_link', desc: '', args: []);
  }

  /// `Building your timeline based on your listenings...`
  String get building_your_timeline {
    return Intl.message(
      'Building your timeline based on your listenings...',
      name: 'building_your_timeline',
      desc: '',
      args: [],
    );
  }

  /// `Official`
  String get official {
    return Intl.message('Official', name: 'official', desc: '', args: []);
  }

  /// `Author: {author}`
  String author_name(Object author) {
    return Intl.message(
      'Author: $author',
      name: 'author_name',
      desc: '',
      args: [author],
    );
  }

  /// `Third-party`
  String get third_party {
    return Intl.message('Third-party', name: 'third_party', desc: '', args: []);
  }

  /// `Plugin requires authentication`
  String get plugin_requires_authentication {
    return Intl.message(
      'Plugin requires authentication',
      name: 'plugin_requires_authentication',
      desc: '',
      args: [],
    );
  }

  /// `Update available`
  String get update_available {
    return Intl.message(
      'Update available',
      name: 'update_available',
      desc: '',
      args: [],
    );
  }

  /// `Supports scrobbling`
  String get supports_scrobbling {
    return Intl.message(
      'Supports scrobbling',
      name: 'supports_scrobbling',
      desc: '',
      args: [],
    );
  }

  /// `This plugin scrobbles your music to generate your listening history.`
  String get plugin_scrobbling_info {
    return Intl.message(
      'This plugin scrobbles your music to generate your listening history.',
      name: 'plugin_scrobbling_info',
      desc: '',
      args: [],
    );
  }

  /// `Default metadata source`
  String get default_metadata_source {
    return Intl.message(
      'Default metadata source',
      name: 'default_metadata_source',
      desc: '',
      args: [],
    );
  }

  /// `Set default metadata source`
  String get set_default_metadata_source {
    return Intl.message(
      'Set default metadata source',
      name: 'set_default_metadata_source',
      desc: '',
      args: [],
    );
  }

  /// `Default audio source`
  String get default_audio_source {
    return Intl.message(
      'Default audio source',
      name: 'default_audio_source',
      desc: '',
      args: [],
    );
  }

  /// `Set default audio source`
  String get set_default_audio_source {
    return Intl.message(
      'Set default audio source',
      name: 'set_default_audio_source',
      desc: '',
      args: [],
    );
  }

  /// `Set default`
  String get set_default {
    return Intl.message('Set default', name: 'set_default', desc: '', args: []);
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Support plugin development`
  String get support_plugin_development {
    return Intl.message(
      'Support plugin development',
      name: 'support_plugin_development',
      desc: '',
      args: [],
    );
  }

  /// `- Can access **{name}** API`
  String can_access_name_api(Object name) {
    return Intl.message(
      '- Can access **$name** API',
      name: 'can_access_name_api',
      desc: '',
      args: [name],
    );
  }

  /// `Do you want to install this plugin?`
  String get do_you_want_to_install_this_plugin {
    return Intl.message(
      'Do you want to install this plugin?',
      name: 'do_you_want_to_install_this_plugin',
      desc: '',
      args: [],
    );
  }

  /// `This plugin is from a third-party repository. Please ensure you trust the source before installing.`
  String get third_party_plugin_warning {
    return Intl.message(
      'This plugin is from a third-party repository. Please ensure you trust the source before installing.',
      name: 'third_party_plugin_warning',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message('Author', name: 'author', desc: '', args: []);
  }

  /// `This plugin can do following`
  String get this_plugin_can_do_following {
    return Intl.message(
      'This plugin can do following',
      name: 'this_plugin_can_do_following',
      desc: '',
      args: [],
    );
  }

  /// `Install`
  String get install {
    return Intl.message('Install', name: 'install', desc: '', args: []);
  }

  /// `Install a Metadata Provider`
  String get install_a_metadata_provider {
    return Intl.message(
      'Install a Metadata Provider',
      name: 'install_a_metadata_provider',
      desc: '',
      args: [],
    );
  }

  /// `No Track being played currently`
  String get no_tracks_playing {
    return Intl.message(
      'No Track being played currently',
      name: 'no_tracks_playing',
      desc: '',
      args: [],
    );
  }

  /// `Synced lyrics are not available for this song. Please use the`
  String get synced_lyrics_not_available {
    return Intl.message(
      'Synced lyrics are not available for this song. Please use the',
      name: 'synced_lyrics_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Plain Lyrics`
  String get plain_lyrics {
    return Intl.message(
      'Plain Lyrics',
      name: 'plain_lyrics',
      desc: '',
      args: [],
    );
  }

  /// `tab instead.`
  String get tab_instead {
    return Intl.message(
      'tab instead.',
      name: 'tab_instead',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer`
  String get disclaimer {
    return Intl.message('Disclaimer', name: 'disclaimer', desc: '', args: []);
  }

  /// `The Spotube team does not hold any responsibility (including legal) for any "Third-party" plugins.\nPlease use them at your own risk. For any bugs/issues, please report them to the plugin repository.\n\nIf any "Third-party" plugin is breaking ToS/DMCA of any service/legal entity, please ask the "Third-party" plugin author or the hosting platform .e.g GitHub/Codeberg to take action. Above listed ("Third-party" labelled) are all public/community maintained plugins. We're not curating them, so we cannot take any action on them.\n\n`
  String get third_party_plugin_dmca_notice {
    return Intl.message(
      'The Spotube team does not hold any responsibility (including legal) for any "Third-party" plugins.\nPlease use them at your own risk. For any bugs/issues, please report them to the plugin repository.\n\nIf any "Third-party" plugin is breaking ToS/DMCA of any service/legal entity, please ask the "Third-party" plugin author or the hosting platform .e.g GitHub/Codeberg to take action. Above listed ("Third-party" labelled) are all public/community maintained plugins. We\'re not curating them, so we cannot take any action on them.\n\n',
      name: 'third_party_plugin_dmca_notice',
      desc: '',
      args: [],
    );
  }

  /// `Input doesn't match the required format`
  String get input_does_not_match_format {
    return Intl.message(
      'Input doesn\'t match the required format',
      name: 'input_does_not_match_format',
      desc: '',
      args: [],
    );
  }

  /// `Plugins`
  String get plugins {
    return Intl.message('Plugins', name: 'plugins', desc: '', args: []);
  }

  /// `Paste download url or GitHub/Codeberg repo url or direct link to .smplug file`
  String get paste_plugin_download_url {
    return Intl.message(
      'Paste download url or GitHub/Codeberg repo url or direct link to .smplug file',
      name: 'paste_plugin_download_url',
      desc: '',
      args: [],
    );
  }

  /// `Download and install plugin from url`
  String get download_and_install_plugin_from_url {
    return Intl.message(
      'Download and install plugin from url',
      name: 'download_and_install_plugin_from_url',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add plugin: {error}`
  String failed_to_add_plugin_error(Object error) {
    return Intl.message(
      'Failed to add plugin: $error',
      name: 'failed_to_add_plugin_error',
      desc: '',
      args: [error],
    );
  }

  /// `Upload plugin from file`
  String get upload_plugin_from_file {
    return Intl.message(
      'Upload plugin from file',
      name: 'upload_plugin_from_file',
      desc: '',
      args: [],
    );
  }

  /// `Installed`
  String get installed {
    return Intl.message('Installed', name: 'installed', desc: '', args: []);
  }

  /// `Available plugins`
  String get available_plugins {
    return Intl.message(
      'Available plugins',
      name: 'available_plugins',
      desc: '',
      args: [],
    );
  }

  /// `Configure your own metadata provider and audio source plugins`
  String get configure_plugins {
    return Intl.message(
      'Configure your own metadata provider and audio source plugins',
      name: 'configure_plugins',
      desc: '',
      args: [],
    );
  }

  /// `Audio Scrobblers`
  String get audio_scrobblers {
    return Intl.message(
      'Audio Scrobblers',
      name: 'audio_scrobblers',
      desc: '',
      args: [],
    );
  }

  /// `Scrobbling`
  String get scrobbling {
    return Intl.message('Scrobbling', name: 'scrobbling', desc: '', args: []);
  }

  /// `Source: `
  String get source {
    return Intl.message('Source: ', name: 'source', desc: '', args: []);
  }

  /// `Uncompressed`
  String get uncompressed {
    return Intl.message(
      'Uncompressed',
      name: 'uncompressed',
      desc: '',
      args: [],
    );
  }

  /// `For audiophiles. Provides high-quality/lossless audio streams. Accurate ISRC based track matching.`
  String get dab_music_source_description {
    return Intl.message(
      'For audiophiles. Provides high-quality/lossless audio streams. Accurate ISRC based track matching.',
      name: 'dab_music_source_description',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
