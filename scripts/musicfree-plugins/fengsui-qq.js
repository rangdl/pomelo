/**
 * qq.js — 风誰·QQ音乐 插件（风誰制作 · 二开专用版 v0.5.16）
 * ------------------------------------------------------------------
 * 风誰制作，仅供个人使用。
 * 本插件是在 Z·QQ音乐原版（wenshao 原作，Super Z 反编译）基础上
 * 二开而来：中转与播放沿用原版，另补了原版缺失的歌曲评论功能
 * 与搜索翻页。
 * 适用宿主：MusicFree / 同类插件系统
 * 平台标识：风誰·QQ音乐
 * 原作者：wenshao（原始混淆版）
 * 反编译 + 变量重命名 + 注释 by Super Z
 * 二开：风誰
 * ------------------------------------------------------------------
 * 通过 ws.suol.cc/qq/qq_php.php 中转的 QQ 音乐接口，支持：
 *   1. 多类型搜索：歌曲 / 专辑 / 歌手 / 歌单（支持翻页）
 *   2. 多音质播放：flac / 320 / 128 / m4a
 *   3. LRC 歌词获取
 *   4. 专辑 / 歌单详情
 *   5. 歌手作品（歌曲或专辑）
 *   6. 榜单列表 + 榜单详情
 *   7. 推荐歌单分类标签 + 按标签筛选歌单
 *   8. 单曲 / 歌单 / 专辑分享链接导入
 *   9. 歌曲评论（v0.5.0 新增）：getMusicComments
 * ------------------------------------------------------------------
 * 数据模型关键点：
 *   - QQ 音乐用 songmid 作为主键（字符串，14 位左右）
 *   - 数字 songId 在分享链接里更常见，但播放接口要的是 songmid
 *     → 通过 resolveSongBySongId() 做转换（带内存缓存）
 *   - mediaId（strMediaMid）和 songmid 是两套东西，部分歌曲需要同时提供
 *   - 评论接口要的是数字 songId：歌曲对象里的 songId 字段即是；
 *     只有 songmid 时用标题回查搜索取 songId
 * ------------------------------------------------------------------
 * v0.5.0 改动（2026-11-21）：
 *   1. 新增 getMusicComments：QQ 官方评论接口直连
 *      （c.y.qq.com fcg_global_comment_h5.fcg，biztype=1），
 *      第一页先放热门评论再接普通评论，翻页按 pagenum 接着拉。
 *      中转站也有 path=comment，但不分页（pagenum 传了也返回
 *      同一批），所以评论这里不用中转，直接调官方接口。
 *   2. 搜索支持翻页：后端返回 total，原版却把 isEnd 写死成 true，
 *      只能看到第一页；现按 total 算 isEnd。
 *   3. 去掉 srcUrl（私有版，不再从原地址更新回原版）。
 *   4. 改版为风誰制作二开专用版：平台改名 风誰·QQ音乐，
 *      作者改风誰，仅供个人使用。
 * v0.5.10 改动（2026-11-21）：跨平台播歌兜底（用户点头）。
 *   本平台拿不到播放链接时（中转/Meting 全失败），按歌名+歌手去酷狗
 *   找同一首歌播。各平台版权不同，同一首歌在某平台是 VIP、在另一平台
 *   是免费的，不是绕付费墙，不用任何 VIP 账号。实测王蓉《爸爸妈妈》、
 *   七里香、告白气球、稻香、Shape of You 都能从酷狗播整首。
 *   匹配：歌名、歌手都对上（原唱优先），时长差 30 秒以上不要；
 *   搜索走酷狗官方 song_search_v2（关键字“歌名 歌手”，空结果重试一次、
 *   再走中转搜索兜底），播放走酷狗中转 kg.php。失败静默返回 null，不抛错。
 * v0.5.16 改动（2026-11-22）：搜索合并官方结果补缺失的同名歌。
 *   用户实测：搜歌时原唱排不上甚至搜不到（中转排序丢原唱，官方搜索排第一
 *   的歌中转结果里可能根本没有）。现合并官方搜索，把中转漏掉的同名歌
 *   （标题与关键词完全一致）补进列表，最多 3 首；封面合并沿用 0.5.15。
 * v0.5.15 改动（2026-11-22）：搜索列表大面积无封面时用官方搜索补封面。
 *   用户实测：QQ 搜索列表本身就没封面（不是播放页的问题）。中转搜出来的歌
 *   缺 albummid，且 fillMissingCover 的官方接口在手机网络下也可能失败。
 *   现 fillMissingCover 之后仍大面积缺封面时，调官方搜索按 songmid/歌名+歌手
 *   匹配，只补 artwork/album，不动列表顺序与其它字段。
 * v0.5.14 改动（2026-11-22）：补上 getMusicInfo（反向推理找到的根因，见方法注释）。
 *   官方协议写明播放时会调它补全搜索结果缺失的信息、点名举例就是封面图；
 *   之前四个插件里只有 QQ 没有这个方法。搜索结果若无封面，播放时无处可补。
 *   现按 songmid 调官方 fcg_play_single_song.fcg 取 album.mid，经封面代理拼封面。
 * v0.5.13 改动（2026-11-22）：播放页封面改走自家封面代理（用户实测《第57次取消发送》仍无封面）。
 *   0.5.12 只改了协议，App 到 y.qq.com 的加载路径没变（用户截图时 VPN 下行仅 9.25 KB/s），
 *   仍不显示。现纯 mid 拼出的封面改走 Worker https://fengshei-cover.a2-cf3.workers.dev/cover/<mid>.jpg，
 *   Worker 服务端去 y.qq.com 取图回吐（带缓存，失败 302 回原链接兜底）。已是完整 URL 的封面
 *   暂时不动（最小范围）。中转站本身没死（酷狗/网易云/酷我全通，只 QQ *.php 从本机 IP 被限流），
 *   源码也不公开、复制不到；封面代理是唯一直接针对症状的路。
 * v0.5.12 改动（2026-11-22）：修播放页无封面（用户实测《第57次取消发送》，搜索路径）。
 *   根因：buildCoverUrl 只把 http://y.gtimg.cn 的封面转 https，别的 http 封面
 *   （如中转返回的 http://y.qq.com/...）原样透传；浏览器能打开 http 图片，
 *   不等于 App 内能加载，播放页因此只剩占位圆盘。现所有完整封面 URL 一律转 https
 *   （QQ 系图床 y.qq.com / y.gtimg.cn 均实测 https 200；本函数只处理 QQ 封面，
 *   不影响别家）。注意：y.gtimg.cn 并非万能——部分新专辑 mid 在它上面 404，
 *   只有 y.qq.com 有图，故不改 host，只改协议。
 * v0.5.11 改动（2026-11-21）：榜单封面收尾（酷狗/网易云同批修，用户实测报榜单无封面）。
 *   QQ 主路榜单封面本身是好的（中转 picUrl，HEAD 200），这次只补两处：
 *   buildCoverUrl 里 y.gtimg.cn 的封面统一转 https（实测 https 200）；
 *   中转挂了时用的内置兜底榜单 QQ_TOPLIST_FALLBACK 之前没有封面，
 *   现 12 条全补上（从官方 fcg_v8_toplist_cp 实测取得）。
 * v0.5.9 改动（2026-11-21）：兜底补全（用户无感标准）。
 *   兜底切换自动、要快、失败静默换下一条路；实在没路了返回空结果、不抛错打断用户；
 *   兜底返回的数据格式与主路一致（封面/时长/字段齐全）。
 *   1. 搜索：中转改走 callApiRetry（歌单搜索无官方接口，重试是唯一兜底）。
 *   2. 播放：中转失败时依次重试中转一次、降音质 128k、换 https 中转，再走 Meting；
 *      全失败才报干净错误。
 *   3. 歌词：中转 lyric 失败时走官方 fcg_query_lyric_new 兜底（有歌词、无翻译）；
 *      翻译仍走 PlayLyricInfo；全失败返回 {rawLrc:""}，不抛错。
 *   4. 评论：官方评论接口失败时走中转 comment 兜底（第一页，无翻页）；全失败返回空。
 *   5. 专辑详情：中转失败时走 musicu AlbumSongList 兜底（songInfo 归一化，封面/时长齐全）。
 *   6. 歌单详情/导入歌单：中转失败时走旧 DissInfo fcg_ucc_getcdinfo_byids_cp 兜底（511 首）。
 *   7. 歌手作品：中转失败时走官方搜歌/搜专辑按歌手名过滤兜底；歌手详情：走官方
 *      搜歌手 + 搜歌拼热门歌曲兜底（简介/粉丝无官方匿名接口，降级、可接受）。
 *   8. 榜单列表：中转失败时用内置主榜单兜底；榜单详情：走旧 fcg_v8_toplist_cp 兜底。
 *   9. 推荐歌单标签：中转失败时用内置标签兜底；按标签拉歌单：走 fcg_get_diss_by_tag 兜底。
 *  10. 导入单曲：用 fcg_play_single_song 把占位信息补成真标题/歌手/专辑/封面。
 *  11. 超时收紧：主路 10~12 秒、兜底 8 秒，切换不让用户久等。
 * v0.5.8 改动（2026-11-21）：搜索兜底补全 + 原唱重排。
 *   1. 歌手搜索兜底：官方没有歌手搜索接口，改从官方单曲搜索结果里
 *      抽 singer mid 去重拼歌手项，头像用 QQ 歌手头像 CDN 规律
 *      T001R300x300M000{mid}.jpg（实测 200）。
 *   2. 原唱重排：单曲搜索结果按网易云插件同款逻辑重排（标题干净的
 *      原唱在前，翻唱/Live/旧版/现场往后），中转与官方两路都排。
 *   3. songId→songmid 回查与评论 songId 回查也走官方搜索兜底
 *      （之前只调中转 search，中转挂了就解析失败）。
 * v0.5.7 改动（2026-11-21）：中转 search 挂了 + 中转多接口间歇空返回。
 *   1. 搜索兜底：中转 search 自 2026-11-21 晚起一律 400“搜索结果解析
 *      失败”，单曲/歌手/专辑全搜不到。现中转失败时走 QQ 官方搜索直连
 *      （c.y.qq.com search_for_qq_cp，t=0 单曲 / t=8 专辑，实测可用），
 *      中转恢复后仍优先走中转；歌手/歌单没有可用的官方接口，仍走中转。
 *   2. 重试：中转 songlist、top/category、top、album/songs 等接口间歇
 *      返回 result=100 但 data 为空（实测同一请求重试即恢复，与歌手
 *      接口同款抖动）。新增 callApiRetry，空数据最多重试 2 次（间隔
 *      600ms），合法空结果重试后仍为空、行为不变。
 *   3. 空输入守卫：getLyric / getMusicComments / getMediaSource 传入
 *      空歌曲对象时不再抛 TypeError，返回空或干净报错。
 * v0.5.6 改动（2026-11-21）：补歌手信息——原版没有 getArtistInfo，
 * 我们自己做。歌手搜索（t=9）本来就有，normalizeArtist 补上协议要的
 * name/avatar 字段（头像从 150 升到 300）；新增 getArtistInfo（中转
 * singer/songs 自带 singer_brief 简介 + singer_info.fans 粉丝数，
 * 再拉热门歌曲与专辑）；getArtistWorks 改按 total_song/total_album
 * 算 isEnd，不再写死 true。接口失败不崩，返回空或原对象兜底。
 * v0.5.5 改动（2026-11-21）：歌词翻译——原版和中转都没有翻译，补上。
 *   旧路走不通：中转 lyric 的 trans 为空；官方 fcg_query_lyric_new.fcg
 *   的 trans 也是空（匿名 Web 请求拿不到翻译）。
 *   新路：QQ 官方 musicu.fcg 的 music.musichallSong.PlayLyricInfo.
 *   GetPlayLyricInfo 接口，trans=1 + crypt=0 时直接返回明文 base64
 *   的翻译 LRC，时间戳与原歌词一一对应。crypt=1 会返回 3DES 加密
 *   的 hex（QQ 自定义密钥扩展，与标准 3DES 不兼容），没必要走那条路。
 *   getLyric 现在并行拉中转歌词 + 官方翻译，有翻译就带 translation
 *   返回；官方接口失败或无翻译（中文歌）时只返回歌词，不报错。
 * v0.5.4 改动（2026-11-21）：评论滤空——QQ 评论偶有内容为空的条目
 * （昵称头像都在、内容空白，疑似图片/表情类评论），getMusicComments 里
 * 滤掉 comment 为空的条目，只留有文字的评论。
 * v0.5.3 改动（2026-11-21）：搜索空封面批量补 + 翻译现状说明。
 * 封面：搜索结果大部分有封面，但极少数歌（Remix/Live 等边缘版本）的 albummid
 * 为空、拼不出封面；现对 artwork 为空的歌用 QQ 官方 fcg_play_single_song.fcg
 * 按 songmid 批量取 album.mid 再拼（只有存在空封面时才调一次，失败不阻塞搜索）。
 * 翻译（v0.5.3 当时未接，非 bug）：中转 lyric 返回里有 trans 字段但值是空的；直连 QQ 官方歌词
 * 接口（fcg_query_lyric_new.fcg）实测 Shape of You / Lemon / Dynamite 的 trans
 * 也全是空——官方这个接口本身不给翻译，上游没有，插件接不上。
 * （v0.5.5 已解决：改走 musicu.fcg PlayLyricInfo，见上。）
 * v0.5.2 改动（2026-11-21）：加 Meting（liveling，server=tencent）播放兜底。
 *   中转 song/url 仍优先；中转返回非 100 或抛错时走 Meting（只 standard/128k）。
 *   实测：老男孩/小苹果经 Meting 拿整首 128k；最炫民族风/十年 Meting 返回空；
 *   VIP 歌（晴天/七里香/小幸运/演员）Meting 一律 404——Meting 的 QQ 侧没有
 *   VIP Cookie。星海 tx 源 403（须认证）、QQ 官方 vkey 无登录拿不到 purl、
 *   gdstudio 不支持 tencent、jsososo 公共接口已死，均已验过、不用。
 *   注意：2026-11-21 自查曾误判“中转 song/url 全挂”——实为助理服务器调它
 *   偶发 400（搜索正常，仅播歌接口 400，换 UA/重试仍 400，免费歌老男孩重试
 *   后又能拿到直链，属中转侧挑请求/间歇限流）；用户同日截图证明《小幸运》
 *   在他手机上用原版 Z·QQ音乐能播整首。所以中转没死，兜底只是“中转再出
 *   问题时也有路可走”，不是替代中转。QQ VIP 全覆盖仍需用户自己的 QQ 绿钻/
 *   VIP 登录态（未向用户索要账号，文件里不写任何账号）。
 * 后端约定：返回体 { result: 100, data: ... } 表示成功
 *
 */

