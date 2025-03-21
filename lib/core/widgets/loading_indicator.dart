import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum LoadingSize {
  small,
  medium,
  large,
}

class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final double? strokeWidth;
  final String? message;
  final bool isOverlay;

  const LoadingIndicator({
    Key? key,
    this.size = LoadingSize.medium,
    this.color,
    this.strokeWidth,
    this.message,
    this.isOverlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? AppTheme.primaryColor;
    final double indicatorSize = _getSize();
    final double indicatorStrokeWidth = strokeWidth ?? _getStrokeWidth();

    final Widget indicator = SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: indicatorStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
      ),
    );

    if (isOverlay) {
      return _buildOverlay(context, indicator);
    }

    if (message != null) {
      return _buildWithMessage(context, indicator);
    }

    return indicator;
  }

  Widget _buildOverlay(BuildContext context, Widget indicator) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: _buildWithMessage(context, indicator),
      ),
    );
  }

  Widget _buildWithMessage(BuildContext context, Widget indicator) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  double _getSize() {
    switch (size) {
      case LoadingSize.small:
        return 16.0;
      case LoadingSize.medium:
        return 24.0;
      case LoadingSize.large:
        return 36.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2.0;
      case LoadingSize.medium:
        return 3.0;
      case LoadingSize.large:
        return 4.0;
    }
  }
}