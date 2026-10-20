import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/routing/app_navigation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../services/interaction_service.dart';
import '../../services/post_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/person_avatar.dart';
import 'reply_feed_screen.dart';

const Color _lineColor = Color.fromARGB(255, 84, 79, 79);

class NotesDetailScreen extends StatefulWidget {
  final Post post;

  const NotesDetailScreen({super.key, required this.post});

  @override
  State<NotesDetailScreen> createState() => _NotesDetailScreenState();
}

class _NotesDetailScreenState extends State<NotesDetailScreen> {
  final PostService _postService = PostService();
  final InteractionService _interactionService = InteractionService();

  late Post _post;
  List<Comment> _comments = [];

  late bool _liked;
  late int _likeCount;
  late bool _restacked;
  late int _restackCount;
  late int _commentCount;

  bool _likeBusy = false;
  bool _restackBusy = false;
  bool _isLoading = true;
  String? _loadError;

  // true kalau ada aksi yang berhasil tersimpan, supaya Home memuat ulang.
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _comments = widget.post.comments;
    _liked = widget.post.likedByMe;
    _likeCount = widget.post.likesCount;
    _restacked = widget.post.restackedByMe;
    _restackCount = widget.post.restacksCount;
    _commentCount = widget.post.commentsCount;
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    try {
      final latest = await _postService.fetchPost(_post.id);
      if (!mounted) return;

      setState(() {
        _post = latest;
        _comments = latest.comments;
        _commentCount = latest.commentsCount;
        if (!_likeBusy) {
          _liked = latest.likedByMe;
          _likeCount = latest.likesCount;
        }
        if (!_restackBusy) {
          _restacked = latest.restackedByMe;
          _restackCount = latest.restacksCount;
        }
        _isLoading = false;
        _loadError = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Gagal memuat balasan.';
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    _loadLatest();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _closeScreen() {
    final post = widget.post;
    post.likedByMe = _liked;
    post.likesCount = _likeCount;
    post.restackedByMe = _restacked;
    post.restacksCount = _restackCount;
    post.commentsCount = _commentCount;

    Navigator.pop(context, _changed);
  }

  Future<void> _toggleLike() async {
    if (_likeBusy) return;

    final previousLiked = _liked;
    final previousCount = _likeCount;
    final wantLiked = !previousLiked;

    setState(() {
      _likeBusy = true;
      _liked = wantLiked;
      _likeCount = previousCount + (wantLiked ? 1 : -1);
    });

    try {
      final result =
          await _interactionService.setLike(_post.id, liked: wantLiked);
      if (!mounted) return;
      setState(() {
        _liked = result.active;
        _likeCount = result.count;
        _changed = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _liked = previousLiked;
        _likeCount = previousCount;
      });
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  Future<void> _toggleRestack() async {
    if (_restackBusy) return;

    final previousRestacked = _restacked;
    final previousCount = _restackCount;
    final wantRestacked = !previousRestacked;

    setState(() {
      _restackBusy = true;
      _restacked = wantRestacked;
      _restackCount = previousCount + (wantRestacked ? 1 : -1);
    });

    try {
      final result = await _interactionService.setRestack(
        _post.id,
        restacked: wantRestacked,
      );
      if (!mounted) return;
      setState(() {
        _restacked = result.active;
        _restackCount = result.count;
        _changed = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _restacked = previousRestacked;
        _restackCount = previousCount;
      });
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _restackBusy = false);
    }
  }

  Future<void> _openReplyScreen() async {
    final created = await Navigator.push<Comment>(
      context,
      MaterialPageRoute(builder: (_) => ReplyScreen(post: _post)),
    );

    if (created == null || !mounted) return;

    setState(() {
      _comments = [..._comments, created];
      _commentCount += 1;
      _changed = true;
    });
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    Color color = Colors.black,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(String authorName) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_horiz,
        color: Color.fromARGB(255, 123, 119, 119),
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 60),
      onSelected: (value) {
        // Aksi menu belum disambungkan.
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        _menuItem('follow', Icons.person_add_alt_1_outlined, 'Ikuti $authorName'),
        _menuItem('copy', Icons.link, 'Salin tautan'),
        _menuItem('save', Icons.bookmark_border, 'Simpan'),
        _menuItem('share', Icons.share_outlined, 'Bagikan'),
        _menuItem('download', Icons.file_download, 'Simpan sebagai gambar'),
        _menuItem('copy_teks', Icons.filter_center_focus, 'Salin teks'),
        _menuItem('scan_teks', Icons.link, 'Simpan sebagai gambar'),
        _menuItem('scan_teks', Icons.auto_awesome_outlined, 'Pindai teks AI'),
        _menuItem('close', Icons.close, 'Tampilkan lebih sedikit'),
        _menuItem(
          'hide',
          Icons.speaker_notes_off_outlined,
          'Sembunyikan penulis',
          color: Colors.redAccent,
        ),
        _menuItem('block', Icons.block, 'Blokir', color: Colors.redAccent),
        _menuItem('report', Icons.error_outline, 'Laporkan',
            color: Colors.redAccent),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authorName = _post.username ?? _post.authorName ?? 'Pengguna';
    final time = formatPostTime(_post.publishedAt);
    final hasTitle = _post.type != 'note' &&
        _post.title != null &&
        _post.title!.isNotEmpty;
    final hasImage = _post.imageUrl != null && _post.imageUrl!.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closeScreen();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: _closeScreen,
            icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
          ),
          title: const Text(
            'Note',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey, height: 1.0),
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadLatest,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              PersonAvatar(
                                name: authorName,
                                imageUrl: _post.authorAvatarUrl,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (time.isNotEmpty) ...[
                                        Text(
                                          '$time ·',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                      const Text(
                                        'Berlangganan',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _buildOptionsMenu(authorName),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (hasTitle) ...[
                        Text(
                          _post.title!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        _post.content,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      if (hasImage) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _post.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: const Color(0xFFF5F5F5),
                              alignment: Alignment.center,
                              child: const Text('Gambar tidak dapat dimuat'),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Divider(height: 1, thickness: 1, color: _lineColor),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    '${formatCount(_likeCount)} SUKA · '
                    '${formatCount(_restackCount)} RESTACK · '
                    '${formatCount(_commentCount)} BALASAN',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 65, 62, 62),
                      fontSize: 12.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: _lineColor),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          _liked ? Icons.favorite : Icons.favorite_border,
                          color: _liked ? Colors.red : Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        onPressed: _openReplyScreen,
                        icon: const Icon(Icons.chat_bubble_outline),
                        iconSize: 30,
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        onPressed: _toggleRestack,
                        icon: Icon(
                          Icons.loop_outlined,
                          color: _restacked ? AppColors.primary : Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        iconSize: 30,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: _lineColor),
                _buildReplies(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          currentIndex: 0,
          onTap: (index) => AppNavigation.onTabSelected(context, index),
        ),
      ),
    );
  }

  Widget _buildReplies() {
    if (_comments.isEmpty) {
      if (_isLoading) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }

      if (_loadError != null) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                _loadError!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(onPressed: _retry, child: const Text('Coba lagi')),
            ],
          ),
        );
      }

      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Belum ada balasan.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final comment in _comments) _ReplyTile(comment: comment),
      ],
    );
  }
}

class _ReplyTile extends StatelessWidget {
  final Comment comment;

  const _ReplyTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final name = comment.username ?? comment.authorName ?? 'Pengguna';
    final time = formatPostTime(comment.createdAt);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 5, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: _lineColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PersonAvatar(
                name: name,
                imageUrl: comment.authorAvatarUrl,
                radius: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    Row(
                      children: [
                        if (time.isNotEmpty) Text('$time ·'),
                        const Text(
                          ' Berlangganan',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
                color: _lineColor,
                iconSize: 28,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close),
                color: _lineColor,
                iconSize: 28,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 8, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.content,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.favorite_outline, color: _lineColor),
                    SizedBox(width: 20),
                    Icon(Icons.chat_bubble_outline, color: _lineColor),
                    SizedBox(width: 20),
                    Icon(Icons.loop_outlined, color: _lineColor),
                    SizedBox(width: 20),
                    Icon(Icons.share_outlined, color: _lineColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}