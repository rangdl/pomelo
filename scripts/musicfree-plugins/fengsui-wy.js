/**
 * wy.js — 风誰·网易云 插件（风誰制作 · 二开专用版 v0.0.19）
 * ------------------------------------------------------------------
 * 风誰制作，仅供个人使用。
 * 本插件是在 Z·网易云原版（wenshao 原作，Super Z 反编译）基础上
 * 二开而来：中转与播放沿用原版，另补了原版缺失的歌曲评论功能。
 * 适用宿主：MusicFree / 同类插件系统
 * 平台标识：风誰·网易云
 * 原作者：wenshao（原始混淆版）
 * 反编译 + 变量重命名 + 注释 by Super Z
 * 二开：风誰
 * ------------------------------------------------------------------
 * 通过 ws.suol.cc/api/wy/wy_php.php/ 中转的网易云音乐接口，
 * 走的是网易云官方 API（NeteaseCloudMusicApi 风格）的字段结构：
 *   - songs[i].ar        歌手数组（每个含 name）
 *   - songs[i].al        专辑对象（含 name 与 picUrl）
 *   - songs[i].dt        时长（毫秒）
 *   - songs[i].br        音质（bitrate）
 * 支持功能：
 *   1. 搜索（仅 music 分类，每页 15 条）
 *   2. 多音质播放：128k / 192k / 320k / 999k（无损）
 *   3. LRC 歌词
 *   4. 单曲详情补全
 *   5. 歌单详情（每页 500 条）
 *   6. 推荐榜单：热歌榜 / 新歌榜 / 原创榜 / 飙升榜 / 抖音排行榜 / 美国Billboard榜
 *   7. 歌单 / 单曲分享链接导入
 *   8. 歌曲评论（v0.0.3 新增）：getMusicComments
 *   9. 歌手信息（v0.0.13 新增）：搜索歌手 + getArtistWorks + getArtistInfo
 * ------------------------------------------------------------------
 * v0.0.3 改动（2026-11-21）：只补了一个原版缺的方法 getMusicComments。
 * 原版其他代码一个字没动（搜索 / 播放 / 歌词 / 歌单全走原来的
 * ws.suol.cc 中转）。评论出不来的原因是：原版根本没写这个方法，
 * MusicFree 评论区找不到人要数据；而且中转站也没实现评论接口
 * （调 comment/music 返回 404“wy_php 未实现该接口”）。
 * 所以评论这里直连网易云官方评论接口
 * /api/v1/resource/comments/R_SO_4_{id}，实测能返回。
 * 第一页先放热门评论，再接普通评论；翻页按 offset 接着拉。
 * v0.0.4 改动（2026-11-21）：改版为风誰制作二开专用版。
 * 平台改名 风誰·网易云，作者改风誰，功能与 v0.0.3 完全一致，
 * 仅供个人使用。
 * v0.0.5 改动（2026-11-21）：修 30 秒试听问题。
 * 中转对部分 VIP 歌只给 30 秒试听（如王蓉《爸爸妈妈》299449，
 * 中转给 481KB/30 秒，整首应约 10MB）。现先走中转，拿到的是
 * 试听就用 gdstudio 兜底拿整首（实测该歌能拿到整首 FLAC 28.8MB）。
 * 中转能给整首的歌不受影响，还是走中转。
 * v0.0.6 改动（2026-11-21）：修 v0.0.5 试听判断的漏洞。
 * v0.0.5 只认 song.duration，有歌单/收藏里 duration 为空时，
 * 试听判断失效，又会直接放 30 秒。现加第二信号：没时长时看
 * 文件本身，小于 2MB 就当试听处理，去兜底拿整首。
 * v0.0.7 改动（2026-11-21）：融入落雪音频（星海聚合音源）作第三层兜底。
 * 播放链路：中转 → gdstudio → 星海（yy.zddyr.top/lx/api/，落雪社区
 * 音源 pdone/lx-music-source 的聚合后端，无需 key）。落雪官方源
 * （lyswhut/lx-music-source）要用户自己的 VIP token 才能解 VIP，
 * 不能直接当公开兜底，故用的是社区星海后端。实测爸爸妈妈 /
 * 布拉格广场 / 屋顶均返回整首 320k，晴天返回 404（与其它源一致）。
 * v0.0.9 改动（2026-11-21）：加第四层兜底 Meting（liveling，配有网易云 VIP Cookie）。
 * 播放链路：中转 → gdstudio → 星海 → Meting（meting.liveling.top）。
 * 实测：布拉格广场/做一天的你/孤勇者/青花瓷VIP/稻香/爸爸妈妈等 VIP 歌均返回整首，
 * quality 参数有效（standard=128k，exhigh=320k，lossless=FLAC）。
 * 但《晴天》186016 在此源也返回 404（四档音质都试过），是该歌本身受限；
 * 目前没有任何公开第三方源能给晴天整首，要全覆盖需用自己的网易云 VIP
 * 账号（MUSIC_U）走登录态取直链（本插件不内置任何账号）。
 * v0.0.16 改动（2026-11-21）：跨平台播歌兜底（用户点头）。
 *   本平台拿不到整首播放链接时（中转/gdstudio/星海/Meting 全失败），
 *   按歌名+歌手去酷狗找同一首歌播。各平台版权不同，同一首歌在某平台
 *   是 VIP、在另一平台是免费的，不是绕付费墙，不用任何 VIP 账号。
 *   实测《晴天》/七里香/告白气球/稻香/Shape of You 都能从酷狗播整首。
 *   匹配：歌名、歌手都对上（原唱优先），时长差 30 秒以上不要；
 *   搜索走酷狗官方 song_search_v2（关键字“歌名 歌手”，空结果重试一次、
 *   再走中转搜索兜底），播放走酷狗中转 kg.php。失败静默返回 null，不抛错。
 *   另修：Meting 偶尔给 VIP 歌返回试听片段（七里香只给 387KB），现 HEAD
 *   验 Content-Length、明显短于整首就当这层失败，继续走跨平台兜底。
 * v0.0.17 改动（2026-11-21）：修榜单无封面（用户实测发现）。
 *   根因：getTopLists 是写死的 6 个榜单，从来没给 coverImg 字段，宿主无图可显。
 *   现官方 /api/toplist 一次拉全榜单封面（coverImgUrl），失败用内置封面兜底；
 *   榜单详情顶层补 coverImg、sheetItem 补 coverImg/artwork，主路封面统一转 https。
 * v0.0.19 改动（2026-11-22）：榜单改名（用户点头）。
 *   2250011882 官方现名“抖音排行榜”（插件旧名欧美榜）、60198 官方现名
 *   “美国Billboard榜”（插件旧名华语榜），标题与描述改成官方名。
 * v0.0.18 改动（2026-11-21）：堵试听漏网（用户实测《我不难过》仍 30 秒）。
 *   根因：两处漏网——① 中转直链只靠 size 元数据判试听，元数据缺失时试听
 *   直接返回；② 所有兜底失败后，已知是试听的中转链接仍当最后手段返回。
 *   修法：中转直链返回前也 HEAD 验 Content-Length（判试听就走兜底）；已知
 *   是试听的中转链接不再返回，改报“暂无音源”。线上 0.0.16 实测《我不难过》
 *   三个版本、三档音质全是整首（36MB FLAC），用户手机上仍 30 秒最可能是
 *   还没点订阅更新到 0.0.16，或手机网络下兜底全失败走了最后手段。
 * v0.0.15 改动（2026-11-21）：兜底补全（用户无感标准）。
 *   兜底切换自动、要快、失败静默换下一条路；实在没路了返回空结果、不抛错打断用户；
 *   兜底返回的数据格式与主路一致（封面/时长/字段齐全）。
 *   1. 搜索补专辑/歌单类型（之前只实现 music/artist，其余直接返回空）：官方
 *      /api/v1/search/get type=10（专辑）/ type=1000（歌单），失败走中转 cloudsearch 兜底。
 *   2. 搜歌：官方返回 0 条时再试中转（之前直接返回空）；中转失败也不抛错，返回空结果。
 *   3. 封面补全 fillArtworkFromDetail：中转 song/detail 失败时走官方 api/song/detail 兜底。
 *   4. 歌词：中转 lyric 失败时走官方 api/song/lyric 兜底（lrc + tlyric 都有）；全失败返回 {rawLrc:""}，不抛错。
 *   5. 评论：官方 music.163.com 失败时走 api.music.163.com 兜底；全失败返回空，不抛错。
 *   6. 歌单详情/导入歌单：中转 playlist/track/all 失败时走官方 api/playlist/detail 兜底
 *     （result.tracks，前 200 首，首翻页 isEnd=true）；后端失败返回空，不抛错。
 *   7. 单曲详情/导入单曲：中转 song/detail 失败时走官方 api/song/detail 兜底。
 *   8. 歌手作品（歌曲）：官方失败时走中转 artist/top/song 兜底；歌手详情：官方失败时
 *      走中转 cloudsearch type=100 按名字回查（头像/曲目数，简介缺失是降级、可接受）。
 *   9. 超时收紧：主路 10 秒、兜底 8 秒，切换不让用户久等。
 * v0.0.14 改动（2026-11-21）：修 importMusicItem 不认 song?id= 链接——
 * 正则 /song[\/=](\d+)/ 要求 song 后紧跟 / 或 =，而标准分享链接是
 * song?id=210049（song 后是 ?），导致报“无法识别的歌曲链接格式”。
 * 改成 /song[^\d]*(\d+)/，与 importMusicSheet 的 playlist 正则同款。
 * v0.0.13 改动（2026-11-21）：补歌手信息——原版没有 getArtistInfo，
 * 我们自己做。search 补 type="artist"（官方搜索 type=100，中转
 * cloudsearch type=100 兜底）；新增 getArtistWorks（热门歌曲 / 专辑）
 * 与 getArtistInfo（详情：头像、简介、热门歌曲）。接口失败不崩，
 * 返回空或原对象兜底。
 * v0.0.12 改动（2026-11-21）：评论去尾——评论内容末尾有时带一行
 * "\n[歌曲：XXX]"，是网易云官方接口自带的（评论者把歌附在评论上，
 * contentResource 字段）；在歌自己的评论区里这行是多余的死文字，
 * formatNetEaseComment 里把末尾这一行截掉，正文不动。
 * v0.0.11 改动（2026-11-21）：修搜索无封面 + 歌词加翻译。
 * 封面根因：官方 /api/v1/search/get 返回的 album 对象只有 picId、没有 picUrl，
 * picId 拼不出封面 URL（4 种拼法实测全 404），官方 song/detail 也没有 picUrl；
 * 中转 song/detail 一次能批量补 15 首的 picUrl（https 直链），所以搜索后统一补一次。
 * 翻译：中转 lyric 返回里有 tlyric（外文歌的中文翻译），之前没接，现在接上。
 * 后端约定：返回体 { code: 200, ... } 表示成功
 *
 */

