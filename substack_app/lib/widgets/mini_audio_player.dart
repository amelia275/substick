import 'package:flutter/material.dart';

import '../features/podcast/podcast_player_controller.dart';
import '../features/podcast/podcast_player_screen.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PodcastPlayerController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final episode = controller.currentEpisode;
        if (episode == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PodcastPlayerScreen(),
              ),
            );
          },
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: const Color(0xFF0A0A0A),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    episode.coverUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFFDDE3DC),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.podcasts,
                        color: Colors.black87,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        episode.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.togglePlayPause,
                  icon: Icon(
                    controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: controller.closeMiniPlayer,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