const axios = require("axios");

// 后端代理基础地址
const BASE_URL = "http://ws.suol.cc/qq/qq_php.php";
const API = BASE_URL;

// 平台标识
const PLATFORM = "风誰·QQ音乐";

// 播放时需要的 UA 与 Referer
const UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36";

/**
 * 音质映射：把宿主统一的音质档位转成 QQ 音乐后端识别的字符串
 */
const QUALITY_MAP = {
  super: "flac",
  high: "320",
  standard: "128",
  low: "m4a",
};

/**
 * 搜索类型映射：把宿主的字符串分类转成 QQ 音乐后端的 t 参数数字
 */
const SEARCH_TYPE_T = {
  music: 0,
  album: 8,
  artist: 9,
  sheet: 2,
};

/**
 * 把 QQ 音乐的 albummid / albumMid 字段补全成完整封面 URL
 * 已是完整 URL 的直接返回；纯 mid 则拼成 QQ 音乐标准 CDN 路径
 * @param {string} midOrUrl 专辑 mid 或完整 URL
 * @returns {string}
 */
function buildCoverUrl(midOrUrl) {
  if (!midOrUrl) {
    return "";
  }
  const str = String(midOrUrl);
  if (/^https?:\/\//i.test(str)) {
    // v0.5.12：所有完整封面 URL 一律转 https（v0.5.11 只转了 y.gtimg.cn，
    // 漏了 y.qq.com 等 http 封面——浏览器能打开不等于 App 内能加载）。
    return str.replace(/^http:\/\//i, "https://");
  }
  // 提取 mid：可能形如 M000abc.jpg.jpg 或纯 mid
  const midMatch = str.match(/M000([^.]+)\.jpg$/);
  const mid = midMatch ? midMatch[1] : str;
  // v0.7.3：纯 mid 的封面改回直连 y.qq.com 原图站，不再走 fengshei-cover
  // 中转。原因：Worker 回吐不带 Content-Length（分块流），App 内图片加载器
  // 碰上会一直转圈出不来；浏览器能打开不等于 App 内能加载。y.qq.com 原图
  // 带 Content-Length，手机浏览器直连已验证可开。
  return "https://y.qq.com/music/photo_new/T002R300x300M000" + mid + ".jpg";
}

/**
 * 补空封面（v0.5.3 新增）
 * 搜索结果里极少数歌（Remix/Live 等边缘版本）的 albummid 为空，拼不出封面。
 * 两步兜底：
 *  1. 用 QQ 官方 fcg_play_single_song.fcg 按 songmid 批量取 album.mid 再拼；
 *  2. 仍为空的（QQ 库里这歌根本没有专辑归属，albumid=0、albumname 为空），
 *     在同一页结果里找同歌名+同歌手的另一版本（去掉 Live/Remix/中文版等
 *     版本标记后标题相同），借用它的封面——同一首歌的不同版本用同一张
 *     封面是合理的，总比没有强。
 * 只有存在空封面时才调一次接口；失败不阻塞搜索（返回原数组）。
 * @param {Array<object>} songs normalizeSong 后的歌曲
 * @returns {Promise<Array<object>>}
 */
async function fillMissingCover(songs) {
  const missing = songs.filter((s) => !s.artwork && s.id);
  if (!missing.length) return songs;
  try {
    const response = await axios.get(
      "https://c.y.qq.com/v8/fcg-bin/fcg_play_single_song.fcg",
      {
        params: {
          songmid: missing.map((s) => s.id).join(","),
          format: "json",
        },
        headers: { Referer: "https://y.qq.com/" },
        timeout: 10000,
      }
    );
    const map = {};
    for (const d of response.data?.data || []) {
      if (d.mid && d.album?.mid) map[String(d.mid)] = d.album.mid;
    }
    for (const s of missing) {
      const albumMid = map[String(s.id)];
      if (albumMid) s.artwork = buildCoverUrl(albumMid);
    }
  } catch (e) {
    // 补封面失败不阻塞搜索
  }
  // 第二步：仍为空的，借用同页同歌名+同歌手的另一版本的封面
  const stillMissing = songs.filter((s) => !s.artwork);
  if (stillMissing.length) {
    // 标题归一化：去掉括号里的版本标记（Live/Remix/中文版……）、去空格、小写
    const strip = (t) =>
      String(t || "")
        .toLowerCase()
        .replace(/[（(][^）)]*[）)]/g, "")
        .replace(/\s+/g, "")
        .trim();
    const withCover = songs.filter((s) => s.artwork);
    for (const s of stillMissing) {
      const key = strip(s.title) + "||" + String(s.artist || "").toLowerCase();
      const donor = withCover.find(
        (c) => strip(c.title) + "||" + String(c.artist || "").toLowerCase() === key
      );
      if (donor) s.artwork = donor.artwork;
    }
  }
  return songs;
}

/**
 * 官方搜索合并（v0.5.15 补封面，v0.5.16 补缺失的歌）。
 * 手机上中转搜索常大面积无封面（中转返回缺 albummid，且
 * fillMissingCover 用的官方接口在手机网络下也可能失败），中转的排序也
 * 常丢掉原唱（官方搜索排第一的歌，中转结果里可能根本没有）。
 * 这里调一次官方搜索，两件事一起做：按 songmid 优先、归一化歌名+歌手
 * 兜底匹配补封面；把官方结果里有、而中转结果里没有的同名歌曲（标题
 * 与关键词完全一致的版本，多半是原唱）补进列表。只补 artwork/album
 * 和缺失的同名歌，不动原有顺序（后面的原唱重排会把同名歌排到前面）；
 * 官方搜索失败或超时时保持原结果、不阻塞搜索。
 * @param {Array<object>} songs normalizeSong 后的歌曲
 * @param {string} keyword 搜索关键词
 * @param {number} page 页码
 * @returns {Promise<Array<object>>} 合并后的歌曲列表
 */
async function mergeOfficialSearchResults(songs, keyword, page) {
  if (!songs || !songs.length) return songs;
  const norm = (t) =>
    String(t || "")
      .toLowerCase()
      .replace(/[（(][^）)]*[）)]/g, "")
      .replace(/\s+/g, "")
      .trim();
  const kwNorm = norm(keyword);
  const missingCover = songs.filter((s) => !s.artwork);
  const hasExact = songs.some((s) => norm(s.title) === kwNorm);
  // 封面齐全且已有同名歌时不用调官方搜索，避免每次搜索都多一次请求
  if (!missingCover.length && hasExact) return songs;
  let fb = null;
  try {
    fb = await Promise.race([
      searchOfficialQQ(keyword, page, "music"),
      new Promise((resolve) => setTimeout(() => resolve(null), 6000)),
    ]);
  } catch (e) {
    fb = null;
  }
  if (!fb || !fb.data || !fb.data.length) return songs;
  const byId = {};
  const byKey = {};
  for (const s of fb.data) {
    if (!s.artwork) continue;
    if (s.id) byId[String(s.id)] = s;
    byKey[norm(s.title) + "||" + String(s.artist || "").toLowerCase()] = s;
  }
  // 补封面（只补 artwork/album）
  for (const s of missingCover) {
    const donor =
      byId[String(s.id)] ||
      byKey[norm(s.title) + "||" + String(s.artist || "").toLowerCase()];
    if (donor) {
      s.artwork = donor.artwork;
      if (!s.album && donor.album) s.album = donor.album;
    }
  }
  // 补缺失的同名歌（官方有、中转没有的版本），最多补 3 首，避免列表过长；
  // 插到列表最前面，官方排序本身就是按热度来的，原唱会在最前面，
  // 后面的原唱重排只会把同名歌往前排、不会把它们压下去。
  // 去重按 songmid 和歌名+歌手两道：中转返回的 id 格式可能与官方不一致，
  // 只按 id 去重会在同一版本出现两次。
  const haveIds = new Set(songs.map((s) => String(s.id)));
  const haveKeys = new Set(
    songs.map((s) => norm(s.title) + "||" + String(s.artist || "").toLowerCase())
  );
  const toAdd = [];
  for (const s of fb.data) {
    if (toAdd.length >= 3) break;
    if (!s.id || haveIds.has(String(s.id))) continue;
    const key = norm(s.title) + "||" + String(s.artist || "").toLowerCase();
    if (haveKeys.has(key)) continue;
    if (norm(s.title) !== kwNorm) continue;
    toAdd.push(s);
    haveIds.add(String(s.id));
    haveKeys.add(key);
  }
  if (toAdd.length) songs.unshift(...toAdd);
  return songs;
}

/**
 * 从搜索/列表响应中抽出歌曲数组
 * QQ 音乐不同接口返回字段不一致，有 list / songlist / songList 三种写法
 * @param {object} body 接口返回的整个 body
 * @returns {Array}
 */
