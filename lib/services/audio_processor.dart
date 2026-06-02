// import 'package:flutter_audio_toolkit/flutter_audio_toolkit.dart';

final audioProcessor = AudioProcessor();

class AudioProcessor {
  // final audioToolkit = FlutterAudioToolkit();

  Future<void> processAudio() async {
    // Your audio processing code here
  }

  // Future<void> converter(String input, String output) async {
  //   final audioInfo = await audioToolkit.getAudioInfo(input);
  //   final durationMs = audioInfo.durationMs ?? 0;
  //   audioToolkit.trimAudio(
  //     inputPath: input,
  //     outputPath: output,
  //     startTimeMs: 0,
  //     endTimeMs: durationMs,
  //     format: AudioFormat.m4a,
  //   );
  // }
}
