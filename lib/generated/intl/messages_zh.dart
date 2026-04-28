// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(count) => "添加 (${count}) 首歌曲到歌单中";

  static String m1(count) => "添加 (${count}) 首歌曲到播放队列中";

  static String m2(track) => "添加 ${track} 到以下播放列表";

  static String m3(tracks_length) => "已将 ${tracks_length} 首曲目添加到队列";

  static String m4(tracks) => "已添加 ${tracks} 首歌曲到播放队列";

  static String m5(track) => "添加 ${track} 到播放队列";

  static String m6(count) => "和 ${count} 更多";

  static String m7(author) => "作者：${author}";

  static String m8(name) => "- 可以访问 **${name}** API";

  static String m9(client) => "您正在被 ${client} 控制";

  static String m10(client) => "允许 ${client} 连接吗？";

  static String m11(name) => "${name} Cookie";

  static String m12(shareUrl) => "${shareUrl} 已复制到剪贴板";

  static String m13(data) => "已将 ${data} 复制至剪贴板";

  static String m14(current_year) =>
      "© 2021-${current_year} Kingkor Roy Tirtho";

  static String m15(minutes) => "${minutes} 分钟";

  static String m16(count) => "${count} 次播放";

  static String m17(count) => "${count} 次流媒体";

  static String m18(tracks_length) => "正在下载 (${tracks_length})";

  static String m19(count) => "下载 (${count}) 首歌曲";

  static String m20(error) => "错误 ${error}";

  static String m21(filesExported, files) =>
      "导出了 ${filesExported} / ${files} 个文件";

  static String m22(error) => "添加插件失败：${error}";

  static String m23(followers) => "${followers} 名关注者";

  static String m24(count) => "找到 ${count} 个文件";

  static String m25(quality) => "最高音质：${quality}";

  static String m26(hours) => "${hours} 时";

  static String m27(hours) => "${hours} 时";

  static String m28(minutes) => "${minutes} 分";

  static String m29(nightlyBuildNum) =>
      "Spotube Nightly ${nightlyBuildNum} 已发布";

  static String m30(pipedInstance) =>
      "当前Piped实例${pipedInstance}不可用\n\n请更改实例或将\'API类型\'更改为官方YouTube API\n\n更改后请确保重新启动应用程序";

  static String m31(count) => "接下来播放 (${count}) 首歌曲";

  static String m32(track) => "播放 ${track}";

  static String m33(providerName) => "由 ${providerName} 提供支持";

  static String m34(track_length) =>
      "这将清空当前的播放队列。${track_length} 首歌曲将被移除\n你确定要继续吗?";

  static String m35(version) => "Spotube v${version} 已发布";

  static String m36(track) => "将 ${track} 从播放队列中移除";

  static String m37(count, type) => "选择多达 ${count} 种的类型 ${type}";

  static String m38(count) => "已选择 ${count} 首歌曲";

  static String m39(money) => "总计 ${money}";

  static String m40(track) => "歌曲 ${track} 已存在";

  static String m41(track) => "${track} 将在下一首播放";

  static String m42(tracks) => "${tracks} 首歌曲在播放队列中";

  static String m43(engine) => "${engine} 未在您的系统中安装。";

  static String m44(engine) => "${engine} 未安装";

  static String m45(engine) => "确保它可用在 PATH 变量中，或\n设置 ${engine} 可执行文件的绝对路径";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "about_spotube": MessageLookupByLibrary.simpleMessage("关于 Spotube"),
    "accent_color": MessageLookupByLibrary.simpleMessage("主色调"),
    "accept": MessageLookupByLibrary.simpleMessage("同意"),
    "account": MessageLookupByLibrary.simpleMessage("账户"),
    "acousticness": MessageLookupByLibrary.simpleMessage("原声程度"),
    "adaptive": MessageLookupByLibrary.simpleMessage("自适应"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "add_all_to_playlist": MessageLookupByLibrary.simpleMessage("将全部添加到播放列表"),
    "add_all_to_queue": MessageLookupByLibrary.simpleMessage("将全部添加到队列"),
    "add_artist_to_blacklist": MessageLookupByLibrary.simpleMessage("屏蔽该艺人"),
    "add_count_to_playlist": m0,
    "add_count_to_queue": m1,
    "add_cover": MessageLookupByLibrary.simpleMessage("添加封面"),
    "add_custom_url": MessageLookupByLibrary.simpleMessage("添加自定义 URL"),
    "add_genres": MessageLookupByLibrary.simpleMessage("添加曲风"),
    "add_library_location": MessageLookupByLibrary.simpleMessage("添加到图书馆"),
    "add_to_blacklist": MessageLookupByLibrary.simpleMessage("添加到屏蔽列表"),
    "add_to_following_playlists": m2,
    "add_to_playlist": MessageLookupByLibrary.simpleMessage("添加到歌单"),
    "add_to_queue": MessageLookupByLibrary.simpleMessage("添加到播放队列"),
    "added_num_tracks_to_queue": m3,
    "added_to_queue": m4,
    "added_track_to_queue": m5,
    "album": MessageLookupByLibrary.simpleMessage("专辑"),
    "albums": MessageLookupByLibrary.simpleMessage("专辑"),
    "all_time": MessageLookupByLibrary.simpleMessage("所有时间"),
    "alternative_track_sources": MessageLookupByLibrary.simpleMessage("其它音源"),
    "always_on_top": MessageLookupByLibrary.simpleMessage("置顶"),
    "an_error_occurred": MessageLookupByLibrary.simpleMessage("发生错误"),
    "and_n_more": m6,
    "appearance": MessageLookupByLibrary.simpleMessage("外观"),
    "are_you_sure": MessageLookupByLibrary.simpleMessage("你确定吗？"),
    "artist": MessageLookupByLibrary.simpleMessage("艺人"),
    "artist_url_copied": MessageLookupByLibrary.simpleMessage("艺人的分享链接已复制至剪贴板"),
    "artists": MessageLookupByLibrary.simpleMessage("艺人"),
    "audio_quality": MessageLookupByLibrary.simpleMessage("音质"),
    "audio_scrobblers": MessageLookupByLibrary.simpleMessage("音频 Scrobblers"),
    "audio_source": MessageLookupByLibrary.simpleMessage("音频源"),
    "author": MessageLookupByLibrary.simpleMessage("作者"),
    "author_name": m7,
    "available_plugins": MessageLookupByLibrary.simpleMessage("可用插件"),
    "birthday": MessageLookupByLibrary.simpleMessage("生日"),
    "blacklist": MessageLookupByLibrary.simpleMessage("屏蔽列表"),
    "blacklist_description": MessageLookupByLibrary.simpleMessage("已屏蔽的歌曲与艺人"),
    "blacklisted": MessageLookupByLibrary.simpleMessage("已屏蔽"),
    "browse": MessageLookupByLibrary.simpleMessage("浏览"),
    "browse_all": MessageLookupByLibrary.simpleMessage("浏览全部"),
    "browse_anonymously": MessageLookupByLibrary.simpleMessage("匿名浏览"),
    "browse_more": MessageLookupByLibrary.simpleMessage("浏览更多"),
    "bug_issues": MessageLookupByLibrary.simpleMessage("缺陷和问题报告"),
    "build_number": MessageLookupByLibrary.simpleMessage("构建代码"),
    "building_your_timeline": MessageLookupByLibrary.simpleMessage(
      "正在根据您的收听记录构建您的时间线...",
    ),
    "by_clicking_accept_terms": MessageLookupByLibrary.simpleMessage(
      "点击 \'同意\' 代表着你同意以下的条款",
    ),
    "cache_folder": MessageLookupByLibrary.simpleMessage("缓存文件夹"),
    "cache_music": MessageLookupByLibrary.simpleMessage("缓存音乐"),
    "can_access_name_api": m8,
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancel_all": MessageLookupByLibrary.simpleMessage("取消全部"),
    "change_cover": MessageLookupByLibrary.simpleMessage("更改封面"),
    "channel": MessageLookupByLibrary.simpleMessage("频道"),
    "check_for_updates": MessageLookupByLibrary.simpleMessage("检查更新"),
    "choose_the_device": MessageLookupByLibrary.simpleMessage("选择设备："),
    "choose_your_language": MessageLookupByLibrary.simpleMessage("选择您的语言"),
    "choose_your_region": MessageLookupByLibrary.simpleMessage("选择您的地区"),
    "choose_your_region_description": MessageLookupByLibrary.simpleMessage(
      "这将帮助Spotube为您的位置显示正确的内容。",
    ),
    "clear_all": MessageLookupByLibrary.simpleMessage("清除全部"),
    "clear_cache": MessageLookupByLibrary.simpleMessage("清除缓存"),
    "clear_cache_confirmation": MessageLookupByLibrary.simpleMessage(
      "您要清除缓存吗？",
    ),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "close_behavior": MessageLookupByLibrary.simpleMessage("点击关闭按钮行为"),
    "collaborative": MessageLookupByLibrary.simpleMessage("共享协作"),
    "compact": MessageLookupByLibrary.simpleMessage("紧凑"),
    "configure_plugins": MessageLookupByLibrary.simpleMessage(
      "配置您自己的元数据提供者和音频源插件",
    ),
    "connect": MessageLookupByLibrary.simpleMessage("连接"),
    "connect_client_alert": m9,
    "connect_request": m10,
    "connection_request_denied": MessageLookupByLibrary.simpleMessage(
      "连接被拒绝。用户拒绝访问。",
    ),
    "connection_restored": MessageLookupByLibrary.simpleMessage("您的互联网连接已恢复"),
    "contribute_on_github": MessageLookupByLibrary.simpleMessage(
      "在GitHub上做出贡献",
    ),
    "cookie_name_cookie": m11,
    "copied_shareurl_to_clipboard": m12,
    "copied_to_clipboard": m13,
    "copy_link": MessageLookupByLibrary.simpleMessage("复制链接"),
    "copy_to_clipboard": MessageLookupByLibrary.simpleMessage("复制到剪贴板"),
    "copyright": m14,
    "count_mins": m15,
    "count_plays": m16,
    "count_streams": m17,
    "country": MessageLookupByLibrary.simpleMessage("国家和地区"),
    "create": MessageLookupByLibrary.simpleMessage("创建"),
    "create_a_playlist": MessageLookupByLibrary.simpleMessage("创建一个歌单"),
    "credentials_will_not_be_shared_disclaimer":
        MessageLookupByLibrary.simpleMessage("不用担心，软件不会收集或分享任何个人数据给第三方"),
    "crunching_results": MessageLookupByLibrary.simpleMessage("处理结果中..."),
    "currently_downloading": m18,
    "custom": MessageLookupByLibrary.simpleMessage("自定义"),
    "custom_hours": MessageLookupByLibrary.simpleMessage("自定义时间"),
    "dab_music_source_description": MessageLookupByLibrary.simpleMessage(
      "适合发烧友。提供高质量/无损音频流。基于 ISRC 的精确曲目匹配。",
    ),
    "danceability": MessageLookupByLibrary.simpleMessage("律动感"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "decline": MessageLookupByLibrary.simpleMessage("拒绝"),
    "default_audio_source": MessageLookupByLibrary.simpleMessage("默认音频源"),
    "default_metadata_source": MessageLookupByLibrary.simpleMessage("默认元数据源"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "delete_playlist": MessageLookupByLibrary.simpleMessage("删除播放列表"),
    "delete_playlist_confirmation": MessageLookupByLibrary.simpleMessage(
      "您确定要删除此播放列表吗？",
    ),
    "description": MessageLookupByLibrary.simpleMessage("描述"),
    "deselect_all": MessageLookupByLibrary.simpleMessage("取消全选"),
    "desktop": MessageLookupByLibrary.simpleMessage("桌面端设置"),
    "details": MessageLookupByLibrary.simpleMessage("详情"),
    "developers": MessageLookupByLibrary.simpleMessage("开发者"),
    "devices": MessageLookupByLibrary.simpleMessage("设备"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免责声明"),
    "disconnect": MessageLookupByLibrary.simpleMessage("断开连接"),
    "disconnect_lastfm": MessageLookupByLibrary.simpleMessage("断开 Last.fm 连接"),
    "discord_rich_presence": MessageLookupByLibrary.simpleMessage(
      "Discord 丰富展现",
    ),
    "dislikes": MessageLookupByLibrary.simpleMessage("踩"),
    "do_you_want_to_install_this_plugin": MessageLookupByLibrary.simpleMessage(
      "您想安装此插件吗？",
    ),
    "do_you_want_to_open_the_following_link":
        MessageLookupByLibrary.simpleMessage("您想打开以下链接吗"),
    "do_you_want_to_replace": MessageLookupByLibrary.simpleMessage(
      "你确定要替换已下载的歌曲吗？？",
    ),
    "donate_on_open_collective": MessageLookupByLibrary.simpleMessage(
      "在Open Collective上捐款",
    ),
    "done": MessageLookupByLibrary.simpleMessage("完成"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "download_agreement_1": MessageLookupByLibrary.simpleMessage(
      "我明白侵犯音乐版权是一件不好的事情",
    ),
    "download_agreement_2": MessageLookupByLibrary.simpleMessage(
      "我将尽可能支持艺术家的工作。我现在之所以做不到是因为缺乏资金来购买正版",
    ),
    "download_agreement_3": MessageLookupByLibrary.simpleMessage(
      "我完全了解我的 IP 存在被 YouTube的风险。我同意 Spotube 的所有者与贡献者们无须对我目前的行为所导致的任何后果负责",
    ),
    "download_all": MessageLookupByLibrary.simpleMessage("下载全部"),
    "download_and_install_plugin_from_url":
        MessageLookupByLibrary.simpleMessage("从 URL 下载并安装插件"),
    "download_count": m19,
    "download_ip_ban_warning": MessageLookupByLibrary.simpleMessage(
      "小心，如果出现超出正常的下载请求那你的 IP 可能会被 YouTube 封禁，这意味着你的设备将在长达 2-3 个月的时间内无法使用该 IP 访问 YouTube（即使你没登录）。Spotube 对此不承担任何责任",
    ),
    "download_location": MessageLookupByLibrary.simpleMessage("下载路径"),
    "download_music_format": MessageLookupByLibrary.simpleMessage("下载音乐格式"),
    "download_music_quality": MessageLookupByLibrary.simpleMessage("下载音乐质量"),
    "download_now": MessageLookupByLibrary.simpleMessage("立即下载"),
    "download_track": MessageLookupByLibrary.simpleMessage("下载歌曲"),
    "download_warning": MessageLookupByLibrary.simpleMessage(
      "如果你大量下载这些歌曲，你显然在侵犯音乐的版权并对音乐创作社区造成了伤害。我希望你能意识到这一点。永远要尊重并支持艺术家们的辛勤工作",
    ),
    "downloads": MessageLookupByLibrary.simpleMessage("下载"),
    "duration": MessageLookupByLibrary.simpleMessage("歌曲时长 (s)"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "edit_port": MessageLookupByLibrary.simpleMessage("编辑端口"),
    "email": MessageLookupByLibrary.simpleMessage("电子邮件"),
    "enable_connect": MessageLookupByLibrary.simpleMessage("启用连接"),
    "enable_connect_description": MessageLookupByLibrary.simpleMessage(
      "从其他设备控制Spotube",
    ),
    "encryption_failed_warning": MessageLookupByLibrary.simpleMessage(
      "Spotube使用加密来安全地存储您的数据。但是失败了。因此，它将回退到不安全的存储\n如果您使用Linux，请确保已安装gnome-keyring、kde-wallet和keepassxc等秘密服务",
    ),
    "endless_playback": MessageLookupByLibrary.simpleMessage("无尽播放"),
    "endless_playback_description": MessageLookupByLibrary.simpleMessage(
      "自动将新歌曲添加到队列的末尾",
    ),
    "energy": MessageLookupByLibrary.simpleMessage("冲击感"),
    "epic_failure": MessageLookupByLibrary.simpleMessage("史诗级失败！"),
    "error": m20,
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "exit_mini_player": MessageLookupByLibrary.simpleMessage("退出小窗模式"),
    "explore_genres": MessageLookupByLibrary.simpleMessage("探索音乐类型"),
    "export": MessageLookupByLibrary.simpleMessage("导出"),
    "export_cache_confirmation": MessageLookupByLibrary.simpleMessage(
      "您要导出这些文件到",
    ),
    "export_cache_files": MessageLookupByLibrary.simpleMessage("导出缓存文件"),
    "exported_n_out_of_m_files": m21,
    "extended": MessageLookupByLibrary.simpleMessage("宽广"),
    "failed_to_add_plugin_error": m22,
    "failed_to_encrypt": MessageLookupByLibrary.simpleMessage("加密失败"),
    "fans_also_like": MessageLookupByLibrary.simpleMessage("粉丝也喜欢"),
    "featured": MessageLookupByLibrary.simpleMessage("推荐"),
    "file_not_found": MessageLookupByLibrary.simpleMessage("文件未找到"),
    "fill_in_all_fields": MessageLookupByLibrary.simpleMessage("请填写所有栏目"),
    "filter_albums": MessageLookupByLibrary.simpleMessage("筛选专辑..."),
    "filter_artist": MessageLookupByLibrary.simpleMessage("筛选艺人..."),
    "filter_playlists": MessageLookupByLibrary.simpleMessage("筛选歌单..."),
    "first_go_to": MessageLookupByLibrary.simpleMessage("首先，前往"),
    "follow": MessageLookupByLibrary.simpleMessage("关注"),
    "follow_step_by_step_guide": MessageLookupByLibrary.simpleMessage(
      "请按照以下指南进行",
    ),
    "followers": m23,
    "following": MessageLookupByLibrary.simpleMessage("关注中"),
    "found_n_files": m24,
    "founder": MessageLookupByLibrary.simpleMessage("发起人"),
    "freedom_of_music": MessageLookupByLibrary.simpleMessage("“音乐的自由”"),
    "freedom_of_music_palm": MessageLookupByLibrary.simpleMessage(
      "“音乐的自由掌握在您手中”",
    ),
    "friends": MessageLookupByLibrary.simpleMessage("朋友"),
    "generate": MessageLookupByLibrary.simpleMessage("生成"),
    "generating_playlist": MessageLookupByLibrary.simpleMessage(
      "正在生成你的自定义歌单...",
    ),
    "genre": MessageLookupByLibrary.simpleMessage("探索歌单"),
    "genre_categories_filter": MessageLookupByLibrary.simpleMessage("筛选类别..."),
    "genres": MessageLookupByLibrary.simpleMessage("音乐类型"),
    "get_started": MessageLookupByLibrary.simpleMessage("让我们开始吧"),
    "go_to_album": MessageLookupByLibrary.simpleMessage("前往专辑"),
    "guest": MessageLookupByLibrary.simpleMessage("访客"),
    "hacker": MessageLookupByLibrary.simpleMessage("黑客"),
    "help_project_grow": MessageLookupByLibrary.simpleMessage("帮助这个项目成长"),
    "help_project_grow_description": MessageLookupByLibrary.simpleMessage(
      "Spotube是一个开源项目。您可以通过为项目做出贡献、报告错误或建议新功能来帮助该项目成长。",
    ),
    "high": MessageLookupByLibrary.simpleMessage("高"),
    "highest_quality": m25,
    "hipotetical_calculation": MessageLookupByLibrary.simpleMessage(
      "*这是根据在线音乐流媒体平台每流平均支付0.003美元至0.005美元计算得出的。这是一个假设性的计算，旨在让用户了解如果他们在不同的音乐流媒体平台上收听歌曲，他们将需要向艺人支付多少费用。",
    ),
    "hour": m26,
    "hours": m27,
    "how_to_start_radio": MessageLookupByLibrary.simpleMessage("您想如何开始收听电台？"),
    "input_does_not_match_format": MessageLookupByLibrary.simpleMessage(
      "输入与所需格式不匹配",
    ),
    "install": MessageLookupByLibrary.simpleMessage("安装"),
    "install_a_metadata_provider": MessageLookupByLibrary.simpleMessage(
      "安装元数据提供者",
    ),
    "installed": MessageLookupByLibrary.simpleMessage("已安装"),
    "instrumentalness": MessageLookupByLibrary.simpleMessage("歌唱部分占比"),
    "invidious_description": MessageLookupByLibrary.simpleMessage(
      "用于音轨匹配的Invidious服务器实例",
    ),
    "invidious_instance": MessageLookupByLibrary.simpleMessage(
      "Invidious服务器实例",
    ),
    "invidious_source_description": MessageLookupByLibrary.simpleMessage(
      "类似于Piped，但可用性更高。",
    ),
    "invidious_warning": MessageLookupByLibrary.simpleMessage(
      "有些可能无法正常工作。请自行承担风险",
    ),
    "jiosaavn_source_description": MessageLookupByLibrary.simpleMessage(
      "最适合南亚地区。",
    ),
    "key": MessageLookupByLibrary.simpleMessage("曲调"),
    "kingkor_roy_tirtho": MessageLookupByLibrary.simpleMessage(
      "Kingkor Roy Tirtho",
    ),
    "know_how_to_login": MessageLookupByLibrary.simpleMessage("不知道该怎么做？"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "language_region": MessageLookupByLibrary.simpleMessage("语言和地区"),
    "last_2_years": MessageLookupByLibrary.simpleMessage("过去2年"),
    "last_6_months": MessageLookupByLibrary.simpleMessage("过去6个月"),
    "layout_mode": MessageLookupByLibrary.simpleMessage("布局类型"),
    "library": MessageLookupByLibrary.simpleMessage("音乐库"),
    "license": MessageLookupByLibrary.simpleMessage("许可证"),
    "light": MessageLookupByLibrary.simpleMessage("浅色"),
    "liked_tracks": MessageLookupByLibrary.simpleMessage("已点赞的歌曲"),
    "liked_tracks_description": MessageLookupByLibrary.simpleMessage(
      "你点赞过的所有歌曲",
    ),
    "likes": MessageLookupByLibrary.simpleMessage("赞"),
    "liveness": MessageLookupByLibrary.simpleMessage("现场感"),
    "load_more": MessageLookupByLibrary.simpleMessage("加载更多"),
    "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "local_library": MessageLookupByLibrary.simpleMessage("本地图书馆"),
    "local_tab": MessageLookupByLibrary.simpleMessage("本地"),
    "local_tracks": MessageLookupByLibrary.simpleMessage("本地音轨"),
    "login": MessageLookupByLibrary.simpleMessage("登录"),
    "login_with_lastfm": MessageLookupByLibrary.simpleMessage("使用 Last.fm 登录"),
    "login_with_your_lastfm": MessageLookupByLibrary.simpleMessage(
      "使用您的 Last.fm 帐户登录",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("退出"),
    "logout_of_this_account": MessageLookupByLibrary.simpleMessage("退出该账户"),
    "logs": MessageLookupByLibrary.simpleMessage("日志"),
    "long": MessageLookupByLibrary.simpleMessage("长"),
    "loop_track": MessageLookupByLibrary.simpleMessage("单曲循环"),
    "loudness": MessageLookupByLibrary.simpleMessage("响度"),
    "low": MessageLookupByLibrary.simpleMessage("低"),
    "lyrics": MessageLookupByLibrary.simpleMessage("歌词"),
    "made_with": MessageLookupByLibrary.simpleMessage("于孟加拉🇧🇩用 ❤️ 发电"),
    "manage_metadata_providers": MessageLookupByLibrary.simpleMessage(
      "管理元数据提供者",
    ),
    "market_place_region": MessageLookupByLibrary.simpleMessage("市场地区"),
    "max": MessageLookupByLibrary.simpleMessage("最高"),
    "medium": MessageLookupByLibrary.simpleMessage("中"),
    "min": MessageLookupByLibrary.simpleMessage("最低"),
    "mini_player": MessageLookupByLibrary.simpleMessage("小窗模式"),
    "minimize_to_tray": MessageLookupByLibrary.simpleMessage("最小化到托盘"),
    "mins": m28,
    "minutes_listened": MessageLookupByLibrary.simpleMessage("听的分钟数"),
    "mode": MessageLookupByLibrary.simpleMessage("旋律重复度"),
    "moderate": MessageLookupByLibrary.simpleMessage("中"),
    "more_actions": MessageLookupByLibrary.simpleMessage("更多操作"),
    "multiple_device_connected": MessageLookupByLibrary.simpleMessage(
      "已连接多个设备。\n选择您希望执行此操作的设备",
    ),
    "name_of_playlist": MessageLookupByLibrary.simpleMessage("歌单的名称"),
    "new_releases": MessageLookupByLibrary.simpleMessage("新歌热播"),
    "next": MessageLookupByLibrary.simpleMessage("下一步"),
    "next_track": MessageLookupByLibrary.simpleMessage("下一首歌曲"),
    "nightly_version": m29,
    "no_default_metadata_provider_selected":
        MessageLookupByLibrary.simpleMessage("您未设置默认元数据提供者"),
    "no_favorite_albums_yet": MessageLookupByLibrary.simpleMessage(
      "看起来你还没有将任何专辑添加到收藏夹",
    ),
    "no_logs_found": MessageLookupByLibrary.simpleMessage("未找到日志"),
    "no_loop": MessageLookupByLibrary.simpleMessage("无循环"),
    "no_lyrics_available": MessageLookupByLibrary.simpleMessage("抱歉，无法找到此曲的歌词"),
    "no_name": MessageLookupByLibrary.simpleMessage("无名"),
    "no_title": MessageLookupByLibrary.simpleMessage("没有标题"),
    "no_tracks": MessageLookupByLibrary.simpleMessage("看起来这里没有任何曲目"),
    "no_tracks_added_yet": MessageLookupByLibrary.simpleMessage(
      "看起来你还没有添加任何曲目",
    ),
    "no_tracks_listened_yet": MessageLookupByLibrary.simpleMessage(
      "看起来你还没有听任何东西",
    ),
    "no_tracks_playing": MessageLookupByLibrary.simpleMessage("当前没有播放任何曲目"),
    "none": MessageLookupByLibrary.simpleMessage("无"),
    "normalize_audio": MessageLookupByLibrary.simpleMessage("标准化音频"),
    "not_born": MessageLookupByLibrary.simpleMessage("尚未出生"),
    "not_following_artists": MessageLookupByLibrary.simpleMessage("你没有关注任何艺术家"),
    "not_logged_in": MessageLookupByLibrary.simpleMessage("你尚未登录"),
    "not_playing": MessageLookupByLibrary.simpleMessage("未播放"),
    "nothing_found": MessageLookupByLibrary.simpleMessage("未找到任何内容"),
    "number_of_tracks_generate": MessageLookupByLibrary.simpleMessage(
      "生成歌曲的数目",
    ),
    "official": MessageLookupByLibrary.simpleMessage("官方"),
    "ok": MessageLookupByLibrary.simpleMessage("确定"),
    "open": MessageLookupByLibrary.simpleMessage("打开"),
    "open_link_in_browser": MessageLookupByLibrary.simpleMessage("在浏览器中打开链接？"),
    "override_layout_settings": MessageLookupByLibrary.simpleMessage(
      "将覆盖响应式布局设置",
    ),
    "owned_by_you": MessageLookupByLibrary.simpleMessage("由您拥有"),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "paste_plugin_download_url": MessageLookupByLibrary.simpleMessage(
      "粘贴下载 URL、GitHub/Codeberg 存储库 URL 或 .smplug 文件的直接链接",
    ),
    "pause": MessageLookupByLibrary.simpleMessage("暂停"),
    "pause_playback": MessageLookupByLibrary.simpleMessage("暂停播放"),
    "personalized": MessageLookupByLibrary.simpleMessage("为你打造"),
    "pick_color_scheme": MessageLookupByLibrary.simpleMessage("选择配色方案"),
    "piped_api_down": MessageLookupByLibrary.simpleMessage("Piped API不可用"),
    "piped_description": MessageLookupByLibrary.simpleMessage(
      "Piped 服务器实例用于匹配歌曲",
    ),
    "piped_down_error_instructions": m30,
    "piped_instance": MessageLookupByLibrary.simpleMessage("Piped 服务器实例"),
    "piped_source_description": MessageLookupByLibrary.simpleMessage(
      "感觉自由？与YouTube一样但更自由。",
    ),
    "piped_warning": MessageLookupByLibrary.simpleMessage(
      "它们中的一部分可能并不能正常工作。使用时请自行承担风险",
    ),
    "pitch_dark_theme": MessageLookupByLibrary.simpleMessage("深色主题"),
    "plain": MessageLookupByLibrary.simpleMessage("无同步"),
    "plain_lyrics": MessageLookupByLibrary.simpleMessage("纯歌词"),
    "play": MessageLookupByLibrary.simpleMessage("播放"),
    "play_all_next": MessageLookupByLibrary.simpleMessage("播放全部下一首"),
    "play_count_next": m31,
    "play_next": MessageLookupByLibrary.simpleMessage("下一首播放"),
    "playback": MessageLookupByLibrary.simpleMessage("播放"),
    "playing_track": m32,
    "playlist": MessageLookupByLibrary.simpleMessage("播放列表"),
    "playlist_name": MessageLookupByLibrary.simpleMessage("歌单名称"),
    "playlists": MessageLookupByLibrary.simpleMessage("歌单"),
    "please_sponsor": MessageLookupByLibrary.simpleMessage("请赞助/捐赠"),
    "plugin_requires_authentication": MessageLookupByLibrary.simpleMessage(
      "插件需要身份验证",
    ),
    "plugin_scrobbling_info": MessageLookupByLibrary.simpleMessage(
      "此插件会 scrobble 您的音乐以生成您的收听历史记录。",
    ),
    "plugins": MessageLookupByLibrary.simpleMessage("插件"),
    "popularity": MessageLookupByLibrary.simpleMessage("流行度"),
    "port_helper_msg": MessageLookupByLibrary.simpleMessage(
      "默认值为-1，表示随机数。如果您已配置防火墙，建议设置此项。",
    ),
    "powered_by_provider": m33,
    "pre_download_play": MessageLookupByLibrary.simpleMessage("先下后播"),
    "pre_download_play_description": MessageLookupByLibrary.simpleMessage(
      "先下载歌曲后再播放而非流式播放（推荐带宽较高用户使用）",
    ),
    "previous": MessageLookupByLibrary.simpleMessage("上一步"),
    "previous_track": MessageLookupByLibrary.simpleMessage("上一首歌曲"),
    "profile": MessageLookupByLibrary.simpleMessage("个人资料"),
    "profile_followers": MessageLookupByLibrary.simpleMessage("关注者"),
    "public": MessageLookupByLibrary.simpleMessage("公开"),
    "querying_info": MessageLookupByLibrary.simpleMessage("正在查询信息..."),
    "queue": MessageLookupByLibrary.simpleMessage("播放队列"),
    "queue_clear_alert": m34,
    "read_the_latest": MessageLookupByLibrary.simpleMessage("阅读最新"),
    "recently_played": MessageLookupByLibrary.simpleMessage("最近播放"),
    "recommendation_country": MessageLookupByLibrary.simpleMessage(
      "选择国家与地区以获取对应推荐",
    ),
    "release_notes": MessageLookupByLibrary.simpleMessage("版本说明"),
    "release_version": m35,
    "released": MessageLookupByLibrary.simpleMessage("发行时间"),
    "remote": MessageLookupByLibrary.simpleMessage("远程"),
    "remove_from_blacklist": MessageLookupByLibrary.simpleMessage("从屏蔽列表中移除"),
    "remove_from_favorites": MessageLookupByLibrary.simpleMessage("取消点赞"),
    "remove_from_playlist": MessageLookupByLibrary.simpleMessage("从歌单中移除"),
    "remove_from_queue": MessageLookupByLibrary.simpleMessage("从播放队列移除"),
    "remove_library_location": MessageLookupByLibrary.simpleMessage("从图书馆中删除"),
    "removed_track_from_queue": m36,
    "repeat_playlist": MessageLookupByLibrary.simpleMessage("歌单循环"),
    "replace": MessageLookupByLibrary.simpleMessage("替换"),
    "replace_downloaded_tracks": MessageLookupByLibrary.simpleMessage(
      "替换已下载的歌曲",
    ),
    "replace_queue_question": MessageLookupByLibrary.simpleMessage(
      "您想要替换当前队列还是追加到队列？",
    ),
    "repository": MessageLookupByLibrary.simpleMessage("源码"),
    "restore_defaults": MessageLookupByLibrary.simpleMessage("恢复默认值"),
    "resume_playback": MessageLookupByLibrary.simpleMessage("恢复播放"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "save_as_favorite": MessageLookupByLibrary.simpleMessage("点赞"),
    "scrobble_to_lastfm": MessageLookupByLibrary.simpleMessage(
      "在 Last.fm 上记录播放",
    ),
    "scrobbling": MessageLookupByLibrary.simpleMessage("Scrobbling"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "search_local_tracks": MessageLookupByLibrary.simpleMessage("搜索本地歌曲..."),
    "search_mode": MessageLookupByLibrary.simpleMessage("搜索模式"),
    "search_to_get_results": MessageLookupByLibrary.simpleMessage("搜索以获取结果"),
    "search_tracks": MessageLookupByLibrary.simpleMessage("搜索歌曲..."),
    "select": MessageLookupByLibrary.simpleMessage("选择"),
    "select_all": MessageLookupByLibrary.simpleMessage("全选"),
    "select_audio_source": MessageLookupByLibrary.simpleMessage("选择音频源"),
    "select_genres": MessageLookupByLibrary.simpleMessage("选择曲风"),
    "select_up_to_count_type": m37,
    "selected_count_tracks": m38,
    "set_default": MessageLookupByLibrary.simpleMessage("设为默认"),
    "set_default_audio_source": MessageLookupByLibrary.simpleMessage("设置默认音频源"),
    "set_default_metadata_source": MessageLookupByLibrary.simpleMessage(
      "设置默认元数据源",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "share": MessageLookupByLibrary.simpleMessage("分享"),
    "short": MessageLookupByLibrary.simpleMessage("短"),
    "show_hide_ui_on_hover": MessageLookupByLibrary.simpleMessage(
      "悬停时显示/隐藏控制栏",
    ),
    "show_tray_icon": MessageLookupByLibrary.simpleMessage("显示托盘图标"),
    "shuffle": MessageLookupByLibrary.simpleMessage("随机播放"),
    "shuffle_playlist": MessageLookupByLibrary.simpleMessage("随机播放歌单"),
    "skip": MessageLookupByLibrary.simpleMessage("跳过"),
    "skip_download_tracks": MessageLookupByLibrary.simpleMessage("下载时跳过已下载的歌曲"),
    "skip_non_music": MessageLookupByLibrary.simpleMessage("跳过非音乐片段（屏蔽赞助商）"),
    "skip_this_nonsense": MessageLookupByLibrary.simpleMessage("跳过此无聊内容"),
    "sleep_timer": MessageLookupByLibrary.simpleMessage("睡眠定时器"),
    "slide_to_seek": MessageLookupByLibrary.simpleMessage("滑动以前进或后退"),
    "something_went_wrong": MessageLookupByLibrary.simpleMessage("某些地方出现了问题"),
    "song_link": MessageLookupByLibrary.simpleMessage("歌曲链接"),
    "songs": MessageLookupByLibrary.simpleMessage("歌曲"),
    "sort_a_z": MessageLookupByLibrary.simpleMessage("按字母正序"),
    "sort_album": MessageLookupByLibrary.simpleMessage("按专辑"),
    "sort_artist": MessageLookupByLibrary.simpleMessage("按艺人"),
    "sort_duration": MessageLookupByLibrary.simpleMessage("按时长排序"),
    "sort_newest": MessageLookupByLibrary.simpleMessage("按添加日期正序"),
    "sort_oldest": MessageLookupByLibrary.simpleMessage("按添加日期倒序"),
    "sort_tracks": MessageLookupByLibrary.simpleMessage("排序方式"),
    "sort_z_a": MessageLookupByLibrary.simpleMessage("按字母倒序"),
    "source": MessageLookupByLibrary.simpleMessage("来源："),
    "speechiness": MessageLookupByLibrary.simpleMessage("朗诵比例"),
    "spotube_description": MessageLookupByLibrary.simpleMessage(
      "Spotube，一个轻量、跨平台且完全免费的 Spotify 客户端。",
    ),
    "spotube_has_an_update": MessageLookupByLibrary.simpleMessage(
      "Spotube 有更新",
    ),
    "start_a_radio": MessageLookupByLibrary.simpleMessage("开始收听电台"),
    "stats": MessageLookupByLibrary.simpleMessage("统计"),
    "step_1": MessageLookupByLibrary.simpleMessage("步骤 1"),
    "stop": MessageLookupByLibrary.simpleMessage("停止"),
    "streamUrl": MessageLookupByLibrary.simpleMessage("播放流 URL"),
    "streamed_songs": MessageLookupByLibrary.simpleMessage("已流媒体歌曲"),
    "streaming_fees_hypothetical": MessageLookupByLibrary.simpleMessage(
      "*基于 Spotify 每次播放的支付金额\n从 \$0.003 到 \$0.005 计算。这是一个假设性的\n计算，旨在让用户了解如果他们在 Spotify 上收听\n这些歌曲，可能会付给艺术家的金额。",
    ),
    "streaming_music_format": MessageLookupByLibrary.simpleMessage("流媒体音乐格式"),
    "streaming_music_quality": MessageLookupByLibrary.simpleMessage("流媒体音乐质量"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "subscription": MessageLookupByLibrary.simpleMessage("订阅"),
    "summary_artists": MessageLookupByLibrary.simpleMessage("艺术家的"),
    "summary_full_albums": MessageLookupByLibrary.simpleMessage("完整专辑"),
    "summary_got_your_love": MessageLookupByLibrary.simpleMessage("获得了你的爱"),
    "summary_listened_to_music": MessageLookupByLibrary.simpleMessage("听音乐"),
    "summary_minutes": MessageLookupByLibrary.simpleMessage("分钟"),
    "summary_music_reached_you": MessageLookupByLibrary.simpleMessage("音乐触及了你"),
    "summary_owed_to_artists": MessageLookupByLibrary.simpleMessage("本月欠艺术家的"),
    "summary_playlists": MessageLookupByLibrary.simpleMessage("播放列表"),
    "summary_songs": MessageLookupByLibrary.simpleMessage("歌曲"),
    "summary_streamed_overall": MessageLookupByLibrary.simpleMessage("总体流媒体"),
    "summary_were_on_repeat": MessageLookupByLibrary.simpleMessage("已重复播放"),
    "support": MessageLookupByLibrary.simpleMessage("支持"),
    "support_plugin_development": MessageLookupByLibrary.simpleMessage(
      "支持插件开发",
    ),
    "supports_scrobbling": MessageLookupByLibrary.simpleMessage(
      "支持 Scrobbling",
    ),
    "sync_album_color": MessageLookupByLibrary.simpleMessage("匹配封面颜色"),
    "sync_album_color_description": MessageLookupByLibrary.simpleMessage(
      "选取专辑封面主题色作为主色调",
    ),
    "synced": MessageLookupByLibrary.simpleMessage("同步"),
    "synced_lyrics_not_available": MessageLookupByLibrary.simpleMessage(
      "此歌曲的同步歌词不可用。请使用",
    ),
    "system": MessageLookupByLibrary.simpleMessage("系统"),
    "system_default": MessageLookupByLibrary.simpleMessage("系统默认"),
    "tab_instead": MessageLookupByLibrary.simpleMessage("选项卡。"),
    "target": MessageLookupByLibrary.simpleMessage("目标"),
    "tempo": MessageLookupByLibrary.simpleMessage("分钟节拍数 (BPM)"),
    "the_box_is_empty": MessageLookupByLibrary.simpleMessage("箱子为空"),
    "theme": MessageLookupByLibrary.simpleMessage("主题"),
    "third_party": MessageLookupByLibrary.simpleMessage("第三方"),
    "third_party_plugin_dmca_notice": MessageLookupByLibrary.simpleMessage(
      "Spotube 团队对任何“第三方”插件不承担任何责任（包括法律责任）。\n请自行承担风险使用。对于任何错误/问题，请向插件存储库报告。\n\n如果任何“第三方”插件违反了任何服务/法律实体的服务条款/DMCA，请要求该“第三方”插件作者或托管平台（例如 GitHub/Codeberg）采取行动。上面列出的（标记为“第三方”）都是公共/社区维护的插件。我们不对此类插件进行管理，因此无法对其采取任何行动。\n\n",
    ),
    "third_party_plugin_warning": MessageLookupByLibrary.simpleMessage(
      "此插件来自第三方存储库。请在安装前确保您信任此来源。",
    ),
    "this_device": MessageLookupByLibrary.simpleMessage("此设备"),
    "this_month": MessageLookupByLibrary.simpleMessage("本月"),
    "this_plugin_can_do_following": MessageLookupByLibrary.simpleMessage(
      "此插件可以执行以下操作",
    ),
    "this_week": MessageLookupByLibrary.simpleMessage("本周"),
    "this_year": MessageLookupByLibrary.simpleMessage("今年"),
    "time": MessageLookupByLibrary.simpleMessage("时长"),
    "time_signature": MessageLookupByLibrary.simpleMessage("音符时值"),
    "title": MessageLookupByLibrary.simpleMessage("标题"),
    "top_albums": MessageLookupByLibrary.simpleMessage("热门专辑"),
    "top_artists": MessageLookupByLibrary.simpleMessage("热门艺术家"),
    "top_tracks": MessageLookupByLibrary.simpleMessage("热门歌曲"),
    "total_money": m39,
    "track_exists": m40,
    "track_will_play_next": m41,
    "tracks": MessageLookupByLibrary.simpleMessage("歌曲"),
    "tracks_in_queue": m42,
    "u_love_spotube": MessageLookupByLibrary.simpleMessage("我们明白你喜欢 Spotube"),
    "uncompressed": MessageLookupByLibrary.simpleMessage("无损"),
    "undo": MessageLookupByLibrary.simpleMessage("撤销"),
    "unsafe_url_warning": MessageLookupByLibrary.simpleMessage(
      "从不受信任的来源打开链接可能不安全。请谨慎！\n您也可以将链接复制到剪贴板。",
    ),
    "unshuffle_playlist": MessageLookupByLibrary.simpleMessage("取消随机播放歌单"),
    "unsupported_platform": MessageLookupByLibrary.simpleMessage("不支持的平台"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "update_available": MessageLookupByLibrary.simpleMessage("有可用更新"),
    "update_playlist": MessageLookupByLibrary.simpleMessage("更新播放列表"),
    "upload_plugin_from_file": MessageLookupByLibrary.simpleMessage("从文件上传插件"),
    "use_amoled_mode": MessageLookupByLibrary.simpleMessage("使用 AMOLED 模式"),
    "use_system_title_bar": MessageLookupByLibrary.simpleMessage("使用系统标题栏"),
    "user_profile": MessageLookupByLibrary.simpleMessage("用户资料"),
    "username": MessageLookupByLibrary.simpleMessage("用户名"),
    "valence": MessageLookupByLibrary.simpleMessage("心理感受"),
    "version": MessageLookupByLibrary.simpleMessage("版本"),
    "view_all": MessageLookupByLibrary.simpleMessage("查看所有"),
    "view_logs": MessageLookupByLibrary.simpleMessage("查看日志"),
    "views": MessageLookupByLibrary.simpleMessage("浏览次数"),
    "wait_for_download_to_finish": MessageLookupByLibrary.simpleMessage(
      "请等待当前下载任务完成",
    ),
    "webview_not_found": MessageLookupByLibrary.simpleMessage("未找到 Webview"),
    "webview_not_found_description": MessageLookupByLibrary.simpleMessage(
      "您的设备中未安装 Webview 运行时。\n如果已安装，请确保它在 environment PATH 中\n\n安装后，重新启动应用程序",
    ),
    "you_are_offline": MessageLookupByLibrary.simpleMessage("您当前处于离线状态"),
    "youtube": MessageLookupByLibrary.simpleMessage("YouTube"),
    "youtube_engine": MessageLookupByLibrary.simpleMessage("YouTube 引擎"),
    "youtube_engine_not_installed_message": m43,
    "youtube_engine_not_installed_title": m44,
    "youtube_engine_set_path": m45,
    "youtube_engine_unix_issue_message": MessageLookupByLibrary.simpleMessage(
      "在 macOS/Linux/Unix 类操作系统中，在 .zshrc/.bashrc/.bash_profile 等文件中设置路径无效。\n您需要在 shell 配置文件中设置路径",
    ),
    "youtube_source_description": MessageLookupByLibrary.simpleMessage(
      "推荐并且效果最佳。",
    ),
  };
}
