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
    _videoPlayerController =
        VideoPlayerController.asset('assets/videos/video.mp4');

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false, // hide all controls
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _togglePlayPause() {
  if (_chewieController.isPlaying) {
    _chewieController.pause(); // this pauses both video and audio
  } else {
    _chewieController.play();
  }
  setState(() {}); // update UI for play icon
}


  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.color10.withOpacity(0.15),
            AppColors.color10,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width / 15,
          horizontal: MediaQuery.of(context).size.width / 8.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Text
            Text(
              "Watch Our Product in Action",
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width / 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Experience premium quality coats through this video demonstration.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: MediaQuery.of(context).size.width / 40,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 20),

            // Video with tap-to-play/pause overlay
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 2,
                          child: Chewie(controller: _chewieController),
                        ),
                      ),
                      // Tap detector on top
                      Positioned.fill(
                        child: GestureDetector(
  onTap: _togglePlayPause,
  child: Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    child: !_chewieController.isPlaying
        ? Icon(
            Icons.play_arrow,
            color: Colors.white.withOpacity(0.8),
            size: 80,
          )
        : null,
  ),
)

                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
