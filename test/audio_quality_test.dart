import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/shared/settings/audio_quality.dart';

void main() {
  test('MusicFree 音质映射与官方 low/standard/high/super 一致', () {
    expect(AudioQuality.low.musicFreeValue, 'low');
    expect(AudioQuality.standard.musicFreeValue, 'standard');
    expect(AudioQuality.high.musicFreeValue, 'high');
    expect(AudioQuality.lossless.musicFreeValue, 'super');
  });

  test('LX 音质映射为 128k/320k/flac/flac24bit', () {
    expect(AudioQuality.low.lxValue, '128k');
    expect(AudioQuality.standard.lxValue, '320k');
    expect(AudioQuality.high.lxValue, 'flac');
    expect(AudioQuality.lossless.lxValue, 'flac24bit');
  });

  test('fromName 支持新档位并默认回退 high', () {
    expect(AudioQuality.fromName('low'), AudioQuality.low);
    expect(AudioQuality.fromName('standard'), AudioQuality.standard);
    expect(AudioQuality.fromName('high'), AudioQuality.high);
    expect(AudioQuality.fromName('lossless'), AudioQuality.lossless);
    expect(AudioQuality.fromName('unknown'), AudioQuality.high);
    expect(AudioQuality.fromName(null), AudioQuality.high);
  });
}
