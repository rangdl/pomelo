/**
 * kg.js — 风誰·酷狗 插件（风誰制作 · 二开专用版 v0.4.9）
 * ------------------------------------------------------------------
 * 风誰制作，仅供个人使用。
 * 本插件是在 Z·酷狗原版（wenshao 原作，Super Z 反编译）基础上
 * 二开而来：中转与播放沿用原版，另补了原版缺失的歌曲评论与
 * 歌单详情功能，并去掉 updateURL（防止被更新回原版）。
 * 适用宿主：MusicFree / 同类插件系统
 * 平台标识：风誰·酷狗
 * 原作者：wenshao（原始混淆版）
 * 反编译 + 变量重命名 + 注释 by Super Z
 * 二开：风誰
 * ------------------------------------------------------------------
 * 通过 ws.suol.cc/kg/kg.php 中转的酷狗概念版接口，支持：
 *   1. 关键字搜索歌曲
 *   2. 多音质播放（flac / 320 / 128）
 *   3. LRC 歌词获取
 *   4. 单曲元信息补全
 *   5. 推荐位：每日推荐 / 最近收听 / 我的云盘 / 我的歌单
 *   6. 歌单导入：支持 gcid / 歌单 ID / 分享短链三种形式
 *   7. 专辑详情：复用歌单接口（listid = albumId）
 *   8. 歌曲评论（v0.4.0 新增）：getMusicComments
 *   9. 歌单详情（v0.4.0 新增）：getMusicSheetInfo
 *  10. 歌词翻译（v0.4.4 新增）：getLyric 补 translation
 *  11. 时长单位修正（v0.4.5 新增）：中转给的 duration 是毫秒，统一转秒
 *  12. 歌手信息（v0.4.6 新增）：搜索歌手 + getArtistWorks + getArtistInfo
 * ------------------------------------------------------------------
 * v0.4.9 改动（2026-11-21）：修榜单无封面（用户实测发现）。
 *   根因：getTopLists 里每日推荐/最近收听/我的云盘从来没给 coverImg 字段，
 *   且插件根本没有真正的酷狗榜单；getTopListDetail 返回里也没有任何封面字段。
 *   现新增官方榜单：mobilecdn rank/list 一次拉全 55 个榜单（TOP500/飙升榜/
 *   热歌榜等，img_9 作封面，{size} 换 240、转 https），详情走 rank/song；
 *   每日推荐/云盘封面取列表首歌封面（云盘上传文件本身无封面时搜同首歌补），
 *   最近收听取首歌详情封面（失败留空不阻塞）。
 *   详情返回统一补 coverImg/artwork + sheetItem + topListItem。
 * v0.4.8 改动（2026-11-21）：兜底补全（用户无感标准）。
 *   兜底切换自动、要快、失败静默换下一条路；实在没路了返回空结果、不抛错打断用户；
 *   兜底返回的数据格式与主路一致（封面/时长/字段齐全）。
 *   1. 搜索：中转失败时走官方 song_search_v2 兜底（带封面 Image、时长秒、AlbumID，
 *      字段与中转结果一致；FileName/SingerName 里的 <em> 标签去掉）。
 *   2. 播放：中转失败时依次重试中转一次、降音质 128k、换 https 中转；全失败才报干净错误。
 *   3. 歌词：中转 lyric 失败时走官方 lyrics.kugou.com fmt=lrc 兜底（base64 解码即 LRC），
 *      再失败走 fmt=krc 解开转 LRC；翻译仍走 KRC。
 *   4. 评论：官方网关失败重试一次（最多 2 次）；全失败返回空，不抛错。
 *   5. 歌单/专辑详情/导入歌单：中转失败时走官方 mobilecdn special/song 兜底
 *      （listid 即 specialid；gcid 无官方对应接口，仍走中转）。
 *   6. 歌手作品（歌曲）：官方 singer/song 失败时走官方搜歌按歌手名过滤兜底；
 *      歌手详情：官方 singer/info 失败时走搜歌手 + 搜歌拼热门歌曲兜底。
 *   7. 单曲详情：中转失败时回填输入歌曲自身信息（标题/歌手/专辑/封面/时长），不返回 null。
 *   8. 推荐位/每日推荐/最近收听/云盘：中转调用加重试；getTopLists 网络失败也不抛错。
 *   9. 超时收紧：主路 10~15 秒、兜底 8 秒，切换不让用户久等。
 * v0.4.7 改动（2026-11-21）：修 search 对不支持的搜索类型返回歌曲——
 * search 只实现 music / artist，但 album / sheet 等类型会直接落到
 * 搜歌分支，把歌曲当专辑/歌单结果返回。现非 music 类型（artist 分支
 * 已提前返回）直接返回空，与网易云插件行为一致。
 * v0.4.6 改动（2026-11-21）：补歌手信息——原版没有 getArtistInfo，
 * 我们自己做。歌手搜索走酷狗官方 mobilecdn singer/search（中转只会
 * 搜歌）；歌手详情/作品走官方 singer/info、singer/song、singer/album。
 * 搜索结果本身没有头像，批量调 singer/info 补（失败留空，不阻塞搜索）。
 * 接口失败不崩，返回空或原对象兜底。
 * v0.4.5 改动（2026-11-21）：修 duration 单位——中转返回的 duration 是毫秒
 * （如 233000），而 MusicFree 协议要的是秒（233），之前直接透传导致时长
 * 显示成几千倍。搜索 / 单曲详情 / 云盘三处统一 Math.floor(ms / 1000)。
 * getLyric 查 KRC 时仍按酷狗歌词接口的原生单位（毫秒）传，翻译不受影响。
 * v0.4.4 改动（2026-11-21）：KRC 破解，翻译接上——之前以为标准异或+zlib
 * 解不开，实测是密钥后 4 字节错了。正确密钥 "@Gaw^2tGQ61-ÎÒni"（字节
 * [0x40,0x47,0x61,0x77,0x5e,0x32,0x74,0x47,0x51,0x36,0x31,0x2d,0xce,
 * 0xd2,0x6e,0x69]），跳过 "krc1" 头、异或、zlib 解压即得 KRC 文本；翻译在
 * [language:] 段（base64 JSON，取 type 为 1 的项，逐行与歌词时间戳对齐）。
 * 宿主环境没有 zlib，所以自带纯 JS 的 DEFLATE 解压器（RFC 1951）。
 * getLyric 现在返回 { rawLrc, translation }；KRC 拿不到或解不开时只返
 * 回歌词不带翻译，不影响正常显示。中文歌本来就没有翻译，返回空。
 * v0.4.3 改动（2026-11-21）：封面统一转 https——中转给的封面是 http://imge.kugou.com，
 * 实测 https 也能打开（200），转 https 更稳妥；搜索封面本身一直是正常的（中转直给）。
 * v0.4.2 改动（2026-11-21）：getMusicSheetInfo 补伪歌单 id 路由——每日推荐/最近收听/我的云盘
 *   以前走 playlist_songs 拿不到歌返回空，现复用 getTopListDetail 的专属逻辑（recom/history/cloud）。
 * v0.4.0 改动（2026-11-21）：
 *   - 新增 getMusicComments：原版没有这个方法，MusicFree 评论区
 *     一直是空的。中转站也没实现评论接口（action=comment 返回
 *     400“unknown action: comment”），所以评论走酷狗官方网关
 *     gateway.kugou.com（x-router: m.comment.service.kugou.com），
 *     带 MD5 签名 key（纯 JS 实现），实测能返回真实评论。
 *   - 新增 getMusicSheetInfo：原版没有，打开已保存/导入的歌单时
 *     用得上；复用歌单接口 playlist_songs / playlist_gcid。
 *   - 去掉 updateURL（原值 http://ws.suol.cc/qq/kg.js 路径可疑，
 *     且私有版不应被更新回原版）。
 *   - 注：第 189 行“尝试拉取用户歌单”注释在文件里本身是干净的
 *     UTF-8，之前看到的乱码只是浏览器渲染问题，无需改。
 *   - 搜索分页：中转搜索不支持 page 参数（page=2 返回与第 1 页
 *     相同结果），这是后端限制，插件侧无法解决，搜索仍为单页 20 条。
 * 后端约定：返回体 { code: 0, data: ... } 表示成功
 * 后端 baseUrl: http://ws.suol.cc/kg/kg.php
 *
 */

const axios = require("axios");

// 后端代理基础地址
const BASE_URL = "http://ws.suol.cc/kg/kg.php";
const API = BASE_URL;

// 酷狗官方移动端接口（歌手信息用，中转只会搜歌）
// singer/search、singer/info、singer/song、singer/album 均无需登录
const KG_MOBILE = "http://mobilecdn.kugou.com/api/v3";

// 播放时需要带上的 UA 与 Referer
const UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/134.0 Safari/537.36";

/** 图片地址统一转 https（v0.4.3：中转给 http，实测 https 也通，转 https 更稳妥） */
function toHttps(u) {
  return String(u || "").replace("http://", "https://");
}

