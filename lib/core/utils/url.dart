/// URL 处理工具
library;

final _trailingSlashes = RegExp(r'/+$');

/// 去除服务器地址末尾的多余斜杠
///
/// 用户在配置界面填写服务器地址时常带上尾部 `/`，
/// 而拼接接口路径时同样会带 `/`，直接拼接会产生 `//` 导致部分服务端 404。
/// 各音源在创建 client、写入配置前统一用本函数归一化，
/// 保证同一服务器不会因写法差异被当作两份配置。
///
/// ```dart
/// cleanServerUrl('https://demo.com/');   // https://demo.com
/// cleanServerUrl('https://demo.com///'); // https://demo.com
/// cleanServerUrl('https://demo.com');    // https://demo.com
/// ```
String cleanServerUrl(String url) => url.replaceAll(_trailingSlashes, '');
