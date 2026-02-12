import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../../../design_system/veda_colors.dart';

/// A simple video player for Flutter web that uses a native HTML <video> element.
///
/// Provides browser-native controls (play, pause, seek, volume, fullscreen).
class WebVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;

  const WebVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height = 200,
  });

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId =
        'video-player-${widget.videoUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    _registerView();
  }

  void _registerView() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final video =
            web.document.createElement('video') as web.HTMLVideoElement;
        video.src = widget.videoUrl;
        video.controls = true;
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'contain';
        video.style.backgroundColor = '#000000';
        video.style.borderRadius = '0px';
        video.preload = 'metadata';
        return video;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: VedaColors.black,
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