// ------------------------------------------------------------------
// KRC 歌词解密（v0.4.4 新增）：酷狗官方歌词接口的 KRC 文件里含翻译，
// 但它是加密压缩过的。解开它才能拿到翻译。
//
// 格式（公开实现对照验证）：文件以 "krc1" 开头（4 字节），后面是
// XOR 加密过的 zlib 数据。XOR 密钥 16 字节 "@Gaw^2tGQ61-ÎÒni"
// （字节 [0x40,0x47,0x61,0x77,0x5e,0x32,0x74,0x47,0x51,0x36,
// 0x31,0x2d,0xce,0xd2,0x6e,0x69]）。
// 注意：之前用的密钥后 4 字节是错的（0xce,0x32,0x2a,0x3f），
// 所以前 12 字节能对上 zlib 头、后面却解不开——密钥错在第 13~16 位。
// 解开后是 KRC 文本，翻译在 [language:...] 段里（base64 的 JSON，
// 取 type 为 1 的那一项，lyricContent 的每一行对应一句歌词的翻译）。
// 宿主环境没有 zlib，所以这里自带一个纯 JS 的 DEFLATE 解压器（RFC 1951）。
// ------------------------------------------------------------------

/** KRC 的 XOR 密钥（16 字节） */
const KRC_KEY = [
  0x40, 0x47, 0x61, 0x77, 0x5e, 0x32, 0x74, 0x47,
  0x51, 0x36, 0x31, 0x2d, 0xce, 0xd2, 0x6e, 0x69,
];

/** base64 解码（不依赖环境自带 atob，自己实现才稳妥） */
function krcB64Decode(str) {
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

/** DEFLATE 解压（RFC 1951，纯 JS 实现；输入是去掉 zlib 头的原始 deflate 流） */
function krcInflate(data) {
  const LEN_BASE = [3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258];
  const LEN_EXT = [0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0];
  const DIST_BASE = [1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577];
  const DIST_EXT = [0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13];
  let pos = 0;
  let bitBuf = 0;
  let bitCnt = 0;
  function bits(n) {
    while (bitCnt < n) {
      bitBuf |= data[pos++] << bitCnt;
      bitCnt += 8;
    }
    const v = bitBuf & ((1 << n) - 1);
    bitBuf >>>= n;
    bitCnt -= n;
    return v;
  }
  // 按码长建规范 Huffman 表
  function build(lengths) {
    let maxBits = 0;
    for (const l of lengths) if (l > maxBits) maxBits = l;
    const blCount = new Array(maxBits + 1).fill(0);
    for (const l of lengths) if (l) blCount[l]++;
    const nextCode = new Array(maxBits + 1).fill(0);
    let code = 0;
    for (let b = 1; b <= maxBits; b++) {
      code = (code + blCount[b - 1]) << 1;
      nextCode[b] = code;
    }
    const table = Object.create(null);
    for (let i = 0; i < lengths.length; i++) {
      const len = lengths[i];
      if (len) {
        table[len + ":" + nextCode[len]] = i;
        nextCode[len]++;
      }
    }
    return { table, maxBits };
  }
  function decode(huff) {
    let code = 0;
    let len = 0;
    for (;;) {
      code = (code << 1) | bits(1);
      len++;
      const sym = huff.table[len + ":" + code];
      if (sym !== undefined) return sym;
      if (len > huff.maxBits) throw new Error("bad huffman code");
    }
  }
  const out = [];
  for (;;) {
    const bfinal = bits(1);
    const btype = bits(2);
    if (btype === 0) {
      // 存储块：对齐到字节边界，直接抄
      bitBuf = 0;
      bitCnt = 0;
      const len = data[pos] | (data[pos + 1] << 8);
      pos += 4;
      for (let i = 0; i < len; i++) out.push(data[pos++]);
    } else {
      let litHuff;
      let distHuff;
      if (btype === 1) {
        // 固定 Huffman 表
        const litLen = new Array(288).fill(0);
        for (let i = 0; i < 144; i++) litLen[i] = 8;
        for (let i = 144; i < 256; i++) litLen[i] = 9;
        for (let i = 256; i < 280; i++) litLen[i] = 7;
        for (let i = 280; i < 288; i++) litLen[i] = 8;
        litHuff = build(litLen);
        distHuff = build(new Array(30).fill(5));
      } else if (btype === 2) {
        // 动态 Huffman 表
        const hlit = bits(5) + 257;
        const hdist = bits(5) + 1;
        const hclen = bits(4) + 4;
        const order = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];
        const clLen = new Array(19).fill(0);
        for (let i = 0; i < hclen; i++) clLen[order[i]] = bits(3);
        const clHuff = build(clLen);
        const total = hlit + hdist;
        const lengths = new Array(total).fill(0);
        let i = 0;
        while (i < total) {
          const sym = decode(clHuff);
          if (sym < 16) {
            lengths[i++] = sym;
          } else if (sym === 16) {
            const rep = bits(2) + 3;
            const prev = lengths[i - 1];
            for (let j = 0; j < rep; j++) lengths[i++] = prev;
          } else if (sym === 17) {
            const rep = bits(3) + 3;
            for (let j = 0; j < rep; j++) lengths[i++] = 0;
          } else {
            const rep = bits(7) + 11;
            for (let j = 0; j < rep; j++) lengths[i++] = 0;
          }
        }
        litHuff = build(lengths.slice(0, hlit));
        distHuff = build(lengths.slice(hlit));
      } else {
        throw new Error("bad btype " + btype);
      }
      for (;;) {
        const sym = decode(litHuff);
        if (sym === 256) break; // 块结束
        if (sym < 256) {
          out.push(sym);
        } else {
          const li = sym - 257;
          const len = LEN_BASE[li] + bits(LEN_EXT[li]);
          const dsym = decode(distHuff);
          const dist = DIST_BASE[dsym] + bits(DIST_EXT[dsym]);
          for (let j = 0; j < len; j++) out.push(out[out.length - dist]);
        }
      }
    }
    if (bfinal) break;
  }
  return new Uint8Array(out);
}

/** 把 Uint8Array 按 UTF-8 解成字符串（不依赖 TextDecoder，自己实现才稳妥） */
function krcUtf8Decode(bytes) {
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

/** 解开 KRC（输入是下载接口返回的 base64 content），返回 KRC 文本 */
function krcDecode(b64) {
  const raw = krcB64Decode(b64);
  if (raw[0] !== 0x6b || raw[1] !== 0x72 || raw[2] !== 0x63 || raw[3] !== 0x31) {
    throw new Error("bad krc1 magic");
  }
  const body = raw.slice(4);
  const xored = new Uint8Array(body.length);
  for (let i = 0; i < body.length; i++) xored[i] = body[i] ^ KRC_KEY[i % 16];
  // zlib 包：2 字节头 + deflate 流 + 4 字节校验，跳过头 2 字节解 deflate
  const text = krcInflate(xored.slice(2));
  return krcUtf8Decode(text).replace(/^\uFEFF/, "");
}

/** 从解开的 KRC 文本里提取翻译，拼成带时间戳的 LRC 串（与原歌词行一一对应） */
function krcExtractTranslation(krcText) {
  const m = krcText.match(/\[language:([^\]]+)\]/);
  if (!m) return "";
  let lang;
  try {
    lang = JSON.parse(krcUtf8Decode(krcB64Decode(m[1])));
  } catch (e) {
    return "";
  }
  const trans = (lang.content || []).find((e) => e.type === 1);
  if (!trans || !trans.lyricContent) return "";
  const rows = trans.lyricContent;
  const starts = [];
  const re = /^\[(\d+),(\d+)\]/gm;
  let mm;
  while ((mm = re.exec(krcText)) !== null) starts.push(+mm[1]);
  const out = [];
  rows.forEach((row, i) => {
    const t = (row || []).join("").trim();
    if (t && starts[i] !== undefined) {
      const ms = starts[i];
      const min = String(Math.floor(ms / 60000)).padStart(2, "0");
      const sec = String(Math.floor(ms / 1000) % 60).padStart(2, "0");
      const cs = String(Math.floor((ms % 1000) / 10)).padStart(2, "0");
      out.push("[" + min + ":" + sec + "." + cs + "]" + t);
    }
  });
  return out.join("\n");
}

/**
 * 音质映射：把宿主统一的音质档位转成酷狗后端识别的字符串
 */
const QUALITY_MAP = {
  super: "flac",
  high: "320",
  standard: "128",
  low: "128",
};

/**
 * 把后端返回的歌曲原始对象归一化成 MusicFree 通用结构
 * 处理点：
 *   1. title 可能是 "歌手 - 歌名" 形式，需要拆分
 *   2. title 末尾可能带 .mp3 / .flac 等扩展名，去掉
 *   3. 字段名兼容：name / filename / artist / singer / cover / pic
 * @param {object} raw 后端原始歌曲对象
 * @returns {object} 归一化后的歌曲对象
 */
function normalizeSong(raw) {
  let title = String(raw.name || raw.filename || "未知歌曲").trim();
  let artist = raw.artist || raw.singer || "";

  // 拆 "歌手 - 歌名"
  const splitMatch = title.match(/^(.+?)\s*-\s*(.+)$/);
  if (splitMatch && (splitMatch[1].trim() === artist || !artist)) {
    if (!artist) {
      artist = splitMatch[1].trim();
    }
    title = splitMatch[2].trim();
  }

  // 去掉文件扩展名
  title = title.replace(/\.(mp3|flac|wav|m4a|aac|ogg|ape)$/i, "");

  return {
    id: String(raw.id || ""),
    platform: "风誰·酷狗",
    title: title || "未知歌曲",
    artist: artist || "未知歌手",
    album: raw.album || "",
    artwork: toHttps(raw.cover || raw.pic),
    // v0.4.5：中转给的 duration 是毫秒，MusicFree 协议要秒，统一转秒
    duration: Math.floor((raw.duration || 0) / 1000),
  };
}

