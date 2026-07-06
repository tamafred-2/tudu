import 'audio_service_interface.dart';
import 'audio_service_stub.dart'
    if (dart.library.html) 'audio_service_web.dart';

class AudioService {
  static final AudioServiceInterface _instance = getAudioService();

  static AudioServiceInterface get instance => _instance;
}
