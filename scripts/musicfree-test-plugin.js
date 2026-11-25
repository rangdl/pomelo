// 测试用 MusicFree 插件（协议：module.exports = { platform, version, search, getMediaSource, ... }）
// 运行时只提供 fetch 与 JS 内建对象，没有 require/axios/cheerio。
// 用途：验证「搜索 -> 选中 -> getMediaSource 取播放地址 -> 播放」整条链路。

module.exports = {
  platform: "pomelo-test",
  version: "1.0.0",
  author: "pomelo",
  description: "测试插件：固定曲目 + 公开测试音频",
  // 结果项未单独声明 lxSource 时，宿主用它匹配 LX 音源
  lxSource: "kw",

  async search(query, page, type) {
    // 宿主只关心 music 类型
    if (type !== "music") return { isEnd: true, data: [] };

    return {
      isEnd: true,
      data: [
        {
          id: "mf-test-a",
          platform: "pomelo-test",
          title: "测试曲目 A（SoundHelix）",
          artist: "pomelo",
          album: "test",
          artwork: "",
          // 走 lxSource 声明的 kw 去解析
          lxSource: "kw"
        },
        {
          id: "mf-test-b",
          platform: "pomelo-test",
          title: "测试曲目 B（samplelib 6s）",
          artist: "pomelo",
          album: "test",
          artwork: "",
          lxSource: "tx"
        },
        {
          id: "mf-test-echo",
          platform: "pomelo-test",
          title: "搜索回显: " + query + " (page " + page + ")",
          artist: "pomelo",
          album: "test",
          artwork: "",
          lxSource: "kw"
        }
      ]
    };
  },

  async getMediaSource(musicItem, quality) {
    // 协议允许返回 { url, headers } 或直接返回 url 字符串。
    if (musicItem.id === "mf-test-echo") {
      // 返回裸字符串，验证宿主对 String 返回值的兼容
      return "https://samplelib.com/lib/preview/mp3/sample-15s.mp3";
    }

    const map = {
      "mf-test-a": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "mf-test-b": "https://samplelib.com/lib/preview/mp3/sample-6s.mp3"
    };

    return {
      url: map[musicItem.id] || "https://samplelib.com/lib/preview/mp3/sample-3s.mp3",
      headers: {
        "user-agent": "pomelo/0.1",
        // 把请求到的音质回传，便于在日志里确认参数传递正确
        "x-quality": String(quality || "")
      }
    };
  }
};
