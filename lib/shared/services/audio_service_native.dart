import 'package:audioplayers/audioplayers.dart';
import 'audio_service_interface.dart';

class NativeAudioService implements AudioServiceInterface {
  final AudioPlayer _player = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop)
    ..setPlayerMode(PlayerMode.lowLatency);

  @override
  Future<void> playSuccessChime() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/success_chime.wav'), volume: 0.6);
    } catch (e) {
      // Safely ignore if audio cannot be played on the host system
    }
  }
}

AudioServiceInterface getAudioService() => NativeAudioService();
