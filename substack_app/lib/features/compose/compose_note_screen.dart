import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/post_service.dart';
import '../../state/current_user_state.dart';
import '../../widgets/current_user_avatar.dart';

const Color _chipColor = Color(0xFFEEEEEE);

class ComposeNoteScreen extends StatefulWidget {
  const ComposeNoteScreen({super.key});

  @override
  State<ComposeNoteScreen> createState() => _ComposeNoteScreenState();
}

class _ComposeNoteScreenState extends State<ComposeNoteScreen> {
  static const int _maxLength = 2000;

  final _controller = TextEditingController();
  final _postService = PostService();

  bool _isPosting = false;
  String? _errorMessage;

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    CurrentUserState.ensureLoaded();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini belum tersedia')),
    );
  }

  Future<void> _close() async {
    if (_isPosting) return;

    if (!_hasText) {
      Navigator.pop(context);
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buang catatan ini?'),
        content: const Text('Teks yang sudah kamu tulis akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Lanjut menulis'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Buang',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (discard == true && mounted) Navigator.pop(context);
  }

  Future<void> _post() async {
    if (!_hasText || _isPosting) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isPosting = true;
      _errorMessage = null;
    });

    try {
      await _postService.createNote(_controller.text.trim());
      if (!mounted) return;
      Navigator.pop(context, true);
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
    return PopScope(
      canPop: !_hasText && !_isPosting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CurrentUserAvatar(radius: 17),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              maxLines: null,
                              maxLength: _maxLength,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                fontSize: 19,
                                height: 1.35,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Tulis sesuatu…',
                                hintStyle: TextStyle(
                                  fontSize: 19,
                                  color: Color(0xFFA9A9A9),
                                ),
                                border: InputBorder.none,
                                counterText: '',
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 22),
                      _buildToolbar(),
                    ],
                  ),
                ),
              ),
              _buildShortcuts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                onPressed: _close,
                icon: const Icon(
                  Icons.close,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const Text(
            'Catatan baru',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _showUnavailable,
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildActionPill(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Draf" saat kosong, berubah menjadi tombol oranye "Posting" saat ada teks.
  Widget _buildActionPill() {
    final canPost = _hasText;

    return GestureDetector(
      onTap: canPost ? _post : _showUnavailable,
      child: Container(
        constraints: const BoxConstraints(minWidth: 52),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: canPost ? AppColors.primary : _chipColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isPosting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                canPost ? 'Posting' : 'Draf',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: canPost ? Colors.white : AppColors.textPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildToolbar() {
    const icons = [
      Icons.photo_library,
      Icons.photo_camera,
      Icons.align_horizontal_left,
      Icons.more_horiz,
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          for (final icon in icons)
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: InkResponse(
                onTap: _showUnavailable,
                child: Icon(icon, size: 26, color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShortcuts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
      child: Row(
        children: [
          _ComposeShortcut(
            leading: const Icon(
              Icons.article,
              size: 22,
              color: AppColors.textPrimary,
            ),
            label: 'Artikel',
            onTap: _showUnavailable,
          ),
          const SizedBox(width: 15),
          _ComposeShortcut(
            leading: const _LiveBadge(),
            label: 'Mulai Live',
            onTap: _showUnavailable,
          ),
          const SizedBox(width: 15),
          _ComposeShortcut(
            leading: const Icon(
              Icons.videocam,
              size: 22,
              color: AppColors.textPrimary,
            ),
            label: 'Rekam',
            onTap: _showUnavailable,
          ),
        ],
      ),
    );
  }
}

class _ComposeShortcut extends StatelessWidget {
  final Widget leading;
  final String label;
  final VoidCallback onTap;

  const _ComposeShortcut({
    required this.leading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: _chipColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 22,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: leading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE84A4A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}