/**
 * 把酷狗歌手搜索结果归一化成 MusicFree IArtistItem
 * 歌手搜索只给 singername + singerid，没有头像，头像在 getArtistInfo /
 * 搜索批量补头像时再填（失败留空）。
 * @param {object} raw {singername, singerid}
 * @returns {object} IArtistItem
 */
function formatKugouArtist(raw) {
  const name = raw.singername || "未知歌手";
  return {
    id: String(raw.singerid || ""),
    platform: "风誰·酷狗",
    name,
    title: name,
    avatar: "",
    artwork: "",
    description: "",
    _singerId: String(raw.singerid || ""),
  };
}

/**
 * 把酷狗歌手作品接口的歌曲归一化（filename 是 "歌手 - 歌名"）
 * singer/song 返回的字段与中转搜索不同：hash 是主键，duration 已是秒。
 * @param {object} raw singer/song 的歌曲对象
 * @param {string} fallbackArtist 歌手名（filename 里没歌手时用）
 * @returns {object} 归一化后的歌曲对象
 */
function normalizeKugouSingerSong(raw, fallbackArtist) {
  let title = String(raw.filename || raw.songname || "未知歌曲").trim();
  let artist = fallbackArtist || "";
  const splitMatch = title.match(/^(.+?)\s*-\s*(.+)$/);
  if (splitMatch) {
    if (!artist) artist = splitMatch[1].trim();
    title = splitMatch[2].trim();
  }
  title = title.replace(/\.(mp3|flac|wav|m4a|aac|ogg|ape)$/i, "");
  return {
    id: String(raw.hash || ""),
    platform: "风誰·酷狗",
    title: title || "未知歌曲",
    artist: artist || "未知歌手",
    album: raw.album_name || "",
    artwork: "",
    duration: Math.floor(Number(raw.duration) || 0),
  };
}

/**
 * 酷狗官方 singer/info 只拉头像（搜索批量补头像用）
 * 失败返回 ""，不抛错。
 * @param {string|number} singerId 酷狗 singerid
 * @returns {Promise<string>} 头像 URL（https），失败返回 ""
 */
async function fetchKugouSingerAvatar(singerId) {
  try {
    const response = await axios.get(KG_MOBILE + "/singer/info", {
      params: { singerid: singerId },
      timeout: 8000,
    });
    const img = response.data && response.data.data && response.data.data.imgurl;
    // imgurl 里带 {size} 占位符，换成 240 才是真实地址
    return toHttps((img || "").replace("{size}", "240"));
  } catch (e) {
    return "";
  }
}

// ============== 兜底接口（v0.4.8 新增，用户无感标准） ==============
// 中转挂了时走官方接口，失败静默换路、全失败返回空、不抛错。
// 兜底返回的数据格式与主路一致（封面/时长/字段齐全）。

/** 去掉 song_search_v2 返回里的 <em> 高亮标签 */
function stripEm(str) {
  return String(str || "").replace(/<\/?em>/gi, "");
}

/**
 * 把 song_search_v2 的歌曲归一化（官方搜索兜底用）
 * 字段：FileHash / FileName（带 <em>，形如“歌手 - 歌名”）/ SingerName /
 * AlbumName / AlbumID / Duration（秒，已是秒不用除 1000）/ Image（带 {size} 占位符）
 */
function normalizeOfficialKugouSong(raw) {
  let title = stripEm(raw.FileName || "").trim();
  let artist = stripEm(raw.SingerName || "");
  const splitMatch = title.match(/^(.+?)\s*-\s*(.+)$/);
  if (splitMatch) {
    if (!artist) artist = splitMatch[1].trim();
    title = splitMatch[2].trim();
  }
  title = title.replace(/\.(mp3|flac|wav|m4a|aac|ogg|ape)$/i, "");
  return {
    id: String(raw.FileHash || ""),
    platform: "风誰·酷狗",
    title: title || "未知歌曲",
    artist: artist || "未知歌手",
    album: stripEm(raw.AlbumName || ""),
    artwork: toHttps((raw.Image || "").replace("{size}", "240")),
    duration: Math.floor(Number(raw.Duration) || 0), // 官方搜索给的已是秒
  };
}

/**
 * 把 special/song 的歌曲归一化（歌单/专辑兜底用）
 * 字段：hash / filename（“歌手 - 歌名”）/ duration（秒）；无封面、无专辑名
 */
function normalizeOfficialKugouSpecialSong(raw) {
  let title = String(raw.filename || "").trim();
  let artist = "";
  const splitMatch = title.match(/^(.+?)\s*-\s*(.+)$/);
  if (splitMatch) {
    artist = splitMatch[1].trim();
    title = splitMatch[2].trim();
  }
  title = title.replace(/\.(mp3|flac|wav|m4a|aac|ogg|ape)$/i, "");
  return {
    id: String(raw.hash || ""),
    platform: "风誰·酷狗",
    title: title || "未知歌曲",
    artist: artist || "未知歌手",
    album: raw.album_name || "",
    artwork: "",
    duration: Math.floor(Number(raw.duration) || 0), // 已是秒
  };
}

/**
 * 官方搜歌兜底（v0.4.8 新增）
 * song_search_v2：带封面 Image、时长秒、AlbumID，字段与中转结果一致。
 * 失败返回 null，不抛错。
 * @param {string} keyword 关键字
 * @param {number} page 页码（从 1 开始）
 * @returns {Promise<{isEnd: boolean, data: Array} | null>}
 */
async function searchOfficialKugouSong(keyword, page) {
  try {
    const response = await axios.get("https://songsearch.kugou.com/song_search_v2", {
      params: {
        keyword,
        page: page || 1,
        pagesize: 20,
        userid: 0,
        clientver: "",
        platform: "WebFilter",
        tag: "em",
        filter: 2,
        iscorrection: 1,
        privilege_filter: 0,
      },
      timeout: 8000,
    });
    const lists = (response.data?.data?.lists) || [];
    const total = Number(response.data?.data?.total || 0);
    const data = lists.map(normalizeOfficialKugouSong).filter((s) => s.id);
    return {
      isEnd: total > 0 ? (page || 1) * 20 >= total : data.length < 20,
      data,
    };
  } catch (e) {
    return null;
  }
}

/**
 * 把 KRC 文本转成 LRC（歌词兜底用）
 * KRC 行格式：[开始毫秒,持续毫秒]歌词；转成 [mm:ss.cc]歌词。
 * @param {string} krcText 解开后的 KRC 文本
 * @returns {string} LRC 文本
 */
function krcToLrc(krcText) {
  const out = [];
  const re = /\[(\d+),\d+\]([^\n\r]*)/g;
  let m;
  while ((m = re.exec(krcText)) !== null) {
    const ms = Number(m[1]);
    const text = (m[2] || "").trim();
    if (!text) continue;
    const min = String(Math.floor(ms / 60000)).padStart(2, "0");
    const sec = String(Math.floor(ms / 1000) % 60).padStart(2, "0");
    const cs = String(Math.floor((ms % 1000) / 10)).padStart(2, "0");
    out.push("[" + min + ":" + sec + "." + cs + "]" + text);
  }
  return out.join("\n");
}

/**
 * 官方歌词兜底（v0.4.8 新增）
 * lyrics.kugou.com search + download：fmt=lrc 直接给 base64 的 LRC；
 * 拿不到 lrc 时改下 fmt=krc，解开再转 LRC。失败返回 ""，不抛错。
 * @param {{id: string}} song 歌曲对象（id 为酷狗 hash）
 * @returns {Promise<string>} LRC 文本，无歌词返回 ""
 */
async function fetchKugouLyricOfficial(song) {
  try {
    const searchRes = await axios.get("https://lyrics.kugou.com/search", {
      params: { ver: 1, man: "yes", client: "pc", hash: song.id },
      timeout: 8000,
    });
    const cands = searchRes.data && searchRes.data.candidates;
    if (!cands || !cands.length) return "";
    const cand = cands[0];
    // 先试 fmt=lrc（直接给 base64 的 LRC）
    try {
      const dlRes = await axios.get("https://lyrics.kugou.com/download", {
        params: { ver: 1, client: "pc", id: cand.id, accesskey: cand.accesskey, fmt: "lrc", charset: "utf8" },
        timeout: 8000,
      });
      const dl = dlRes.data;
      if (dl && dl.status === 200 && dl.content) {
        const text = krcUtf8Decode(krcB64Decode(dl.content)).replace(/^\uFEFF/, "");
        if (text.trim()) return text;
      }
    } catch (e) {
      // lrc 失败，落到 krc
    }
    // 再试 fmt=krc（解开转 LRC）
    try {
      const dlRes = await axios.get("https://lyrics.kugou.com/download", {
        params: { ver: 1, client: "pc", id: cand.id, accesskey: cand.accesskey, fmt: "krc", charset: "utf8" },
        timeout: 8000,
      });
      const dl = dlRes.data;
      if (dl && dl.status === 200 && dl.content) {
        return krcToLrc(krcDecode(dl.content));
      }
    } catch (e) {
      // krc 也失败，返回空
    }
    return "";
  } catch (e) {
    return "";
  }
}

