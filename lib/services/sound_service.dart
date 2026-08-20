import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;
  bool _isMuted = false;

  static const String _muteKey = 'tamabrawler_mute';

  Future<void> init() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    // Load mute preference
    final prefs = await SharedPreferences.getInstance();
    _isMuted = prefs.getBool(_muteKey) ?? false;
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_muteKey, _isMuted);

    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }

  bool get isMuted => _isMuted;

  Future<void> playBgm() async {
    if (!_isMuted) {
      await _bgmPlayer.play(AssetSource('audio/bgm_loop.wav'));
    }
  }

  Future<void> playSfx(String name) async {
    if (!_isMuted) {
      await _sfxPlayer.play(AssetSource('audio/$name.wav'));
    }
  }
}
