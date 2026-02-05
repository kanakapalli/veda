import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Service to play raw PCM audio data from Gemini Live API
/// Gemini outputs 24kHz, 16-bit PCM audio
class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  web.AudioContext? _audioContext;
  final List<Uint8List> _audioQueue = [];
  bool _isPlaying = false;
  double _nextPlayTime = 0;
  bool _isMuted = false;

  static const int _sampleRate = 24000; // Gemini outputs 24kHz

  bool get isMuted => _isMuted;

  set muted(bool value) {
    _isMuted = value;
    if (_isMuted) {
      stop();
    }
  }

  void _ensureContext() {
    _audioContext ??= web.AudioContext();
  }

  /// Queue audio data for playback
  /// [audioData] should be raw PCM 16-bit little-endian at 24kHz
  void playAudio(Uint8List audioData) {
    if (audioData.isEmpty || _isMuted) return;

    debugPrint('[AudioPlayerService] Queuing ${audioData.length} bytes');
    _audioQueue.add(audioData);

    if (!_isPlaying) {
      _playNext();
    }
  }

  void _playNext() {
    if (_audioQueue.isEmpty) {
      _isPlaying = false;
      return;
    }

    _isPlaying = true;
    _ensureContext();

    final audioData = _audioQueue.removeAt(0);

    try {
      // Convert PCM16 to Float32 for Web Audio API
      final samples = _pcm16ToFloat32(audioData);

      // Create audio buffer
      final buffer = _audioContext!.createBuffer(
        1, // mono
        samples.length,
        _sampleRate,
      );

      // Copy samples to buffer using copyToChannel
      buffer.copyToChannel(samples.toJS, 0);

      // Create source node
      final source = _audioContext!.createBufferSource();
      source.buffer = buffer;
      source.connect(_audioContext!.destination);

      // Schedule playback
      final currentTime = _audioContext!.currentTime;
      final startTime = _nextPlayTime > currentTime ? _nextPlayTime : currentTime;

      source.start(startTime);
      _nextPlayTime = startTime + buffer.duration;

      // Schedule next chunk
      final durationMs = (buffer.duration * 1000).toInt();
      Future.delayed(Duration(milliseconds: durationMs - 50), _playNext);

      debugPrint('[AudioPlayerService] Playing ${samples.length} samples, duration=${buffer.duration}s');
    } catch (e) {
      debugPrint('[AudioPlayerService] Error playing audio: $e');
      _isPlaying = false;
      // Try next chunk
      Future.delayed(const Duration(milliseconds: 10), _playNext);
    }
  }

  /// Convert PCM 16-bit little-endian to Float32 [-1.0, 1.0]
  Float32List _pcm16ToFloat32(Uint8List pcmData) {
    final numSamples = pcmData.length ~/ 2;
    final float32 = Float32List(numSamples);
    final byteData = ByteData.sublistView(pcmData);

    for (var i = 0; i < numSamples; i++) {
      final sample = byteData.getInt16(i * 2, Endian.little);
      float32[i] = sample / 32768.0;
    }

    return float32;
  }

  /// Stop all playback and clear queue
  void stop() {
    _audioQueue.clear();
    _isPlaying = false;
    _nextPlayTime = 0;
    debugPrint('[AudioPlayerService] Stopped');
  }

  /// Dispose resources
  void dispose() {
    stop();
    _audioContext?.close();
    _audioContext = null;
  }
}