/**
 * 官方歌单/专辑歌曲兜底（v0.4.8 新增）
 * mobilecdn special/song：listid 即 specialid；gcid 无官方对应接口，返回 null。
 * 失败返回 null，不抛错。
 * @param {string} listid 歌单/专辑 id（数字）
 * @param {number} page 页码（从 1 开始）
 * @param {number} pagesize 每页条数
 * @returns {Promise<{isEnd: boolean, data: Array} | null>}
 */
async function fetchKugouSpecialSongs(listid, page, pagesize) {
  if (!/^\d+$/.test(String(listid || ""))) return null;
  try {
    const response = await axios.get(KG_MOBILE + "/special/song", {
      params: { format: "json", specialid: listid, page: page || 1, pagesize: pagesize || 50 },
      timeout: 8000,
    });
    const d = (response.data && response.data.data) || {};
    const list = Array.isArray(d.info) ? d.info : [];
    const total = Number(d.total) || 0;
    const data = list.map(normalizeOfficialKugouSpecialSong).filter((s) => s.id);
    return {
      isEnd: total > 0 ? (page || 1) * (pagesize || 50) >= total : data.length < (pagesize || 50),
      data,
    };
  } catch (e) {
    return null;
  }
}

/**
 * 云盘封面解析（v0.4.9 新增）
 * 云盘是用户上传文件，中转不给封面（cover 全空）。取列表前 3 首歌名+歌手
 * 走官方 song_search_v2 搜同首歌，用搜到那版的封面当云盘封面；搜不到留空，不阻塞。
 * @param {Array} songs user_cloud 原始歌曲数组
 * @returns {Promise<string>} 封面 URL（https），失败返回 ""
 */
async function resolveKgCloudCover(songs) {
  try {
    const list = Array.isArray(songs) ? songs : [];
    for (const raw of list.slice(0, 3)) {
      const norm = normalizeSong(raw);
      const title = String(norm.title || "").replace(/未知歌曲/g, "").trim();
      const artist = String(norm.artist || "").replace(/未知歌手/g, "").trim();
      if (!title) continue;
      const keyword = artist ? title + " " + artist : title;
      const res = await searchOfficialKugouSong(keyword, 1);
      const hit = res && Array.isArray(res.data) ? res.data[0] : null;
      if (hit && hit.artwork) return hit.artwork;
    }
  } catch (e) {
    // 搜不到/失败留空，不阻塞
  }
  return "";
}

/**
 * 酷狗官方榜单列表（v0.4.9 新增）
 * mobilecdn rank/list：注意必须走 HTTP（HTTPS 返回空），图片再转 https。
 * 每条含 rankid / rankname / img_9（或 img_cover，带 {size} 占位）。
 * 失败返回 []，不抛错。
 * @returns {Promise<Array<{id: string, title: string, description: string, coverImg: string, artwork: string}>>}
 */
async function fetchKgRankList() {
  try {
    const response = await axios.get(KG_MOBILE + "/rank/list", {
      params: { version: 9108, plat: 0 },
      timeout: 8000,
    });
    const info = (response.data && response.data.data && response.data.data.info) || [];
    return info
      .filter((r) => r && r.rankid && r.rankname)
      .map((r) => {
        const cover = toHttps(String(r.img_9 || r.img_cover || "").replace("{size}", "240"));
        return {
          id: "rank:" + String(r.rankid),
          title: r.rankname,
          description: "酷狗音乐榜单" + (r.update_frequency ? " · " + r.update_frequency : ""),
          coverImg: cover,
          artwork: cover,
        };
      });
  } catch (e) {
    return [];
  }
}

/**
 * 酷狗官方榜单歌曲（v0.4.9 新增）
 * mobilecdn rank/song：同样走 HTTP；每页 100 条。
 * 失败返回 null，不抛错。
 * @param {string|number} rankid 榜单 id
 * @param {number} page 页码（从 1 开始）
 * @returns {Promise<{total: number, data: Array} | null>}
 */
async function fetchKgRankSongs(rankid, page) {
  try {
    const response = await axios.get(KG_MOBILE + "/rank/song", {
      params: { rankid, page: page || 1, pagesize: 100, version: 9108, plat: 0 },
      timeout: 10000,
    });
    const d = (response.data && response.data.data) || {};
    const list = Array.isArray(d.info) ? d.info : [];
    return { total: Number(d.total) || 0, data: list.map(normalizeRankSong).filter((s) => s.id) };
  } catch (e) {
    return null;
  }
}

/**
 * 把 rank/song 的歌曲归一化（v0.4.9 新增）
 * rank/song 字段：hash / songname / authors[].author_name / duration（秒）/
 * album_sizable_cover（带 {size} 占位）。转成 normalizeSong 能认的形状
 * （duration 按毫秒传，内部统一转秒；封面 {size} 换 240）。
 * @param {object} s rank/song 原始歌曲对象
 * @returns {object} 归一化后的歌曲对象
 */
function normalizeRankSong(s) {
  return normalizeSong({
    id: s.hash || "",
    name: s.songname || "",
    artist: (s.authors || []).map((a) => a.author_name).filter(Boolean).join("/"),
    cover: String(s.album_sizable_cover || "").replace("{size}", "240"),
    duration: (s.duration || 0) * 1000,
    album: "",
  });
}

/**
 * 给榜单/推荐位详情返回统一补封面字段（v0.4.9 新增）
 * 宿主可能读顶层 coverImg、sheetItem.artwork、topListItem.coverImg 任一字段，
 * 三处都给。封面优先用列表传来的 coverImg，其次取首歌封面，都没有就留空。
 * @param {object} sheet 列表传来的榜单对象
 * @param {Array} musicList 歌曲列表
 * @param {object} extra 额外字段（如 isEnd）
 * @returns {object} 补好封面的详情返回体
 */
function withKgTopCover(sheet, musicList, extra) {
  const firstArt = (musicList && musicList[0] && musicList[0].artwork) || "";
  const cover = toHttps(sheet.coverImg || sheet.artwork || "") || firstArt;
  const title = sheet.title || "酷狗榜单";
  const id = String(sheet.id || "");
  const description = sheet.description || "";
  return Object.assign(
    {
      title,
      id,
      description,
      coverImg: cover,
      artwork: cover,
      sheetItem: { title, artwork: cover, coverImg: cover, description },
      topListItem: { id, platform: "风誰·酷狗", title, coverImg: cover, description },
      musicList: musicList || [],
    },
    extra || {}
  );
}

/**
 * 中转调用带一次重试（v0.4.8 新增）
 * 中转间歇失败时静默重试一次（间隔 600ms），再失败返回 null，不抛错。
 * @param {object} params 中转请求参数
 * @param {number} timeout 超时（毫秒）
 * @returns {Promise<object|null>} 中转返回体，失败返回 null
 */
async function callKgProxy(params, timeout) {
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const response = await axios.get(API, { params, timeout: timeout || 10000 });
      return response.data;
    } catch (e) {
      if (attempt === 0) {
        await new Promise((r) => setTimeout(r, 600));
      }
    }
  }
  return null;
}

// ============== 酷狗评论（纯 JS MD5 签名） ==============
// 评论走酷狗官方网关 gateway.kugou.com（x-router 指到评论服务），
// key = MD5(appid + salt + clientver + clienttime)，概念版用 lite 参数。
// MD5 是纯 JS 实现（RFC 1321），因 MusicFree 插件只允许 require("axios")。
// 已验证：与 Node crypto 的 MD5 逐字节一致；带该 key 调真接口返回真实评论。
const KG_CMT_APPID = "3116";
const KG_CMT_CLIENTVER = "11440";
const KG_CMT_SALT = "LnT6xpN3khm36zse0QzvmgTZ3waWdRSA";
const KG_CMT_GATEWAY = "https://gateway.kugou.com/index.php";
const KG_CMT_ROUTER = "m.comment.service.kugou.com";
const KG_CMT_CODE = "articulossong";

