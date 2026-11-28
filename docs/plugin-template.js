/**
 * Pomelo 插件模板
 * =============================================================================
 * 协议基础与 MusicFree 插件一致（`module.exports = { ... }`），本模板列出宿主
 * 当前支持的全部能力。**所有方法都是可选的**：只实现需要的即可，宿主会根据
 * 实际实现的方法决定 UI 入口。
 *
 * 导入方式：设置 → 插件管理 → 粘贴源码安装。
 * 同一 `platform` 重复导入视为更新（会保留启用状态与兜底开关）。
 * =============================================================================
 */
module.exports = {
  // ---- 元信息（必填：platform / version）------------------------------------
  platform: '示例平台',
  version: '1.0.0',
  author: 'your-name',
  description: '插件一句话说明',

  // 更新地址：宿主"检查更新"会拉取该地址的源码，并与 version 比较。
  // 也可以是 GitHub raw / jsDelivr 等直链。
  // 不是 JS 直链（如发布页、仓库主页）时，用户可在插件管理里选择
  // "在浏览器打开更新地址"，不会强制下载解析。
  srcUrl: 'https://example.com/pomelo-plugin.js',

  // 声明本插件结果对应的标准音源 key（kw/tx/wy/kg/mg/qs）。
  // 宿主用它做跨插件兜底匹配：不填时会按 platform 名推断（如"风誰·酷狗"→kg）。
  sourceKeys: ['kw'],

  // 声明本插件支持的搜索类型（music/sheet/artist/album/lyric）。
  // 不填 = 不限制（与 MusicFree 语义一致）；宿主搜索页只展示声明过的类型。
  supportedSearchType: ['music', 'sheet', 'artist', 'album'],

  // 默认搜索类型；不填时宿主回退 music。
  defaultSearchType: 'music',

  // 声明本插件支持的音质，宿主会按 low/standard/high/super 传入。
  supportedQualitys: ['low', 'standard', 'high', 'super'],

  // ---- 搜索 ----------------------------------------------------------------
  // type: 'music' | 'sheet' | 'artist' | 'album' | 'lyric'
  // 返回 { isEnd?: boolean, data: [...] }；isEnd 不填视为已到末页
  // （与 MusicFree 一致，只有显式 false 宿主才会继续请求下一页）。
  async search(query, page, type) {
    return {
      isEnd: true,
      data: [
        {
          id: 'track-id-1',
          title: '歌名',
          artist: '歌手',
          album: '专辑',
          artwork: 'https://example.com/cover.jpg',
          duration: 240, // 秒
        },
      ],
    };
  },

  // ---- 榜单 ----------------------------------------------------------------
  // 返回 [{ title: '分组名', data: [{ id, title, description, ... }] }]
  async getTopLists() {
    return [
      {
        title: '热门榜单',
        data: [{ id: 'top-1', title: '飙升榜', description: '每小时更新' }],
      },
    ];
  },

  // 返回 { isEnd: boolean, musicList: [...] }
  async getTopListDetail(topListItem, page) {
    return { isEnd: true, musicList: [] };
  },

  // ---- 歌单 ----------------------------------------------------------------
  // 返回 [{ id, title, parentId? }]
  async getRecommendSheetTags() {
    return [{ id: 'tag-1', title: '流行' }];
  },

  // 返回 { isEnd: boolean, data: [...] }
  async getRecommendSheetsByTag(tag, page) {
    return { isEnd: true, data: [] };
  },

  // 返回 { isEnd: boolean, musicList: [...], sheetInfo?: {} }
  async getMusicSheetInfo(sheetItem, page) {
    return { isEnd: true, musicList: [] };
  },

  // 从分享链接导入歌单；返回曲目数组
  async importMusicSheet(url) {
    return [];
  },

  // 从分享链接导入单曲；返回单个曲目对象，解析失败返回 null
  async importMusicItem(url) {
    return null;
  },

  // ---- 歌手 / 专辑 ----------------------------------------------------------
  // type: 'music' | 'album'
  // 返回 { isEnd: boolean, data: [...] }
  async getArtistWorks(artistItem, page, type) {
    return { isEnd: true, data: [] };
  },

  // 返回 { isEnd: boolean, musicList: [...] }
  async getAlbumInfo(albumItem, page) {
    return { isEnd: true, musicList: [] };
  },

  // ---- 歌曲详情 / 评论 -------------------------------------------------------
  // 返回补充信息，宿主会合并到歌曲详情弹层
  async getMusicInfo(musicItem) {
    return { album: '专辑', duration: 240, genre: 'Pop', releaseDate: '2024-01-01' };
  },

  // sort: 'hot' | 'new'；返回 { isEnd?: boolean, data: [...] } 或数组
  async getMusicComments(musicItem, page, sort) {
    return {
      isEnd: true,
      data: [{ nickName: '听友', comment: '好听', like: 12, createAt: 0 }],
    };
  },

  // ---- 歌词 ----------------------------------------------------------------
  // 返回 LRC 文本，或 { lyric: '...' } / { rawLrc: '...' }；
  // 若平台有翻译歌词，用 translation 一并返回（也是带时间戳的 LRC 文本），
  // 宿主会按时间戳对齐后与原文一起显示。
  async getLyric(musicItem) {
    return {
      lyric: '[00:00.00] 歌词内容',
      translation: '[00:00.00] 歌词译文',
    };
  },

  // ---- 音源（可选）----------------------------------------------------------
  // quality: 'low' | 'standard' | 'high' | 'super'
  // 返回 { url, headers? }；拿不到时返回 null，宿主会按音源 key 尝试其它插件兜底。
  //
  // 注意：宿主会在调用时额外传第三个参数 sourceKey（本插件的主音源 key），
  // 自有格式插件可以忽略它。
  // ---- 音源 -------------------------------------------------------------
  // quality: 'low' | 'standard' | 'high' | 'super'
  // 返回 { url, headers?, userAgent?, quality? }；拿不到时返回 null，宿主会按音源
  // key 尝试其它插件兜底。
  //
  // sourceKey：宿主会把当前条目的音源 key 写进 musicItem.sourceKey，需要按源
  // 选路的插件读它即可；方法签名与 MusicFree 一致，只有两个参数。
  // userAgent：等价于 headers['User-Agent']，两者都给时以 userAgent 为准。
  // quality：返回实际提供的档位，宿主会据此显示「降档」提示。
  async getMediaSource(musicItem, quality) {
    return {
      url: 'https://example.com/audio.mp3',
      headers: {
        Referer: 'https://example.com/',
        'User-Agent': 'Mozilla/5.0',
      },
      quality: quality,
    };
  },
};

/**
 * LX 音源脚本说明
 * =============================================================================
 * 无需改写为上面的格式：把原生 LX 脚本直接粘贴导入即可。宿主会自动识别
 * （脚本内的 `lx.on('request', ...)` + `lx.send('inited', ...)`），并在兼容层里
 * 包装成等价的 `getMediaSource(musicItem, quality)`：
 *
 *   - `inited` 里声明的每个源（kw/kg/tx/wy/mg/qs…）都会成为本插件的音源 key；
 *   - 宿主请求 high 时，脚本若只声明 128k/320k，会自动降档；
 *   - 脚本声明了 `lyric` action 时，宿主会额外暴露歌词能力；
 *   - `lx.send('updateAlert', { log, updateUrl })` 会被识别为更新提示，
 *     `updateUrl` 会作为更新地址。
 *
 * 因此 LX 脚本不需要适配本模板，直接导入即可与自有格式插件共存。
 */
