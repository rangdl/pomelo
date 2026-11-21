/// 内置示例插件源码，用于端到端验证（搜索 → 解析播放地址 → 播放）。
///
/// 这是**测试用**插件：搜索返回固定列表，播放地址用公开测试音频。
/// 生产插件由用户自己安装。
const String demoPluginSource = r'''
module.exports = {
  platform: "pomelo-demo",
  version: "0.1.0",
  author: "pomelo",
  description: "内置示例插件：固定曲目 + 公开测试音频，用于验证播放链路",
  async search(query, page, type) {
    if (type !== 'music') return { isEnd: true, data: [] };
    return {
      isEnd: true,
      data: [
        {
          id: "demo-a",
          platform: "pomelo-demo",
          title: "示例音频 A（SoundHelix）",
          artist: "pomelo",
          album: "demo",
          artwork: "",
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
        },
        {
          id: "demo-b",
          platform: "pomelo-demo",
          title: "示例音频 B（samplelib 6s）",
          artist: "pomelo",
          album: "demo",
          artwork: "",
          url: "https://samplelib.com/lib/preview/mp3/sample-6s.mp3"
        },
        {
          id: "demo-search",
          platform: "pomelo-demo",
          title: "网络请求测试: " + query,
          artist: "httpbin",
          album: "demo",
          artwork: "",
          // 用 fetch 实测一次网络（也验证插件内 fetch 可用）
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"
        }
      ]
    };
  },

  async getMediaSource(musicItem, quality) {
    // 真实插件会在这里请求接口拿到带时效的播放地址。
    return {
      url: musicItem.url,
      headers: { "user-agent": "pomelo/0.1" }
    };
  }
};
''';
