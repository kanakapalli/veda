import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

/// Service for recording audio from microphone
/// Streams PCM audio data for real-time processing
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _streamSubscription;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Callback for audio data chunks
  void Function(Uint8List)? onAudioData;

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    return await _recorder.hasPermission();
  }

  /// Start recording audio
  /// Streams PCM 16-bit, 16kHz mono audio for Gemini Live API
  Future<void> startRecording() async {
    if (_isRecording) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    // Configure for PCM streaming
    final config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 256000,
    );

    // Start streaming
    final stream = await _recorder.startStream(config);
    _isRecording = true;

    _streamSubscription = stream.listen(
      (data) {
        onAudioData?.call(data);
      },
      onError: (error) {
        _isRecording = false;
      },
      onDone: () {
        _isRecording = false;
      },
    );
  }

  /// Stop recording
  Future<void> stopRecording() async {
    if (!_isRecording) return;

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    await _recorder.stop();
    _isRecording = false;
  }

  /// Dispose resources
  void dispose() {
    stopRecording();
    _recorder.dispose();
  }
}
