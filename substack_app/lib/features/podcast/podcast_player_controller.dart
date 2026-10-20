import 'dart:async';
import 'package:flutter/material.dart';

class PodcastCommentData {
  final String username;
  final String dateText;
  final String? likedByAuthor;
  final String content;
  final int likesCount;
  final String? repliesSummary;
  final Color avatarColor;

  const PodcastCommentData({
    required this.username,
    required this.dateText,
    this.likedByAuthor,
    required this.content,
    required this.likesCount,
    this.repliesSummary,
    this.avatarColor = const Color(0xFF4A5568),
  });
}

class PodcastEpisodeItem {
  final String id;
  final String showTitle;
  final String publicationName;
  final String authorName;
  final String timeAgo;
  final String publishedDateText;
  final String title;
  final String subtitle;
  final String articleBody;
  final String captionSnippet;
  final String coverUrl;
  final String thumbnailUrl;
  final int totalDurationSeconds;
  final int likesCount;
  final int restacksCount;
  final List<PodcastCommentData> comments;

  const PodcastEpisodeItem({
    required this.id,
    required this.showTitle,
    required this.publicationName,
    required this.authorName,
    required this.timeAgo,
    required this.publishedDateText,
    required this.title,
    required this.subtitle,
    required this.articleBody,
    required this.captionSnippet,
    required this.coverUrl,
    required this.thumbnailUrl,
    required this.totalDurationSeconds,
    this.likesCount = 4,
    this.restacksCount = 1,
    this.comments = const [],
  });
}

class PodcastPlayerController extends ChangeNotifier {
  PodcastPlayerController._();

  static final PodcastPlayerController instance = PodcastPlayerController._();

  PodcastEpisodeItem? _currentEpisode;
  bool _isPlaying = false;
  int _positionSeconds = 0;
  double _playbackSpeed = 1.0;
  Timer? _timer;

  // Menyimpan posisi terakhir tiap episode agar tombol di daftar berubah jadi progress bar
  final Map<String, int> _savedPositions = {};

  PodcastEpisodeItem? get currentEpisode => _currentEpisode;
  bool get isPlaying => _isPlaying;
  int get positionSeconds => _positionSeconds;
  double get playbackSpeed => _playbackSpeed;

  int get totalSeconds => _currentEpisode?.totalDurationSeconds ?? 0;

  double get progress {
    if (totalSeconds <= 0) return 0;
    return (_positionSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  bool hasProgressFor(String episodeId) {
    return (_savedPositions[episodeId] ?? 0) > 0;
  }

  double progressFor(String episodeId, int episodeTotalSeconds) {
    if (episodeTotalSeconds <= 0) return 0;
    final pos = _savedPositions[episodeId] ?? 0;
    return (pos / episodeTotalSeconds).clamp(0.0, 1.0);
  }

  String remainingLabelFor(String episodeId, int episodeTotalSeconds) {
    final pos = _savedPositions[episodeId] ?? 0;
    if (pos <= 0) {
      final mins = (episodeTotalSeconds / 60).round();
      return '${mins}mnt';
    }
    final remaining = (episodeTotalSeconds - pos).clamp(0, episodeTotalSeconds);
    final mins = remaining ~/ 60;
    final secs = remaining % 60;
    return '${mins}mnt ${secs}dtk';
  }

  void playEpisode(PodcastEpisodeItem episode) {
    if (_currentEpisode?.id != episode.id) {
      _currentEpisode = episode;
      _positionSeconds = _savedPositions[episode.id] ?? 12;
      _savedPositions[episode.id] = _positionSeconds;
    }
    _isPlaying = true;
    _startTimer();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_currentEpisode == null) return;
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _startTimer();
    } else {
      _stopTimer();
    }
    notifyListeners();
  }

  void seekToSeconds(int seconds) {
    if (_currentEpisode == null) return;
    _positionSeconds = seconds.clamp(0, totalSeconds);
    _savedPositions[_currentEpisode!.id] = _positionSeconds;
    notifyListeners();
  }

  void skipBackward10() {
    seekToSeconds(_positionSeconds - 10);
  }

  void skipForward30() {
    seekToSeconds(_positionSeconds + 30);
  }

  void cycleSpeed() {
    const speeds = [1.0, 1.25, 1.5, 2.0];
    final currentIdx = speeds.indexOf(_playbackSpeed);
    _playbackSpeed = speeds[(currentIdx + 1) % speeds.length];
    notifyListeners();
  }

  void closeMiniPlayer() {
    _stopTimer();
    _isPlaying = false;
    _currentEpisode = null;
    notifyListeners();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying || _currentEpisode == null) return;
      if (_positionSeconds < totalSeconds) {
        _positionSeconds += 1;
        _savedPositions[_currentEpisode!.id] = _positionSeconds;
        notifyListeners();
      } else {
        _isPlaying = false;
        _stopTimer();
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  static String formatClock(int seconds) {
    final safe = seconds.clamp(0, 359999);
    final mins = (safe ~/ 60).toString().padLeft(2, '0');
    final secs = (safe % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