function md5Ascii(input) {
  function rl(n, c) { return (n << c) | (n >>> (32 - c)); }
  function add(x, y) {
    const l = (x & 0xffff) + (y & 0xffff);
    const m = (x >> 16) + (y >> 16) + (l >> 16);
    return (m << 16) | (l & 0xffff);
  }
  function f(x, y, z) { return (x & y) | (~x & z); }
  function g(x, y, z) { return (x & z) | (y & ~z); }
  function h(x, y, z) { return x ^ y ^ z; }
  function ii2(x, y, z) { return y ^ (x | ~z); }
  function ff(a, b, c, d, x, s, ac) { a = add(a, add(add(f(b, c, d), x), ac)); return add(rl(a, s), b); }
  function gg(a, b, c, d, x, s, ac) { a = add(a, add(add(g(b, c, d), x), ac)); return add(rl(a, s), b); }
  function hh(a, b, c, d, x, s, ac) { a = add(a, add(add(h(b, c, d), x), ac)); return add(rl(a, s), b); }
  function ii(a, b, c, d, x, s, ac) { a = add(a, add(add(ii2(b, c, d), x), ac)); return add(rl(a, s), b); }
  const msg = [];
  for (let n = 0; n < input.length; n++) msg.push(input.charCodeAt(n) & 0xff);
  const bitLen = input.length * 8;
  msg.push(0x80);
  while (msg.length % 64 !== 56) msg.push(0);
  for (let n = 0; n < 8; n++) msg.push((bitLen / Math.pow(2, n * 8)) & 0xff);
  let a0 = 0x67452301, b0 = 0xefcdab89, c0 = 0x98badcfe, d0 = 0x10325476;
  const K = [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
  ];
  const S = [7,12,17,22, 7,12,17,22, 7,12,17,22, 7,12,17,22,
             5,9,14,20, 5,9,14,20, 5,9,14,20, 5,9,14,20,
             4,11,16,23, 4,11,16,23, 4,11,16,23, 4,11,16,23,
             6,10,15,21, 6,10,15,21, 6,10,15,21, 6,10,15,21];
  for (let off = 0; off < msg.length; off += 64) {
    const M = [];
    for (let j = 0; j < 16; j++) {
      M[j] = msg[off + j * 4] | (msg[off + j * 4 + 1] << 8) | (msg[off + j * 4 + 2] << 16) | (msg[off + j * 4 + 3] << 24);
    }
    let a = a0, b = b0, c = c0, d = d0;
    for (let j = 0; j < 64; j++) {
      let f2, gi;
      if (j < 16) { f2 = f(b, c, d); gi = j; }
      else if (j < 32) { f2 = g(b, c, d); gi = (5 * j + 1) % 16; }
      else if (j < 48) { f2 = h(b, c, d); gi = (3 * j + 5) % 16; }
      else { f2 = ii2(b, c, d); gi = (7 * j) % 16; }
      const tmp = d; d = c; c = b;
      const sum = add(add(a, f2), add(K[j], M[gi]));
      b = add(b, rl(sum, S[j]));
      a = tmp;
    }
    a0 = add(a0, a); b0 = add(b0, b); c0 = add(c0, c); d0 = add(d0, d);
  }
  function hex(n) {
    let s = "";
    for (let j = 0; j < 4; j++) s += ("0" + ((n >> (j * 8)) & 0xff).toString(16)).slice(-2);
    return s;
  }
  return hex(a0) + hex(b0) + hex(c0) + hex(d0);
}

/**
 * 把 "2024-11-07 20:06:05" 转成毫秒时间戳
 * @param {string} str 酷狗 addtime 字符串
 * @returns {number} 毫秒时间戳，解析失败返回 0
 */
function parseKgTime(str) {
  if (!str) return 0;
  const m = String(str).match(/(\d{4})-(\d{1,2})-(\d{1,2})[ T](\d{1,2}):(\d{1,2}):(\d{1,2})/);
  if (!m) return 0;
  return new Date(+m[1], +m[2] - 1, +m[3], +m[4], +m[5], +m[6]).getTime();
}

/**
 * 把酷狗评论归一化成 MusicFree 的评论结构
 * 格式按官方 bilibili 示例插件的 formatComment：
 *   { id, nickName, avatar, comment, like, createAt, location }
 * @param {object} c 酷狗评论对象
 */
function formatKugouComment(c) {
  const like = c.like || {};
  return {
    id: c.id,
    nickName: c.user_name || "未知用户",
    avatar: c.user_pic || "",
    comment: c.content || "",
    like: like.likenum || like.count || 0,
    createAt: parseKgTime(c.addtime),
    location: c.location || undefined,
  };
}

