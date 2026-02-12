import 'package:flutter/material.dart';

import '../../../../design_system/veda_colors.dart';

/// Stub video player for non-web platforms.
/// Shows a placeholder since native HTML video is not available.
class WebVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final double height;

  const WebVideoPlayer({
    super.key,
    required this.videoUrl,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: VedaColors.black,
        border: Border.all(color: VedaColors.zinc800, width: 1),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: Colors.white54, size: 40),
            SizedBox(height: 8),
            Text(
              'Video playback is only\navailable on web',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
