import 'package:flutter/material.dart';

enum LoadingType {
  circular,
  linear,
  shimmer,
  skeleton,
  dots,
}

class LoadingStateWidget extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;
  final Widget? child;

  const LoadingStateWidget({
    Key? key,
    this.type = LoadingType.circular,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
    this.child,
  }) : super(key: key);

  @override
  State<LoadingStateWidget> createState() => _LoadingStateWidgetState();
}

class _LoadingStateWidgetState extends State<LoadingStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.primaryColor;
    final size = widget.size ?? 40.0;

    Widget loadingWidget;

    switch (widget.type) {
      case LoadingType.circular:
        loadingWidget = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 3.0,
          ),
        );
        break;

      case LoadingType.linear:
        loadingWidget = SizedBox(
          width: size * 3,
          child: LinearProgressIndicator(
            color: color,
            backgroundColor: color.withOpacity(0.2),
          ),
        );
        break;

      case LoadingType.shimmer:
        loadingWidget = _buildShimmerEffect(size, color);
        break;

      case LoadingType.skeleton:
        loadingWidget = _buildSkeletonLoader(size, color);
        break;

      case LoadingType.dots:
        loadingWidget = _buildDotsLoader(size, color);
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          if (widget.showMessage && widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (widget.child != null) ...[
            const SizedBox(height: 16),
            widget.child!,
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(double size, Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: size * 3,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader(double size, Color color) {
    return Column(
      children: [
        Container(
          width: size * 3,
          height: size * 0.4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: size * 2,
          height: size * 0.3,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildDotsLoader(double size, Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value + delay) % 1.0;
            final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  final LoadingType loadingType;
  final Color? overlayColor;
  final Color? loadingColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.loadingType = LoadingType.circular,
    this.overlayColor,
    this.loadingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.5),
            child: LoadingStateWidget(
              type: loadingType,
              message: loadingMessage,
              color: loadingColor,
            ),
          ),
      ],
    );
  }
}

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final String? loadingText;
  final ButtonStyle? style;
  final LoadingType loadingType;

  const LoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.loadingText,
    this.style,
    this.loadingType = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                if (loadingText != null) ...[
                  const SizedBox(width: 8),
                  Text(loadingText!),
                ],
              ],
            )
          : child,
    );
  }
}

class PullToRefreshWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final String? refreshMessage;

  const PullToRefreshWrapper({
    Key? key,
    required this.onRefresh,
    required this.child,
    this.refreshMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
