/// Conditional export: uses the native HTML video player on web,
/// and a placeholder stub on mobile platforms.
export 'web_video_player_stub.dart'
    if (dart.library.js_interop) 'web_video_player_web.dart';
