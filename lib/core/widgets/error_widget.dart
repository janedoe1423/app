import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String? message;
  final String? title;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final Color? iconColor;
  final String? retryText;
  final bool showHomeButton;
  final VoidCallback? onGoHome;
  final String? homeButtonText;

  const AppErrorWidget({
    Key? key,
    this.message,
    this.title,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.showRetryButton = true,
    this.iconColor,
    this.retryText,
    this.showHomeButton = false,
    this.onGoHome,
    this.homeButtonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultMessage = 'Something went wrong. Please try again.';
    final defaultTitle = 'Oops!';
    final defaultIconColor = AppTheme.errorColor;
    final defaultRetryText = 'Retry';
    final defaultHomeButtonText = 'Go Home';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? defaultIconColor,
            ),
            const SizedBox(height: 24),
            Text(
              title ?? defaultTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? defaultMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (showRetryButton && onRetry != null)
              AppButton(
                text: retryText ?? defaultRetryText,
                onPressed: onRetry,
                type: AppButtonType.primary,
                width: 140,
                height: 48,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            if (showRetryButton && onRetry != null && showHomeButton && onGoHome != null)
              const SizedBox(height: 16),
            if (showHomeButton && onGoHome != null)
              AppButton(
                text: homeButtonText ?? defaultHomeButtonText,
                onPressed: onGoHome,
                type: AppButtonType.outline,
                width: 140,
                height: 48,
                icon: const Icon(
                  Icons.home,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Factory constructor for network error
  factory AppErrorWidget.network({
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    return AppErrorWidget(
      title: 'No Connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      iconColor: Colors.grey,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      retryText: 'Try Again',
    );
  }

  // Factory constructor for empty state
  factory AppErrorWidget.empty({
    String? message,
    VoidCallback? onRetry,
    bool showRetryButton = false,
    String? title,
  }) {
    return AppErrorWidget(
      title: title ?? 'Nothing Found',
      message: message ?? 'There are no items to display.',
      icon: Icons.inbox_outlined,
      iconColor: Colors.amber,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      retryText: 'Refresh',
    );
  }

  // Factory constructor for permission denied
  factory AppErrorWidget.permissionDenied({
    String? message,
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    return AppErrorWidget(
      title: 'Permission Denied',
      message: message ?? 'You don\'t have permission to access this resource.',
      icon: Icons.no_encryption_gmailerrorred,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      retryText: 'Request Access',
    );
  }

  // Factory constructor for server error
  factory AppErrorWidget.serverError({
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    return AppErrorWidget(
      title: 'Server Error',
      message: 'Our servers are currently experiencing issues. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
    );
  }

  // Factory constructor for maintenance
  factory AppErrorWidget.maintenance({
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    return AppErrorWidget(
      title: 'Under Maintenance',
      message: 'The app is currently under maintenance. Please try again later.',
      icon: Icons.build,
      iconColor: Colors.orange,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      retryText: 'Check Status',
    );
  }
}