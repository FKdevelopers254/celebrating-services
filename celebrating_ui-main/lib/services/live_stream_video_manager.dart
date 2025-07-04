import 'package:video_player/video_player.dart'; // Ensure this is in your pubspec.yaml

class LiveStreamVideoManager {
  static final LiveStreamVideoManager _instance =
      LiveStreamVideoManager._internal();
  factory LiveStreamVideoManager() => _instance;
  LiveStreamVideoManager._internal();

  final Map<String, VideoPlayerController?> _controllers = {};

  VideoPlayerController getController(String streamUrl, String streamId) {
    if (_controllers.containsKey(streamId) && _controllers[streamId] != null) {
      return _controllers[streamId]!;
    } else {
      final controller = VideoPlayerController.network(streamUrl)
        ..setLooping(true)
        ..setVolume(0.0);
      _controllers[streamId] = controller;
      controller.initialize();
      return controller;
    }
  }

  void disposeController(String streamId) {
    _controllers[streamId]?.dispose();
    _controllers.remove(streamId);
  }

  void pauseAllExcept(String streamId) {
    _controllers.forEach((id, controller) {
      if (id != streamId && controller != null && controller.value.isPlaying) {
        controller.pause();
      }
    });
  }

  void play(String streamId) {
    _controllers[streamId]?.play();
  }

  void mute(String streamId) {
    _controllers[streamId]?.setVolume(0.0);
  }

  void unmute(String streamId) {
    _controllers[streamId]?.setVolume(1.0);
  }
}
