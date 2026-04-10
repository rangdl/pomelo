// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "Add (${count}) to Playlist";

  static String m1(count) => "Add (${count}) to Queue";

  static String m2(track) => "Add ${track} to following Playlists";

  static String m3(tracks_length) => "Added ${tracks_length} tracks to queue";

  static String m4(tracks) => "Added ${tracks} tracks to queue";

  static String m5(track) => "Added ${track} to queue";

  static String m6(count) => "and ${count} more";

  static String m7(author) => "Author: ${author}";

  static String m8(name) => "- Can access **${name}** API";

  static String m9(client) => "You\'re being controlled by ${client}";

  static String m10(client) => "Allow ${client} to connect?";

  static String m11(name) => "${name} Cookie";

  static String m12(shareUrl) => "Copied ${shareUrl} to clipboard";

  static String m13(data) => "Copied ${data} to clipboard";

  static String m14(current_year) =>
      "© 2021-${current_year} Kingkor Roy Tirtho";

  static String m15(minutes) => "${minutes} mins";

  static String m16(count) => "${count} plays";

  static String m17(count) => "${count} streams";

  static String m18(tracks_length) =>
      "Currently Downloading (${tracks_length})";

  static String m19(count) => "Download (${count})";

  static String m20(error) => "Error ${error}";

  static String m21(filesExported, files) =>
      "Exported ${filesExported} out of ${files} files";

  static String m22(error) => "Failed to add plugin: ${error}";

  static String m23(followers) => "${followers} Followers";

  static String m24(count) => "Found ${count} files";

  static String m25(quality) => "Highest Quality: ${quality}";

  static String m26(hours) => "${hours} Hour";

  static String m27(hours) => "${hours} Hours";

  static String m28(minutes) => "${minutes} Minutes";

  static String m29(nightlyBuildNum) =>
      "Spotube Nightly ${nightlyBuildNum} has been released";

  static String m30(pipedInstance) =>
      "The Piped instance ${pipedInstance} is currently down\n\nEither change the instance or change the \'API type\' to official YouTube API\n\nMake sure to restart the app after change";

  static String m31(count) => "Play (${count}) next";

  static String m32(track) => "Playing ${track}";

  static String m33(providerName) => "Powered by ${providerName}";

  static String m34(track_length) =>
      "This will clear the current queue. ${track_length} tracks will be removed\nDo you want to continue?";

  static String m35(version) => "Spotube v${version} has been released";

  static String m36(track) => "Removed ${track} from queue";

  static String m37(count, type) => "Select up to ${count} ${type}";

  static String m38(count) => "Selected ${count} tracks";

  static String m39(money) => "Total ${money}";

  static String m40(track) => "Track ${track} already exists";

  static String m41(track) => "${track} will play next";

  static String m42(tracks) => "${tracks} tracks in queue";

  static String m43(engine) => "${engine} is not installed in your system.";

  static String m44(engine) => "${engine} is not installed";

  static String m45(engine) =>
      "Make sure it\'s available in the PATH variable or\nset the absolute path to the ${engine} executable below";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "about_spotube": MessageLookupByLibrary.simpleMessage("About Spotube"),
    "accent_color": MessageLookupByLibrary.simpleMessage("Accent Color"),
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "acousticness": MessageLookupByLibrary.simpleMessage("Acousticness"),
    "adaptive": MessageLookupByLibrary.simpleMessage("Adaptive"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "add_all_to_playlist": MessageLookupByLibrary.simpleMessage(
      "Add all to playlist",
    ),
    "add_all_to_queue": MessageLookupByLibrary.simpleMessage(
      "Add all to queue",
    ),
    "add_artist_to_blacklist": MessageLookupByLibrary.simpleMessage(
      "Add artist to blacklist",
    ),
    "add_count_to_playlist": m0,
    "add_count_to_queue": m1,
    "add_cover": MessageLookupByLibrary.simpleMessage("Add cover"),
    "add_custom_url": MessageLookupByLibrary.simpleMessage("Add custom URL"),
    "add_genres": MessageLookupByLibrary.simpleMessage("Add Genres"),
    "add_library_location": MessageLookupByLibrary.simpleMessage(
      "Add to library",
    ),
    "add_to_blacklist": MessageLookupByLibrary.simpleMessage(
      "Add to blacklist",
    ),
    "add_to_following_playlists": m2,
    "add_to_playlist": MessageLookupByLibrary.simpleMessage("Add to playlist"),
    "add_to_queue": MessageLookupByLibrary.simpleMessage("Add to queue"),
    "added_num_tracks_to_queue": m3,
    "added_to_queue": m4,
    "added_track_to_queue": m5,
    "album": MessageLookupByLibrary.simpleMessage("Album"),
    "albums": MessageLookupByLibrary.simpleMessage("Albums"),
    "all_time": MessageLookupByLibrary.simpleMessage("All time"),
    "alternative_track_sources": MessageLookupByLibrary.simpleMessage(
      "Alternative track sources",
    ),
    "always_on_top": MessageLookupByLibrary.simpleMessage("Always on top"),
    "an_error_occurred": MessageLookupByLibrary.simpleMessage(
      "An error occurred",
    ),
    "and_n_more": m6,
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "are_you_sure": MessageLookupByLibrary.simpleMessage("Are you sure?"),
    "artist": MessageLookupByLibrary.simpleMessage("Artist"),
    "artist_url_copied": MessageLookupByLibrary.simpleMessage(
      "Artist URL copied to clipboard",
    ),
    "artists": MessageLookupByLibrary.simpleMessage("Artists"),
    "audio_quality": MessageLookupByLibrary.simpleMessage("Audio Quality"),
    "audio_scrobblers": MessageLookupByLibrary.simpleMessage(
      "Audio Scrobblers",
    ),
    "audio_source": MessageLookupByLibrary.simpleMessage("Audio Source"),
    "author": MessageLookupByLibrary.simpleMessage("Author"),
    "author_name": m7,
    "available_plugins": MessageLookupByLibrary.simpleMessage(
      "Available plugins",
    ),
    "birthday": MessageLookupByLibrary.simpleMessage("Birthday"),
    "blacklist": MessageLookupByLibrary.simpleMessage("Blacklist"),
    "blacklist_description": MessageLookupByLibrary.simpleMessage(
      "Blacklisted tracks and artists",
    ),
    "blacklisted": MessageLookupByLibrary.simpleMessage("Blacklisted"),
    "browse": MessageLookupByLibrary.simpleMessage("Browse"),
    "browse_all": MessageLookupByLibrary.simpleMessage("Browse All"),
    "browse_anonymously": MessageLookupByLibrary.simpleMessage(
      "Browse Anonymously",
    ),
    "browse_more": MessageLookupByLibrary.simpleMessage("Browse More"),
    "bug_issues": MessageLookupByLibrary.simpleMessage("Bug+Issues"),
    "build_number": MessageLookupByLibrary.simpleMessage("Build Number"),
    "building_your_timeline": MessageLookupByLibrary.simpleMessage(
      "Building your timeline based on your listenings...",
    ),
    "by_clicking_accept_terms": MessageLookupByLibrary.simpleMessage(
      "By clicking \'accept\' you agree to following terms:",
    ),
    "cache_folder": MessageLookupByLibrary.simpleMessage("Cache folder"),
    "cache_music": MessageLookupByLibrary.simpleMessage("Cache music"),
    "can_access_name_api": m8,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancel_all": MessageLookupByLibrary.simpleMessage("Cancel All"),
    "change_cover": MessageLookupByLibrary.simpleMessage("Change cover"),
    "channel": MessageLookupByLibrary.simpleMessage("Channel"),
    "check_for_updates": MessageLookupByLibrary.simpleMessage(
      "Check for updates",
    ),
    "choose_the_device": MessageLookupByLibrary.simpleMessage(
      "Choose the device:",
    ),
    "choose_your_language": MessageLookupByLibrary.simpleMessage(
      "Choose your language",
    ),
    "choose_your_region": MessageLookupByLibrary.simpleMessage(
      "Choose your region",
    ),
    "choose_your_region_description": MessageLookupByLibrary.simpleMessage(
      "This will help Spotube show you the right content\nfor your location.",
    ),
    "clear_all": MessageLookupByLibrary.simpleMessage("Clear all"),
    "clear_cache": MessageLookupByLibrary.simpleMessage("Clear cache"),
    "clear_cache_confirmation": MessageLookupByLibrary.simpleMessage(
      "Do you want to clear the cache?",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "close_behavior": MessageLookupByLibrary.simpleMessage("Close Behavior"),
    "collaborative": MessageLookupByLibrary.simpleMessage("Collaborative"),
    "compact": MessageLookupByLibrary.simpleMessage("Compact"),
    "configure_plugins": MessageLookupByLibrary.simpleMessage(
      "Configure your own metadata provider and audio source plugins",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("Connect"),
    "connect_client_alert": m9,
    "connect_request": m10,
    "connection_request_denied": MessageLookupByLibrary.simpleMessage(
      "Connection denied. User denied access.",
    ),
    "connection_restored": MessageLookupByLibrary.simpleMessage(
      "Your internet connection was restored",
    ),
    "contribute_on_github": MessageLookupByLibrary.simpleMessage(
      "Contribute on GitHub",
    ),
    "cookie_name_cookie": m11,
    "copied_shareurl_to_clipboard": m12,
    "copied_to_clipboard": m13,
    "copy_link": MessageLookupByLibrary.simpleMessage("Copy Link"),
    "copy_to_clipboard": MessageLookupByLibrary.simpleMessage(
      "Copy to clipboard",
    ),
    "copyright": m14,
    "count_mins": m15,
    "count_plays": m16,
    "count_streams": m17,
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "create_a_playlist": MessageLookupByLibrary.simpleMessage(
      "Create a playlist",
    ),
    "credentials_will_not_be_shared_disclaimer":
        MessageLookupByLibrary.simpleMessage(
          "Don\'t worry, any of your credentials won\'t be collected or shared with anyone",
        ),
    "crunching_results": MessageLookupByLibrary.simpleMessage(
      "Crunching results...",
    ),
    "currently_downloading": m18,
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "custom_hours": MessageLookupByLibrary.simpleMessage("Custom Hours"),
    "dab_music_source_description": MessageLookupByLibrary.simpleMessage(
      "For audiophiles. Provides high-quality/lossless audio streams. Accurate ISRC based track matching.",
    ),
    "danceability": MessageLookupByLibrary.simpleMessage("Danceability"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "decline": MessageLookupByLibrary.simpleMessage("Decline"),
    "default_audio_source": MessageLookupByLibrary.simpleMessage(
      "Default audio source",
    ),
    "default_metadata_source": MessageLookupByLibrary.simpleMessage(
      "Default metadata source",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_playlist": MessageLookupByLibrary.simpleMessage("Delete Playlist"),
    "delete_playlist_confirmation": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this playlist?",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "deselect_all": MessageLookupByLibrary.simpleMessage("Deselect All"),
    "desktop": MessageLookupByLibrary.simpleMessage("Desktop"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "developers": MessageLookupByLibrary.simpleMessage("Developers"),
    "devices": MessageLookupByLibrary.simpleMessage("Devices"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "disconnect_lastfm": MessageLookupByLibrary.simpleMessage(
      "Disconnect Last.fm",
    ),
    "discord_rich_presence": MessageLookupByLibrary.simpleMessage(
      "Discord Rich Presence",
    ),
    "dislikes": MessageLookupByLibrary.simpleMessage("Dislikes"),
    "do_you_want_to_install_this_plugin": MessageLookupByLibrary.simpleMessage(
      "Do you want to install this plugin?",
    ),
    "do_you_want_to_open_the_following_link":
        MessageLookupByLibrary.simpleMessage(
          "Do you want to open the following link",
        ),
    "do_you_want_to_replace": MessageLookupByLibrary.simpleMessage(
      "Do you want to replace the existing track??",
    ),
    "donate_on_open_collective": MessageLookupByLibrary.simpleMessage(
      "Donate on Open Collective",
    ),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "download_agreement_1": MessageLookupByLibrary.simpleMessage(
      "I know I\'m pirating Music. I\'m bad",
    ),
    "download_agreement_2": MessageLookupByLibrary.simpleMessage(
      "I\'ll support the Artist wherever I can and I\'m only doing this because I don\'t have money to buy their art",
    ),
    "download_agreement_3": MessageLookupByLibrary.simpleMessage(
      "I\'m completely aware that my IP can get blocked on YouTube & I don\'t hold Spotube or his owners/contributors responsible for any accidents caused by my current action",
    ),
    "download_all": MessageLookupByLibrary.simpleMessage("Download all"),
    "download_and_install_plugin_from_url":
        MessageLookupByLibrary.simpleMessage(
          "Download and install plugin from url",
        ),
    "download_count": m19,
    "download_ip_ban_warning": MessageLookupByLibrary.simpleMessage(
      "BTW, your IP can get blocked on YouTube due excessive download requests than usual. IP block means you can\'t use YouTube (even if you\'re logged in) for at least 2-3 months from that IP device. And Spotube doesn\'t hold any responsibility if this ever happens",
    ),
    "download_location": MessageLookupByLibrary.simpleMessage(
      "Download location",
    ),
    "download_music_format": MessageLookupByLibrary.simpleMessage(
      "Download music format",
    ),
    "download_music_quality": MessageLookupByLibrary.simpleMessage(
      "Download music quality",
    ),
    "download_now": MessageLookupByLibrary.simpleMessage("Download Now"),
    "download_track": MessageLookupByLibrary.simpleMessage("Download track"),
    "download_warning": MessageLookupByLibrary.simpleMessage(
      "If you download all Tracks at bulk you\'re clearly pirating Music & causing damage to the creative society of Music. I hope you are aware of this. Always, try respecting & supporting Artist\'s hard work",
    ),
    "downloads": MessageLookupByLibrary.simpleMessage("Downloads"),
    "duration": MessageLookupByLibrary.simpleMessage("Duration (s)"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "edit_port": MessageLookupByLibrary.simpleMessage("Edit port"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "enable_connect": MessageLookupByLibrary.simpleMessage("Enable Connect"),
    "enable_connect_description": MessageLookupByLibrary.simpleMessage(
      "Control Spotube from other devices",
    ),
    "encryption_failed_warning": MessageLookupByLibrary.simpleMessage(
      "Spotube uses encryption to securely store your data. But failed to do so. So it\'ll fallback to insecure storage\nIf you\'re using linux, please make sure you\'ve any secret-service (gnome-keyring, kde-wallet, keepassxc etc) installed",
    ),
    "endless_playback": MessageLookupByLibrary.simpleMessage(
      "Endless Playback",
    ),
    "endless_playback_description": MessageLookupByLibrary.simpleMessage(
      "Automatically append new songs\nto the end of the queue",
    ),
    "energy": MessageLookupByLibrary.simpleMessage("Energy"),
    "epic_failure": MessageLookupByLibrary.simpleMessage("Epic failure!"),
    "error": m20,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "exit_mini_player": MessageLookupByLibrary.simpleMessage(
      "Exit Mini player",
    ),
    "explore_genres": MessageLookupByLibrary.simpleMessage("Explore Genres"),
    "export": MessageLookupByLibrary.simpleMessage("Export"),
    "export_cache_confirmation": MessageLookupByLibrary.simpleMessage(
      "Do you want to export these files to",
    ),
    "export_cache_files": MessageLookupByLibrary.simpleMessage(
      "Export Cached Files",
    ),
    "exported_n_out_of_m_files": m21,
    "extended": MessageLookupByLibrary.simpleMessage("Extended"),
    "failed_to_add_plugin_error": m22,
    "failed_to_encrypt": MessageLookupByLibrary.simpleMessage(
      "Failed to encrypt",
    ),
    "fans_also_like": MessageLookupByLibrary.simpleMessage("Fans also like"),
    "featured": MessageLookupByLibrary.simpleMessage("Featured"),
    "file_not_found": MessageLookupByLibrary.simpleMessage("File not found"),
    "fill_in_all_fields": MessageLookupByLibrary.simpleMessage(
      "Please fill in all the fields",
    ),
    "filter_albums": MessageLookupByLibrary.simpleMessage("Filter albums..."),
    "filter_artist": MessageLookupByLibrary.simpleMessage("Filter artists..."),
    "filter_playlists": MessageLookupByLibrary.simpleMessage(
      "Filter your playlists...",
    ),
    "first_go_to": MessageLookupByLibrary.simpleMessage("First, Go to"),
    "follow": MessageLookupByLibrary.simpleMessage("Follow"),
    "follow_step_by_step_guide": MessageLookupByLibrary.simpleMessage(
      "Follow along the Step by Step guide",
    ),
    "followers": m23,
    "following": MessageLookupByLibrary.simpleMessage("Following"),
    "found_n_files": m24,
    "founder": MessageLookupByLibrary.simpleMessage("Founder"),
    "freedom_of_music": MessageLookupByLibrary.simpleMessage(
      "“Freedom of Music”",
    ),
    "freedom_of_music_palm": MessageLookupByLibrary.simpleMessage(
      "“Freedom of Music in the palm of your hand”",
    ),
    "friends": MessageLookupByLibrary.simpleMessage("Friends"),
    "generate": MessageLookupByLibrary.simpleMessage("Generate"),
    "generating_playlist": MessageLookupByLibrary.simpleMessage(
      "Generating your custom playlist...",
    ),
    "genre": MessageLookupByLibrary.simpleMessage("Genre"),
    "genre_categories_filter": MessageLookupByLibrary.simpleMessage(
      "Filter categories or genres...",
    ),
    "genres": MessageLookupByLibrary.simpleMessage("Genres"),
    "get_started": MessageLookupByLibrary.simpleMessage("Let\'s get started"),
    "go_to_album": MessageLookupByLibrary.simpleMessage("Go to Album"),
    "guest": MessageLookupByLibrary.simpleMessage("Guest"),
    "hacker": MessageLookupByLibrary.simpleMessage("Hacker"),
    "help_project_grow": MessageLookupByLibrary.simpleMessage(
      "Help this project grow",
    ),
    "help_project_grow_description": MessageLookupByLibrary.simpleMessage(
      "Spotube is an open-source project. You can help this project grow by contributing to the project, reporting bugs, or suggesting new features.",
    ),
    "high": MessageLookupByLibrary.simpleMessage("High"),
    "highest_quality": m25,
    "hipotetical_calculation": MessageLookupByLibrary.simpleMessage(
      "*This is calculated based on average online music streaming platform\'s per stream\npayout of \$0.003 to \$0.005. This is a hypothetical\ncalculation to give user insight about how much they\nwould have paid to the artists if they were to listen\ntheir song in different music streaming platform.",
    ),
    "hour": m26,
    "hours": m27,
    "how_to_start_radio": MessageLookupByLibrary.simpleMessage(
      "How do you want to start the radio?",
    ),
    "input_does_not_match_format": MessageLookupByLibrary.simpleMessage(
      "Input doesn\'t match the required format",
    ),
    "install": MessageLookupByLibrary.simpleMessage("Install"),
    "install_a_metadata_provider": MessageLookupByLibrary.simpleMessage(
      "Install a Metadata Provider",
    ),
    "installed": MessageLookupByLibrary.simpleMessage("Installed"),
    "instrumentalness": MessageLookupByLibrary.simpleMessage(
      "Instrumentalness",
    ),
    "invidious_description": MessageLookupByLibrary.simpleMessage(
      "The Invidious server instance to use for track matching",
    ),
    "invidious_instance": MessageLookupByLibrary.simpleMessage(
      "Invidious Server Instance",
    ),
    "invidious_source_description": MessageLookupByLibrary.simpleMessage(
      "Similar to Piped but with higher availability.",
    ),
    "invidious_warning": MessageLookupByLibrary.simpleMessage(
      "Some of them might not work well. So use at your own risk",
    ),
    "jiosaavn_source_description": MessageLookupByLibrary.simpleMessage(
      "Best for South Asian region.",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "kingkor_roy_tirtho": MessageLookupByLibrary.simpleMessage(
      "Kingkor Roy Tirtho",
    ),
    "know_how_to_login": MessageLookupByLibrary.simpleMessage(
      "Don\'t know how to do this?",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "language_region": MessageLookupByLibrary.simpleMessage(
      "Language & Region",
    ),
    "last_2_years": MessageLookupByLibrary.simpleMessage("Last 2 years"),
    "last_6_months": MessageLookupByLibrary.simpleMessage("Last 6 months"),
    "layout_mode": MessageLookupByLibrary.simpleMessage("Layout Mode"),
    "library": MessageLookupByLibrary.simpleMessage("Library"),
    "license": MessageLookupByLibrary.simpleMessage("License"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "liked_tracks": MessageLookupByLibrary.simpleMessage("Liked Tracks"),
    "liked_tracks_description": MessageLookupByLibrary.simpleMessage(
      "All your liked tracks",
    ),
    "likes": MessageLookupByLibrary.simpleMessage("Likes"),
    "liveness": MessageLookupByLibrary.simpleMessage("Liveness"),
    "load_more": MessageLookupByLibrary.simpleMessage("Load more"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "local_library": MessageLookupByLibrary.simpleMessage("Local library"),
    "local_tab": MessageLookupByLibrary.simpleMessage("Local"),
    "local_tracks": MessageLookupByLibrary.simpleMessage("Local Tracks"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "login_with_lastfm": MessageLookupByLibrary.simpleMessage(
      "Login with Last.fm",
    ),
    "login_with_your_lastfm": MessageLookupByLibrary.simpleMessage(
      "Login with your Last.fm account",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logout_of_this_account": MessageLookupByLibrary.simpleMessage(
      "Logout of this account",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "long": MessageLookupByLibrary.simpleMessage("Long"),
    "loop_track": MessageLookupByLibrary.simpleMessage("Loop track"),
    "loudness": MessageLookupByLibrary.simpleMessage("Loudness"),
    "low": MessageLookupByLibrary.simpleMessage("Low"),
    "lyrics": MessageLookupByLibrary.simpleMessage("Lyrics"),
    "made_with": MessageLookupByLibrary.simpleMessage(
      "Made with ❤️ in Bangladesh🇧🇩",
    ),
    "manage_metadata_providers": MessageLookupByLibrary.simpleMessage(
      "Manage metadata providers",
    ),
    "market_place_region": MessageLookupByLibrary.simpleMessage(
      "Marketplace Region",
    ),
    "max": MessageLookupByLibrary.simpleMessage("Max"),
    "medium": MessageLookupByLibrary.simpleMessage("Medium"),
    "min": MessageLookupByLibrary.simpleMessage("Min"),
    "mini_player": MessageLookupByLibrary.simpleMessage("Mini Player"),
    "minimize_to_tray": MessageLookupByLibrary.simpleMessage(
      "Minimize to tray",
    ),
    "mins": m28,
    "minutes_listened": MessageLookupByLibrary.simpleMessage(
      "Minutes listened",
    ),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "moderate": MessageLookupByLibrary.simpleMessage("Moderate"),
    "more_actions": MessageLookupByLibrary.simpleMessage("More actions"),
    "multiple_device_connected": MessageLookupByLibrary.simpleMessage(
      "There are multiple device connected.\nChoose the device you want this action to take place",
    ),
    "name_of_playlist": MessageLookupByLibrary.simpleMessage(
      "Name of the playlist",
    ),
    "new_releases": MessageLookupByLibrary.simpleMessage("New Releases"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "next_track": MessageLookupByLibrary.simpleMessage("Next track"),
    "nightly_version": m29,
    "no_default_metadata_provider_selected":
        MessageLookupByLibrary.simpleMessage(
          "You\'ve no default metadata provider set",
        ),
    "no_favorite_albums_yet": MessageLookupByLibrary.simpleMessage(
      "Looks like you haven\'t added any albums to your favorites yet",
    ),
    "no_logs_found": MessageLookupByLibrary.simpleMessage("No logs found"),
    "no_loop": MessageLookupByLibrary.simpleMessage("No loop"),
    "no_lyrics_available": MessageLookupByLibrary.simpleMessage(
      "Sorry, unable find lyrics for this track",
    ),
    "no_name": MessageLookupByLibrary.simpleMessage("No Name"),
    "no_title": MessageLookupByLibrary.simpleMessage("No Title"),
    "no_tracks": MessageLookupByLibrary.simpleMessage(
      "Looks like there are no tracks here",
    ),
    "no_tracks_added_yet": MessageLookupByLibrary.simpleMessage(
      "Looks like you haven\'t added any tracks yet",
    ),
    "no_tracks_listened_yet": MessageLookupByLibrary.simpleMessage(
      "Looks like you haven\'t listened to anything yet",
    ),
    "no_tracks_playing": MessageLookupByLibrary.simpleMessage(
      "No Track being played currently",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "normalize_audio": MessageLookupByLibrary.simpleMessage("Normalize audio"),
    "not_born": MessageLookupByLibrary.simpleMessage("Not born"),
    "not_following_artists": MessageLookupByLibrary.simpleMessage(
      "You\'re not following any artists",
    ),
    "not_logged_in": MessageLookupByLibrary.simpleMessage(
      "You\'re not logged in",
    ),
    "not_playing": MessageLookupByLibrary.simpleMessage("Not playing"),
    "nothing_found": MessageLookupByLibrary.simpleMessage("Nothing found"),
    "number_of_tracks_generate": MessageLookupByLibrary.simpleMessage(
      "Number of tracks to generate",
    ),
    "official": MessageLookupByLibrary.simpleMessage("Official"),
    "ok": MessageLookupByLibrary.simpleMessage("Ok"),
    "open": MessageLookupByLibrary.simpleMessage("Open"),
    "open_link_in_browser": MessageLookupByLibrary.simpleMessage(
      "Open Link in Browser?",
    ),
    "override_layout_settings": MessageLookupByLibrary.simpleMessage(
      "Override responsive layout mode settings",
    ),
    "owned_by_you": MessageLookupByLibrary.simpleMessage("Owned by you"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste_plugin_download_url": MessageLookupByLibrary.simpleMessage(
      "Paste download url or GitHub/Codeberg repo url or direct link to .smplug file",
    ),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "pause_playback": MessageLookupByLibrary.simpleMessage("Pause Playback"),
    "personalized": MessageLookupByLibrary.simpleMessage("Personalized"),
    "pick_color_scheme": MessageLookupByLibrary.simpleMessage(
      "Pick color scheme",
    ),
    "piped_api_down": MessageLookupByLibrary.simpleMessage("Piped API is down"),
    "piped_description": MessageLookupByLibrary.simpleMessage(
      "The Piped server instance to use for track matching",
    ),
    "piped_down_error_instructions": m30,
    "piped_instance": MessageLookupByLibrary.simpleMessage(
      "Piped Server Instance",
    ),
    "piped_source_description": MessageLookupByLibrary.simpleMessage(
      "Feeling free? Same as YouTube but a lot free.",
    ),
    "piped_warning": MessageLookupByLibrary.simpleMessage(
      "Some of them might not work well. So use at your own risk",
    ),
    "pitch_dark_theme": MessageLookupByLibrary.simpleMessage("AMOLED Mode"),
    "plain": MessageLookupByLibrary.simpleMessage("Plain"),
    "plain_lyrics": MessageLookupByLibrary.simpleMessage("Plain Lyrics"),
    "play": MessageLookupByLibrary.simpleMessage("Play"),
    "play_all_next": MessageLookupByLibrary.simpleMessage("Play all next"),
    "play_count_next": m31,
    "play_next": MessageLookupByLibrary.simpleMessage("Play next"),
    "playback": MessageLookupByLibrary.simpleMessage("Playback"),
    "playing_track": m32,
    "playlist": MessageLookupByLibrary.simpleMessage("Playlist"),
    "playlist_name": MessageLookupByLibrary.simpleMessage("Playlist Name"),
    "playlists": MessageLookupByLibrary.simpleMessage("Playlists"),
    "please_sponsor": MessageLookupByLibrary.simpleMessage(
      "Please Sponsor/Donate",
    ),
    "plugin_requires_authentication": MessageLookupByLibrary.simpleMessage(
      "Plugin requires authentication",
    ),
    "plugin_scrobbling_info": MessageLookupByLibrary.simpleMessage(
      "This plugin scrobbles your music to generate your listening history.",
    ),
    "plugins": MessageLookupByLibrary.simpleMessage("Plugins"),
    "popularity": MessageLookupByLibrary.simpleMessage("Popularity"),
    "port_helper_msg": MessageLookupByLibrary.simpleMessage(
      "Default is -1 which indicates random number. If you\'ve firewall configured, setting this is recommended.",
    ),
    "powered_by_provider": m33,
    "pre_download_play": MessageLookupByLibrary.simpleMessage(
      "Pre-download and play",
    ),
    "pre_download_play_description": MessageLookupByLibrary.simpleMessage(
      "Instead of streaming audio, download bytes and play instead (Recommended for higher bandwidth users)",
    ),
    "previous": MessageLookupByLibrary.simpleMessage("Previous"),
    "previous_track": MessageLookupByLibrary.simpleMessage("Previous track"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profile_followers": MessageLookupByLibrary.simpleMessage("Followers"),
    "public": MessageLookupByLibrary.simpleMessage("Public"),
    "querying_info": MessageLookupByLibrary.simpleMessage("Querying info..."),
    "queue": MessageLookupByLibrary.simpleMessage("Queue"),
    "queue_clear_alert": m34,
    "read_the_latest": MessageLookupByLibrary.simpleMessage("Read the latest "),
    "recently_played": MessageLookupByLibrary.simpleMessage("Recently Played"),
    "recommendation_country": MessageLookupByLibrary.simpleMessage(
      "Recommendation Country",
    ),
    "release_notes": MessageLookupByLibrary.simpleMessage("release notes"),
    "release_version": m35,
    "released": MessageLookupByLibrary.simpleMessage("Released"),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remove_from_blacklist": MessageLookupByLibrary.simpleMessage(
      "Remove from blacklist",
    ),
    "remove_from_favorites": MessageLookupByLibrary.simpleMessage(
      "Remove from favorites",
    ),
    "remove_from_playlist": MessageLookupByLibrary.simpleMessage(
      "Remove from playlist",
    ),
    "remove_from_queue": MessageLookupByLibrary.simpleMessage(
      "Remove from queue",
    ),
    "remove_library_location": MessageLookupByLibrary.simpleMessage(
      "Remove from library",
    ),
    "removed_track_from_queue": m36,
    "repeat_playlist": MessageLookupByLibrary.simpleMessage("Repeat playlist"),
    "replace": MessageLookupByLibrary.simpleMessage("Replace"),
    "replace_downloaded_tracks": MessageLookupByLibrary.simpleMessage(
      "Replace all downloaded tracks",
    ),
    "replace_queue_question": MessageLookupByLibrary.simpleMessage(
      "Do you want to replace the current queue or append to it?",
    ),
    "repository": MessageLookupByLibrary.simpleMessage("Repository"),
    "restore_defaults": MessageLookupByLibrary.simpleMessage(
      "Restore defaults",
    ),
    "resume_playback": MessageLookupByLibrary.simpleMessage("Resume Playback"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "save_as_favorite": MessageLookupByLibrary.simpleMessage(
      "Save as favorite",
    ),
    "scrobble_to_lastfm": MessageLookupByLibrary.simpleMessage(
      "Scrobble to Last.fm",
    ),
    "scrobbling": MessageLookupByLibrary.simpleMessage("Scrobbling"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "search_local_tracks": MessageLookupByLibrary.simpleMessage(
      "Search local tracks...",
    ),
    "search_mode": MessageLookupByLibrary.simpleMessage("Search Mode"),
    "search_to_get_results": MessageLookupByLibrary.simpleMessage(
      "Search to get results",
    ),
    "search_tracks": MessageLookupByLibrary.simpleMessage("Search tracks..."),
    "select": MessageLookupByLibrary.simpleMessage("Select"),
    "select_all": MessageLookupByLibrary.simpleMessage("Select All"),
    "select_audio_source": MessageLookupByLibrary.simpleMessage(
      "Select Audio Source",
    ),
    "select_genres": MessageLookupByLibrary.simpleMessage("Select Genres"),
    "select_up_to_count_type": m37,
    "selected_count_tracks": m38,
    "set_default": MessageLookupByLibrary.simpleMessage("Set default"),
    "set_default_audio_source": MessageLookupByLibrary.simpleMessage(
      "Set default audio source",
    ),
    "set_default_metadata_source": MessageLookupByLibrary.simpleMessage(
      "Set default metadata source",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "short": MessageLookupByLibrary.simpleMessage("Short"),
    "show_hide_ui_on_hover": MessageLookupByLibrary.simpleMessage(
      "Show/Hide UI on hover",
    ),
    "show_tray_icon": MessageLookupByLibrary.simpleMessage(
      "Show System tray icon",
    ),
    "shuffle": MessageLookupByLibrary.simpleMessage("Shuffle"),
    "shuffle_playlist": MessageLookupByLibrary.simpleMessage(
      "Shuffle playlist",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "skip_download_tracks": MessageLookupByLibrary.simpleMessage(
      "Skip downloading all downloaded tracks",
    ),
    "skip_non_music": MessageLookupByLibrary.simpleMessage(
      "Skip non-music segments (SponsorBlock)",
    ),
    "skip_this_nonsense": MessageLookupByLibrary.simpleMessage(
      "Skip this nonsense",
    ),
    "sleep_timer": MessageLookupByLibrary.simpleMessage("Sleep Timer"),
    "slide_to_seek": MessageLookupByLibrary.simpleMessage(
      "Slide to seek forward or backward",
    ),
    "something_went_wrong": MessageLookupByLibrary.simpleMessage(
      "Something went wrong",
    ),
    "song_link": MessageLookupByLibrary.simpleMessage("Song Link"),
    "songs": MessageLookupByLibrary.simpleMessage("Songs"),
    "sort_a_z": MessageLookupByLibrary.simpleMessage("Sort by A-Z"),
    "sort_album": MessageLookupByLibrary.simpleMessage("Sort by Album"),
    "sort_artist": MessageLookupByLibrary.simpleMessage("Sort by Artist"),
    "sort_duration": MessageLookupByLibrary.simpleMessage("Sort by Duration"),
    "sort_newest": MessageLookupByLibrary.simpleMessage("Sort by newest added"),
    "sort_oldest": MessageLookupByLibrary.simpleMessage("Sort by oldest added"),
    "sort_tracks": MessageLookupByLibrary.simpleMessage("Sort Tracks"),
    "sort_z_a": MessageLookupByLibrary.simpleMessage("Sort by Z-A"),
    "source": MessageLookupByLibrary.simpleMessage("Source: "),
    "speechiness": MessageLookupByLibrary.simpleMessage("Speechiness"),
    "spotube_description": MessageLookupByLibrary.simpleMessage(
      "Open source extensible music streaming platform and app, based on BYOMM (Bring your own music metadata) concept",
    ),
    "spotube_has_an_update": MessageLookupByLibrary.simpleMessage(
      "Spotube has an update",
    ),
    "start_a_radio": MessageLookupByLibrary.simpleMessage("Start a Radio"),
    "stats": MessageLookupByLibrary.simpleMessage("Stats"),
    "step_1": MessageLookupByLibrary.simpleMessage("Step 1"),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "streamUrl": MessageLookupByLibrary.simpleMessage("Stream URL"),
    "streamed_songs": MessageLookupByLibrary.simpleMessage("Streamed songs"),
    "streaming_fees_hypothetical": MessageLookupByLibrary.simpleMessage(
      "Streaming fees (hypothetical)",
    ),
    "streaming_music_format": MessageLookupByLibrary.simpleMessage(
      "Streaming music format",
    ),
    "streaming_music_quality": MessageLookupByLibrary.simpleMessage(
      "Streaming music quality",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscription": MessageLookupByLibrary.simpleMessage("Subscription"),
    "summary_artists": MessageLookupByLibrary.simpleMessage("artist\'s"),
    "summary_full_albums": MessageLookupByLibrary.simpleMessage("full albums"),
    "summary_got_your_love": MessageLookupByLibrary.simpleMessage(
      "Got your love",
    ),
    "summary_listened_to_music": MessageLookupByLibrary.simpleMessage(
      "Listened to music",
    ),
    "summary_minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "summary_music_reached_you": MessageLookupByLibrary.simpleMessage(
      "Music reached you",
    ),
    "summary_owed_to_artists": MessageLookupByLibrary.simpleMessage(
      "Owed to artists\nthis month",
    ),
    "summary_playlists": MessageLookupByLibrary.simpleMessage("playlists"),
    "summary_songs": MessageLookupByLibrary.simpleMessage("songs"),
    "summary_streamed_overall": MessageLookupByLibrary.simpleMessage(
      "Streamed overall",
    ),
    "summary_were_on_repeat": MessageLookupByLibrary.simpleMessage(
      "Were on repeat",
    ),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "support_plugin_development": MessageLookupByLibrary.simpleMessage(
      "Support plugin development",
    ),
    "supports_scrobbling": MessageLookupByLibrary.simpleMessage(
      "Supports scrobbling",
    ),
    "sync_album_color": MessageLookupByLibrary.simpleMessage(
      "Sync album color",
    ),
    "sync_album_color_description": MessageLookupByLibrary.simpleMessage(
      "Uses the dominant color of the album art as the accent color",
    ),
    "synced": MessageLookupByLibrary.simpleMessage("Synced"),
    "synced_lyrics_not_available": MessageLookupByLibrary.simpleMessage(
      "Synced lyrics are not available for this song. Please use the",
    ),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "system_default": MessageLookupByLibrary.simpleMessage("System Default"),
    "tab_instead": MessageLookupByLibrary.simpleMessage("tab instead."),
    "target": MessageLookupByLibrary.simpleMessage("Target"),
    "tempo": MessageLookupByLibrary.simpleMessage("Tempo (BPM)"),
    "the_box_is_empty": MessageLookupByLibrary.simpleMessage(
      "The box is empty",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "third_party": MessageLookupByLibrary.simpleMessage("Third-party"),
    "third_party_plugin_dmca_notice": MessageLookupByLibrary.simpleMessage(
      "The Spotube team does not hold any responsibility (including legal) for any \"Third-party\" plugins.\nPlease use them at your own risk. For any bugs/issues, please report them to the plugin repository.\n\nIf any \"Third-party\" plugin is breaking ToS/DMCA of any service/legal entity, please ask the \"Third-party\" plugin author or the hosting platform .e.g GitHub/Codeberg to take action. Above listed (\"Third-party\" labelled) are all public/community maintained plugins. We\'re not curating them, so we cannot take any action on them.\n\n",
    ),
    "third_party_plugin_warning": MessageLookupByLibrary.simpleMessage(
      "This plugin is from a third-party repository. Please ensure you trust the source before installing.",
    ),
    "this_device": MessageLookupByLibrary.simpleMessage("This Device"),
    "this_month": MessageLookupByLibrary.simpleMessage("This month"),
    "this_plugin_can_do_following": MessageLookupByLibrary.simpleMessage(
      "This plugin can do following",
    ),
    "this_week": MessageLookupByLibrary.simpleMessage("This week"),
    "this_year": MessageLookupByLibrary.simpleMessage("This year"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "time_signature": MessageLookupByLibrary.simpleMessage("Time Signature"),
    "title": MessageLookupByLibrary.simpleMessage("Title"),
    "top_albums": MessageLookupByLibrary.simpleMessage("Top Albums"),
    "top_artists": MessageLookupByLibrary.simpleMessage("Top Artists"),
    "top_tracks": MessageLookupByLibrary.simpleMessage("Top Tracks"),
    "total_money": m39,
    "track_exists": m40,
    "track_will_play_next": m41,
    "tracks": MessageLookupByLibrary.simpleMessage("Tracks"),
    "tracks_in_queue": m42,
    "u_love_spotube": MessageLookupByLibrary.simpleMessage(
      "We know you love Spotube",
    ),
    "uncompressed": MessageLookupByLibrary.simpleMessage("Uncompressed"),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unsafe_url_warning": MessageLookupByLibrary.simpleMessage(
      "It can be unsafe to open links from untrusted sources. Be cautious!\nYou can also copy the link to your clipboard.",
    ),
    "unshuffle_playlist": MessageLookupByLibrary.simpleMessage(
      "Unshuffle playlist",
    ),
    "unsupported_platform": MessageLookupByLibrary.simpleMessage(
      "Unsupported platform",
    ),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "update_available": MessageLookupByLibrary.simpleMessage(
      "Update available",
    ),
    "update_playlist": MessageLookupByLibrary.simpleMessage("Update playlist"),
    "upload_plugin_from_file": MessageLookupByLibrary.simpleMessage(
      "Upload plugin from file",
    ),
    "use_amoled_mode": MessageLookupByLibrary.simpleMessage(
      "Pitch black dark theme",
    ),
    "use_system_title_bar": MessageLookupByLibrary.simpleMessage(
      "Use system title bar",
    ),
    "user_profile": MessageLookupByLibrary.simpleMessage("User Profile"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "valence": MessageLookupByLibrary.simpleMessage("Valence"),
    "version": MessageLookupByLibrary.simpleMessage("Version"),
    "view_all": MessageLookupByLibrary.simpleMessage("View all"),
    "view_logs": MessageLookupByLibrary.simpleMessage("View logs"),
    "views": MessageLookupByLibrary.simpleMessage("Views"),
    "wait_for_download_to_finish": MessageLookupByLibrary.simpleMessage(
      "Please wait for the current download to finish",
    ),
    "webview_not_found": MessageLookupByLibrary.simpleMessage(
      "Webview not found",
    ),
    "webview_not_found_description": MessageLookupByLibrary.simpleMessage(
      "No webview runtime is installed in your device.\nIf it\'s installed make sure it\'s in the Environment PATH\n\nAfter installing, restart the app",
    ),
    "you_are_offline": MessageLookupByLibrary.simpleMessage(
      "You are currently offline",
    ),
    "youtube": MessageLookupByLibrary.simpleMessage("YouTube"),
    "youtube_engine": MessageLookupByLibrary.simpleMessage("YouTube Engine"),
    "youtube_engine_not_installed_message": m43,
    "youtube_engine_not_installed_title": m44,
    "youtube_engine_set_path": m45,
    "youtube_engine_unix_issue_message": MessageLookupByLibrary.simpleMessage(
      "In macOS/Linux/unix like OS\'s, setting path on .zshrc/.bashrc/.bash_profile etc. won\'t work.\nYou need to set the path in the shell configuration file",
    ),
    "youtube_source_description": MessageLookupByLibrary.simpleMessage(
      "Recommended and works best.",
    ),
  };
}
