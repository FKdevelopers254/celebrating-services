import 'dart:ui';

import '../models/post.dart';
import '../widgets/app_buttons.dart';
import '../widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/comment.dart';
import 'comments_modal.dart';
import 'video_player_widget.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final ValueNotifier<bool>? feedMuteNotifier; // Add this for feed mute state
  const PostCard({super.key, required this.post, this.feedMuteNotifier});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _currentRating;
  late int _currentPage;
  late PageController _pageController;
  late bool _isContentExpanded; //For text expansion in view more
  late bool _isRatingSectionActive;
  ValueNotifier<bool>? _muteNotifier;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.post.likesCount ?? 0;
    _currentPage = 0;
    _pageController = PageController();
    _isContentExpanded = false;
    _isRatingSectionActive = false;
    _muteNotifier = widget.feedMuteNotifier;
    _muteNotifier?.addListener(_onMuteChanged);
  }

  void _onMuteChanged() {
    setState(() {}); // Rebuild to update mute state in video widgets
  }

  void _showCommentsModal(BuildContext context, List<Comment> comments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take up more height
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor:
              0.85, // Adjust this to control how much screen height the modal takes
          child: CommentsModal(comments: comments, postId: widget.post.id),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _currentRating = widget.post.likesCount ?? 0;
      _currentPage = 0;
      _pageController = PageController();
      _isContentExpanded = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _muteNotifier?.removeListener(_onMuteChanged);
    // Only pause (do not dispose) the current video when this post card is disposed
    PostCardVideoPlaybackManager().pauseCurrent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildPostContent(),
          _buildMediaSection(), // Add media section with safe video player usage
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(
          radius: 20,
          imageUrl: '', // No author image available in new model
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.post.userId,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              Text(
                widget.post.userId,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        AppTextButton(
          text: 'Follow',
          onPressed: () {
            print('Follow button pressed!');
          },
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    final maxLines = 3;
    final content = widget.post.content;
    final textStyle = const TextStyle(fontSize: 14);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moreColor = Colors.grey[600];
    final span = TextSpan(text: content, style: textStyle);
    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 70);

    final bool isOverflow = tp.didExceedMaxLines;
    String visibleText = content;
    if (!_isContentExpanded && isOverflow) {
      int endIndex =
          tp.getPositionForOffset(Offset(tp.width, tp.height)).offset;
      if (endIndex < content.length) {
        int lastSpace = content.lastIndexOf(' ', endIndex);
        if (lastSpace > 0) endIndex = lastSpace;
      }
      visibleText = content.substring(0, endIndex).trim();
    }

    String timeAgo = '';
    if (widget.post.createdAt != null) {
      final now = DateTime.now();
      final diff = now.difference(widget.post.createdAt!);
      if (diff.inSeconds < 60) {
        timeAgo = '${diff.inSeconds}s ago';
      } else if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours}h ago';
      } else {
        timeAgo = '${diff.inDays}d ago';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(timeAgo, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        if (!_isContentExpanded && isOverflow)
          GestureDetector(
            onTap: () {
              setState(() {
                _isContentExpanded = true;
              });
            },
            child: RichText(
              text: TextSpan(
                style: textStyle.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
                children: [
                  TextSpan(text: visibleText),
                  TextSpan(
                    text: '       ... more',
                    style: textStyle.copyWith(
                      color: moreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          GestureDetector(
            onTap: () {
              if (isOverflow) {
                setState(() {
                  _isContentExpanded = false;
                });
              }
            },
            child: RichText(
              text: TextSpan(
                style: textStyle.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
                children: [
                  TextSpan(text: content),
                  if (isOverflow)
                    TextSpan(
                      text: '  show less',
                      style: textStyle.copyWith(
                        color: moreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaSection() {
    if (widget.post.mediaUrls.isEmpty) {
      return SizedBox.shrink();
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(0.0),
      child: AspectRatio(
        aspectRatio: 16 / 12,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.post.mediaUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, i) {
                final url = widget.post.mediaUrls[i];
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                );
              },
            ),
            if (widget.post.mediaUrls.length > 1)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${widget.post.mediaUrls.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    // Use likesCount as a placeholder for rating
    final int rating = widget.post.likesCount ?? 0;
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_rounded, color: Colors.orange, size: 30),
          const SizedBox(width: 4),
          Text('$rating', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            PostActionButton(
              icon: Icons.thumb_up_alt_outlined,
              text: '${widget.post.likesCount ?? 0}',
              onPressed: () {
                print(
                  'Like toggled for Post ${widget.post.id}. Current likes: ${widget.post.likesCount ?? 0}',
                );
              },
            ),
            PostActionButton(
              icon: Icons.comment_outlined,
              text: '${widget.post.commentsCount ?? 0}',
              onPressed: () {
                // Comments functionality placeholder
                print('Comments for Post ${widget.post.id}');
              },
            ),
          ],
        ),
        Row(
          children: [
            PostActionButton(
              icon: Icons.repeat_outlined,
              onPressed: () {
                print('Repost Post ${widget.post.id}');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post Reposted!')));
              },
            ),
            PostActionButton(
              icon: Icons.send_outlined,
              onPressed: () {
                print('Send Post ${widget.post.id}');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post Sent!')));
              },
            ),
          ],
        ),
      ],
    );
  }
}