const axios = require("axios");

// 后端代理基础地址
const BASE_URL = "http://ws.suol.cc/api/wy/wy_php.php/";
const SERVER = BASE_URL;

// 网易云官方直连（搜索用，不登录也能搜）
const NETEASE_API = "https://music.163.com";

/**
 * 音质映射：把宿主统一的音质档位转成网易云的 bitrate（bps）
 */
const BR_MAP = {
  low: 128000,
  standard: 192000,
  high: 320000,
  super: 999000, // FLAC 无损
};

/**
 * 把网易云返回的歌曲对象归一化成 MusicFree 通用结构
 * 注意：网易云用 _songId 字段保留原始 id，避免被宿主转换
 * 兼容两种字段风格：官方 v1 搜索给 artists/album/duration，中转
 * cloudsearch 给 ar/al/dt，两边都要认。
 * @param {object} song 网易云原始歌曲对象
 */
function formatSong(song) {
  const artists = song.artists || song.ar || [];
  const album = song.album || song.al || {};
  return {
    id: String(song.id),
    platform: "风誰·网易云",
    title: song.name || "未知",
    artist: artists.map((a) => a.name).join("/") || "未知歌手",
    album: album.name || "",
    artwork: (album.picUrl || "").replace("http://", "https://"),
    duration: Math.floor((song.duration || song.dt || 0) / 1000), // ms → s
    _songId: String(song.id), // 防止宿主把 id 转成其他形式后丢失原始 id
  };
}

/**
 * 把网易云原始歌手对象归一化成 MusicFree IArtistItem
 * 协议字段：id（必填）、name（必填）、avatar（必填）、fans、description、
 * musicList、albumList。搜索结果里只有 id/name/picUrl，简介与作品在
 * getArtistInfo 里再补。
 * @param {object} a 网易云 artist 对象（id/name/picUrl/albumSize/musicSize）
 * @returns {object} IArtistItem
 */
function formatArtist(a) {
  const pic = (a.picUrl || "").replace("http://", "https://");
  return {
    id: String(a.id),
    platform: "风誰·网易云",
    name: a.name || "未知歌手",
    title: a.name || "未知歌手",
    avatar: pic,
    artwork: pic,
    description:
      (a.musicSize ? a.musicSize + " 首歌曲" : "") +
      (a.albumSize ? " · " + a.albumSize + " 张专辑" : ""),
    _artistId: String(a.id),
  };
}

/**
 * 把网易云专辑搜索结果归一化成 MusicFree 专辑项
 * 官方 /api/v1/search/get type=10 返回：id/name/artist/artists/picUrl/size
 * @param {object} al 专辑对象
 * @returns {object}
 */
function formatAlbum(al) {
  const artist =
    (al.artist && al.artist.name) ||
    (Array.isArray(al.artists) ? al.artists.map((a) => a.name).filter(Boolean).join("/") : "") ||
    "";
  return {
    id: String(al.id),
    platform: "风誰·网易云",
    title: al.name || "未知专辑",
    artist,
    artwork: (al.picUrl || "").replace("http://", "https://"),
    _albumId: String(al.id),
  };
}

/**
 * 把网易云歌单搜索结果归一化成 MusicFree 歌单项
 * 官方 /api/v1/search/get type=1000 返回：id/name/coverImgUrl/creator/trackCount
 * @param {object} pl 歌单对象
 * @returns {object}
 */
function formatSheet(pl) {
  const cover = (pl.coverImgUrl || "").replace("http://", "https://");
  return {
    id: String(pl.id),
    platform: "风誰·网易云",
    title: pl.name || "未知歌单",
    artist: (pl.creator && pl.creator.nickname) || "",
    artwork: cover,
    coverImg: cover,
    description: (pl.trackCount ? pl.trackCount + " 首" : "") || "",
    _uid: String(pl.id),
  };
}

// 标题里的版本标记：带这些的一般是翻唱/改编版，不是原唱，原唱重排时往后放
const COVER_MARKERS = [
  "女声版", "男声版", "童声", "DJ版", "DJ舞曲", "钢琴版", "钢琴曲",
  "Live", "live", "翻唱", "Remix", "remix", "完整版", "正式版",
  "弦乐版", "吉他版", "竖琴", "八音盒", "纯享版", "加速版",
  "原唱", // 真原唱的标题就是歌名本身，不会特意写“原唱”二字；写了的反而是翻唱在蹭
];

/**
 * 批量补封面（v0.0.11 新增，v0.0.15 补官方兜底）
 * 官方搜索 /api/v1/search/get 返回的 album 对象只有 picId、没有 picUrl，
 * picId 拼不出封面 URL（4 种拼法实测全 404），官方 song/detail 也没有 picUrl。
 * 中转 song/detail 一次能批量补 15 首的 picUrl（https 直链），所以搜索后统一补一次。
 * v0.0.15：中转补封面失败时走官方 api/song/detail 兜底（它返回 al.picUrl），
 * 保证中转挂了封面也不空。只补 artwork 为空的歌；失败不阻塞搜索（返回原数组）。
 * @param {Array<object>} songs formatSong 后的歌曲
 * @returns {Promise<Array<object>>}
 */
async function fillArtworkFromDetail(songs) {
  const missing = songs.filter((s) => !s.artwork && s._songId);
  if (!missing.length) return songs;
  const ids = missing.map((s) => s._songId).join(",");
  // 主路：中转 song/detail 批量补
  try {
    const response = await axios.get(SERVER + "song/detail", {
      params: { ids },
      timeout: 10000,
    });
    const map = {};
    for (const d of response.data?.songs || []) {
      if (d.id != null && d.al?.picUrl) map[String(d.id)] = d.al.picUrl;
    }
    for (const s of missing) {
      const url = map[String(s._songId)];
      if (url) s.artwork = String(url).replace("http://", "https://");
    }
    if (!missing.some((s) => !s.artwork)) return songs;
  } catch (e) {
    // 中转失败，落到官方兜底
  }
  // 兜底：官方 api/song/detail（ids=[...]，返回 al.picUrl）
  try {
    const response = await axios.get(NETEASE_API + "/api/song/detail", {
      params: { ids: "[" + ids + "]" },
      timeout: 8000,
    });
    const map = {};
    for (const d of response.data?.songs || []) {
      if (d.id != null && d.album?.picUrl) map[String(d.id)] = d.album.picUrl;
    }
    for (const s of missing) {
      if (!s.artwork) {
        const url = map[String(s._songId)];
        if (url) s.artwork = String(url).replace("http://", "https://");
      }
    }
  } catch (e) {
    // 补封面失败不阻塞搜索
  }
  return songs;
}

/**
 * 原唱重排（v0.0.10 新增）：把最像原唱的排前面。
 * 原唱的标题通常就是歌名本身、干干净净；翻唱常在标题后加版本标记。
 * 只重排、不删结果；分数相同保持原顺序。
 * @param {Array<object>} songs 归一化后的歌曲（formatSong 之后）
 * @param {string} keyword 搜索关键词
 */
