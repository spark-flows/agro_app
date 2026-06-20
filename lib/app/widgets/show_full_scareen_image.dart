import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class ShowFullScareenImage extends StatelessWidget {
  const ShowFullScareenImage({super.key});

  List<dynamic> get _arguments =>
      Get.arguments is List ? Get.arguments as List<dynamic> : const [];

  String get _rawMediaUrl =>
      _arguments.isNotEmpty ? (_arguments[0]?.toString().trim() ?? '') : '';

  String get _mediaType =>
      _arguments.length > 1
          ? (_arguments[1]?.toString().toLowerCase().trim() ?? 'image')
          : 'image';

  String get _title => _mediaType == 'video' ? 'Video' : 'Image';

  String? _resolveMediaUrl(String mediaPath) {
    final trimmedPath = mediaPath.trim();
    if (trimmedPath.isEmpty) {
      return null;
    }

    final directUri = Uri.tryParse(trimmedPath);
    if (directUri != null &&
        (directUri.scheme == 'http' || directUri.scheme == 'https') &&
        directUri.host.isNotEmpty) {
      return trimmedPath;
    }

    final normalizedBase = ApiWrapper.imageUrl.endsWith('/')
        ? ApiWrapper.imageUrl
        : '${ApiWrapper.imageUrl}/';
    final normalizedPath = trimmedPath.startsWith('/')
        ? trimmedPath.substring(1)
        : trimmedPath;
    final combinedUrl = '$normalizedBase$normalizedPath';
    final combinedUri = Uri.tryParse(combinedUrl);

    if (combinedUri != null &&
        (combinedUri.scheme == 'http' || combinedUri.scheme == 'https') &&
        combinedUri.host.isNotEmpty) {
      return combinedUrl;
    }

    return null;
  }

  Widget _buildInvalidPreview({
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: ColorsValue.appBg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ColorsValue.white, size: 56),
          Dimens.boxHeight12,
          Text(label, style: Styles.whiteColorW60016),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsValue.appBg,
      appBar: AppBarWidget(
        onTapBack: () {
          Get.back();
        },
        title: _title,
      ),
      body: SafeArea(
        child: Container(
          color: ColorsValue.primary,
          child: PhotoViewGallery.builder(
            backgroundDecoration: BoxDecoration(color: ColorsValue.appBg),
            builder: (BuildContext context, int index) {
              switch (_mediaType) {
                case 'video':
                  return buildForVideo(_rawMediaUrl);
                case 'image':
                default:
                  return buildForImage(_rawMediaUrl);
              }
            },
            itemCount: 1,
          ),
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions buildForImage(String image) {
    final resolvedImageUrl = _resolveMediaUrl(image);

    if (resolvedImageUrl == null) {
      return PhotoViewGalleryPageOptions.customChild(
        child: _buildInvalidPreview(
          icon: Icons.broken_image_rounded,
          label: 'Image not available',
        ),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
      );
    }

    return PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(resolvedImageUrl),
      initialScale: PhotoViewComputedScale.contained * 1,
      minScale: PhotoViewComputedScale.contained * 1,
    );
  }

  PhotoViewGalleryPageOptions buildForVideo(String video) {
    final resolvedVideoUrl = _resolveMediaUrl(video);

    if (resolvedVideoUrl == null) {
      return PhotoViewGalleryPageOptions.customChild(
        child: _buildInvalidPreview(
          icon: Icons.videocam_off_rounded,
          label: 'Video not available',
        ),
        initialScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained,
      );
    }

    return PhotoViewGalleryPageOptions.customChild(
      child: GalleryAllVideoPlayer(resolvedVideoUrl),
      initialScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.contained,
    );
  }
}

// ignore: must_be_immutable
class GalleryAllVideoPlayer extends StatefulWidget {
  dynamic video;

  GalleryAllVideoPlayer(this.video, {super.key});

  @override
  _GalleryAllVideoPlayerState createState() => _GalleryAllVideoPlayerState();
}

class _GalleryAllVideoPlayerState extends State<GalleryAllVideoPlayer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _visible = false;

  @override
  void initState() {
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(widget.video);
    _controller!.setLooping(true);
    _initializeVideoPlayerFuture = _controller!.initialize();
    _initializeVideoPlayerFuture!.then((val) {
      setState(() {
        _controller!.play();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsValue.appBg,
      body: Stack(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
                _visible = true;
              });
              Timer(const Duration(milliseconds: 1000), () {
                setState(() {
                  _visible = false;
                });
              });
            },
            child: Center(
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    );
                  } else {
                    return const CircularProgressIndicator(color: ColorsValue.primary);
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                color: Colors.transparent,
                child: Icon(
                  !_controller!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: ColorsValue.primary,
                  size: Dimens.sixty,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: Dimens.twenty,
            left: Dimens.zero,
            right: Dimens.zero,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: Dimens.fiftyFive),
              child: VideoProgressIndicator(
                _controller!,
                padding: Dimens.edgeInsets0,
                colors: VideoProgressColors(
                  playedColor: ColorsValue.primary,
                  bufferedColor: ColorsValue.primary.withAlpha(100),
                  backgroundColor: ColorsValue.primary.withAlpha(100),
                ),
                allowScrubbing: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