function extractSongList(body) {
  if (!body || body.result !== 100) {
    return [];
  }
  const data = body.data || {};
  if (Array.isArray(data.list)) {
    return data.list;
  }
  if (Array.isArray(data.songlist)) {
    return data.songlist;
  }
  if (Array.isArray(data.songList)) {
    return data.songList;
  }
  return [];
}

/**
 * 把 QQ 音乐原始歌曲对象归一化成 MusicFree 通用结构
 * 字段兼容性极强：搜索/榜单/歌单/专辑接口返回的歌曲字段都有差异
 * @param {object} raw QQ 音乐原始歌曲对象
 * @returns {object | null}
 */
function normalizeSong(raw) {
  if (!raw || typeof raw !== "object") {
    return null;
  }

  // 歌手：可能是数组 [{name}, ...]、字符串、或 singerName 兜底
  const artist = Array.isArray(raw.singer)
    ? raw.singer
        .map((s) => s && (s.name || s.title) || "")
        .filter(Boolean)
        .join(" / ")
    : typeof raw.singer === "string"
    ? raw.singer
    : raw.singerName || "未知歌手";

  // 专辑：可能是对象或纯字符串
  const albumObj =
    raw.album && typeof raw.album === "object" ? raw.album : {};
  const albumMid = raw.albummid || raw.albumMid || albumObj.mid || "";

  // songmid 是主键，mid 是历史字段
  const songmid = String(raw.songmid || raw.mid || "");

  return {
    id: songmid || String(raw.songId || raw.songid || ""),
    songId: String(raw.songId || raw.songid || ""), // 保留数字 songId 用于回查
    platform: PLATFORM,
    title: raw.songname || raw.name || raw.title || "未知",
    artist,
    album: raw.albumname || albumObj.name || albumObj.title || "",
    albumId: String(albumMid),
    mediaId: String(
      raw.strMediaMid ||
        raw.media_mid ||
        (raw.file && raw.file.media_mid) ||
        songmid
    ),
    duration: raw.interval || raw.duration || 0,
    artwork: buildCoverUrl(albumMid || raw.cover || raw.albumPic),
  };
}

/**
 * 把 QQ 音乐原始歌手对象归一化
 */
function normalizeArtist(raw) {
  // singerPic 是 150x150，升到 300x300 做头像（实测能打开 200），并转 https
  const pic = buildCoverUrl(raw.singerPic)
    .replace("150x150", "300x300")
    .replace("http://", "https://");
  const name = raw.singerName || "未知歌手";
  return {
    id: String(raw.singerMID || ""),
    platform: PLATFORM,
    name,
    title: name,
    artist: name,
    avatar: pic,
    artwork: pic,
    description: raw.songNum ? raw.songNum + " 首歌曲" : "",
    _singerMid: String(raw.singerMID || ""),
  };
}

/**
 * 把 QQ 音乐原始歌单对象归一化
 */
function normalizeSheet(raw) {
  const creatorName =
    raw.creator && typeof raw.creator === "object" ? raw.creator.name || "" : "";
  const sheetId = raw.content_id || raw.dissid || raw.tid || "";
  const cover = buildCoverUrl(raw.imgurl || raw.diss_cover || raw.cover);
  return {
    id: String(sheetId),
    platform: PLATFORM,
    title: raw.dissname || raw.title || "未知歌单",
    artist: creatorName,
    coverImg: cover,
    artwork: cover,
    description:
      raw.introduction ||
      (raw.song_cnt ? raw.song_cnt + " 首" : "") ||
      (raw.listen_num ? "播放 " + raw.listen_num : ""),
  };
}

/**
 * 把 QQ 音乐原始专辑对象归一化
 */
function normalizeAlbum(raw) {
  const albumMid =
    raw.albumMID ||
    raw.mid ||
    raw.albummid ||
    raw.album_mid ||
    raw.albumid ||
    "";
  const artist =
    raw.singerName ||
    raw.singer_name ||
    (Array.isArray(raw.singer) && raw.singer[0] ? raw.singer[0].name : "") ||
    "未知歌手";
  return {
    id: String(albumMid),
    platform: PLATFORM,
    title:
      raw.albumName ||
      raw.album_name ||
      raw.name ||
      raw.title ||
      "未知专辑",
    artist,
    artwork: buildCoverUrl(
      raw.albumPic || raw.pic || raw.picUrl || raw.album_pic_mid
    ),
    isAlbum: true,
  };
}

/**
 * 把 QQ 音乐官方评论接口返回的一条评论归一化成 MusicFree 的评论结构
 * 格式按官方 bilibili 示例插件的 formatComment：
 *   { id, nickName, avatar, comment, like, createAt, location }
 * QQ 的 time 是秒级时间戳，MusicFree 要毫秒，×1000。
 * @param {object} c QQ 评论对象
 */
function formatQQComment(c) {
  return {
    id: c.commentid,
    nickName: c.nick || "未知用户",
    avatar: c.avatarurl || "",
    comment: c.rootcommentcontent || "",
    like: c.praisenum || 0,
    createAt: (c.time || 0) * 1000,
    location: undefined,
  };
}

/**
 * 取评论用的数字 songId（QQ 评论接口 topid 只认数字 songId）
 * 优先用歌曲对象自带的 songId；只有 songmid 时用标题回查搜索，
 * 找到 songmid 匹配的那首，取它的 songId。
 * @param {{songId?: string, id?: string, title?: string, name?: string}} song
 * @returns {Promise<string>} 数字 songId，拿不到返回 ""
 */
async function resolveNumericSongId(song) {
  const sid = String(song.songId || "");
  if (/^\d+$/.test(sid)) {
    return sid;
  }
  const id = String(song.id || "");
  if (/^\d+$/.test(id)) {
    return id;
  }
  const title = song.title || song.name || "";
  if (!title || title === "QQ音乐歌曲") {
    return "";
  }
  try {
    // 中转 search 挂了时走官方搜索兜底（v0.5.8）
    const body = await callApi(
      "search",
      { key: title, pageNo: 1, pageSize: 10, t: 0 },
      10000
    ).catch(() => null);
    let candidates = extractSongList(body);
    if (!candidates.length) {
      const fb = await searchOfficialQQ(title, 1, "music");
      if (fb && fb.data.length) {
        candidates = fb.data.map((s) => ({
          songmid: s.id,
          songid: s.songId,
        }));
      }
    }
    let matched = null;
    for (let i = 0; i < candidates.length; i++) {
      const c = candidates[i];
      if (String(c.songmid || c.mid || "") === id) {
        matched = c;
        break;
      }
    }
    if (!matched && candidates.length) {
      matched = candidates[0];
    }
    if (!matched) {
      return "";
    }
    return String(matched.songid || matched.songId || "");
  } catch (e) {
    return "";
  }
}

/**
 * 通用 GET 请求封装：自动拼 path 参数并提取 data 字段
 * @param {string} path     后端 action 名
 * @param {object} params   业务参数
 * @param {number} timeout  超时（毫秒）
 * @returns {Promise<object>} 接口返回的 body
 */
function callApi(path, params, timeout) {
  return axios
    .get(API, {
      params: Object.assign({ path }, params),
      timeout: timeout || 10000,
    })
    .then((resp) => resp.data);
}

/**
 * 歌手接口重试版 callApi（v0.5.6 新增）
 * 中转站 singer/songs、singer/album 间歇性返回 result=100 但 data 为空
 * （实测同一请求重试即恢复），属于上游抖动。空数据时最多重试 2 次，
 * 每次间隔 600ms；3 次都空才认空。失败抛错由调用方兜底。
 * @param {string} path 接口路径
 * @param {object} params 参数
 * @param {number} timeout 超时
 * @returns {Promise<object>} 响应体
 */
async function callSingerApi(path, params, timeout) {
  let last = null;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const body = await callApi(path, params, timeout);
      last = body;
      if (body && body.result === 100) {
        const list = extractSongList(body);
        const data = body.data || {};
        // 有歌单/有简介/有总数就算有效数据，不用重试
        if (list.length > 0 || data.singer_brief || data.total_song || data.total_album) {
          return body;
        }
      }
    } catch (e) {
      last = null;
    }
    if (attempt < 2) {
      await new Promise((r) => setTimeout(r, 600));
    }
  }
  return last || { result: 100, data: {} };
}

// songId → songmid 的内存缓存（避免对同一首歌反复回查搜索接口）
const songIdResolveCache = {};

/**
 * 把数字 songId 转成 songmid（后端 song/url 接口只认 songmid）
 * 实现方式：用歌曲标题去搜索，再从结果里找到 songid 匹配的那一首
 * @param {{songId?: string, id?: string, title?: string, name?: string}} song
 * @returns {Promise<{songmid: string, mediaId: string} | null>}
 */
async function resolveSongBySongId(song) {
  const songId = String(song.songId || song.id || "");
  if (!songId) {
    return null;
  }

  // 命中缓存
  if (songIdResolveCache[songId]) {
    return songIdResolveCache[songId];
  }

  const title = song.title || song.name || "";
  if (!title) {
    return null;
  }

  // 回查搜索接口（取前 10 条）；中转 search 挂了时走官方搜索兜底
  const searchBody = await callApi(
    "search",
    { key: title, pageNo: 1, pageSize: 10, t: 0 },
    10000
  ).catch(() => null);
  let candidates = extractSongList(searchBody);
  if (!candidates.length) {
    const fb = await searchOfficialQQ(title, 1, "music");
    if (fb && fb.data.length) {
      candidates = fb.data.map((s) => ({
        songmid: s.id,
        songid: s.songId,
        strMediaMid: s.mediaId,
        media_mid: s.mediaId,
      }));
    }
  }

  // 优先找 songid 严格匹配的
  let matched = null;
  for (const c of candidates) {
    if (String(c.songid || c.songId || "") === songId) {
      matched = c;
      break;
    }
  }
  // 退而求其次用第一条
  if (!matched && candidates.length) {
    matched = candidates[0];
  }
  if (!matched) {
    return null;
  }

  const result = {
    songmid: String(matched.songmid || matched.mid || ""),
    mediaId: String(
      matched.strMediaMid ||
        matched.media_mid ||
        (matched.file && matched.file.media_mid) ||
        ""
    ),
  };

  if (result.songmid) {
    songIdResolveCache[songId] = result;
  }
  return result;
}

// Meting（liveling）QQ 兜底
const METING_API = "https://meting.liveling.top/api";

/**
 * Meting（liveling，server=tencent）兜底解析 QQ 播放地址（v0.5.2 新增）
 * 来源：liveling 的 Meting API（meting.liveling.top），站长自费维护的公益接口。
 * 实测（2026-11-21）：只 standard（128k）可用，exhigh/lossless 一律 404；
 * 免费歌部分可用——老男孩 CL=3,149,077（196s 整首）、小苹果 CL=3,473,018
 * （216s 整首）；最炫民族风/十年返回空（CL=224）；VIP 歌（晴天/七里香/
 * 小幸运/演员）一律 404，Meting 的 QQ 侧没有 VIP Cookie（与网易云侧不同）。
 * 所以这层兜底只覆盖部分免费歌；VIP 歌仍以中转为主，中转也拿不到时
 * 只能走用户自己的 QQ 绿钻/VIP 登录态（见文件头）。
 * @param {string} songmid QQ songmid
 * @returns {Promise<string|null>} 直链，拿不到返回 null
 */
async function resolveMetingQQUrl(songmid) {
  try {
    const res = await axios.get(METING_API, {
      params: { server: "tencent", type: "url", id: songmid, quality: "standard" },
      timeout: 3000,
      maxRedirects: 0,
      validateStatus: () => true,
    });
    const loc = res.headers && (res.headers.location || res.headers.Location);
    if (res.status === 302 && typeof loc === "string" && loc.indexOf("http") === 0) {
      return loc;
    }
    return null;
  } catch (e) {
    return null;
  }
}