function rankOriginalsFirst(songs, keyword) {
  const kw = String(keyword || "").trim().toLowerCase();
  const scored = songs.map((s, idx) => {
    let score = 0;
    const title = String(s.title || "");
    const lower = title.toLowerCase();
    // 标题与关键词完全一致（干净的原唱标题）加分
    if (kw && lower === kw) score += 3;
    // 带版本标记的往后放
    if (COVER_MARKERS.some((m) => lower.includes(m.toLowerCase()))) score -= 3;
    return { s, score, idx };
  });
  scored.sort((a, b) => b.score - a.score || a.idx - b.idx);
  return scored.map((x) => x.s);
}

/**
 * 把网易云官方评论接口返回的一条评论归一化成 MusicFree 的评论结构
 * 格式按官方 bilibili 示例插件的 formatComment：
 *   { id, nickName, avatar, comment, like, createAt, location }
 * @param {object} c 网易云评论对象
 */
function formatNetEaseComment(c) {
  const user = c.user || {};
  const loc = (c.ipLocation && c.ipLocation.location) || "";
  // v0.0.12：截掉评论末尾的 "\n[歌曲：XXX]" 引用行——评论者把歌附在评论上时
  // 网易云接口会在 content 末尾追加这一行；在歌自己的评论区里它是多余的
  // 死文字（网易云 App 里是个可点的卡片，到 MusicFree 只剩一行纯文字）。
  // 只截末尾这一行，正文不动。注意冒号是半角 ":"（实测原始文本如此）。
  const comment = (c.content || "").replace(/\n\[歌曲[:：][^\]]*\]\s*$/, "");
  return {
    id: c.commentId,
    nickName: user.nickname || "未知用户",
    avatar: user.avatarUrl || "",
    comment: comment,
    like: c.likedCount || 0,
    createAt: c.time || 0, // 网易云 time 已是毫秒时间戳
    location: loc || undefined,
  };
}

const GDSTUDIO_API = "https://music-api.gdstudio.xyz/api.php";

/**
 * gdstudio 兜底解析播放地址（v0.0.5 新增）
 * 中转只给 30 秒试听、或拿不到地址时，用它拿整首。
 * 实测：王蓉《爸爸妈妈》299449，中转只给 30 秒（481KB），
 * gdstudio 能拿到整首 FLAC（28.8MB，约 266 秒），直链可播。
 * @param {string|number} songId 网易云歌曲 id
 * @returns {Promise<string|null>} 直链或 null
 */
async function resolveGdstudioUrl(songId) {
  try {
    const res = await axios.get(GDSTUDIO_API, {
      params: { types: "url", id: songId, source: "netease", br: 999 },
      timeout: 8000,
    });
    const url = res.data && res.data.url;
    return typeof url === "string" && url.indexOf("http") === 0 ? url : null;
  } catch (e) {
    return null;
  }
}

const LX_XINGHAI_API = "https://yy.zddyr.top/lx/api/";
/**
 * 星海（落雪 lx-music 聚合音源）兜底解析播放地址（v0.0.7 新增）
 * 来源：落雪音乐社区音源「星海音乐源」（pdone/lx-music-source，v3.2.18）
 * 的聚合后端 yy.zddyr.top/lx/api/（source=wy），无需 key，直接调。
 * 中转与 gdstudio 都拿不到整首时用它。实测：爸爸妈妈 / 布拉格广场 /
 * 屋顶均返回整首 320k（HEAD 验过 Content-Length 与 audio/mpeg）；
 * 晴天返回 404（与其它源一致，仍报无音源）。
 * @param {object} song 歌曲对象（title/artist/album/duration）
 * @param {string|number} songId 网易云歌曲 id
 * @param {string} quality 音质档位
 * @returns {Promise<string|null>} 直链或 null
 */
