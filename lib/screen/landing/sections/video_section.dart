import 'package:flutter/material.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoSection extends StatefulWidget {
  const VideoSection({super.key});

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset('assets/videos/video.mp4');
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: true,
      showControls: false,
    );

    _videoPlayerController.addListener(() {
      if (mounted) setState(() {});
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _togglePlayPause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.color10,
            AppColors.color5,
            Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.width / 15,
          horizontal: size.width / 8.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              "Watch Our Product in Action",
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width / 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Experience premium quality coats through this video demonstration.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: size.width / 40,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.width / 20),

            // === VIDEO SECTION ===
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ✨ Video with gradient fade matching background
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.color10.withOpacity(0.3),
                                  AppColors.color5.withOpacity(0.6),
                                  Colors.white.withOpacity(0.8),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.softLight,
                            child: AspectRatio(
                              aspectRatio: _videoPlayerController.value.aspectRatio != 0
                                  ? _videoPlayerController.value.aspectRatio
                                  : 16 / 9,
                              child: SizedBox(
                                width: double.infinity,
                                child: Chewie(controller: _chewieController),
                              ),
                            ),
                          ),
                        ),

                        // Tap-to-play overlay
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: !_videoPlayerController.value.isPlaying
                                  ? Icon(
                                      Icons.play_arrow,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 80,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