// ------------------------------------------------------------------
// 跨平台播歌兜底（v0.5.10 新增）：本平台拿不到播放链接时，
// 按歌名+歌手去酷狗找同一首歌播。各平台版权不同，同一首歌在某平台是
// VIP、在另一平台是免费的，不是绕付费墙，不用任何 VIP 账号。
// 实测：QQ 王蓉《爸爸妈妈》、七里香、告白气球、稻香、Shape of You 都能
// 从酷狗播整首（有效 MP3 128k，文件大小与时长相符）。
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
      const res = await axios.get(KG_XPLAY_SEARCH, { params, timeout: 5000 });
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
 * 跨平台播歌兜底：本平台拿不到链接时去酷狗找同一首歌播
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

/** base64 解码（不依赖环境自带 atob，自己实现才稳妥；与酷狗插件同款） */
function qqB64Decode(str) {
  const tbl = {};
  const alpha =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  for (let i = 0; i < 64; i++) tbl[alpha[i]] = i;
  str = String(str || "").replace(/[^A-Za-z0-9+/=]/g, "");
  const out = [];
  for (let i = 0; i < str.length; i += 4) {
    const a = tbl[str[i]];
    const b = tbl[str[i + 1]];
    const c = str[i + 2] === "=" ? 0 : tbl[str[i + 2]];
    const d = str[i + 3] === "=" ? 0 : tbl[str[i + 3]];
    out.push((a << 2) | (b >> 4));
    if (str[i + 2] !== "=") out.push(((b & 15) << 4) | (c >> 2));
    if (str[i + 3] !== "=") out.push(((c & 3) << 6) | d);
  }
  return new Uint8Array(out);
}

/** 把 Uint8Array 按 UTF-8 解成字符串（不依赖 TextDecoder，自己实现才稳妥） */
function qqUtf8Decode(bytes) {
  let s = "";
  let i = 0;
  while (i < bytes.length) {
    const b = bytes[i++];
    if (b < 0x80) {
      s += String.fromCharCode(b);
    } else if ((b & 0xe0) === 0xc0) {
      s += String.fromCharCode(((b & 0x1f) << 6) | (bytes[i++] & 0x3f));
    } else if ((b & 0xf0) === 0xe0) {
      s += String.fromCharCode(
        ((b & 0x0f) << 12) | ((bytes[i++] & 0x3f) << 6) | (bytes[i++] & 0x3f)
      );
    } else {
      const cp =
        ((b & 0x07) << 18) |
        ((bytes[i++] & 0x3f) << 12) |
        ((bytes[i++] & 0x3f) << 6) |
        (bytes[i++] & 0x3f);
      const c = cp - 0x10000;
      s += String.fromCharCode(0xd800 + (c >> 10), 0xdc00 + (c & 0x3ff));
    }
  }
  return s;
}

// QQ 官方歌词接口（musicu.fcg，PlayLyricInfo 模块）
const MUSICU_URL = "https://u.y.qq.com/cgi-bin/musicu.fcg";

/**
 * 取 QQ 官方歌词翻译（v0.5.5 新增）
 *
 * 旧路走不通：中转 lyric 的 trans 为空；官方 fcg_query_lyric_new.fcg
 * 的 trans 也是空。QQ 的翻译在 PlayLyricInfo 接口里：
 * POST musicu.fcg，module music.musichallSong.PlayLyricInfo，
 * method GetPlayLyricInfo，param trans=1 + crypt=0 时，返回的 trans
 * 是明文 base64 的翻译 LRC（时间戳与原歌词一一对应）。
 * crypt=1 会返回 3DES 加密的 hex（QQ 自定义密钥扩展），没必要走。
 * 失败（网络 / 无翻译 / 中文歌）返回 ""，不阻塞歌词显示。
 * @param {string} songmid
 * @returns {Promise<string>} 翻译 LRC（无翻译时为空串）
 */
async function fetchQQTranslation(songmid) {
  try {
    const resp = await axios.post(
      MUSICU_URL,
      {
        comm: { ct: 24, cv: 0, uin: 0 },
        req_0: {
          module: "music.musichallSong.PlayLyricInfo",
          method: "GetPlayLyricInfo",
          param: {
            crypt: 0,
            lrc_t: 0,
            qrc: 0,
            qrc_t: 0,
            roma: 0,
            roma_t: 0,
            trans: 1,
            trans_t: 0,
            needSingingAnnotations: false,
            type: 1,
            songMid: songmid,
          },
        },
      },
      {
        headers: {
          "Content-Type": "application/json",
          Referer: "https://y.qq.com/",
          "User-Agent": UA,
        },
        timeout: 8000,
      }
    );
    const data =
      resp && resp.data && resp.data.req_0 && resp.data.req_0.data;
    const trans = data && data.trans;
    if (!trans || typeof trans !== "string") {
      return "";
    }
    const text = qqUtf8Decode(qqB64Decode(trans)).replace(/^\uFEFF/, "");
    // QQ 用 "[时间戳]//" 占位未翻译的行（多是标题/作词等头信息），去掉，
    // 只留真正有中文翻译的行；一行翻译都没有就当无翻译处理。
    const lines = text
      .split("\n")
      .filter((line) => !/^\[\d+:\d+\.\d+\]\s*\/\/\s*$/.test(line));
    const cleaned = lines.join("\n").trim();
    if (!/\[\d+:\d+\.\d+\][^\[\]]*\S/.test(cleaned)) {
      return "";
    }
    return cleaned;
  } catch (e) {
    return "";
  }
}

/**
 * 带重试的 callApi（v0.5.7 新增）
 * 中转站多个接口（songlist、top/category、top、album/songs、
 * songlist/category、songlist/list）间歇性返回 result=100 但 data
 * 为空（实测同一请求重试即恢复，与歌手接口同款抖动）。
 * 空数据时最多重试 2 次（间隔 600ms）；3 次都空才认空。
 * 明确失败（result !== 100）不重试；合法的空结果重试后仍为空，
 * 行为不变，只是多 2 次请求。网络抛错也重试。
 * @param {string} path 接口路径
 * @param {object} params 参数
 * @param {number} timeout 超时
 * @param {function} hasData 判别“有可用数据”的函数，可空
 * @returns {Promise<object>} 响应体
 */
async function callApiRetry(path, params, timeout, hasData) {
  let last = null;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const body = await callApi(path, params, timeout);
      last = body;
      if (body && body.result === 100) {
        if (!hasData || hasData(body)) return body;
      } else if (body && body.result !== 100) {
        return body;
      }
    } catch (e) {
      last = null;
    }
    if (attempt < 2) {
      await new Promise((r) => setTimeout(r, 600));
    }
  }
  return last || { result: 100, data: {} };
}

// QQ 官方搜索直连（v0.5.7 搜索兜底用）
// 中转 search 自 2026-11-21 晚起一律 400“搜索结果解析失败”；
// 官方 c.y.qq.com/soso/fcgi-bin/search_for_qq_cp 直连可用，
// t=0 单曲 / t=8 专辑，翻页正常。歌手/歌单没有可用的官方接口。
const QQ_OFFICIAL_SEARCH = "https://c.y.qq.com/soso/fcgi-bin/search_for_qq_cp";
const QQ_OFFICIAL_SEARCH_T = { music: 0, album: 8 };

/**
 * 把官方搜索的歌曲记录归一化成插件的歌曲结构
 * 官方字段：songmid/songid/songname/singer[{name}]/albummid/albumname/interval（秒）
 */
function normalizeOfficialQQSong(raw) {
  const singer = Array.isArray(raw.singer)
    ? raw.singer.map((s) => s && s.name).filter(Boolean).join(" / ")
    : "";
  return {
    id: String(raw.songmid || ""),
    songId: String(raw.songid || ""),
    platform: PLATFORM,
    title: raw.songname || "未知",
    artist: singer || "未知歌手",
    album: raw.albumname || "",
    albumId: String(raw.albummid || ""),
    mediaId: String(raw.songmid || ""),
    duration: Number(raw.interval || 0),
    artwork: buildCoverUrl(raw.albummid || ""),
  };
}

/** 把官方搜索的专辑记录归一化 */
function normalizeOfficialQQAlbum(raw) {
  return {
    id: String(raw.albumMID || ""),
    platform: PLATFORM,
    title: raw.albumName || "未知专辑",
    artist: raw.singerName || "未知歌手",
    artwork: buildCoverUrl(raw.albumMID || ""),
    isAlbum: true,
  };
}

/**
 * QQ 官方搜索兜底（v0.5.7 新增，v0.5.8 补歌手）
 * 单曲/专辑走官方 search_for_qq_cp（t=0 / t=8）；歌手没有官方歌手
 * 搜索接口，改从官方单曲搜索结果里抽 singer mid 去重拼歌手项，
 * 头像用 QQ 歌手头像 CDN 规律 T001R300x300M000{mid}.jpg（实测 200）。
 * 歌单没有可用的官方接口，返回 null 让调用方走原有逻辑。
 * 官方接口失败返回 null，不抛错。
 * @param {string} keyword 关键字
 * @param {number} page 页码（从 1 开始）
 * @param {string} searchType music / album / artist
 * @returns {Promise<{isEnd: boolean, data: Array} | null>}
 */
async function searchOfficialQQ(keyword, page, searchType) {
  // 歌手兜底：单曲搜索结果里抽 singer
  if (searchType === "artist") {
    try {
      const resp = await axios.get(QQ_OFFICIAL_SEARCH, {
        params: { format: "json", w: keyword, p: page, n: 20, t: 0 },
        headers: { Referer: "https://y.qq.com/", "User-Agent": UA },
        timeout: 12000,
      });
      const data = (resp.data && resp.data.data) || {};
      const list = (data.song && data.song.list) || [];
      const seen = {};
      const artists = [];
      for (const s of list) {
        for (const sg of (s.singer || [])) {
          if (sg.mid && !seen[sg.mid]) {
            seen[sg.mid] = true;
            const pic = `https://y.gtimg.cn/music/photo_new/T001R300x300M000${sg.mid}.jpg`;
            artists.push({
              id: String(sg.mid),
              platform: PLATFORM,
              name: sg.name || "未知歌手",
              title: sg.name || "未知歌手",
              artist: sg.name || "未知歌手",
              avatar: pic,
              artwork: pic,
              description: "",
              _singerMid: String(sg.mid),
            });
          }
        }
      }
      return { isEnd: list.length < 20, data: artists };
    } catch (e) {
      return null;
    }
  }
  const t = QQ_OFFICIAL_SEARCH_T[searchType];
  if (t === undefined) return null;
  try {
    const resp = await axios.get(QQ_OFFICIAL_SEARCH, {
      params: { format: "json", w: keyword, p: page, n: 20, t },
      headers: { Referer: "https://y.qq.com/", "User-Agent": UA },
      timeout: 12000,
    });
    const data = (resp.data && resp.data.data) || {};
    if (t === 0) {
      const list = (data.song && data.song.list) || [];
      const total = Number((data.song && data.song.totalnum) || 0);
      let songs = list.map(normalizeOfficialQQSong).filter((s) => s.id);
      // 与中转路径一致：补极少数 albummid 为空导致的空封面
      await fillMissingCover(songs);
      // v0.5.8：原唱重排（与网易云插件同款逻辑）
      songs = rankOriginalsFirst(songs, keyword);
      return {
        isEnd: total > 0 ? page * 20 >= total : songs.length < 20,
        data: songs,
      };
    }
    const list = (data.album && data.album.list) || [];
    const total = Number((data.album && data.album.totalnum) || 0);
    return {
      isEnd: total > 0 ? page * 20 >= total : list.length < 20,
      data: list.map(normalizeOfficialQQAlbum).filter((a) => a.id),
    };
  } catch (e) {
    return null;
  }
}

