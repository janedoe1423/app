import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
  outlined, // Alternative name for outline for backward compatibility
  text,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final bool fullWidth; // Alternative name for isFullWidth for backward compatibility
  final IconData? icon;
  final bool iconOnly;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? borderRadius;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.fullWidth = false,
    this.icon,
    this.iconOnly = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button style based on type
    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = _buildPrimaryButton(context);
        break;
      case AppButtonType.secondary:
        button = _buildSecondaryButton(context);
        break;
      case AppButtonType.outline:
      case AppButtonType.outlined: // Handle both outline and outlined
        button = _buildOutlineButton(context);
        break;
      case AppButtonType.text:
        button = _buildTextButton(context);
        break;
    }

    // Apply full width if needed
    if (isFullWidth || fullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: backgroundColor == null ? AppTheme.primaryContrastText :
            AppTheme.textPrimaryLightColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        elevation: 2,
        disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
        disabledForegroundColor: AppTheme.textPrimaryLightColor.withOpacity(0.7),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.secondaryColor,
        foregroundColor: textColor ?? AppTheme.textPrimaryDarkColor,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
        elevation: 1,
        disabledBackgroundColor: AppTheme.secondaryColor.withOpacity(0.5),
        disabledForegroundColor: AppTheme.textPrimaryDarkColor.withOpacity(0.7),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton(BuildContext context) {
    return OutlinedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryColor,
        padding: _getPadding(),
        backgroundColor: backgroundColor,
        side: BorderSide(
          color: (isDisabled || isLoading)
              ? AppTheme.primaryColor.withOpacity(0.5)
              : AppTheme.primaryColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryColor,
        padding: _getPadding(),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(_getLoaderColor()),
        ),
      );
    }

    if (iconOnly && icon != null) {
      return Icon(icon);
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: iconOnly ? 0 : 8),
          if (!iconOnly) _buildTextWidget(),
        ],
      );
    }

    return _buildTextWidget();
  }

  Widget _buildTextWidget() {
    final bool isOutlined = type == AppButtonType.outline ||
        type == AppButtonType.outlined ||
        type == AppButtonType.text;
    final Color color = isOutlined ? AppTheme.primaryColor : AppTheme.primaryContrastText;

    return Text(
      text,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
        color: textColor ?? color,
      ),
    );
  }

  EdgeInsets _getPadding() {
    if (padding != null) {
      return padding!;
    }

    if (iconOnly) {
      switch (size) {
        case AppButtonSize.small:
          return const EdgeInsets.all(8);
        case AppButtonSize.medium:
          return const EdgeInsets.all(12);
        case AppButtonSize.large:
          return const EdgeInsets.all(16);
      }
    }

    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  Color _getLoaderColor() {
    switch (type) {
      case AppButtonType.primary:
        return AppTheme.textPrimaryLightColor;
      case AppButtonType.secondary:
        return AppTheme.textPrimaryDarkColor;
      case AppButtonType.outline:
      case AppButtonType.text:
      case AppButtonType.outlined:
        return AppTheme.primaryColor;
    }
  }
}