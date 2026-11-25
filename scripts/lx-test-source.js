/**
 * @name 测试音源（LX UserApi）
 * @description 固定返回公开测试音频，用于验证 musicUrl 解析链路：源声明 / 参数传递 / 加密桥 / 网络请求
 * @version 1.0.0
 * @author pomelo
 */

// 协议：宿主只会在 action 为 musicUrl 时调用 request
lx.on('request', async ({ source, action, info }) => {
  if (action !== 'musicUrl') throw new Error('unsupported action: ' + action);

  const musicInfo = (info && info.musicInfo) || {};
  const name = musicInfo.name || 'unknown';
  const quality = (info && info.type) || '128k';

  // 同步加密桥：验证 sendMessage('lxMd5') 可用（真实脚本常用于计算签名）
  const sign = lx.utils.crypto.md5(source + '|' + name + '|' + quality);
  console.log('resolve', source, quality, sign);

  // 真实脚本在这里用 lx.request 请求平台接口拿直链；
  // 测试脚本直接返回公开音频，并把参数带进 query 便于核对。
  return 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3'
    + '?source=' + encodeURIComponent(source)
    + '&quality=' + encodeURIComponent(quality)
    + '&sign=' + sign;
});

// 必须声明源，宿主按 source 精确匹配 LX 脚本
lx.send('inited', {
  status: true,
  sources: {
    kw: {
      name: '测试音源-KW',
      type: 'music',
      actions: ['musicUrl'],
      qualitys: ['128k', '320k']
    },
    tx: {
      name: '测试音源-TX',
      type: 'music',
      actions: ['musicUrl'],
      qualitys: ['128k', '320k', 'flac']
    }
  }
});
