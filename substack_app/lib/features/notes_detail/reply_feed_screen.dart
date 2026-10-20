import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/post.dart';
import '../../services/comment_service.dart';
import '../../widgets/current_user_avatar.dart';
import '../../widgets/person_avatar.dart';

class ReplyScreen extends StatefulWidget {
  final Post post;

  const ReplyScreen({super.key, required this.post});

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  static const int _maxLength = 1000;

  final TextEditingController _replyController = TextEditingController();
  final CommentService _commentService = CommentService();

  bool _isPosting = false;
  String? _errorMessage;

  bool get _canPost => _replyController.text.trim().isNotEmpty && !_isPosting;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _showUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini belum tersedia')),
    );
  }

  Future<void> _submit() async {
    if (!_canPost) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isPosting = true;
      _errorMessage = null;
    });

    try {
      final comment = await _commentService.createComment(
        widget.post.id,
        _replyController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, comment);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isPosting = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPosting = false;
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final authorName = post.username ?? post.authorName ?? 'Pengguna';
    final time = formatPostTime(post.publishedAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Balas',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                disabledForegroundColor: _isPosting
                    ? Colors.white
                    : const Color(0xFFB3B3B3),
                disabledBackgroundColor: _isPosting
                    ? AppColors.primary
                    : const Color(0xFFEEEEEE),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _canPost ? _submit : null,
              child: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Posting'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PersonAvatar(name: authorName, imageUrl: post.authorAvatarUrl),
                const SizedBox(width: 15),
                Text(
                  authorName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Text(
                post.content,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF262626),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CurrentUserAvatar(radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    autofocus: true,
                    maxLines: null,
                    maxLength: _maxLength,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tinggalkan balasan...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 52),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 52),
                IconButton(
                  icon: const Icon(Icons.image_outlined, color: Colors.black87),
                  onPressed: _showUnavailable,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(right: 16),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.black87,
                  ),
                  onPressed: _showUnavailable,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(right: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black87),
                  onPressed: _showUnavailable,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}