// ---- 74520 解析兜底（v0.5.0 新增）----
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
// 74520 加了 UA 校验，无 UA 的请求直接 nginx 403（2026-11-24 实测），
// 登录/解析 POST 必须带浏览器 UA + Referer（与 QQ/网易云 0.7.1/0.2.1 同款）。
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
  platform: "风誰·酷狗",
  version: "0.6.2",
  author: "风誰",
  description:
    "风誰制作 · 酷狗概念版二开专用版：搜索/多音质播放/歌词/每日推荐/我的歌单/最近收听/云盘/歌单导入/评论/歌单详情（仅供个人使用）",
  cacheControl: "no-cache",
  supportedSearchType: ["music", "artist"],

  // v0.6.2：74520 播放兜底重新接回（中转 2026-11-24 大面积 404 回退）。
  // 账号密码填在插件设置里，不填则本层静默跳过、不影响原有播放链。
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
   * 关键字搜索歌曲 / 歌手
   * 歌曲走原版中转；歌手走酷狗官方 singer/search（中转只会搜歌）。
   * 歌手搜索结果没有头像，批量调 singer/info 补（失败留空，不阻塞）。
   * @param {string} keyword 搜索关键字
   * @param {number} page 页码（从 1 开始）
   * @param {string} searchType 搜索类型
   * @returns {{isEnd: boolean, data: Array}}
   */
  async search(keyword, page, searchType) {
    // v0.4.6：歌手搜索
    if (searchType === "artist") {
      const pageNo = page && page > 0 ? page : 1;
      const pageSize = 10;
      try {
        const response = await axios.get(KG_MOBILE + "/search/singer", {
          params: { format: "json", keyword, page: pageNo, pagesize: pageSize, showtype: 1 },
          timeout: 15000,
        });
        const list = (response.data && Array.isArray(response.data.data))
          ? response.data.data
          : [];
        const artists = list.map(formatKugouArtist).filter((a) => a.id);
        // 批量补头像（并行，单个失败不影响其他）
        const avatars = await Promise.all(
          artists.map((a) => fetchKugouSingerAvatar(a.id))
        );
        artists.forEach((a, i) => {
          if (avatars[i]) {
            a.avatar = avatars[i];
            a.artwork = avatars[i];
          }
        });
        return { isEnd: artists.length < pageSize, data: artists };
      } catch (e) {
        return { isEnd: true, data: [] };
      }
    }
    // v0.4.7：只支持 music / artist；其他类型（album/sheet）返回空，
    // 不当成搜歌（之前会把歌曲结果当专辑/歌单返回）。
    if (searchType && searchType !== "music") {
      return { isEnd: true, data: [] };
    }
    // 主路：中转搜索；失败走官方 song_search_v2 兜底（带封面、字段一致）
    try {
      const response = await axios.get(API, {
        params: { msg: keyword, num: 20 },
        timeout: 10000,
      });
      const body = response.data;
      if (body && body.code === 0 && Array.isArray(body.data) && body.data.length) {
        return { isEnd: true, data: body.data.map(normalizeSong) };
      }
    } catch (e) {
      // 中转失败，落到官方兜底
    }
    const fb = await searchOfficialKugouSong(keyword, page || 1);
    if (fb) return fb;
    return { isEnd: true, data: [] };
  },

  /**
   * 获取播放地址
   * v0.4.8：主路中转（指定音质）→ 重试中转一次 → 降音质 128k → 换 https 中转；
   * 全失败才报干净错误。官方播放接口（getdata/getSongInfo/tracker）实测均不可用，
   * 无官方兜底；中转本身 http/https 双通道 + 音质降级即为兜底。
   * @param {{id: string}} song    歌曲对象（id 实为酷狗 hash）
   * @param {string}       quality 音质档位
   */
  async getMediaSource(song, quality) {
    const qualityCode = QUALITY_MAP[quality] || "128";
    const headers = { "User-Agent": UA, Referer: "http://www.kugou.com/" };
    // 依次尝试：中转（指定音质）→ 中转重试 → 中转 128k → https 中转 128k
    // v0.5.2：中转只调 1 次，跟原版一样，不重试、不等。
    const attempts = [{ base: API, q: qualityCode }];
    for (let i = 0; i < attempts.length; i++) {
      try {
        const response = await axios.get(attempts[i].base, {
          params: { id: song.id, quality: attempts[i].q },
          timeout: i === 0 ? 8000 : 6000,
        });
        const body = response.data;
        if (body && body.code === 0 && body.data && body.data.url) {
          return { url: body.data.url, headers };
        }
      } catch (e) {
        // 静默换下一条路
      }
    }
    // v0.6.2：中转失败后走 74520 兜底（2026-11-24 中转大面积 404 回退）。
    // 74520 只能解析非 VIP 酷狗歌（VIP 四档全 404），无账号静默跳过。
    const dl = await resolveDl74520Url("kugou", song.id, quality, {
      title: song.title,
      author: song.artist,
    });
    if (dl && dl.url) return dl;
    throw new Error("获取播放链接失败");
  },

  /**
   * 获取 LRC 歌词 + 翻译
   * @param {{id: string, duration?: number}} song 歌曲对象（id 实为酷狗 hash）
   *
   * 歌词仍走中转站（与原来一样）。翻译走酷狗官方歌词接口：
   * 先按 hash 查 lyric id 与 accesskey，再下 KRC 解开取翻译。
   * KRC 拿不到或解不开时只返回歌词、不带翻译，不影响正常显示。
   * v0.4.8：中转 lyric 失败时走官方 fmt=lrc 兜底（再失败走 fmt=krc 转 LRC）；
   * 全失败返回 null，不抛错。
   */
  async getLyric(song) {
    let rawLrc = "";
    // 主路：中转 lyric
    try {
      const response = await axios.get(API, {
        params: { action: "lyric", hash: song.id },
        timeout: 10000,
      });
      const body = response.data;
      if (body && body.code === 0 && body.data && body.data.lyric) {
        rawLrc = body.data.lyric;
      }
    } catch (e) {
      // 中转失败，落到官方兜底
    }
    // 兜底：官方歌词接口（fmt=lrc，拿不到再试 fmt=krc 转 LRC）
    if (!rawLrc) {
      rawLrc = await fetchKugouLyricOfficial(song);
    }
    if (!rawLrc) {
      return null;
    }
    // v0.4.4：补翻译——KRC 解开，翻译接上
    let translation = "";
    try {
      const searchParams = {
        ver: 1,
        man: "yes",
        client: "pc",
        hash: song.id,
      };
      // v0.4.5：歌曲对象里的 duration 已是秒，酷狗歌词接口要毫秒，×1000 还原
      if (song.duration) searchParams.duration = song.duration * 1000;
      const searchRes = await axios.get(
        "https://lyrics.kugou.com/search",
        { params: searchParams, timeout: 8000 }
      );
      const cands = searchRes.data && searchRes.data.candidates;
      if (cands && cands.length) {
        const cand = cands[0];
        const dlRes = await axios.get("https://lyrics.kugou.com/download", {
          params: {
            ver: 1,
            client: "pc",
            id: cand.id,
            accesskey: cand.accesskey,
            fmt: "krc",
            charset: "utf8",
          },
          timeout: 8000,
        });
        const dl = dlRes.data;
        if (dl && dl.status === 200 && dl.content) {
          translation = krcExtractTranslation(krcDecode(dl.content));
        }
      }
    } catch (e) {
      // 翻译拿不到就不要翻译，歌词照常返回
      translation = "";
    }
    return { rawLrc, translation };
  },

  /**
   * 获取歌曲评论（v0.4.0 新增，原版没有这个方法）
   *
   * MusicFree 评论区调的就是这个方法，返回 { isEnd, data: [] }，
   * 每条评论是 { id, nickName, avatar, comment, like, createAt, location }。
   *
   * 注意：中转站没实现评论接口（action=comment 返回 400
   * “unknown action: comment”），所以这里走酷狗官方网关
   * gateway.kugou.com（x-router 指到 m.comment.service.kugou.com），
   * 参数 r=comments/getCommentWithLike、code=articulossong，
   * key = MD5(appid + salt + clientver + clienttime)，概念版用 lite 参数。
   * 酷狗的 hash 就是歌曲 id（32 位十六进制）。
   *
   * @param {{id: string, title?: string}} song 歌曲对象（id 为酷狗 hash）
   * @param {number} page 页码（从 1 开始）
   */
  async getMusicComments(song, page) {
    const hash = String(song.id || "");
    const pageNo = page && page > 0 ? page : 1;
    const pagesize = 20;
    // v0.4.8：官方网关失败重试一次（最多 2 次）；全失败返回空，不阻塞播放页
    let response = null;
    for (let attempt = 0; attempt < 2; attempt++) {
      try {
        const clienttime = Math.floor(Date.now() / 1000);
        const key = md5Ascii(
          KG_CMT_APPID + KG_CMT_SALT + KG_CMT_CLIENTVER + clienttime
        );
        response = await axios.get(KG_CMT_GATEWAY, {
          params: {
            r: "comments/getCommentWithLike",
            code: KG_CMT_CODE,
            extdata: hash,
            childrenname: song.title || "",
            p: pageNo,
            pagesize,
            kugouid: 0,
            ver: 6,
            clienttoken: "",
            appid: KG_CMT_APPID,
            clientver: KG_CMT_CLIENTVER,
            mid: "",
            clienttime,
            key,
            uuid: "-",
            dfid: "-",
          },
          headers: {
            "x-router": KG_CMT_ROUTER,
            "User-Agent": UA,
          },
          timeout: 10000,
        });
        break;
      } catch (e) {
        response = null;
        if (attempt === 0) {
          await new Promise((r) => setTimeout(r, 600));
        }
      }
    }
    if (!response) {
      return { isEnd: true, data: [] };
    }
    const body = response.data || {};
    const list = Array.isArray(body.list) ? body.list : [];
    const total = body.count || 0;
    return {
      isEnd: total ? pageNo * pagesize >= total : list.length < pagesize,
      data: list.map(formatKugouComment),
    };
  },

  /**
   * 获取歌单详情（v0.4.0 新增，原版没有这个方法）
   *
   * 打开已保存 / 导入的歌单时 MusicFree 调这个方法。
   * 复用歌单接口：listid 走 playlist_songs，gcid 走 playlist_gcid。
   *
   * @param {{id?: string, title?: string, artist?: string, artwork?: string, coverImg?: string, description?: string}} sheet 歌单对象
   * @param {number} page 页码（从 1 开始）
   */
  async getMusicSheetInfo(sheet, page) {
    const rawId = String(sheet.id || "");
    const pageNo = page && page > 0 ? page : 1;
    const pagesize = 50;
    // 伪歌单 id（每日推荐/最近收听/我的云盘）复用 getTopListDetail 的专属逻辑，
    // 否则 playlist_songs 拿不到歌会返回空（2026-11-21 自查发现）。
    if (rawId === "recom" || rawId === "history" || rawId === "cloud") {
      const d = await this.getTopListDetail(sheet);
      return {
        isEnd: true,
        musicList: d.musicList || [],
        sheetItem: {
          id: rawId,
          title: sheet.title || d.title || "酷狗歌单",
          artist: sheet.artist || "",
          artwork: sheet.artwork || "",
          description: sheet.description || d.description || "",
        },
      };
    }
    const isGcid = /^gcid_/i.test(rawId);
    const listid = isGcid ? "" : rawId.replace(/^pl:/i, "");
    if (!rawId) {
      return { isEnd: true, musicList: [] };
    }
    // 主路：中转 playlist_songs / playlist_gcid（带一次重试）
    const body = await callKgProxy(
      isGcid
        ? { action: "playlist_gcid", gcid: rawId, page: pageNo, pagesize }
        : { action: "playlist_songs", listid, page: pageNo, pagesize },
      10000
    );
    if (
      body &&
      body.code === 0 &&
      body.data &&
      Array.isArray(body.data.songs)
    ) {
      const songs = body.data.songs;
      const total = body.data.total || 0;
      return {
        isEnd: total
          ? (pageNo - 1) * pagesize + songs.length >= total
          : songs.length < pagesize,
        musicList: songs.map(normalizeSong),
        sheetItem: {
          id: rawId,
          title: sheet.title || "酷狗歌单",
          artist: sheet.artist || "",
          artwork: sheet.artwork || sheet.coverImg || "",
          description: sheet.description || "",
        },
      };
    }
    // v0.4.8 兜底：官方 special/song（listid 即 specialid；gcid 无官方对应接口）
    if (!isGcid && listid) {
      const fb = await fetchKugouSpecialSongs(listid, pageNo, pagesize);
      if (fb && fb.data.length) {
        return {
          isEnd: fb.isEnd,
          musicList: fb.data,
          sheetItem: {
            id: rawId,
            title: sheet.title || "酷狗歌单",
            artist: sheet.artist || "",
            artwork: sheet.artwork || sheet.coverImg || "",
            description: sheet.description || "",
          },
        };
      }
    }
    return { isEnd: true, musicList: [] };
  },

  /**
   * 获取单曲元信息
   * v0.4.8：中转失败时回填输入歌曲自身信息（标题/歌手/专辑/封面/时长），
   * 不返回 null（宿主刷新元信息时不阻塞）。
   * @param {{id: string, title?: string, artist?: string}} song
   */
  async getMusicInfo(song) {
    const body = await callKgProxy({ id: song.id }, 10000);
    if (body && body.code === 0 && body.data) {
      const data = body.data;
      return {
        id: String(data.id || song.id),
        platform: "风誰·酷狗",
        title: data.name || song.title || "未知歌曲",
        artist: data.artist || song.artist || "未知歌手",
        album: data.album || "",
        artwork: toHttps(data.cover),
        // v0.4.5：同上，中转 duration 是毫秒，转秒
        duration: Math.floor((data.duration || 0) / 1000),
      };
    }
    // 兜底：回填输入歌曲自身信息
    return {
      id: String(song.id || ""),
      platform: "风誰·酷狗",
      title: song.title || "未知歌曲",
      artist: song.artist || "未知歌手",
      album: song.album || "",
      artwork: song.artwork || "",
      duration: song.duration || 0,
    };
  },

  /**
   * 返回推荐位分组：
   *   - 「个性推荐」：每日推荐 30 首
   *   - 「我的音乐」：最近收听 / 我的云盘 + 用户自建歌单列表（需登录态）
   * 注意：未登录情况下 user_playlist 接口可能失败，此时只返回个性推荐
   */
  async getTopLists() {
    // v0.4.9：榜单封面——每日推荐/最近收听/云盘补封面，新增官方榜单分组。
    // 五路并行拉取（各带超时、失败留空），互不阻塞；封面拿不到只留空，不影响列表。
    const [recomCover, historyCover, cloudCover, ranks, userPlaylists] =
      await Promise.all([
        // 每日推荐封面：取推荐列表首歌封面
        (async () => {
          try {
            const b = await callKgProxy({ action: "recom" }, 10000);
            const first =
              b && b.code === 0 && Array.isArray(b.data && b.data.songs)
                ? b.data.songs[0]
                : null;
            return first ? normalizeSong(first).artwork || "" : "";
          } catch (e) {
            return "";
          }
        })(),
        // 最近收听封面：历史只有 name/artist/hash，取首歌详情补封面
        (async () => {
          try {
            const b = await callKgProxy({ action: "user_history" }, 10000);
            const first =
              b && b.code === 0 && Array.isArray(b.data && b.data.songs)
                ? b.data.songs[0]
                : null;
            if (!first || !first.hash) return "";
            const info = await this.getMusicInfo({ id: String(first.hash) });
            return (info && info.artwork) || "";
          } catch (e) {
            return "";
          }
        })(),
        // 我的云盘封面：取云盘列表首歌封面；上传文件本身无封面时搜同首歌补
        (async () => {
          try {
            const b = await callKgProxy(
              { action: "user_cloud", page: 1, pagesize: 50 },
              10000
            );
            const list =
              b && b.code === 0 && Array.isArray(b.data && b.data.songs)
                ? b.data.songs
                : [];
            const first = list[0] || null;
            if (first && first.cover) return toHttps(first.cover);
            return await resolveKgCloudCover(list);
          } catch (e) {
            return "";
          }
        })(),
        // 酷狗官方榜单（TOP500/飙升榜/热歌榜等，带封面）
        fetchKgRankList(),
        // 用户歌单（需要登录态，失败则跳过）
        // v0.4.8：网络失败也不抛错，只返回个性推荐
        callKgProxy({ action: "user_playlist", page: 1, pagesize: 30 }, 10000),
      ]);

    const groups = [
      {
        title: "个性推荐",
        data: [
          {
            title: "每日推荐",
            id: "recom",
            description: "酷狗概念版每日推荐 30 首",
            coverImg: recomCover,
            artwork: recomCover,
          },
        ],
      },
    ];

    // 酷狗官方榜单（带封面）
    if (ranks.length) {
      groups.push({
        title: "酷狗榜单",
        data: ranks,
      });
    }

    const body = userPlaylists;
    if (
      body &&
      body.code === 0 &&
      body.data &&
      Array.isArray(body.data.list) &&
      body.data.list.length
    ) {
      groups.push({
        title: "我的音乐",
        data: [
          {
            title: "最近收听",
            id: "history",
            description: "酷狗概念版最近收听",
            coverImg: historyCover,
            artwork: historyCover,
          },
          {
            title: "我的云盘",
            id: "cloud",
            description: "酷狗概念版我的云盘",
            coverImg: cloudCover,
            artwork: cloudCover,
          },
        ].concat(
          body.data.list.map((pl) => ({
            title: pl.name || "未命名歌单",
            id: "pl:" + String(pl.id),
            description: "共 " + (pl.count || 0) + " 首",
            coverImg: toHttps(pl.pic),
          }))
        ),
      });
    }
    return groups;
  },

  /**
   * 推荐位详情：根据 sheetId 类型路由
   *   - "rank:<rankid>"      官方榜单（v0.4.9 新增，走 mobilecdn rank/song）
   *   - "recom"               每日推荐
   *   - "history"             最近收听
   *   - "cloud"               我的云盘
   *   - "pl:<listid>"         用户歌单（分页拉取，最多 10 页兜底）
   * v0.4.9：所有分支统一补封面（withKgTopCover），之前返回里没有任何封面字段。
   */
  async getTopListDetail(sheet, pageNo) {
    const sheetId = String(sheet.id || "");

    // —— 官方榜单（"rank:<rankid>"，v0.4.9 新增）——
    if (sheetId.indexOf("rank:") === 0) {
      const rankid = sheetId.slice(5);
      const fb = await fetchKgRankSongs(rankid, pageNo || 1);
      if (!fb || !fb.data.length) {
        return { isEnd: true, musicList: [] };
      }
      return withKgTopCover(sheet, fb.data, {
        isEnd: (pageNo || 1) * 100 >= (fb.total || 0) || fb.data.length < 100,
      });
    }

    // —— 每日推荐 ——
    // v0.4.8：中转调用带一次重试，失败返回空，不抛错
    if (sheetId === "recom") {
      const body = await callKgProxy({ action: "recom" }, 15000);
      if (
        !body ||
        body.code !== 0 ||
        !body.data ||
        !Array.isArray(body.data.songs)
      ) {
        return { isEnd: true, musicList: [] };
      }
      return withKgTopCover(sheet, body.data.songs.map(normalizeSong), {
        isEnd: true,
      });
    }

    // —— 最近收听 ——
    if (sheetId === "history") {
      const body = await callKgProxy({ action: "user_history" }, 10000);
      if (
        !body ||
        body.code !== 0 ||
        !body.data ||
        !Array.isArray(body.data.songs)
      ) {
        return { isEnd: true, musicList: [] };
      }
      // 最近收听里只返回 name + artist + hash，需要过滤掉 hash 为空的脏数据
      const songs = body.data.songs
        .map((s) => ({
          id: String(s.hash || ""),
          platform: "风誰·酷狗",
          title: s.name || "未知歌曲",
          artist: s.artist || "未知歌手",
          duration: 0,
        }))
        .filter((s) => s.id !== "");
      return withKgTopCover(sheet, songs, { isEnd: true });
    }

    // —— 我的云盘 ——
    if (sheetId === "cloud") {
      const body = await callKgProxy(
        { action: "user_cloud", page: 1, pagesize: 50 },
        10000
      );
      if (
        !body ||
        body.code !== 0 ||
        !body.data ||
        !Array.isArray(body.data.songs)
      ) {
        return { isEnd: true, musicList: [] };
      }
      const songs = body.data.songs
        .map((s) => ({
          id: String(s.hash || ""),
          platform: "风誰·酷狗",
          title: s.name || "未知歌曲",
          artist: s.artist || "未知歌手",
          album: s.album || "",
          artwork: toHttps(s.cover),
          // v0.4.5：同上，中转 duration 是毫秒，转秒
          duration: Math.floor((s.duration || 0) / 1000),
        }))
        .filter((s) => s.id !== "");
      // 云盘上传文件本身无封面：列表没给、歌也没图时搜同首歌补一张
      const extraCover = songs.some((s) => s.artwork)
        ? ""
        : await resolveKgCloudCover(body.data.songs);
      return withKgTopCover(
        Object.assign({}, sheet, {
          coverImg: sheet.coverImg || extraCover,
          artwork: sheet.artwork || extraCover,
        }),
        songs,
        { isEnd: true }
      );
    }

    // —— 用户歌单（"pl:<listid>"）——
    if (sheetId.indexOf("pl:") === 0) {
      const listid = sheetId.slice(3);
      const allSongs = [];
      let page = 1;
      while (true) {
        const body = await callKgProxy(
          {
            action: "playlist_songs",
            listid,
            page,
            pagesize: 50,
          },
          10000
        );
        if (
          !body ||
          body.code !== 0 ||
          !body.data ||
          !Array.isArray(body.data.songs) ||
          !body.data.songs.length
        ) {
          break;
        }
        allSongs.push(...body.data.songs.map(normalizeSong));
        // 拉满总数或 10 页就停（10 页 = 500 首）
        if (allSongs.length >= (body.data.total || 0) || page >= 10) {
          break;
        }
        page += 1;
      }
      // v0.4.8：中转一首没拉到时走官方 special/song 兜底
      if (!allSongs.length) {
        const fb = await fetchKugouSpecialSongs(listid, 1, 50);
        if (fb && fb.data.length) {
          return withKgTopCover(sheet, fb.data, { isEnd: true });
        }
      }
      return withKgTopCover(sheet, allSongs, { isEnd: true });
    }

    return { isEnd: true, musicList: [] };
  },

  /**
   * 导入歌单 / 专辑 / 单曲分享
   * 支持三种输入：
   *   1. https://t.kugou.com/xxx  分享短链
   *      - 优先匹配 gcid_xxx 直接走 playlist_gcid
   *      - 否则匹配 special/single/数字 id 走 playlist_songs
   *      - 都匹配不到就调 resolve_share 让后端解析
   *   2. gcid_xxxxxx              直接当 gcid 用
   *   3. 纯数字                   直接当 listid 用
   * @param {string} input 用户输入
   * @returns {Array<object> | null}
   */
  async importMusicSheet(input) {
    const text = String(input == null ? "" : input).trim();
    if (!text) {
      return null;
    }

    let gcid = "";
    let listid = "";

    if (/^https?:\/\//i.test(text)) {
      // 链接形式
      // 先尝试从 URL 里直接抽出 gcid
      const gcidMatch = text.match(/(gcid_[A-Za-z0-9_]+)/);
      if (gcidMatch) {
        gcid = gcidMatch[1];
      } else {
        // 再尝试抽出 listid（数字）
        const listidMatch =
          text.match(/special\/single\/(\d+)/) ||
          text.match(/plist\/list\/(\d+)/) ||
          text.match(/[?&](?:id|specialid|listid)=(\d+)/);
        if (listidMatch) {
          listid = listidMatch[1];
        }
      }
      // 仍然没有就调后端解析短链
      if (!gcid && !listid) {
        try {
          const response = await axios.get(API, {
            params: { action: "resolve_share", url: text },
            timeout: 25000,
          });
          const body = response.data;
          if (body && body.status === 1 && body.data) {
            gcid = body.data.gcid || "";
            listid = body.data.listid || "";
          }
        } catch (e) {
          // 解析失败忽略，下面会返回 null
        }
      }
    } else if (/^gcid_/i.test(text)) {
      // 形如 gcid_xxx
      gcid = text;
    } else {
      // 纯数字当 listid
      const numMatch = text.match(/\d+/);
      if (numMatch) {
        listid = numMatch[0];
      }
    }

    if (!gcid && !listid) {
      return null;
    }

    // 循环分页拉取歌曲列表（gcid 和 listid 走不同的 action）
    const allSongs = [];
    let page = 1;
    while (true) {
      const body = await callKgProxy(
        gcid
          ? {
              action: "playlist_gcid",
              gcid,
              page,
              pagesize: 50,
            }
          : {
              action: "playlist_songs",
              listid,
              page,
              pagesize: 50,
            },
        10000
      );
      if (
        !body ||
        body.code !== 0 ||
        !body.data ||
        !Array.isArray(body.data.songs) ||
        !body.data.songs.length
      ) {
        break;
      }
      allSongs.push(...body.data.songs.map(normalizeSong));
      if (allSongs.length >= (body.data.total || 0) || page >= 10) {
        break;
      }
      page += 1;
    }

    // v0.4.8：中转一首没拉到时走官方 special/song 兜底（listid 即 specialid）
    if (!allSongs.length && listid) {
      const fb = await fetchKugouSpecialSongs(listid, 1, 50);
      if (fb && fb.data.length) {
        return fb.data;
      }
    }

    return allSongs.length ? allSongs : null;
  },

  /**
   * 获取歌手作品（v0.4.6 新增，原版没有）
   * MusicFree 进入歌手详情页时调这个方法。type="music" 拉歌曲，
   * type="album" 拉专辑，均走酷狗官方 mobilecdn 接口。接口失败返回空，不抛错。
   * v0.4.8：歌曲分支官方失败时走官方搜歌按歌手名过滤兜底；专辑分支失败重试一次。
   * @param {{id?: string, _singerId?: string, name?: string, artist?: {id?: string}}} artistItem 歌手对象
   * @param {number} page 页码（从 1 开始）
   * @param {string} type "music" 或 "album"
   */
  async getArtistWorks(artistItem, page, type) {
    const singerId =
      artistItem._singerId || artistItem.id || (artistItem.artist && artistItem.artist.id) || "";
    if (!singerId) {
      return { isEnd: true, data: [] };
    }
    const pageNo = page && page > 0 ? page : 1;
    const pageSize = 20;
    const name = artistItem.name || artistItem.title || "";
    if (type === "album") {
      for (let attempt = 0; attempt < 2; attempt++) {
        try {
          const response = await axios.get(KG_MOBILE + "/singer/album", {
            params: { format: "json", singerid: singerId, page: pageNo, pagesize: pageSize },
            timeout: 10000,
          });
          const d = (response.data && response.data.data) || {};
          const list = Array.isArray(d.info) ? d.info : [];
          const total = Number(d.total) || 0;
          return {
            isEnd: total > 0 ? pageNo * pageSize >= total : list.length < pageSize,
            data: list.map((al) => ({
              id: String(al.albumid || ""),
              platform: "风誰·酷狗",
              title: al.albumname || "未知专辑",
              artist: name,
              artwork: toHttps((al.imgurl || "").replace("{size}", "240")),
              _albumId: String(al.albumid || ""),
            })).filter((a) => a.id),
          };
        } catch (e) {
          if (attempt === 0) {
            await new Promise((r) => setTimeout(r, 600));
          }
        }
      }
      return { isEnd: true, data: [] };
    }
    // 歌曲分支：主路 mobilecdn singer/song
    try {
      const response = await axios.get(KG_MOBILE + "/singer/song", {
        params: { format: "json", singerid: singerId, page: pageNo, pagesize: pageSize },
        timeout: 10000,
      });
      const d = (response.data && response.data.data) || {};
      const list = Array.isArray(d.info) ? d.info : [];
      const total = Number(d.total) || 0;
      if (list.length) {
        return {
          isEnd: total > 0 ? pageNo * pageSize >= total : list.length < pageSize,
          data: list
            .map((s) => normalizeKugouSingerSong(s, name))
            .filter((s) => s.id),
        };
      }
    } catch (e) {
      // 官方失败，落到搜歌过滤兜底
    }
    // 兜底：官方搜歌（song_search_v2）按歌手名过滤，只取该歌手的歌
    if (name) {
      const fb = await searchOfficialKugouSong(name, pageNo);
      if (fb && fb.data.length) {
        const mine = fb.data.filter(
          (s) => String(s.artist || "").split("/")[0].trim() === name.trim()
        );
        return { isEnd: fb.isEnd, data: mine.length ? mine : fb.data.slice(0, pageSize) };
      }
    }
    return { isEnd: true, data: [] };
  },

  /**
   * 获取歌手详情（v0.4.6 新增，原版没有）
   * 返回 IArtistItem：头像、简介（intro）、热门歌曲 musicList。
   * 接口失败时返回原对象兜底，不抛错，避免阻塞歌手页。
   * v0.4.8：singer/info 失败时走搜歌手 + 搜歌拼热门歌曲兜底（头像无官方替代，
   * 用搜索结果里的头像或留空；简介缺失是降级、可接受）。
   * @param {{id?: string, _singerId?: string, name?: string, avatar?: string, artist?: {id?: string}}} artistItem 歌手对象
   */
  async getArtistInfo(artistItem) {
    const singerId =
      artistItem._singerId || artistItem.id || (artistItem.artist && artistItem.artist.id) || "";
    if (!singerId) {
      return artistItem || {};
    }
    try {
      const response = await axios.get(KG_MOBILE + "/singer/info", {
        params: { singerid: singerId },
        timeout: 10000,
      });
      const d = (response.data && response.data.data) || {};
      if (d.singername || d.imgurl || d.intro) {
        const name = d.singername || artistItem.name || artistItem.title || "未知歌手";
        // imgurl 里带 {size} 占位符，换成 240 才是真实地址
        const avatar = toHttps((d.imgurl || "").replace("{size}", "240")) || artistItem.avatar || artistItem.artwork || "";
        // 顺带拉热门歌曲（前 10 首）放进 musicList
        let musicList = [];
        try {
          const songs = await this.getArtistWorks(
            { id: String(singerId), name },
            1,
            "music"
          );
          musicList = (songs.data || []).slice(0, 10);
        } catch (e) {
          musicList = [];
        }
        return {
          id: String(singerId),
          platform: "风誰·酷狗",
          name,
          title: name,
          avatar,
          artwork: avatar,
          description: d.intro || artistItem.description || "",
          musicList,
          _singerId: String(singerId),
        };
      }
    } catch (e) {
      // 官方失败，落到搜索拼装兜底
    }
    // 兜底：搜歌手（取头像）+ 搜歌（取热门歌曲）
    const name = artistItem.name || artistItem.title || "";
    if (name) {
      try {
        const [searchRes, songsRes] = await Promise.all([
          axios.get(KG_MOBILE + "/search/singer", {
            params: { format: "json", keyword: name, page: 1, pagesize: 5, showtype: 1 },
            timeout: 8000,
          }).catch(() => null),
          searchOfficialKugouSong(name, 1),
        ]);
        const found = ((searchRes?.data?.data) || []).map(formatKugouArtist).filter((a) => a.id)[0];
        const avatar = found
          ? await fetchKugouSingerAvatar(found.id)
          : "";
        const songs = songsRes && songsRes.data.length
          ? songsRes.data.filter((s) => String(s.artist || "").split("/")[0].trim() === name.trim()).slice(0, 10)
          : [];
        return {
          id: String((found && found.id) || singerId),
          platform: "风誰·酷狗",
          name: (found && found.name) || name,
          title: (found && found.name) || name,
          avatar: avatar || artistItem.avatar || artistItem.artwork || "",
          artwork: avatar || artistItem.avatar || artistItem.artwork || "",
          description: artistItem.description || "",
          musicList: songs,
          _singerId: String((found && found.id) || singerId),
        };
      } catch (e) {
        // 兜底也失败，返回原对象
      }
    }
    return artistItem;
  },

  /**
   * 获取专辑详情：直接复用 playlist_songs 接口
   * （酷狗概念版里专辑 ≈ 特殊歌单）
   * v0.4.8：中转失败时走官方 special/song 兜底（albumId 即 specialid）。
   * @param {{id?: string, albumId?: string, title?: string, artist?: string, artwork?: string}} album
   * @param {number} page 页码
   */
  async getAlbumInfo(album, page) {
    const albumId = album.id || album.albumId || "";
    const body = await callKgProxy(
      {
        action: "playlist_songs",
        listid: String(albumId),
        page: page || 1,
        pagesize: 50,
      },
      10000
    );
    if (
      body &&
      body.code === 0 &&
      body.data &&
      Array.isArray(body.data.songs)
    ) {
      return {
        isEnd: true,
        albumItem: {
          id: String(albumId),
          platform: "风誰·酷狗",
          title: album.title || "酷狗歌单",
          artist: album.artist || "",
          artwork: album.artwork || "",
        },
        musicList: body.data.songs.map(normalizeSong),
      };
    }
    // 兜底：官方 special/song
    const fb = await fetchKugouSpecialSongs(albumId, page || 1, 50);
    if (fb && fb.data.length) {
      return {
        isEnd: fb.isEnd,
        albumItem: {
          id: String(albumId),
          platform: "风誰·酷狗",
          title: album.title || "酷狗歌单",
          artist: album.artist || "",
          artwork: album.artwork || "",
        },
        musicList: fb.data,
      };
    }
    return { isEnd: true, albumItem: {}, musicList: [] };
  },
};
