import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedImageViewer extends StatefulWidget {
  final String? imageUrl;
  final String? heroTag;
  final Widget? placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableFullscreen;
  final bool enableZoom;

  const EnhancedImageViewer({
    super.key,
    this.imageUrl,
    this.heroTag,
    this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.enableFullscreen = true,
    this.enableZoom = true,
  });

  @override
  State<EnhancedImageViewer> createState() => _EnhancedImageViewerState();
}

class _EnhancedImageViewerState extends State<EnhancedImageViewer> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget = Image.network(
      widget.imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _isLoading = false;
          return child;
        }
        return _buildLoadingIndicator(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        _hasError = true;
        return _buildErrorWidget();
      },
    );

    if (widget.enableFullscreen) {
      imageWidget = GestureDetector(
        onTap: () => _openFullscreen(context),
        child: imageWidget,
      );
    }

    if (widget.heroTag != null) {
      imageWidget = Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.person,
            size: (widget.width ?? 100) * 0.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: (widget.width ?? 100) * 0.3,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullscreenImageViewer(
            imageUrl: widget.imageUrl!,
            heroTag: widget.heroTag,
            enableZoom: widget.enableZoom,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final bool enableZoom;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.enableZoom = true,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on tap outside
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          // Image viewer
          Center(
            child: widget.enableZoom
                ? InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 4.0,
                    onInteractionEnd: (details) {
                      _resetZoomIfNeeded();
                    },
                    child: _buildImage(),
                  )
                : _buildImage(),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Zoom controls (if zoom is enabled)
          if (widget.enableZoom)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              right: 16,
              child: Column(
                children: [
                  _buildZoomButton(Icons.zoom_in, () => _zoomIn()),
                  const SizedBox(height: 8),
                  _buildZoomButton(Icons.zoom_out, () => _zoomOut()),
                  const SizedBox(height: 8),
                  _buildZoomButton(Icons.zoom_out_map, () => _resetZoom()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    Widget imageWidget = Image.network(
      widget.imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image,
                size: 64,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        );
      },
    );

    if (widget.heroTag != null) {
      imageWidget = Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 4.0) {
      _animateToScale(currentScale * 1.5);
    }
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 0.5) {
      _animateToScale(currentScale / 1.5);
    }
  }

  void _resetZoom() {
    _animateToScale(1.0);
  }

  void _resetZoomIfNeeded() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 1.0) {
      _animateToScale(1.0);
    }
  }

  void _animateToScale(double scale) {
    _animation?.removeListener(_onAnimationUpdate);
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity()..scale(scale),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animation!.addListener(_onAnimationUpdate);
    _animationController.forward(from: 0);
  }

  void _onAnimationUpdate() {
    _transformationController.value = _animation!.value;
  }
}