// 原唱重排（v0.5.8 新增，与网易云插件同款）：标题干净的原唱排前面，
// 带版本标记的（翻唱/Live/旧版/现场等）往后放。只重排、不删结果。
const QQ_COVER_MARKERS = [
  "女声版", "男声版", "童声", "DJ版", "DJ舞曲", "钢琴版", "钢琴曲",
  "Live", "live", "翻唱", "Remix", "remix", "完整版", "正式版",
  "弦乐版", "吉他版", "竖琴", "八音盒", "纯享版", "加速版",
  "原唱", "旧版", "现场",
];

/**
 * @param {Array<object>} songs 归一化后的歌曲
 * @param {string} keyword 搜索关键词
 */
function rankOriginalsFirst(songs, keyword) {
  const kw = String(keyword || "").trim().toLowerCase();
  const scored = songs.map((s, idx) => {
    let score = 0;
    const title = String(s.title || "");
    const lower = title.toLowerCase();
    if (kw && lower === kw) score += 3;
    if (QQ_COVER_MARKERS.some((m) => lower.includes(m.toLowerCase()))) score -= 3;
    return { s, score, idx };
  });
  scored.sort((a, b) => b.score - a.score || a.idx - b.idx);
  return scored.map((x) => x.s);
}

// ============== 兜底接口（v0.5.9 新增，用户无感标准） ==============
// 中转挂了时走 QQ 官方接口，失败静默换路、全失败返回空、不抛错。
// 兜底返回的数据格式与主路一致（封面/时长/字段齐全）。

// 中转 https 通道（http 失败时的备用传输；中转本身 https 可用）
const API_HTTPS = "https://ws.suol.cc/qq/qq_php.php";

/**
 * 官方歌词兜底（v0.5.9 新增）
 * c.y.qq.com fcg_query_lyric_new.fcg：有歌词、无翻译（翻译仍走 PlayLyricInfo）。
 * 失败返回 ""，不抛错。
 * @param {string} songmid
 * @returns {Promise<string>} LRC 文本，无歌词返回 ""
 */
async function fetchQQOfficialLyric(songmid) {
  try {
    const resp = await axios.get(
      "https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg",
      {
        params: { songmid, format: "json", nobase64: 1, g_tk: 5381 },
        headers: { Referer: "https://y.qq.com/", "User-Agent": UA },
        timeout: 8000,
      }
    );
    const lyric = (resp.data && resp.data.lyric) || "";
    return typeof lyric === "string" ? lyric : "";
  } catch (e) {
    return "";
  }
}

/**
 * 把 musicu AlbumSongList 的 songInfo 归一化成插件歌曲结构
 * songInfo 字段：id/mid/name/singer[{mid,name}]/album{mid,name}/interval
 * @param {object} si songInfo 对象
 * @returns {object | null}
 */
function normalizeMusicuAlbumSong(si) {
  if (!si || typeof si !== "object") return null;
  const singer = Array.isArray(si.singer)
    ? si.singer.map((s) => s && s.name).filter(Boolean).join(" / ")
    : "";
  const album = si.album && typeof si.album === "object" ? si.album : {};
  const songmid = String(si.mid || "");
  return {
    id: songmid || String(si.id || ""),
    songId: String(si.id || ""),
    platform: PLATFORM,
    title: si.name || "未知",
    artist: singer || "未知歌手",
    album: album.name || "",
    albumId: String(album.mid || ""),
    mediaId: songmid,
    duration: Number(si.interval || 0),
    artwork: buildCoverUrl(album.mid || ""),
  };
}

/**
 * 专辑歌曲官方兜底（v0.5.9 新增）
 * musicu.fcg music.musichallAlbum.AlbumSongList GetAlbumSongList。
 * 失败返回 null，不抛错。
 * @param {string} albumMid 专辑 mid
 * @param {number} begin 起始下标
 * @param {number} num 条数
 * @returns {Promise<{isEnd: boolean, data: Array} | null>}
 */
async function fetchQQAlbumSongsOfficial(albumMid, begin, num) {
  try {
    const resp = await axios.post(
      MUSICU_URL,
      {
        comm: { ct: 24, cv: 0, uin: 0 },
        req_0: {
          module: "music.musichallAlbum.AlbumSongList",
          method: "GetAlbumSongList",
          param: { albumMid, begin: begin || 0, num: num || 30, order: 2 },
        },
      },
      {
        headers: { "Content-Type": "application/json", Referer: "https://y.qq.com/", "User-Agent": UA },
        timeout: 8000,
      }
    );
    const d = (resp.data && resp.data.req_0 && resp.data.req_0.data) || {};
    const list = Array.isArray(d.songList) ? d.songList : [];
    const total = Number(d.totalNum || 0);
    const data = list.map((x) => normalizeMusicuAlbumSong(x.songInfo)).filter(Boolean);
    return {
      isEnd: total > 0 ? (begin || 0) + data.length >= total : data.length < (num || 30),
      data,
    };
  } catch (e) {
    return null;
  }
}

/**
 * 歌单详情官方兜底（v0.5.9 新增）
 * 旧 DissInfo fcg_ucc_getcdinfo_byids_cp：一次返回整张歌单（最多 511 首）。
 * 条目结构与 normalizeSong 兼容（songmid/songname/songid/interval/singer[]/albummid）。
 * 失败返回 null，不抛错。
 * @param {string|number} dissid 歌单 id
 * @returns {Promise<{title: string, artist: string, coverImg: string, description: string, musicList: Array} | null>}
 */
async function fetchQQDissInfoOfficial(dissid) {
  try {
    const resp = await axios.get(
      "https://c.y.qq.com/qzone/fcg-bin/fcg_ucc_getcdinfo_byids_cp.fcg",
      {
        params: {
          type: 1, json: 1, utf8: 1, onlysong: 0, nosign: 1,
          disstid: dissid, g_tk: 5381, loginUin: 0, hostUin: 0,
          format: "json", inCharset: "utf8", outCharset: "utf-8",
          notice: 0, platform: "yqq.json", needNewCode: 0,
        },
        headers: { Referer: "https://y.qq.com/", "User-Agent": UA },
        timeout: 8000,
      }
    );
    const cd = (resp.data && resp.data.cdlist && resp.data.cdlist[0]) || null;
    if (!cd || !Array.isArray(cd.songlist)) return null;
    return {
      title: cd.dissname || "",
      artist: (cd.creator && cd.creator.name) || "",
      coverImg: buildCoverUrl(cd.logo || cd.diss_cover || ""),
      description: cd.desc || "",
      musicList: cd.songlist.map(normalizeSong).filter(Boolean),
    };
  } catch (e) {
    return null;
  }
}

/**
 * 榜单详情官方兜底（v0.5.9 新增）
 * 旧榜单 fcg_v8_toplist_cp：条目在 songlist[].data（musicData），
 * 结构与 normalizeSong 兼容（songmid/songname/songid/interval/singer[]/albummid）。
 * 失败返回 null，不抛错。
 * @param {string|number} topid 榜单 id
 * @param {number} begin 起始下标
 * @param {number} num 条数
 * @returns {Promise<{isEnd: boolean, data: Array} | null>}
 */
async function fetchQQToplistOfficial(topid, begin, num) {
  try {
    const resp = await axios.get(
      "https://c.y.qq.com/v8/fcg-bin/fcg_v8_toplist_cp.fcg",
      {
        params: {
          tpl: 3, page: "detail", type: "top", topid,
          song_begin: begin || 0, song_num: num || 100,
          g_tk: 5381, loginUin: 0, hostUin: 0, format: "json",
          inCharset: "utf8", outCharset: "utf-8", notice: 0,
          platform: "yqq.json", needNewCode: 0,
        },
        headers: { Referer: "https://y.qq.com/", "User-Agent": UA },
        timeout: 8000,
      }
    );
    const list = Array.isArray(resp.data?.songlist) ? resp.data.songlist : [];
    const data = list.map((x) => normalizeSong(x.data)).filter(Boolean);
    return { isEnd: true, data };
  } catch (e) {
    return null;
  }
}

/**
 * 按标签拉歌单官方兜底（v0.5.9 新增）
 * fcg_get_diss_by_tag：categoryId 为标签 id，sin/ein 分页。
 * 条目结构与 normalizeSheet 兼容（dissid/dissname/imgurl/creator/song_cnt）。
 * 失败返回 null，不抛错。
 * @param {string|number} categoryId 标签 id
 * @param {number} page 页码（从 1 开始）
 * @returns {Promise<{isEnd: boolean, data: Array} | null>}
 */
async function fetchQQDissByTagOfficial(categoryId, page) {
  const pageNo = page || 1;
  const sin = (pageNo - 1) * 20;
  try {
    const resp = await axios.get(
      "https://c.y.qq.com/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg",
      {
        params: {
          picmid: 1, rnd: Math.random(), g_tk: 5381, loginUin: 0, hostUin: 0,
          format: "json", inCharset: "utf8", outCharset: "utf-8", notice: 0,
          platform: "yqq.json", needNewCode: 0,
          categoryId: categoryId || "10000000", sortId: 5, sin, ein: sin + 19,
        },
        headers: { Referer: "https://y.qq.com/", "User-Agent": UA },
        timeout: 8000,
      }
    );
    const list = (resp.data?.data?.list) || [];
    const data = list.map(normalizeSheet).filter(Boolean);
    return { isEnd: data.length < 20, data };
  } catch (e) {
    return null;
  }
}