async function resolveXinghaiUrl(song, songId, quality) {
  try {
    const q = quality === "super" ? "flac" : "320k";
    const res = await axios.get(LX_XINGHAI_API, {
      params: {
        source: "wy",
        name: song.title || "",
        singer: (song.artist || "").replace(/\//g, ","),
        songmid: songId,
        interval: song.duration || "",
        albumName: song.album || "",
        quality: q,
      },
      timeout: 8000,
    });
    const data = res.data || {};
    const url = data.url;
    if (data.code === 200 && typeof url === "string" && url.indexOf("http") === 0) return url;
    return null;
  } catch (e) {
    return null;
  }
}

const METING_LIVELING_API = "https://meting.liveling.top/api";

/**
 * Meting（liveling，配有网易云 VIP Cookie）兜底解析播放地址（v0.0.9 新增）
 * 来源：liveling 的 Meting API（meting.liveling.top，站长自费维护的公益接口），
 * 网易云侧配有 VIP Cookie，会员歌也能解析（QQ 音乐无 VIP Cookie，故只用于网易云）。
 * 接口返回 302，Location 头即真实音频直链（m801.music.126.net），故用
 * maxRedirects: 0 取 Location，不跟随跳转（避免把整首歌当正文下回来）。
 * 实测：布拉格广场/做一天的你/孤勇者/青花瓷VIP/稻香/爸爸妈妈等 VIP 歌均返回整首，
 * quality 参数有效（standard=128k，exhigh=320k，lossless=FLAC）。
 * 但《晴天》186016 在此源也返回 404（standard/exhigh/lossless 四档都试过），
 * 是该歌本身受限，与音质无关。
 * @param {string|number} songId 网易云歌曲 id
 * @param {string} quality 音质档位
 * @returns {Promise<string|null>} 直链或 null
 */
async function resolveMetingUrl(songId, quality) {
  const qmap = { super: "lossless", high: "exhigh", standard: "standard", low: "standard" };
  const q = qmap[quality] || "standard";
  const tryQuality = async (qq) => {
    try {
      const res = await axios.get(METING_LIVELING_API, {
        params: { server: "netease", type: "url", id: songId, quality: qq },
        timeout: 8000,
        maxRedirects: 0,
        validateStatus: () => true,
      });
      const loc = res.headers && (res.headers.location || res.headers.Location);
      if (res.status === 302 && typeof loc === "string" && loc.indexOf("http") === 0) return loc;
      return null;
    } catch (e) {
      return null;
    }
  };
  let url = await tryQuality(q);
  if (!url && q !== "standard") url = await tryQuality("standard");
  return url;
}

// ------------------------------------------------------------------
// 跨平台播歌兜底（v0.0.16 新增）：本平台拿不到整首播放链接时，
// 按歌名+歌手去酷狗找同一首歌播。各平台版权不同，同一首歌在某平台是
// VIP、在另一平台是免费的，不是绕付费墙，不用任何 VIP 账号。
// 实测：网易云《晴天》、七里香、告白气球、稻香、Shape of You 都能从
// 酷狗播整首（有效 MP3 128k，文件大小与时长相符）。
// 匹配要准：歌名、歌手都对上（原唱优先，别拿翻唱版），时长差 120 秒以上不要。
// 搜索：官方 song_search_v2 为主（关键字必须是“歌名 歌手”，只给歌名会返回空），
// 空结果重试一次、再走中转搜索兜底；播放走酷狗中转 kg.php（http→https）。
// 失败静默返回 null，不抛错、不阻塞（用户无感）。
// ------------------------------------------------------------------
const KG_XPLAY_SEARCH = "https://songsearch.kugou.com/song_search_v2";
const KG_XPLAY_API = "http://ws.suol.cc/kg/kg.php";
const KG_XPLAY_API_HTTPS = "https://ws.suol.cc/kg/kg.php";
const KG_XPLAY_UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/134.0 Safari/537.36";

/** 归一化歌名/歌手：去空格、标点、括号，小写（中英文都适用） */
function xplayNormStr(s) {
  return String(s || "")
    .toLowerCase()
    .replace(/[\s\-_.'’"“”‘’()（）\[\]【】<>《》]/g, "");
}

/** 去掉酷狗搜索结果里的 <em> 高亮标签 */
function xplayStripEm(s) {
  return String(s || "").replace(/<\/?em>/gi, "");
}

/** 把酷狗 FileName（“歌手 - 歌名”）拆成歌名与歌手 */
function xplaySplitKgTitle(fn) {
  let t = xplayStripEm(fn || "").trim();
  let artist = "";
  const m = t.match(/^(.+?)\s*-\s*(.+)$/);
  if (m) {
    artist = m[1].trim();
    t = m[2].trim();
  }
  return { title: t, artist };
}

/** 翻唱/Live/DJ 等非原唱版本标记（匹配时降权） */
const XPLAY_VERSION_BAD =
  /翻唱|live|现场|dj|remix|混音|伴奏|铃声|3d|环绕|改编|网友|纯音乐|instrumental/i;

/**
 * 从酷狗候选里挑最像同一首歌的一条
 * 硬条件：歌名归一化相等；歌手互相包含（容 G.E.M. 前缀/多歌手）；
 * 时长差 120 秒以上不要。干净原唱优先，翻唱/Live/DJ 降权。
 * @param {Array<{id,title,artist,duration}>} list 候选（duration 秒）
 * @returns {object|null} 最佳候选或 null
 */
function xplayPickBest(list, title, artist, duration) {
  const tN = xplayNormStr(title);
  const aN = xplayNormStr(artist);
  if (!tN) return null;
  let best = null;
  // 初始分用 -Infinity：有效匹配的分数可能为负（如时长差 103 秒时 100-103=-3），
  // 初始 -1 会把这类有效匹配漏掉（老男孩实测）。
  let bestScore = -Infinity;
  for (const c of list || []) {
    const ctN = xplayNormStr(c.title);
    if (ctN !== tN) continue;
    const caN = xplayNormStr(c.artist);
    if (aN && !(caN.includes(aN) || aN.includes(caN))) continue;
    const dur = Number(c.duration) || 0;
    const diff = duration > 0 ? Math.abs(dur - duration) : 0;
    // 时长差 120 秒以上不要（平台间同一首歌的时长元数据常有出入，
    // 如 QQ 老男孩 196s、酷狗 299s，仍是同一首歌；30 秒太严会误杀）。
    // 原唱/翻唱靠下面的版本标记区分，时长只是辅助信号。
    if (duration > 0 && diff > 120) continue;
    let score = 100 - diff;
    if (XPLAY_VERSION_BAD.test(c.title)) score -= 50;
    if (score > bestScore) {
      bestScore = score;
      best = c;
    }
  }
  return best;
}

/**
 * 酷狗找歌（官方搜索为主，空结果重试一次、再走中转搜索兜底）
 * 官方 song_search_v2 关键字必须是“歌名 歌手”（只给歌名会返回空），
 * 且偶发返回空（限流/抖动），故空结果重试一次仍空才走中转。
 * @param {string} keyword “歌名 歌手”
 * @returns {Promise<Array<{id,title,artist,duration}>>} 候选（duration 秒）
 */
async function xplaySearchKugou(keyword) {
  const params = {
    keyword,
    page: 1,
    pagesize: 10,
    userid: 0,
    clientver: "",
    platform: "WebFilter",
    tag: "em",
    filter: 2,
    iscorrection: 1,
    privilege_filter: 0,
  };
  const normOfficial = (lists) =>
    (lists || [])
      .map((raw) => {
        const { title, artist } = xplaySplitKgTitle(raw.FileName);
        return {
          id: String(raw.FileHash || ""),
          title: title || "未知歌曲",
          artist: xplayStripEm(raw.SingerName || artist) || "未知歌手",
          duration: Math.floor(Number(raw.Duration) || 0),
        };
      })
      .filter((s) => s.id);
  // 官方搜索，空结果重试一次
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const res = await axios.get(KG_XPLAY_SEARCH, { params, timeout: 8000 });
      const list = normOfficial(res.data && res.data.data && res.data.data.lists);
      if (list.length) return list;
    } catch (e) {
      // 失败/空结果都继续走重试或中转兜底
    }
    if (attempt === 0) {
      await new Promise((r) => setTimeout(r, 1000));
    }
  }
  // 中转搜索兜底（msg=关键字，中转 duration 是毫秒，转秒）
  try {
    const res = await axios.get(KG_XPLAY_API, {
      params: { msg: keyword, num: 10 },
      timeout: 8000,
    });
    const body = res.data;
    if (body && body.code === 0 && Array.isArray(body.data)) {
      return body.data
        .map((raw) => {
          let title = String(raw.name || raw.filename || "").trim();
          let artist = raw.artist || raw.singer || "";
          const m = title.match(/^(.+?)\s*-\s*(.+)$/);
          if (m && (m[1].trim() === artist || !artist)) {
            if (!artist) artist = m[1].trim();
            title = m[2].trim();
          }
          title = title.replace(/\.(mp3|flac|wav|m4a|aac|ogg|ape)$/i, "");
          return {
            id: String(raw.id || ""),
            title: title || "未知歌曲",
            artist: artist || "未知歌手",
            duration: Math.floor((Number(raw.duration) || 0) / 1000),
          };
        })
        .filter((s) => s.id);
    }
  } catch (e) {
    // 中转也失败，返回空
  }
  return [];
}

/**
 * 酷狗拿播放链接（中转 kg.php，http→https，128k）
 * @param {string} hash 酷狗歌曲 hash
 * @returns {Promise<string|null>} 直链或 null
 */
async function xplayGetKugouUrl(hash) {
  for (const base of [KG_XPLAY_API, KG_XPLAY_API_HTTPS]) {
    try {
      const res = await axios.get(base, {
        params: { id: hash, quality: "128" },
        timeout: 8000,
      });
      const body = res.data;
      if (body && body.code === 0 && body.data && body.data.url) {
        return body.data.url;
      }
    } catch (e) {
      // 静默换下一条路
    }
  }
  return null;
}

/**
 * 跨平台播歌兜底：本平台拿不到整首时去酷狗找同一首歌播
 * @param {{title?: string, artist?: string, duration?: number}} song 歌曲对象
 * @returns {Promise<{url: string, headers: object}|null>} 酷狗直链或 null
 */
async function resolveKugouCrossPlayUrl(song) {
  const title = (song && song.title) || "";
  const artist = (song && song.artist) || "";
  if (!title || title === "未知" || title === "未知歌曲") return null;
  try {
    const firstArtist =
      artist && artist !== "未知歌手" ? artist.split("/")[0].trim() : "";
    const keyword = firstArtist ? title + " " + firstArtist : title;
    const list = await xplaySearchKugou(keyword);
    const best = xplayPickBest(list, title, artist, song.duration || 0);
    if (!best || !best.id) return null;
    const url = await xplayGetKugouUrl(best.id);
    if (!url) return null;
    return {
      url,
      headers: { "User-Agent": KG_XPLAY_UA, Referer: "http://www.kugou.com/" },
    };
  } catch (e) {
    return null;
  }
}

/**
 * 校验直链是不是整首（v0.0.16 新增）：Meting 偶尔会给 VIP 歌返回试听片段
 * （如七里香只给 387KB，远短于整首），HEAD 看 Content-Length，明显短于
 * 整首就当失败，让链路继续走到跨平台兜底。HEAD 失败或无 Content-Length
 * 时放行（不阻塞）。按 128k 估算整首大小（高音质文件更大，只会更宽松）。
 * @param {string} url 直链
 * @param {number} durationSec 歌曲时长（秒）
 * @returns {Promise<boolean>} 是整首返回 true
 */
async function isFullAudioUrl(url, durationSec) {
  if (!durationSec || durationSec <= 0) return true;
  try {
    const res = await axios.head(url, { timeout: 5000, maxRedirects: 5 });
    const len = Number(res.headers && res.headers["content-length"]);
    if (!len || len <= 0) return true;
    const expected = (durationSec * 128) / 8 * 1000;
    return len >= expected * 0.6;
  } catch (e) {
    return true;
  }
}

/**
 * 6 个固定榜单的内置封面（2026-11-21 从官方接口实测取得，https 直链）：
 * 榜单封面极少变动，仅作 /api/toplist 拉取失败时的兜底。
 * 注意：2250011882 官方现名“抖音排行榜”、60198 官方现名“美国Billboard榜”，
 * 列表标题已改成官方名（v0.0.19，用户点头）。
 */
const WY_TOP_COVERS = {
  3778678: "https://p2.music.126.net/0SUEG8yDACfx0Bw2MYFv4Q==/109951170048519512.jpg",
  3779629: "https://p2.music.126.net/5guhqPBTcIrrhLBotgaT6w==/109951170048511751.jpg",
  2884035: "https://p2.music.126.net/BaP9nrocNTL3gGThysv4eQ==/109951170091896587.jpg",
  19723756: "https://p2.music.126.net/rIi7Qzy2i2Y_1QD7cd0MYA==/109951170048506929.jpg",
  2250011882: "https://p1.music.126.net/8sRm2fQNh_KZeWmJ1sRhQQ==/109951165611408950.jpg",
  60198: "https://p1.music.126.net/rwRsVIJHQ68gglhA6TNEYA==/109951165611413732.jpg",
};

// ---- 74520 解析兜底（v0.1.0 新增）----
// 74520（dl.74520.xyz）是带登录态的音乐解析服务：用社区共享的平台
// Cookie 池解析 QQ/网易云/酷狗的播放直链。实测（2026-11-23）：
// QQ 付费歌《最伟大的作品》320mp3 可解析；网易云 VIP 歌 exhigh（320k）
// 可解析；酷狗 VIP 歌四档全 404（非 VIP 可解析）。for_play=true 播放
// 解析不扣当日下载额度（100/天）。解析只靠登录会话 Cookie，
// 不需要 X-Client-Token。账号密码填在插件设置的 userVariables 里；
// 不填则本层静默跳过，不影响原有播放链。登录会话由宿主 App 的网络层
// 自动带 Cookie，插件只需调登录接口。
const DL74520_BASE = "https://dl.74520.xyz";
const DL74520_LOGIN = DL74520_BASE + "/api/auth/login";
const DL74520_RESOLVE = DL74520_BASE + "/api/music/resolve";
const DL74520_UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36";

// 各平台档位键（实测）：QQ 用 320mp3/128mp3/flac；网易云用 exhigh（320k），
// 320mp3/128mp3 在网易云上会 404；酷狗用 320mp3/128mp3。
const DL74520_QUALITY = {
  qqmusic: { super: ["flac", "320mp3"], high: ["320mp3", "128mp3"], standard: ["320mp3", "128mp3"], low: ["128mp3"] },
  neteasemusic: { super: ["lossless", "exhigh"], high: ["exhigh"], standard: ["exhigh"], low: ["standard", "exhigh"] },
  kugou: { super: ["flac", "320mp3", "128mp3"], high: ["320mp3", "128mp3"], standard: ["320mp3", "128mp3"], low: ["128mp3"] },
};
let dl74520LoggedIn = false;
let dl74520LoginPromise = null;

function getDl74520Creds() {
  try {
    if (typeof env !== "undefined" && env.getUserVariables) {
      const vars = env.getUserVariables() || {};
      const account = (vars.dl74520_account || "").trim();
      const password = (vars.dl74520_password || "").trim();
      if (account && password) return { account, password };
    }
  } catch (e) {}
  return null;
}

async function dl74520Login() {
  if (dl74520LoggedIn) return true;
  if (dl74520LoginPromise) return dl74520LoginPromise;
  dl74520LoginPromise = (async () => {
    const creds = getDl74520Creds();
    if (!creds) return false;
    try {
      const res = await axios.post(
        DL74520_LOGIN,
        { account: creds.account, password: creds.password },
        { timeout: 3000, headers: { "User-Agent": DL74520_UA, Referer: DL74520_BASE + "/" } }
      );
      if (res && res.status === 200) {
        dl74520LoggedIn = true;
        return true;
      }
    } catch (e) {}
    return false;
  })();
  const ok = await dl74520LoginPromise;
  dl74520LoginPromise = null;
  if (!ok) dl74520LoggedIn = false;
  return ok;
}

// 74520 解析：返回 {url, headers} 或 null（失败静默，不抛错）。
// platform: qqmusic / neteasemusic / kugou；quality: low/standard/high/super。
// 注意：74520 解析返回的是整首直链（不给试听），不做 HEAD 验大小——
// 酷狗 320mp3 档实际可能只给 128k 体积，HEAD 验大小会误判成试听。
async function resolveDl74520Url(platform, songId, quality, extra) {
  if (!getDl74520Creds()) return null;
  const map = DL74520_QUALITY[platform] || DL74520_QUALITY.qqmusic;
  const keys = map[quality] || map.standard;
  try {
    if (!(await dl74520Login())) return null;
    for (const q of keys) {
      try {
        const body = {
          platform,
          song_id: String(songId),
          quality: q,
          format: "mp3",
          title: (extra && extra.title) || "audio",
          author: (extra && extra.author) || "",
          for_play: true,
        };
        if (extra && extra.mediaMid) body.media_mid = extra.mediaMid;
        const res = await axios.post(DL74520_RESOLVE, body, { timeout: 3000, headers: { "User-Agent": DL74520_UA, Referer: DL74520_BASE + "/" } });
        const d = res && res.data;
        const inner = (d && d.data) || {};
        const url = inner.url || inner.audio_url || d.url || d.audio_url || "";
        if (url) return { url, headers: {} };
      } catch (e) {
        // 档位 404 换下一档；401 会话过期则重登一次再试下一档
        if (e && e.response && e.response.status === 401) {
          dl74520LoggedIn = false;
          if (await dl74520Login()) continue;
        }
      }
    }
  } catch (e) {}
  return null;
}

module.exports = {
  platform: "风誰·网易云",
  version: "0.2.2",
  author: "风誰",
  description: "风誰制作 · 网易云音乐二开专用版（原版中转 + 评论补全，仅供个人使用）",
  supportedSearchType: ["music", "artist", "album", "sheet"],
  cacheControl: "no-cache",

  // 74520 解析账号（v0.1.0 新增）：填 dl.74520.xyz 的账号密码，播放时
  // 本平台拿不到整首就走 74520 解析（网易云 VIP 可解析）。不填也能用，
  // 只是没有这层兜底。账号密码只存在本机插件设置里，不会发到别处。
  userVariables: [
    {
      key: "dl74520_account",
      name: "74520 账号",
      title: "74520 账号",
      hint: "未填写：输入 74520 账号（手机号或邮箱），填了才启用 74520 解析",
    },
    {
      key: "dl74520_password",
      name: "74520 密码",
      title: "74520 密码",
      type: "password",
      hint: "未填写：输入 74520 密码，只存本机",
    },
  ],

  /**
   * 搜索歌曲 / 歌手 / 专辑 / 歌单
   * v0.0.10：改走网易云官方直连搜索（/api/v1/search/get），原唱优先；
   * 官方搜不到/失败时再走原版中转 cloudsearch 兜底；结果再按原唱重排。
   * v0.0.15：补专辑（type=10）与歌单（type=1000）搜索（之前直接返回空）；
   * 官方返回 0 条时也试中转；全失败返回空结果，不抛错（用户无感）。
   * @param {string} keyword    搜索关键字
   * @param {number} pageNo     页码（从 1 开始）
   * @param {string} searchType 搜索类型
   */
  async search(keyword, pageNo, searchType) {
    // v0.0.13：歌手搜索——官方直连 type=100，失败走中转 cloudsearch 兜底
    if (searchType === "artist") {
      const limit = 10;
      const offset = (pageNo - 1) * limit;
      try {
        const response = await axios.get(NETEASE_API + "/api/v1/search/get", {
          params: { s: keyword, type: 100, offset, limit },
          timeout: 10000,
        });
        if (response.data && response.data.code === 200) {
          const result = response.data.result || {};
          const artists = result.artists || [];
          const totalCount = result.artistCount || 0;
          return {
            isEnd: pageNo * limit >= totalCount || !artists.length,
            data: artists.map(formatArtist),
          };
        }
      } catch (e) {
        // 官方失败，落到中转兜底
      }
      try {
        const response = await axios.get(SERVER + "cloudsearch", {
          params: { keywords: keyword, type: 100, limit, offset },
          timeout: 8000,
        });
        if (response.data && response.data.code === 200) {
          const result = response.data.result || {};
          const artists = result.artists || [];
          const totalCount = result.artistCount || 0;
          return {
            isEnd: pageNo * limit >= totalCount || !artists.length,
            data: artists.map(formatArtist),
          };
        }
      } catch (e) {
        // 中转也失败，返回空，不抛错
      }
      return { isEnd: true, data: [] };
    }
    // v0.0.15：专辑 / 歌单搜索——官方直连，失败走中转兜底
    if (searchType === "album" || searchType === "sheet") {
      const type = searchType === "album" ? 10 : 1000;
      const limit = 10;
      const offset = (pageNo - 1) * limit;
      const totalKey = searchType === "album" ? "albumCount" : "playlistCount";
      const listKey = searchType === "album" ? "albums" : "playlists";
      const format = searchType === "album" ? formatAlbum : formatSheet;
      const tryParse = (body) => {
        if (!body || body.code !== 200) return null;
        const result = body.result || {};
        const list = result[listKey] || [];
        const total = result[totalKey] || 0;
        return {
          isEnd: pageNo * limit >= total || !list.length,
          data: list.map(format).filter((x) => x.id),
        };
      };
      try {
        const response = await axios.get(NETEASE_API + "/api/v1/search/get", {
          params: { s: keyword, type, offset, limit },
          timeout: 10000,
        });
        const parsed = tryParse(response.data);
        if (parsed && parsed.data.length) return parsed;
      } catch (e) {
        // 官方失败，落到中转兜底
      }
      try {
        const response = await axios.get(SERVER + "cloudsearch", {
          params: { keywords: keyword, type, limit, offset },
          timeout: 8000,
        });
        const parsed = tryParse(response.data);
        if (parsed) return parsed;
      } catch (e) {
        // 中转也失败，返回空，不抛错
      }
      return { isEnd: true, data: [] };
    }
    if (searchType !== "music") {
      return { isEnd: true, data: [] };
    }

    const limit = 15;
    const offset = (pageNo - 1) * limit;

    // 主路：网易云官方直连搜索（不登录也能搜，原唱优先）
    try {
      const response = await axios.get(NETEASE_API + "/api/v1/search/get", {
        params: { s: keyword, type: 1, offset, limit },
        timeout: 10000,
      });
      if (response.data && response.data.code === 200) {
        const result = response.data.result || {};
        const songs = result.songs || [];
        const totalCount = result.songCount || 0;
        if (songs.length) {
          const formatted = songs.map(formatSong);
          await fillArtworkFromDetail(formatted);
          return {
            isEnd: pageNo * limit >= totalCount,
            data: rankOriginalsFirst(formatted, keyword),
          };
        }
        // v0.0.15：官方返回 0 条也试中转（官方可能限流/空返回，中转或有结果）
      }
    } catch (e) {
      // 官方搜索失败，落到中转兜底
    }

    // 兜底：原版中转 cloudsearch（保留原版长处）；失败返回空，不抛错
    try {
      const response = await axios.get(SERVER + "cloudsearch", {
        params: { keywords: keyword, type: 1, limit, offset },
        timeout: 8000,
      });
      if (!response.data || response.data.code !== 200) {
        return { isEnd: true, data: [] };
      }
      const result = response.data.result || {};
      const songs = result.songs || [];
      const totalCount = result.songCount || 0;
      const formatted = songs.map(formatSong);
      await fillArtworkFromDetail(formatted);
      return {
        isEnd: pageNo * limit >= totalCount,
        data: rankOriginalsFirst(formatted, keyword),
      };
    } catch (e) {
      return { isEnd: true, data: [] };
    }
  },

  /**
   * 获取播放地址
   * 先走原版中转；中转只给 30 秒试听（或拿不到）时，用 gdstudio 兜底拿整首。
   * 试听判断：按歌曲时长算，文件明显短于整首就是试听。
   * @param {{_songId?: string, id: string, duration?: number}} song 歌曲对象
   * @param {string} quality 音质档位
   */
  async getMediaSource(song, quality) {
    const songId = song._songId || song.id;
    const br = BR_MAP[quality] || 320000;
    const headers = {
      Referer: "https://music.163.com/",
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    };

    // 先走原版中转（保留原版长处）
    let proxyUrl = null;
    let proxyIsTrial = false;
    try {
      const response = await axios.get(SERVER + "song/url", {
        params: { id: songId, br },
        timeout: 8000,
      });
      const data = (response.data && response.data.data) || [];
      const item = data[0] || {};
      proxyUrl = item.url || null;
      // 判断是不是 30 秒试听
      // 信号1：有明确时长时，按时长算，文件明显短于整首就是试听
      if (proxyUrl && item.size && item.br && song.duration > 0) {
        const expected = (song.duration * item.br) / 8;
        if (item.size < expected * 0.6) proxyIsTrial = true;
      }
      // 信号2：没时长时，看文件本身——30 秒试听很小（128k 约 480KB，320k 约 1.2MB），
      // 整首歌通常几 MB 以上；文件小于 2MB 就当试听处理，去兜底拿整首
      // （极短的歌误判也没关系，兜底拿到的还是同一首的整首）
      if (!proxyIsTrial && proxyUrl && item.size && !song.duration) {
        if (item.size < 2000000) proxyIsTrial = true;
      }
    } catch (e) {
      // 中转失败就走兜底
    }

    // v0.0.18：中转直链也 HEAD 再验一次——中转偶尔不给 size 元数据时，
    // 试听会从上面两道信号漏网；HEAD 判定为试听就当这层失败，走兜底。
    // HEAD 失败/无长度时放行（isFullAudioUrl 内部已 fail-open，不阻塞）。
    if (proxyUrl && !proxyIsTrial && !(await isFullAudioUrl(proxyUrl, song.duration))) {
      proxyIsTrial = true;
    }

    // 中转给的是试听（或拿不到），走 74520 解析同平台同首歌拿整首
    // （网易云 VIP 歌 exhigh 可解析；不填账号时静默跳过，落到下面的报错）
    // 已删：gdstudio、星海、Meting、酷狗跨平台（74520 已覆盖，重复的慢路）
    if (!proxyUrl || proxyIsTrial) {
      const dlX = await resolveDl74520Url("neteasemusic", songId, quality, {
        title: song.title,
        author: song.artist,
      });
      if (dlX) return dlX;
    }
    // v0.0.18：已知是试听的中转链接不再当最后手段返回——宁可报无音源，
    // 也不让用户听到 30 秒就断（用户 2026-11-21 实测《我不难过》仍 30 秒）。
    if (proxyUrl && !proxyIsTrial) return { url: proxyUrl, headers };
    throw new Error("该歌曲暂无音源（可能需 VIP 或已下架）");
  },

  /**
   * 获取 LRC 歌词
   * v0.0.15：主路中转 lyric，失败时走官方 api/song/lyric 兜底（lrc + tlyric
   * 都有）；全失败返回 {rawLrc:""}，不抛错（用户无感）。
   * @param {{_songId?: string, id: string}} song
   */
  async getLyric(song) {
    const songId = song._songId || song.id;
    // 主路：中转 lyric
    try {
      const response = await axios.get(SERVER + "lyric", {
        params: { id: songId },
        timeout: 10000,
      });
      if (response.data && response.data.code === 200) {
        return {
          rawLrc: response.data.lrc?.lyric || "",
          translation: response.data.tlyric?.lyric || "",
        };
      }
    } catch (e) {
      // 中转失败，落到官方兜底
    }
    // 兜底：官方 api/song/lyric（不登录也能拉，lrc + tlyric 都有）
    try {
      const response = await axios.get(NETEASE_API + "/api/song/lyric", {
        params: { id: songId, lv: -1, kv: -1, tv: -1 },
        timeout: 8000,
      });
      if (response.data && response.data.code === 200) {
        return {
          rawLrc: response.data.lrc?.lyric || "",
          translation: response.data.tlyric?.lyric || "",
        };
      }
    } catch (e) {
      // 兜底也失败，返回空歌词，不抛错
    }
    return { rawLrc: "" };
  },

  /**
   * 获取歌曲评论（v0.0.3 新增，原版没有这个方法）
   *
   * MusicFree 评论区调的就是这个方法，返回 { isEnd, data: [] }，
   * 每条评论是 { id, nickName, avatar, comment, like, createAt, location }。
   *
   * 注意：中转站 ws.suol.cc 没有实现评论接口（comment/music 返回
   * 404“wy_php 未实现该接口”），所以这里直连网易云官方评论接口
   * /api/v1/resource/comments/R_SO_4_{id}。
   * 第一页先放热门评论，再接普通评论；翻页按 offset 接着拉。
   * v0.0.15：主路 music.163.com 失败时走 api.music.163.com 兜底（同接口、
   * 不同域名）；全失败返回空，不抛错（用户无感）。
   *
   * @param {{_songId?: string, id: string}} musicItem 歌曲对象
   * @param {number} page 页码（从 1 开始）
   */
  async getMusicComments(musicItem, page) {
    const songId = musicItem._songId || musicItem.id;
    const pageNo = page && page > 0 ? page : 1;
    const limit = 20;
    const offset = (pageNo - 1) * limit;
    const params = { limit, offset };
    const headers = { Referer: "https://music.163.com/" };
    // 主路 music.163.com，兜底 api.music.163.com（同接口不同域名）
    let response = null;
    try {
      response = await axios.get(
        "https://music.163.com/api/v1/resource/comments/R_SO_4_" + songId,
        { params, headers, timeout: 10000 }
      );
    } catch (e) {
      try {
        response = await axios.get(
          "https://api.music.163.com/api/v1/resource/comments/R_SO_4_" + songId,
          { params, headers, timeout: 8000 }
        );
      } catch (e2) {
        return { isEnd: true, data: [] };
      }
    }
    const data = (response && response.data) || {};
    const total = data.total || 0;
    let list = [];
    // 第一页先放热门评论
    if (pageNo === 1 && Array.isArray(data.hotComments)) {
      list = list.concat(data.hotComments.map(formatNetEaseComment));
    }
    if (Array.isArray(data.comments)) {
      list = list.concat(data.comments.map(formatNetEaseComment));
    }
    // 去重（热门评论也可能出现在普通列表里）
    const seen = {};
    const deduped = [];
    for (let i = 0; i < list.length; i++) {
      const c = list[i];
      if (c.id != null && !seen[c.id]) {
        seen[c.id] = true;
        deduped.push(c);
      }
    }
    const got = (data.comments || []).length;
    return {
      isEnd: offset + got >= total,
      data: deduped,
    };
  },

  /**
   * 获取单曲详情（用于宿主刷新歌曲的封面 / 专辑 / 时长）
   * v0.0.15：主路中转 song/detail，失败时走官方 api/song/detail 兜底。
   * 失败时返回空对象而非抛错，避免阻塞 UI
   * @param {{_songId?: string, id: string, artwork?: string, album?: string, duration?: number}} song
   */
  async getMusicInfo(song) {
    const songId = song._songId || song.id;
    const build = (detail) => ({
      artwork: ((detail.al?.picUrl || detail.album?.picUrl) || song.artwork || "").replace("http://", "https://"),
      album: (detail.al?.name || detail.album?.name) || song.album,
      duration: Math.floor(((detail.dt || detail.duration) || 0) / 1000) || song.duration,
    });
    try {
      const response = await axios.get(SERVER + "song/detail", {
        params: { ids: songId },
        timeout: 10000,
      });
      const detail = (response.data?.songs || [])[0];
      if (detail) return build(detail);
    } catch (e) {
      // 中转失败，落到官方兜底
    }
    try {
      const response = await axios.get(NETEASE_API + "/api/song/detail", {
        params: { ids: "[" + songId + "]" },
        timeout: 8000,
      });
      const detail = (response.data?.songs || [])[0];
      if (detail) return build(detail);
    } catch (e) {
      // 兜底也失败，返回空对象
    }
    return {};
  },

  /**
   * 获取歌手作品（v0.0.13 新增，原版没有）
   * MusicFree 进入歌手详情页时调这个方法。type="music" 拉热门歌曲，
   * type="album" 拉专辑。接口失败返回空，不抛错。
   * v0.0.15：歌曲分支官方失败时走中转 artist/top/song 兜底（实测可用）；
   * 专辑分支中转未实现 artist/album（404），官方失败时只重试一次。
   * @param {{id?: string, _artistId?: string, artist?: {id?: string}}} artistItem 歌手对象
   * @param {number} page 页码（从 1 开始）
   * @param {string} type "music" 或 "album"
   */
  async getArtistWorks(artistItem, page, type) {
    const artistId =
      artistItem._artistId || artistItem.id || (artistItem.artist && artistItem.artist.id) || "";
    if (!artistId) {
      return { isEnd: true, data: [] };
    }
    const pageNo = page && page > 0 ? page : 1;
    const limit = 20;
    if (type === "album") {
      const offset = (pageNo - 1) * limit;
      for (let attempt = 0; attempt < 2; attempt++) {
        try {
          const response = await axios.get(
            NETEASE_API + "/api/artist/albums/" + artistId,
            { params: { limit, offset }, timeout: 10000 }
          );
          if (response.data && response.data.code === 200) {
            const albums = response.data.hotAlbums || [];
            return {
              isEnd: albums.length < limit,
              data: albums.map((al) => ({
                id: String(al.id),
                platform: "风誰·网易云",
                title: al.name || "未知专辑",
                artist: (al.artists || []).map((a) => a.name).join("/") || artistItem.name || "",
                artwork: (al.picUrl || "").replace("http://", "https://"),
                _albumId: String(al.id),
              })),
            };
          }
          return { isEnd: true, data: [] };
        } catch (e) {
          // 失败重试一次，再失败返回空
        }
      }
      return { isEnd: true, data: [] };
    }
    // 默认拉热门歌曲：官方接口一次给 50 首，按页切片；
    // 官方失败走中转 artist/top/song 兜底（同接口同结构）
    let songs = null;
    try {
      const response = await axios.get(NETEASE_API + "/api/artist/top/song", {
        params: { id: artistId },
        timeout: 10000,
      });
      if (response.data && response.data.code === 200) {
        songs = (response.data.songs || []).map(formatSong);
      }
    } catch (e) {
      // 官方失败，落到中转兜底
    }
    if (!songs) {
      try {
        const response = await axios.get(SERVER + "artist/top/song", {
          params: { id: artistId },
          timeout: 8000,
        });
        if (response.data && response.data.code === 200) {
          songs = (response.data.songs || []).map(formatSong);
        }
      } catch (e) {
        // 兜底也失败，返回空
      }
    }
    if (!songs) return { isEnd: true, data: [] };
    const start = (pageNo - 1) * limit;
    return {
      isEnd: start + limit >= songs.length,
      data: songs.slice(start, start + limit),
    };
  },

  /**
   * 获取歌手详情（v0.0.13 新增，原版没有）
   * 返回 IArtistItem：头像、简介（briefDesc）、热门歌曲 musicList。
   * 接口失败时返回原对象兜底，不抛错，避免阻塞歌手页。
   * v0.0.15：官方失败时走中转 cloudsearch type=100 按名字回查兜底
   * （头像/曲目数/专辑数，简介缺失是降级、可接受；中转未实现 artists 详情接口）。
   * @param {{id?: string, _artistId?: string, name?: string, avatar?: string, artist?: {id?: string}}} artistItem 歌手对象
   */
  async getArtistInfo(artistItem) {
    const artistId =
      artistItem._artistId || artistItem.id || (artistItem.artist && artistItem.artist.id) || "";
    if (!artistId) {
      return artistItem || {};
    }
    try {
      const response = await axios.get(NETEASE_API + "/api/v1/artist/" + artistId, {
        timeout: 10000,
      });
      if (response.data && response.data.code === 200) {
        const a = response.data.artist || {};
        const hotSongs = (response.data.hotSongs || []).slice(0, 10).map(formatSong);
        const pic = (a.picUrl || artistItem.avatar || artistItem.artwork || "").replace("http://", "https://");
        return {
          id: String(a.id || artistId),
          platform: "风誰·网易云",
          name: a.name || artistItem.name || artistItem.title || "未知歌手",
          title: a.name || artistItem.name || artistItem.title || "未知歌手",
          avatar: pic,
          artwork: pic,
          description: a.briefDesc || artistItem.description || "",
          musicList: hotSongs,
          _artistId: String(a.id || artistId),
        };
      }
    } catch (e) {
      // 官方失败，落到中转回查兜底
    }
    // 兜底：中转 cloudsearch type=100 按名字回查（取第一条）
    const name = artistItem.name || artistItem.title || "";
    if (name) {
      try {
        const response = await axios.get(SERVER + "cloudsearch", {
          params: { keywords: name, type: 100, limit: 5, offset: 0 },
          timeout: 8000,
        });
        const artists = (response.data?.result?.artists) || [];
        const a = artists[0];
        if (a) {
          const pic = (a.picUrl || artistItem.avatar || artistItem.artwork || "").replace("http://", "https://");
          return {
            id: String(a.id || artistId),
            platform: "风誰·网易云",
            name: a.name || name,
            title: a.name || name,
            avatar: pic,
            artwork: pic,
            description:
              (a.musicSize ? a.musicSize + " 首歌曲" : "") +
              (a.albumSize ? " · " + a.albumSize + " 张专辑" : "") ||
              artistItem.description || "",
            musicList: [],
            _artistId: String(a.id || artistId),
          };
        }
      } catch (e) {
        // 兜底也失败，返回原对象
      }
    }
    return artistItem;
  },

  /**
   * 获取歌单详情
   *   - 每页 500 条（一次性拉很多，减少翻页开销）
   *   - 仅第一页时附加拉取歌单元信息（标题 / 创建者 / 封面 / 描述）
   * v0.0.15：主路中转 playlist/track/all，失败时走官方 api/playlist/detail
   * 兜底（result.tracks，前 200 首，首翻页 isEnd=true）；后端失败返回空，不抛错。
   * @param {{_uid?: string, id?: string, _topId?: string, title?: string, artist?: string, artwork?: string}} sheet
   * @param {number} page 页码
   */
  async getMusicSheetInfo(sheet, page) {
    const sheetId = sheet._uid || sheet.id || sheet._topId;
    if (!sheetId) {
      return { isEnd: true, musicList: [] };
    }

    const limit = 500;
    const offset = (page - 1) * limit;
    const mapTrack = (s) => ({
      id: String(s.id),
      platform: "风誰·网易云",
      title: s.name || "未知",
      artist:
        ((s.ar || s.artists) || []).map((a) => a.name).join("/") ||
        "未知歌手",
      album: (s.al || s.album)?.name || "",
      artwork: (((s.al || s.album)?.picUrl) || "").replace("http://", "https://"),
      duration: Math.floor((s.dt || s.duration || 0) / 1000),
      _songId: String(s.id),
    });

    // 主路：中转 playlist/track/all
    try {
      const response = await axios.get(SERVER + "playlist/track/all", {
        params: { id: sheetId, limit, offset },
        timeout: 10000,
      });
      if (response.data && response.data.code === 200) {
        const songs = response.data.songs || [];
        const result = {
          isEnd: songs.length < limit,
          musicList: songs.map(mapTrack),
        };
        // 第一页时顺便拉歌单元信息
        if (page === 1) {
          try {
            const detailResp = await axios.get(SERVER + "playlist/detail", {
              params: { id: sheetId },
              timeout: 8000,
            });
            const detail = detailResp.data?.playlist;
            if (detail) {
              result.sheetItem = {
                title: detail.name || sheet.title,
                artist: detail.creator?.nickname || sheet.artist,
                // v0.0.17：封面统一转 https（与兜底路一致）
                artwork: (detail.coverImgUrl || sheet.artwork || "").replace(
                  "http://",
                  "https://"
                ),
                description: detail.description || "",
              };
            }
          } catch (e) {
            // 元信息失败不影响主流程
          }
        }
        return result;
      }
    } catch (e) {
      // 中转失败，落到官方兜底
    }

    // 兜底：官方 api/playlist/detail（result.tracks，前 200 首；只给首翻页）
    if (page === 1) {
      try {
        const response = await axios.get(NETEASE_API + "/api/playlist/detail", {
          params: { id: sheetId },
          timeout: 8000,
        });
        const detail = response.data?.result;
        if (detail && Array.isArray(detail.tracks)) {
          return {
            isEnd: true,
            musicList: detail.tracks.map(mapTrack),
            sheetItem: {
              title: detail.name || sheet.title,
              artist: detail.creator?.nickname || sheet.artist,
              artwork: (detail.coverImgUrl || sheet.artwork || "").replace("http://", "https://"),
              description: detail.description || "",
            },
          };
        }
      } catch (e) {
        // 兜底也失败，返回空
      }
    }
    return { isEnd: true, musicList: [] };
  },

  /**
   * 推荐榜单列表（写死的 6 个固定榜单 ID）
   * v0.0.17：补封面——之前没给 coverImg 字段，榜单列表无图可显。
   * 封面先走官方 /api/toplist 一次拉全（带 coverImgUrl），失败用内置封面兜底。
   */
  async getTopLists() {
    const FIXED_TOPS = [
      { id: "3778678", title: "热歌榜", description: "网易云音乐热歌榜" },
      { id: "3779629", title: "新歌榜", description: "网易云音乐新歌榜" },
      { id: "2884035", title: "原创榜", description: "网易云音乐原创榜" },
      { id: "19723756", title: "飙升榜", description: "网易云音乐飙升榜" },
      { id: "2250011882", title: "抖音排行榜", description: "网易云音乐抖音排行榜" },
      { id: "60198", title: "美国Billboard榜", description: "网易云音乐美国Billboard榜" },
    ];
    const covers = Object.assign({}, WY_TOP_COVERS);
    try {
      const resp = await axios.get(NETEASE_API + "/api/toplist", {
        timeout: 8000,
      });
      const list = resp.data?.list || [];
      for (const p of list) {
        if (p && p.id != null && p.coverImgUrl) {
          covers[String(p.id)] = String(p.coverImgUrl).replace(
            "http://",
            "https://"
          );
        }
      }
    } catch (e) {
      // 拉取失败用内置封面，不阻塞列表
    }
    return [
      {
        title: "网易云音乐排行榜",
        data: FIXED_TOPS.map((t) => {
          const cover = (covers[t.id] || "").replace("http://", "https://");
          return {
            id: t.id,
            title: t.title,
            description: t.description,
            coverImg: cover,
            artwork: cover,
            _topId: t.id, // 供 getTopListDetail 复用
          };
        }),
      },
    ];
  },

  /**
   * 榜单详情：复用 getMusicSheetInfo
   * 把榜单当歌单拉就行
   * v0.0.17：封面透传——列表给的 coverImg 带进详情，详情顶层补 coverImg，
   * sheetItem 补 coverImg/artwork（宿主读哪个字段都有图）；封面统一转 https。
   */
  async getTopListDetail(top, page) {
    const topId = top._topId || top.id;
    const listCover = (
      top.coverImg ||
      top.artwork ||
      WY_TOP_COVERS[String(topId)] ||
      ""
    ).replace("http://", "https://");
    const fakeSheet = {
      id: topId,
      title: top.title,
      _uid: topId,
      coverImg: listCover,
      artwork: listCover,
    };
    const res = await this.getMusicSheetInfo(fakeSheet, page);
    const detailCover = (
      (res.sheetItem && res.sheetItem.artwork) ||
      listCover
    ).replace("http://", "https://");
    if (!res.coverImg) {
      res.coverImg = detailCover;
    } else {
      res.coverImg = String(res.coverImg).replace("http://", "https://");
    }
    if (res.sheetItem) {
      if (!res.sheetItem.coverImg) {
        res.sheetItem.coverImg = detailCover;
      } else {
        res.sheetItem.coverImg = String(res.sheetItem.coverImg).replace(
          "http://",
          "https://"
        );
      }
      if (!res.sheetItem.artwork) {
        res.sheetItem.artwork = detailCover;
      } else {
        res.sheetItem.artwork = String(res.sheetItem.artwork).replace(
          "http://",
          "https://"
        );
      }
    }
    return res;
  },

  /**
   * 导入歌单
   * 支持两种输入：
   *   1. https://music.163.com/playlist?id=xxx  → 抽出数字 id
   *   2. 纯数字                                 → 直接当 id
   * 循环分页拉取所有歌曲，超过 20000 首强制截断（防止极端歌单卡死）
   * v0.0.15：主路中转失败时走官方 api/playlist/detail 兜底（前 200 首）；
   * 后端失败返回空数组，不抛错（格式无法识别时仍抛错提示用户）。
   * @param {string} input 用户输入
   * @returns {Array<object>}
   */
  async importMusicSheet(input) {
    const text = String(input == null ? "" : input).trim();

    let sheetId = null;
    // 从 URL 抽取 playlist 数字 id
    const urlMatch = text.match(/playlist[^\d]*(\d+)/);
    if (urlMatch) {
      sheetId = urlMatch[1];
    } else if (/^\d+$/.test(text)) {
      // 纯数字
      sheetId = text;
    }
    if (!sheetId) {
      throw new Error(
        "无法识别的歌单链接格式，请使用网易云歌单链接或歌单 ID"
      );
    }

    const mapTrack = (s) => ({
      id: String(s.id),
      platform: "风誰·网易云",
      title: s.name || "未知",
      artist:
        ((s.ar || s.artists) || []).map((a) => a.name).join("/") ||
        "未知歌手",
      album: (s.al || s.album)?.name || "",
      artwork: (((s.al || s.album)?.picUrl) || "").replace("http://", "https://"),
      duration: Math.floor((s.dt || s.duration || 0) / 1000),
      _songId: String(s.id),
    });

    const allSongs = [];
    let offset = 0;
    const limit = 500;

    // 主路：中转分页拉取
    try {
      while (true) {
        const response = await axios.get(SERVER + "playlist/track/all", {
          params: { id: sheetId, limit, offset },
          timeout: 10000,
        });
        if (!response.data || response.data.code !== 200) {
          break;
        }
        const songs = response.data.songs || [];
        if (!songs.length) {
          break;
        }
        allSongs.push(...songs.map(mapTrack));
        // 一页没拉满 = 已经到底
        if (songs.length < limit) {
          break;
        }
        offset += limit;
        // 兜底：超过 2 万首强制截断
        if (offset > 20000) {
          break;
        }
      }
    } catch (e) {
      // 中转失败，落到官方兜底
    }
    if (allSongs.length) {
      return allSongs;
    }

    // 兜底：官方 api/playlist/detail（result.tracks，前 200 首）
    try {
      const response = await axios.get(NETEASE_API + "/api/playlist/detail", {
        params: { id: sheetId },
        timeout: 8000,
      });
      const tracks = response.data?.result?.tracks || [];
      return tracks.map(mapTrack);
    } catch (e) {
      return [];
    }
  },

  /**
   * 导入单曲
   * 支持两种输入：
   *   1. https://music.163.com/song?id=xxx  → 抽出数字 id
   *   2. 纯数字                              → 直接当 id
   * @param {string} input 用户输入
   * @returns {object} 标准化的歌曲对象
   */
  async importMusicItem(input) {
    const text = String(input).trim();
    let songId = input;

    const urlMatch = text.match(/song[^\d]*(\d+)/);
    if (urlMatch) {
      songId = urlMatch[1];
    } else if (/^\d+$/.test(text)) {
      songId = text;
    } else {
      throw new Error(
        "无法识别的歌曲链接格式，请使用网易云歌曲链接或歌曲 ID"
      );
    }

    const build = (detail) => ({
      id: String(detail.id || songId),
      title: detail.name || "未知歌曲",
      artist:
        ((detail.ar || detail.artists) || [])
          .map((a) => a.name)
          .join("/") || "未知歌手",
      album: detail.al?.name || detail.album?.name || "",
      artwork: (detail.al?.picUrl || detail.album?.picUrl || "").replace("http://", "https://"),
      duration: Math.floor(((detail.dt || detail.duration) || 0) / 1000),
      _songId: String(detail.id || songId),
    });

    // 主路：中转 song/detail
    try {
      const response = await axios.get(SERVER + "song/detail", {
        params: { ids: songId },
        timeout: 10000,
      });
      const detail = (response.data?.songs || [])[0];
      if (detail) return build(detail);
    } catch (e) {
      // 中转失败，落到官方兜底
    }
    // 兜底：官方 api/song/detail
    try {
      const response = await axios.get(NETEASE_API + "/api/song/detail", {
        params: { ids: "[" + songId + "]" },
        timeout: 8000,
      });
      const detail = (response.data?.songs || [])[0];
      if (detail) return build(detail);
    } catch (e) {
      // 兜底也失败，返回 null（不抛错）
    }
    return null;
  },
};
