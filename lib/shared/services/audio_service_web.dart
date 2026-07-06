// ignore_for_file: depend_on_referenced_packages
import 'package:web/web.dart' as web;
import 'audio_service_interface.dart';

class WebAudioService implements AudioServiceInterface {
  @override
  Future<void> playSuccessChime() async {
    try {
      final context = web.AudioContext();
      final now = context.currentTime;

      // Note 1: E6 (1318.51 Hz)
      final osc1 = context.createOscillator();
      final gain1 = context.createGain();
      osc1.connect(gain1);
      gain1.connect(context.destination);

      osc1.type = 'sine';
      osc1.frequency.value = 1318.51;

      // Gain Envelope
      gain1.gain.setValueAtTime(0, now);
      gain1.gain.linearRampToValueAtTime(0.12, now + 0.04);
      gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.25);

      osc1.start(now);
      osc1.stop(now + 0.25);

      // Note 2: A6 (1760.00 Hz) - Delayed by 80ms
      final osc2 = context.createOscillator();
      final gain2 = context.createGain();
      osc2.connect(gain2);
      gain2.connect(context.destination);

      osc2.type = 'sine';
      osc2.frequency.value = 1760.00;

      final delay = 0.08;
      gain2.gain.setValueAtTime(0, now + delay);
      gain2.gain.linearRampToValueAtTime(0.12, now + delay + 0.04);
      gain2.gain.exponentialRampToValueAtTime(0.001, now + delay + 0.25);

      osc2.start(now + delay);
      osc2.stop(now + delay + 0.25);
    } catch (e) {
      // AudioContext might be blocked or not supported
    }
  }
}

AudioServiceInterface getAudioService() => WebAudioService();