// 榜单列表内置兜底（v0.5.9 新增）：中转 top/category 挂了时用这组主榜单
// topId 为 QQ 音乐公开榜单 id，与旧榜单接口 fcg_v8_toplist_cp 兼容
const QQ_TOPLIST_FALLBACK = [
  {
    title: "巅峰榜",
    data: [
      { id: "4", title: "巅峰榜·流行指数", coverImg: "https://y.gtimg.cn/music/common/upload/test_order_channel_hitlist_con/1847681.png", artwork: "https://y.gtimg.cn/music/common/upload/test_order_channel_hitlist_con/1847681.png" },
      { id: "26", title: "热歌榜", coverImg: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150820174743.jpg", artwork: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150820174743.jpg" },
      { id: "27", title: "新歌榜", coverImg: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150820174831.jpg", artwork: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150820174831.jpg" },
      { id: "62", title: "飙升榜", coverImg: "https://y.gtimg.cn/music/common/upload/t_order_channel_hitlist_conf/1743216.png", artwork: "https://y.gtimg.cn/music/common/upload/t_order_channel_hitlist_conf/1743216.png" },
      { id: "3", title: "巅峰榜·欧美", coverImg: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151215.jpg", artwork: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151215.jpg" },
      { id: "5", title: "巅峰榜·内地", coverImg: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151407.jpg", artwork: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151407.jpg" },
      { id: "6", title: "巅峰榜·港台", coverImg: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20141110193534.jpg", artwork: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20141110193534.jpg" },
      { id: "16", title: "巅峰榜·韩国", coverImg: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151656.jpg", artwork: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151656.jpg" },
      { id: "17", title: "巅峰榜·日本", coverImg: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151730.jpg", artwork: "https://y.gtimg.cn/music/common/upload/iphone_order_channel/20150122151730.jpg" },
      { id: "28", title: "网络歌曲榜", coverImg: "https://y.gtimg.cn/music/common/upload/test_order_channel_hitlist_con/1219597.png", artwork: "https://y.gtimg.cn/music/common/upload/test_order_channel_hitlist_con/1219597.png" },
      { id: "36", title: "K歌金曲榜", coverImg: "https://y.gtimg.cn/music/common/upload/t_order_channel_hitlist_conf/34147.png", artwork: "https://y.gtimg.cn/music/common/upload/t_order_channel_hitlist_conf/34147.png" },
      { id: "32", title: "音乐人榜", coverImg: "https://y.gtimg.cn/music/common//upload/t_order_channel_hitlist_conf/52845.png", artwork: "https://y.gtimg.cn/music/common//upload/t_order_channel_hitlist_conf/52845.png" },
    ],
  },
];

// 推荐歌单标签内置兜底（v0.5.9 新增）：中转 songlist/category 挂了时用这组标签
// categoryId 为 QQ 音乐公开歌单分类 id，与 fcg_get_diss_by_tag 兼容
const QQ_SHEET_TAG_FALLBACK = {
  pinned: [
    { id: "10000000", title: "热门" },
    { id: "10000001", title: "官方歌单" },
    { id: "10000002", title: "经典" },
    { id: "10000003", title: "流行" },
  ],
  data: [
    {
      title: "语种",
      data: [
        { id: "165", title: "华语" },
        { id: "167", title: "欧美" },
        { id: "168", title: "日韩" },
        { id: "169", title: "粤语" },
      ],
    },
    {
      title: "流派",
      data: [
        { id: "6", title: "流行" },
        { id: "8", title: "摇滚" },
        { id: "9", title: "民谣" },
        { id: "11", title: "电子" },
        { id: "14", title: "说唱" },
        { id: "17", title: "轻音乐" },
      ],
    },
    {
      title: "场景",
      data: [
        { id: "19", title: "运动" },
        { id: "20", title: "学习" },
        { id: "21", title: "工作" },
        { id: "22", title: "旅行" },
        { id: "23", title: "睡前" },
      ],
    },
  ],
};

// ---- 74520 解析兜底（v0.6.0 新增）----
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
  platform: PLATFORM,
  author: "风誰",
  version: "0.7.3",
  description:
    "风誰制作 · QQ音乐二开专用版（原版中转 + 评论补全 + 搜索翻页，仅供个人使用）",
  cacheControl: "no-cache",
  primaryKey: ["id", "mediaId"],
  supportedSearchType: ["music", "album", "artist", "sheet"],
  hints: {
    importMusicSheet: [
      "支持 QQ 音乐歌单/专辑分享链接或歌单 ID，例如 https://y.qq.com/n/ryqq/playlist/8075336924",
    ],
    importMusicItem: [
      "支持 QQ 音乐单曲分享链接或 songmid，例如 https://y.qq.com/n/ryqq/songDetail/0039MnYb0qxYhV",
    ],
  },

  // 74520 解析账号（v0.6.0 新增）：填 dl.74520.xyz 的账号密码，播放时
  // 本平台拿不到链接就走 74520 解析（QQ 付费歌 320k 可解析）。
  // 不填也能用，只是没有这层兜底。账号密码只存在本机插件设置里。
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
   * 多类型搜索
   * @param {string} keyword    关键字
   * @param {number} pageNo     页码
   * @param {string} searchType music / album / artist / sheet
   */
  async search(keyword, pageNo, searchType) {
    const t = SEARCH_TYPE_T[searchType] || 0;
    const page = pageNo || 1;
    const pageSize = 20;
    // v0.5.7：中转失败（网络抛错或 result 非 100）不直接返回空，
    // 落到官方搜索兜底；中转返回空数据时也走兜底（中转间歇空返回）。
    // v0.5.9：中转改走 callApiRetry（歌单搜索无官方接口，重试是唯一兜底）。
    const body = await callApiRetry(
      "search",
      { key: keyword, pageNo: page, pageSize, t },
      10000,
      (b) => extractSongList(b).length > 0
    ).catch(() => null);

    if (body && body.result === 100) {
      const list = extractSongList(body);
      let data;
      if (t === 8) {
        data = list.map(normalizeAlbum).filter(Boolean);
      } else if (t === 9) {
        data = list.map(normalizeArtist).filter(Boolean);
      } else if (t === 2) {
        data = list.map(normalizeSheet).filter(Boolean);
      } else {
        data = list.map(normalizeSong).filter(Boolean);
        // v0.5.3：补极少数 albummid 为空导致的空封面
        await fillMissingCover(data);
        // v0.5.15/0.5.16：官方搜索合并（补封面 + 补中转漏掉的同名歌）
        data = await mergeOfficialSearchResults(data, keyword, page);
        // v0.5.8：原唱重排（与网易云插件同款逻辑）
        data = rankOriginalsFirst(data, keyword);
      }
      // 中转有数据就用中转；空数据时继续往下走官方兜底
      if (data.length) {
        // 原版把 isEnd 写死成 true，只能看到第一页；后端其实返回 total，
        // 按 total 算是否到底（total 缺失时退化为“本页没拉满即到底”）
        const total = Number((body.data && body.data.total) || 0);
        const isEnd =
          total > 0 ? page * pageSize >= total : data.length < pageSize;
        return { isEnd, data };
      }
    }
    // 官方搜索兜底（仅单曲/专辑；歌手/歌单返回 null，走下面的空结果）
    const fb = await searchOfficialQQ(keyword, page, searchType);
    if (fb) return fb;
    return { isEnd: true, data: [] };
  },

  /**
   * 获取播放地址
   * 注意：如果传入的 id 是纯数字（说明是 songId 而非 songmid），
   * 需要先调 resolveSongBySongId 转成 songmid 再请求
   * @param {{id: string, mediaId?: string, title?: string}} song
   * @param {string} quality 音质档位
   */
  async getMediaSource(song, quality) {
    const qualityCode = QUALITY_MAP[quality] || "128";
    // v0.5.7：空歌曲对象直接报干净错误，不抛 TypeError
    if (!song || !song.id) {
      throw new Error("无法获取播放链接，请稍后重试");
    }
    let songmid = song.id;
    let mediaId = song.mediaId;

    // 数字 id = songId，需要转换
    if (/^\d+$/.test(String(songmid))) {
      const resolved = await resolveSongBySongId(song);
      if (!resolved) {
        throw new Error("无法解析歌曲ID，请稍后重试");
      }
      songmid = resolved.songmid;
      mediaId = resolved.mediaId || songmid;
    }

    const headers = { Referer: "https://y.qq.com/", "User-Agent": UA };
    // v0.5.9：中转依次尝试（指定音质 → 重试一次 → 降音质 128k → https 中转 128k），
    // 再走 Meting；全失败才报干净错误。切换静默、超时收紧，不让用户久等。
    // v0.6.2：中转只调 1 次，跟原版一样——通了就秒播，不通立刻走兜底，
    // 不重试、不等。兜底全部 3 秒超时，整条链最坏 20 秒内一定有结果。
    const attempts = [{ base: API, type: qualityCode }];
    for (let i = 0; i < attempts.length; i++) {
      const params = {
        path: "song/url",
        id: songmid,
        type: attempts[i].type,
      };
      if (mediaId && mediaId !== songmid) {
        params.mediaId = mediaId;
      }
      try {
        const response = await axios.get(attempts[i].base, {
          params,
          timeout: i === 0 ? 8000 : 6000,
        });
        const body = response.data;
        if (body && body.result === 100 && body.data) {
          return { url: body.data, headers };
        }
      } catch (e) {
        // 静默换下一条路
      }
    }
    // v0.7.0：74520 解析兜底——本平台拿不到链接时走 74520 解析同平台同首歌
    // （QQ 付费歌 320k 可解析；不填账号时静默跳过，直接报干净错误）
    // 已删：Meting（无 VIP 且在退化）、酷狗跨平台（74520 已覆盖同平台 VIP）
    const dlX = await resolveDl74520Url("qqmusic", songmid, quality, {
      title: song.title,
      author: song.artist,
      mediaMid: mediaId,
    });
    if (dlX) return dlX;
    throw new Error("无法获取播放链接，请稍后重试");
  },

  /**
   * 获取歌曲详情（v0.5.14 新增）。
   * 按官方插件协议，播放时软件会调这个方法补全搜索结果里缺失的信息，
   * 点名举例就是封面图。之前四个插件里只有 QQ 没有这个方法：
   * 搜索结果若无封面（如中转返回缺 albummid），播放时没有任何地方补封面，
   * 播放页只剩占位图——0.5.12/0.5.13 只改了封面 URL 的协议和 host，
   * 字段本身是空的就无从改起。现按 songmid 调官方
   * fcg_play_single_song.fcg 取 album.mid，再经自家封面代理拼封面；
   * 取不到就回填原有封面，不抛错、不阻塞播放。
   */
  async getMusicInfo(song) {
    const songmid = song && song.id;
    const fallback = (song && song.artwork) || "";
    if (!songmid) return { artwork: fallback };
    try {
      const response = await axios.get(
        "https://c.y.qq.com/v8/fcg-bin/fcg_play_single_song.fcg",
        {
          params: { songmid, format: "json" },
          headers: { Referer: "https://y.qq.com/" },
          timeout: 10000,
        }
      );
      const d = (response.data && response.data.data && response.data.data[0]) || null;
      const albumMid = d && d.album && d.album.mid;
      if (albumMid) return { artwork: buildCoverUrl(albumMid) };
    } catch (e) {
      // 取不到封面不阻塞播放，回填原有封面
    }
    return { artwork: fallback };
  },

  /**
   * 获取 LRC 歌词
   * 同样需要把数字 songId 转成 songmid
   * v0.5.9：中转 lyric 失败时走官方 fcg_query_lyric_new 兜底（有歌词、无翻译）；
   * 翻译仍走 PlayLyricInfo；全失败返回 {rawLrc:""}，不抛错（用户无感）。
   */
  async getLyric(song) {
    // v0.5.7：空歌曲对象直接返回空歌词，不抛 TypeError
    if (!song || !song.id) {
      return { rawLrc: "" };
    }
    let songmid = song.id;
    if (/^\d+$/.test(String(songmid))) {
      const resolved = await resolveSongBySongId(song);
      if (resolved && resolved.songmid) {
        songmid = resolved.songmid;
      }
    }
    // 歌词走中转（原有逻辑），翻译走 QQ 官方 PlayLyricInfo，两路并行；
    // 翻译失败或无翻译不阻塞歌词。歌词接口也走重试（中转间歇空返回）。
    const [body, translation] = await Promise.all([
      callApiRetry(
        "lyric",
        { songmid },
        8000,
        (b) => !!(b.data && b.data.lyric)
      ).catch(() => null),
      fetchQQTranslation(songmid),
    ]);
    let rawLrc = "";
    if (body && body.result === 100 && body.data && body.data.lyric) {
      rawLrc = body.data.lyric;
    } else {
      // 兜底：官方 fcg_query_lyric_new（有歌词、无翻译）
      rawLrc = await fetchQQOfficialLyric(songmid);
    }
    if (!rawLrc) {
      return { rawLrc: "" };
    }
    const out = { rawLrc };
    if (translation) {
      out.translation = translation;
    }
    return out;
  },

  /**
   * 获取歌曲评论（v0.5.0 新增，原版没有这个方法）
   *
   * MusicFree 评论区调的就是这个方法，返回 { isEnd, data: [] }，
   * 每条评论是 { id, nickName, avatar, comment, like, createAt, location }。
   *
   * 注意：中转站也有 path=comment，但不分页（pagenum 传 0 和 1
   * 返回同一批），所以评论这里直连 QQ 官方评论接口
   * c.y.qq.com/base/fcgi-bin/fcg_global_comment_h5.fcg
   * （biztype=1 为歌曲，topid 为数字 songId，cmd=8 取评论）。
   * 第一页（pagenum=0）先放热门评论再接普通评论；翻页按 pagenum 接着拉。
   * v0.5.9：官方失败时走中转 comment 兜底（第一页，无翻页）；全失败返回空，不抛错。
   *
   * @param {{songId?: string, id?: string, title?: string, name?: string}} musicItem 歌曲对象
   * @param {number} page 页码（从 1 开始）
   */
  async getMusicComments(musicItem, page) {
    // v0.5.7：空对象直接返回空，不抛 TypeError
    if (!musicItem) {
      return { isEnd: true, data: [] };
    }
    const songId = await resolveNumericSongId(musicItem);
    if (!songId) {
      return { isEnd: true, data: [] };
    }
    const pageNo = page && page > 0 ? page : 1;
    const pagenum = pageNo - 1;
    const pagesize = 20;
    const params = {
      g_tk: "5381",
      loginUin: "0",
      hostUin: "0",
      format: "json",
      inCharset: "utf8",
      outCharset: "utf-8",
      notice: "0",
      platform: "yqq.json",
      needNewCode: "0",
      cid: "205360772",
      reqtype: "2",
      biztype: "1",
      topid: songId,
      cmd: "8",
      needmusiccrit: "0",
      pagenum: String(pagenum),
      pagesize: String(pagesize),
      lasthotcommentid: "",
      domain: "qq.com",
      ct: "24",
      cv: "10101010",
    };
    const query = Object.keys(params)
      .map(function (k) {
        return encodeURIComponent(k) + "=" + encodeURIComponent(params[k]);
      })
      .join("&");
    // 主路：官方评论接口
    try {
      const response = await axios.get(
        "https://c.y.qq.com/base/fcgi-bin/fcg_global_comment_h5.fcg?" + query,
        {
          headers: {
            Referer: "https://y.qq.com/",
            "User-Agent": UA,
          },
          timeout: 10000,
        }
      );
      const data = response.data || {};
      if (data.code === 0) {
        const commentObj = data.comment || {};
        const hotObj = data.hot_comment || {};
        const total = Number(commentObj.commenttotal || 0);
        let list = [];
        // 第一页先放热门评论
        if (pageNo === 1 && Array.isArray(hotObj.commentlist)) {
          list = list.concat(hotObj.commentlist.map(formatQQComment));
        }
        if (Array.isArray(commentObj.commentlist)) {
          list = list.concat(commentObj.commentlist.map(formatQQComment));
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
        // v0.5.4：滤掉内容为空的评论（疑似图片/表情类评论，昵称头像在、内容空白）
        const filtered = deduped.filter(
          (c) => c.comment && String(c.comment).trim() !== ""
        );
        const got = (commentObj.commentlist || []).length;
        return {
          isEnd: total > 0 ? pageNo * pagesize >= total : got < pagesize,
          data: filtered,
        };
      }
    } catch (e) {
      // 官方失败，落到中转兜底
    }
    // 兜底：中转 comment（第一页，无翻页；条目结构与官方一致）
    if (pageNo === 1) {
      try {
        const body = await callApi(
          "comment",
          { id: songId, pagenum: 0, pagesize },
          8000
        );
        const list = (body?.data?.comment?.commentlist) || [];
        const data = list
          .map(formatQQComment)
          .filter((c) => c.comment && String(c.comment).trim() !== "");
        if (data.length) {
          return { isEnd: true, data };
        }
      } catch (e) {
        // 兜底也失败，返回空
      }
    }
    return { isEnd: true, data: [] };
  },

  /**
   * 获取专辑详情（专辑下所有歌曲）
   * v0.5.9：主路中转 album/songs（带重试），失败时走 musicu AlbumSongList 兜底。
   * @param {{albumId?: string, id?: string, title?: string, artist?: string}} album
   */
  async getAlbumInfo(album) {
    const albumMid = album.albumId || album.id;
    // v0.5.7：走重试（中转间歇空返回）
    const body = await callApiRetry(
      "album/songs",
      { albummid: albumMid },
      10000,
      (b) => extractSongList(b).length > 0
    );
    if (body && body.result === 100) {
      const songs = extractSongList(body).map(normalizeSong).filter(Boolean);
      if (songs.length) {
        return {
          isEnd: true,
          albumItem: {
            id: String(albumMid),
            platform: PLATFORM,
            title: album.title || "未知专辑",
            artist: album.artist || "",
            description:
              body.data && body.data.total ? "共 " + body.data.total + " 首" : "",
          },
          musicList: songs,
        };
      }
    }
    // 兜底：musicu AlbumSongList（songInfo 归一化，封面/时长齐全）
    const fb = await fetchQQAlbumSongsOfficial(albumMid, 0, 100);
    if (fb && fb.data.length) {
      return {
        isEnd: fb.isEnd,
        albumItem: {
          id: String(albumMid),
          platform: PLATFORM,
          title: album.title || "未知专辑",
          artist: album.artist || "",
          description: "共 " + fb.data.length + " 首",
        },
        musicList: fb.data,
      };
    }
    return { isEnd: true, albumItem: {}, musicList: [] };
  },

  /**
   * 获取歌单详情：分页拉取歌单内歌曲
   * v0.5.9：主路中转 songlist（带重试），失败时走旧 DissInfo 兜底
   * （一次返回整张歌单，首翻页 isEnd=true；翻页无更多数据）。
   * @param {{id: string, title?: string, coverImg?: string, artwork?: string}} sheet
   * @param {number} page 页码（每页 30 条）
   */
  async getMusicSheetInfo(sheet, page) {
    const begin = ((page || 1) - 1) * 30;
    // v0.5.7：走重试（中转间歇空返回，实测 p1 曾 0 首、重试即 30 首）
    const body = await callApiRetry(
      "songlist",
      { id: sheet.id, begin, num: 30 },
      15000,
      (b) =>
        (b.data &&
          Array.isArray(b.data.songlist) &&
          b.data.songlist.length > 0) ||
        Number(b.data && (b.data.total || b.data.total_song_num) || 0) > 0
    );
    if (
      body &&
      body.result === 100 &&
      body.data &&
      Array.isArray(body.data.songlist) &&
      body.data.songlist.length
    ) {
      const songs = body.data.songlist.map(normalizeSong).filter(Boolean);
      const cover = buildCoverUrl(
        body.data.imgurl || body.data.diss_cover || body.data.picurl
      );
      const totalCount = Number(body.data.total || body.data.total_song_num || 0);
      const hasMore =
        body.data.hasmore === 1 ||
        (totalCount > 0 && begin + 30 < totalCount);

      return {
        isEnd: !hasMore,
        sheetItem: {
          id: String(sheet.id),
          platform: PLATFORM,
          title: body.data.dissname || sheet.title || "未知歌单",
          artist: (body.data.creator && body.data.creator.name) || "",
          coverImg: cover || sheet.coverImg,
          artwork: cover || sheet.artwork,
          description:
            body.data.introduction ||
            (totalCount ? "共 " + totalCount + " 首" : ""),
        },
        musicList: songs,
      };
    }
    // 兜底：旧 DissInfo（一次返回整张歌单；只给首翻页）
    if ((page || 1) === 1) {
      const fb = await fetchQQDissInfoOfficial(sheet.id);
      if (fb && fb.musicList.length) {
        return {
          isEnd: true,
          sheetItem: {
            id: String(sheet.id),
            platform: PLATFORM,
            title: fb.title || sheet.title || "未知歌单",
            artist: fb.artist || "",
            coverImg: fb.coverImg || sheet.coverImg,
            artwork: fb.coverImg || sheet.artwork,
            description: fb.description || "",
          },
          musicList: fb.musicList,
        };
      }
    }
    return { isEnd: true, musicList: [] };
  },

  /**
   * 获取歌手作品
   * v0.5.6：改按 total_song/total_album 算 isEnd，不再写死 true。
   * v0.5.9：中转失败时走官方搜歌/搜专辑按歌手名过滤兜底（musicu 歌手模块需登录，
   * 匿名调返回 500003；官方搜索可匿名）。
   * @param {{id: string, _singerMid?: string, artist?: {id: string}, name?: string}} artist 歌手对象
   * @param {number} page 页码
   * @param {string} category "album" 拉专辑，其他拉歌曲
   */
  async getArtistWorks(artist, page, category) {
    const singerMid =
      artist._singerMid || artist.id || (artist.artist && artist.artist.id) || "";
    if (!singerMid) {
      return { isEnd: true, data: [] };
    }
    const pageNo = page || 1;
    const pageSize = 20;
    const name = artist.name || artist.title || "";

    if (category === "album") {
      const body = await callSingerApi(
        "singer/album",
        { singermid: singerMid, pageNo, pageSize },
        undefined
      );
      const albums = extractSongList(body).map(normalizeAlbum).filter(Boolean);
      if (albums.length) {
        const total = Number((body && body.data && (body.data.total_album || body.data.total)) || 0);
        return {
          isEnd: total > 0 ? pageNo * pageSize >= total : albums.length < pageSize,
          data: albums,
        };
      }
      // 兜底：官方搜专辑按歌手名过滤
      if (name) {
        const fb = await searchOfficialQQ(name, pageNo, "album");
        if (fb && fb.data.length) {
          const mine = fb.data.filter((a) => String(a.artist || "") === name);
          return { isEnd: fb.isEnd, data: mine.length ? mine : fb.data };
        }
      }
      return { isEnd: true, data: [] };
    }

    const body = await callSingerApi(
      "singer/songs",
      { singermid: singerMid, num: pageSize, page: pageNo },
      undefined
    );
    const songs = extractSongList(body).map(normalizeSong).filter(Boolean);
    if (songs.length) {
      const total = Number((body && body.data && (body.data.total_song || body.data.total)) || 0);
      return {
        isEnd: total > 0 ? pageNo * pageSize >= total : songs.length < pageSize,
        data: songs,
      };
    }
    // 兜底：官方搜歌按歌手名过滤
    if (name) {
      const fb = await searchOfficialQQ(name, pageNo, "music");
      if (fb && fb.data.length) {
        const mine = fb.data.filter(
          (s) => String(s.artist || "").split(" / ")[0].trim() === name.trim()
        );
        return { isEnd: fb.isEnd, data: mine.length ? mine : fb.data };
      }
    }
    return { isEnd: true, data: [] };
  },

  /**
   * 获取歌手详情（v0.5.6 新增，原版没有）
   * 中转 singer/songs 自带 singer_brief（简介）+ singer_info.fans（粉丝数），
   * 再拉热门歌曲（musicList）与专辑（albumList）。接口失败时返回原对象
   * 兜底，不抛错，避免阻塞歌手页。
   * v0.5.9：中转失败时走官方搜歌手 + 搜歌拼热门歌曲兜底（简介/粉丝无官方
   * 匿名接口，降级、可接受）。
   * @param {{id?: string, _singerMid?: string, name?: string, avatar?: string, artist?: {id?: string}}} artistItem 歌手对象
   */
  async getArtistInfo(artistItem) {
    const singerMid =
      artistItem._singerMid || artistItem.id || (artistItem.artist && artistItem.artist.id) || "";
    if (!singerMid) {
      return artistItem || {};
    }
    try {
      const body = await callSingerApi(
        "singer/songs",
        { singermid: singerMid, num: 10, page: 1 },
        undefined
      );
      const data = (body && body.data) || {};
      const brief = typeof data.singer_brief === "string" ? data.singer_brief : "";
      const info = data.singer_info || {};
      const name = info.name || artistItem.name || artistItem.title || "未知歌手";
      const pic = buildCoverUrl(info.pic || "")
        .replace("150x150", "300x300")
        .replace("http://", "https://");
      const avatar = pic || artistItem.avatar || artistItem.artwork || "";
      const songs = extractSongList(body).map(normalizeSong).filter(Boolean);
      // 专辑列表（失败不阻塞）
      let albums = [];
      try {
        const ab = await callSingerApi(
          "singer/album",
          { singermid: singerMid, pageNo: 1, pageSize: 10 },
          undefined
        );
        albums = extractSongList(ab).map(normalizeAlbum).filter(Boolean);
      } catch (e) {
        albums = [];
      }
      if (brief || songs.length || (info && info.name)) {
        return {
          id: String(singerMid),
          platform: PLATFORM,
          name,
          title: name,
          artist: name,
          avatar,
          artwork: avatar,
          fans: Number(info.fans) || 0,
          description:
            brief ||
            ((data.total_song ? data.total_song + " 首歌曲" : "") +
              (data.total_album ? " · " + data.total_album + " 张专辑" : "")) ||
            artistItem.description ||
            "",
          musicList: songs.slice(0, 10),
          albumList: albums.slice(0, 10),
          _singerMid: String(singerMid),
        };
      }
    } catch (e) {
      // 中转失败，落到官方搜索兜底
    }
    // 兜底：官方搜歌手（头像）+ 搜歌（热门歌曲）
    const name = artistItem.name || artistItem.title || "";
    if (name) {
      try {
        const [artistsRes, songsRes] = await Promise.all([
          searchOfficialQQ(name, 1, "artist"),
          searchOfficialQQ(name, 1, "music"),
        ]);
        const found = (artistsRes && artistsRes.data && artistsRes.data[0]) || null;
        const songs = (songsRes && songsRes.data) || [];
        const mine = songs.filter(
          (s) => String(s.artist || "").split(" / ")[0].trim() === name.trim()
        );
        return {
          id: String((found && found.id) || singerMid),
          platform: PLATFORM,
          name: (found && found.name) || name,
          title: (found && found.name) || name,
          artist: (found && found.name) || name,
          avatar: (found && found.avatar) || artistItem.avatar || artistItem.artwork || "",
          artwork: (found && found.avatar) || artistItem.avatar || artistItem.artwork || "",
          fans: 0,
          description: artistItem.description || "",
          musicList: (mine.length ? mine : songs).slice(0, 10),
          albumList: [],
          _singerMid: String((found && found.id) || singerMid),
        };
      } catch (e) {
        // 兜底也失败，返回原对象
      }
    }
    return artistItem;
  },

  /**
   * 导入单曲
   * 支持两种输入：
   *   1. https://y.qq.com/n/ryqq/songDetail/0039MnYb0qxYhV → 抽出 songmid
   *   2. 纯 songmid 字符串（10~20 位字母数字）
   * v0.5.9：用 fcg_play_single_song 把占位元信息（"QQ音乐歌曲"）补成
   * 真标题/歌手/专辑/封面；失败仍返回占位，不抛错。
   * @param {string} input
   */
  async importMusicItem(input) {
    const text = String(input == null ? "" : input).trim();
    if (!text) {
      return null;
    }
    // 匹配 songDetail 路径里的 songmid，或退化匹配任意 10~20 位字母数字串
    const match =
      text.match(/songDetail[/=]([0-9A-Za-z]{10,20})/) ||
      text.match(/\b([0-9A-Za-z]{10,20})\b/);
    if (!match) {
      return null;
    }
    const songmid = match[1];
    const placeholder = {
      id: songmid,
      mediaId: songmid,
      platform: PLATFORM,
      title: "QQ音乐歌曲",
      artist: "",
      artwork: "",
    };
    // 补真元信息：官方 fcg_play_single_song（失败留占位，不抛错）
    try {
      const response = await axios.get(
        "https://c.y.qq.com/v8/fcg-bin/fcg_play_single_song.fcg",
        {
          params: { songmid, format: "json" },
          headers: { Referer: "https://y.qq.com/" },
          timeout: 8000,
        }
      );
      const d = (response.data?.data || [])[0];
      if (d && d.mid) {
        const singer = Array.isArray(d.singer)
          ? d.singer.map((s) => s && s.name).filter(Boolean).join(" / ")
          : "";
        const album = d.album && typeof d.album === "object" ? d.album : {};
        return {
          id: String(d.mid),
          songId: String(d.id || ""),
          mediaId: String(d.mid),
          platform: PLATFORM,
          title: d.name || "QQ音乐歌曲",
          artist: singer || "",
          album: album.name || "",
          albumId: String(album.mid || ""),
          duration: Number(d.interval || 0),
          artwork: buildCoverUrl(album.mid || ""),
        };
      }
    } catch (e) {
      // 补元信息失败，返回占位
    }
    return placeholder;
  },

  /**
   * 导入歌单 / 专辑
   * 通过多组正则识别输入是歌单 ID（纯数字）还是专辑 mid（字母数字）
   * 支持的 URL 形式：
   *   - /playlist/8075336924
   *   - /taoge.html?id=8075336924
   *   - /songlist/8075336924
   *   - /albumDetail/0039MnYb0qxYhV
   *   - /album.html?albumId=0039MnYb0qxYhV
   * 兜底：纯数字当歌单 ID，纯字母数字当专辑 mid
   * @param {string} input
   */
  async importMusicSheet(input) {
    const text = String(input == null ? "" : input).trim();
    if (!text) {
      return null;
    }

    let albumMid = null;
    let sheetId = null;

    // 一连串正则尝试匹配各种 URL 形式
    let m = text.match(/playlist[/=](\d{6,})/);
    if (m) sheetId = m[1];

    m = text.match(/taoge\.html[^#]*\bid=(\d{6,})/);
    if (m) sheetId = m[1];

    m = text.match(/songlist[/=](\d{6,})/);
    if (m) sheetId = m[1];

    m = text.match(/albumDetail[/=]([0-9A-Za-z]{10,20})/);
    if (m) albumMid = m[1];

    m = text.match(/album\.html[^#]*\balbumId=([0-9A-Za-z]{10,20})/);
    if (m) albumMid = m[1];

    // 兜底：没有明确 URL 标识时按格式推断
    if (!albumMid && !sheetId) {
      const numMatch = text.match(/\d{6,}/);
      const midMatch = text.match(/[0-9A-Za-z]{10,20}/);
      if (midMatch && !numMatch) {
        albumMid = midMatch[0];
      } else if (numMatch) {
        sheetId = numMatch[0];
      }
    }

    if (!albumMid && !sheetId) {
      return null;
    }

    // 走歌单接口
    if (sheetId) {
      // v0.5.7：走重试（中转间歇空返回）
      const body = await callApiRetry(
        "songlist",
        { id: sheetId },
        10000,
        (b) =>
          b.data &&
          Array.isArray(b.data.songlist) &&
          b.data.songlist.length > 0
      );
      if (
        body &&
        body.result === 100 &&
        body.data &&
        Array.isArray(body.data.songlist) &&
        body.data.songlist.length
      ) {
        return body.data.songlist.map(normalizeSong).filter(Boolean);
      }
      // v0.5.9 兜底：旧 DissInfo（一次返回整张歌单）
      const fb = await fetchQQDissInfoOfficial(sheetId);
      if (fb && fb.musicList.length) {
        return fb.musicList;
      }
      return null;
    }

    // 走专辑接口
    // v0.5.7：走重试（中转间歇空返回）
    const body = await callApiRetry(
      "album/songs",
      { albummid: albumMid },
      10000,
      (b) => extractSongList(b).length > 0
    );
    if (body && body.result === 100) {
      const songs = extractSongList(body).map(normalizeSong).filter(Boolean);
      if (songs.length) {
        return songs;
      }
    }
    // v0.5.9 兜底：musicu AlbumSongList
    const fb = await fetchQQAlbumSongsOfficial(albumMid, 0, 100);
    if (fb && fb.data.length) {
      return fb.data;
    }
    return null;
  },

  /**
   * 榜单分组列表：调用后端 top/category 拿到所有榜单分类
   * v0.5.9：中转失败时用内置主榜单兜底（topId 与旧榜单接口兼容）。
   */
  async getTopLists() {
    // v0.5.7：走重试（中转间歇空返回）
    const body = await callApiRetry(
      "top/category",
      undefined,
      undefined,
      (b) => Array.isArray(b.data) && b.data.length > 0
    );
    if (body && body.result === 100 && Array.isArray(body.data) && body.data.length) {
      return body.data.map((group) => ({
        title: group.title || "QQ音乐榜单",
        data: (group.list || []).map((top) => {
          const cover = buildCoverUrl(top.picUrl);
          return {
            id: String(top.topId),
            title: top.label || top.title || "未知榜单",
            coverImg: cover,
            artwork: cover,
            description:
              top.intro || (top.updateTime ? "更新于 " + top.updateTime : ""),
          };
        }),
      }));
    }
    // 兜底：内置主榜单
    return QQ_TOPLIST_FALLBACK;
  },

  /**
   * 榜单详情：拉取榜单内歌曲（每页 100 条）
   * v0.5.9：中转失败时走旧 fcg_v8_toplist_cp 兜底。
   * @param {{id: string|number, title?: string, coverImg?: string, description?: string}} top
   * @param {number} page 页码
   */
  async getTopListDetail(top, page) {
    // v0.5.7：走重试（中转间歇空返回）
    const body = await callApiRetry(
      "top",
      { id: top.id || 4, pageSize: 100, pageNo: page || 1 },
      undefined,
      (b) => Array.isArray(b.data && b.data.list) && b.data.list.length > 0
    );
    if (body && body.result === 100) {
      const data = body.data || {};
      const songs = (Array.isArray(data.list) ? data.list : [])
        .map(normalizeSong)
        .filter(Boolean);
      if (songs.length) {
        return {
          isEnd: true,
          topListItem: {
            id: String(top.id),
            platform: PLATFORM,
            title: top.title || (data.info && data.info.title) || "QQ音乐榜单",
            coverImg: top.coverImg || "",
            description: top.description || "",
          },
          musicList: songs,
        };
      }
    }
    // 兜底：旧 fcg_v8_toplist_cp（首翻页 100 条）
    if ((page || 1) === 1) {
      const fb = await fetchQQToplistOfficial(top.id || 4, 0, 100);
      if (fb && fb.data.length) {
        return {
          isEnd: true,
          topListItem: {
            id: String(top.id),
            platform: PLATFORM,
            title: top.title || "QQ音乐榜单",
            coverImg: top.coverImg || "",
            description: top.description || "",
          },
          musicList: fb.data,
        };
      }
    }
    return { isEnd: true, musicList: [] };
  },

  /**
   * 推荐歌单的分类标签
   * 调用 songlist/category，第一组作为 pinned（置顶标签），其余作为分组
   * 后端没有 pinned 时用 "热门" 兜底
   * v0.5.9：中转失败时用内置标签兜底。
   */
  async getRecommendSheetTags() {
    // v0.5.7：走重试（中转间歇空返回）
    const body = await callApiRetry(
      "songlist/category",
      undefined,
      undefined,
      (b) => Array.isArray(b.data) && b.data.length > 0
    );
    const categories =
      body && body.result === 100 && Array.isArray(body.data) ? body.data : [];

    if (categories.length) {
      const result = { pinned: [], data: [] };
      categories.forEach((cat, index) => {
        const tags = (cat.list || [])
          .map((t) => ({ id: String(t.id), title: t.name || "" }))
          .filter((t) => t.title);

        if (index === 0) {
          // 第一组作为置顶
          result.pinned = tags;
        } else if (tags.length) {
          result.data.push({
            title: cat.type || cat.title || "",
            data: tags,
          });
        }
      });

      if (!result.pinned.length) {
        result.pinned = [{ id: "10000000", title: "热门" }];
      }
      return result;
    }
    // 兜底：内置标签
    return QQ_SHEET_TAG_FALLBACK;
  },

  /**
   * 按标签拉取推荐歌单
   * v0.5.9：中转失败时走 fcg_get_diss_by_tag 兜底。
   * @param {{id?: string}} tag 标签对象
   * @param {number} page 页码（每页 20 条）
   */
  async getRecommendSheetsByTag(tag, page) {
    const categoryId = (tag && tag.id) || "10000000";
    // v0.5.7：走重试（中转间歇空返回）
    const body = await callApiRetry(
      "songlist/list",
      { category: categoryId, pageNo: page || 1, pageSize: 20, sort: 5 },
      undefined,
      (b) => extractSongList(b).length > 0
    );
    if (body && body.result === 100) {
      const sheets = extractSongList(body)
        .map(normalizeSheet)
        .filter(Boolean);
      if (sheets.length) {
        return { isEnd: sheets.length === 0, data: sheets };
      }
    }
    // 兜底：fcg_get_diss_by_tag
    const fb = await fetchQQDissByTagOfficial(categoryId, page || 1);
    if (fb) return fb;
    return { isEnd: true, data: [] };
  },
};
