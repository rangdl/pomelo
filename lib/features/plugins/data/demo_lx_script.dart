/// 示例 LX 音源脚本（测试用）。
const String demoLxScript = r'''
lx.on('request', async ({ source, action, info }) => {
  if (action !== 'musicUrl') throw new Error('unsupported action: ' + action);
  // 真实脚本会请求对应平台接口拿到带时效的直链。
  // 这里演示：把歌曲名编码进公开测试音频的查询参数，证明参数传递正确。
  const name = (info && info.musicInfo && info.musicInfo.name) || 'unknown';
  // 同步调用宿主加密：验证 sendMessage 同步桥可用
  const sign = lx.utils.crypto.md5(name);
  return 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3?src=pomelo&q='
    + encodeURIComponent(name) + '&sign=' + sign;
});

lx.send('inited', {
  status: true,
  sources: {
    kw: { name: '酷我(示例)', type: 'music', actions: ['musicUrl'], qualitys: ['128k', '320k'] },
    tx: { name: 'QQ音乐(示例)', type: 'music', actions: ['musicUrl'], qualitys: ['128k', '320k'] }
  }
});
''';
