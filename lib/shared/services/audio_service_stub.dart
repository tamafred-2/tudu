import 'package:flutter/services.dart';
import 'audio_service_interface.dart';

class StubAudioService implements AudioServiceInterface {
  @override
  Future<void> playSuccessChime() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Safely ignore if system sound cannot be played on host system
    }
  }
}

AudioServiceInterface getAudioService() => StubAudioService();
