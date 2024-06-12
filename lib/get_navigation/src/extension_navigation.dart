import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_snack_bar/get_core/get_core.dart';

import '../../get_snack_bar.dart';

extension ExtensionSnackbar on GetInterface {
  SnackbarController rawSnackbar(
    BuildContext context, {
    String? title,
    String? message,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool instantInit = true,
    bool shouldIconPulse = true,
    double? maxWidth,
    EdgeInsets margin = const EdgeInsets.all(0.0),
    EdgeInsets padding = const EdgeInsets.all(16),
    double borderRadius = 0.0,
    Color? borderColor,
    double borderWidth = 1.0,
    Color backgroundColor = const Color(0xFF303030),
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    Widget? mainButton,
    OnTap? onTap,
    Duration? duration = const Duration(seconds: 3),
    bool isDismissible = true,
    DismissDirection? dismissDirection,
    bool showProgressIndicator = false,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackPosition snackPosition = SnackPosition.bottom,
    SnackStyle snackStyle = SnackStyle.floating,
    Curve forwardAnimationCurve = Curves.easeOutCirc,
    Curve reverseAnimationCurve = Curves.easeOutCirc,
    Duration animationDuration = const Duration(seconds: 1),
    SnackbarStatusCallback? snackbarStatus,
    double barBlur = 0.0,
    double overlayBlur = 0.0,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final getSnackBar = SSSnackBar(
      snackbarStatus: snackbarStatus,
      title: title,
      message: message,
      titleText: titleText,
      messageText: messageText,
      snackPosition: snackPosition,
      borderRadius: borderRadius,
      margin: margin,
      duration: duration,
      barBlur: barBlur,
      backgroundColor: backgroundColor,
      icon: icon,
      shouldIconPulse: shouldIconPulse,
      maxWidth: maxWidth,
      padding: padding,
      borderColor: borderColor,
      borderWidth: borderWidth,
      leftBarIndicatorColor: leftBarIndicatorColor,
      boxShadows: boxShadows,
      backgroundGradient: backgroundGradient,
      mainButton: mainButton,
      onTap: onTap,
      isDismissible: isDismissible,
      dismissDirection: dismissDirection,
      showProgressIndicator: showProgressIndicator,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      snackStyle: snackStyle,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      animationDuration: animationDuration,
      overlayBlur: overlayBlur,
      overlayColor: overlayColor,
      userInputForm: userInputForm,
    );

    final controller = SnackbarController(getSnackBar);

    if (instantInit) {
      controller.show(context);
    } else {
      ambiguate(Engine.instance)!.addPostFrameCallback((_) {
        controller.show(context);
      });
    }
    return controller;
  }

  SnackbarController showSnackbar(BuildContext context, SSSnackBar snackbar) {
    final controller = SnackbarController(snackbar);
    controller.show(context);
    return controller;
  }

  SnackbarController snackbar(
    BuildContext context,
    String title,
    String message, {
    Color? colorText,
    Duration? duration = const Duration(seconds: 3),

    /// with instantInit = false you can put snackbar on initState
    bool instantInit = true,
    SnackPosition? snackPosition,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool? shouldIconPulse,
    double? maxWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
    Color? leftBarIndicatorColor,
    Color? bottomBarIndicatorColor,
    double? bottomBarIndicatorHeight,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    TextButton? mainButton,
    OnTap? onTap,
    OnHover? onHover,
    bool? isDismissible,
    bool? showProgressIndicator,
    DismissDirection? dismissDirection,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackStyle? snackStyle,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Duration? animationDuration,
    double? barBlur,
    double? overlayBlur,
    SnackbarStatusCallback? snackbarStatus,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final getSnackBar = SSSnackBar(
        snackbarStatus: snackbarStatus,
        titleText: titleText ??
            Text(
              title,
              style: TextStyle(
                color: colorText ??
                    Theme.of(context).iconTheme.color ??
                    Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
        messageText: messageText ??
            Text(
              message,
              style: TextStyle(
                color: colorText ??
                    Theme.of(context).iconTheme.color ??
                    Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
        snackPosition: snackPosition ?? SnackPosition.top,
        borderRadius: borderRadius ?? 15,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 10),
        duration: duration,
        barBlur: barBlur ?? 7.0,
        backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.2),
        icon: icon,
        shouldIconPulse: shouldIconPulse ?? true,
        maxWidth: maxWidth,
        padding: padding ?? const EdgeInsets.all(16),
        borderColor: borderColor,
        borderWidth: borderWidth,
        leftBarIndicatorColor: leftBarIndicatorColor,
        bottomBarIndicatorColor: bottomBarIndicatorColor,
        bottomBarIndicatorHeight: bottomBarIndicatorHeight,
        boxShadows: boxShadows,
        backgroundGradient: backgroundGradient,
        mainButton: mainButton,
        onTap: onTap,
        onHover: onHover,
        isDismissible: isDismissible ?? true,
        dismissDirection: dismissDirection,
        showProgressIndicator: showProgressIndicator ?? false,
        progressIndicatorController: progressIndicatorController,
        progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
        progressIndicatorValueColor: progressIndicatorValueColor,
        snackStyle: snackStyle ?? SnackStyle.floating,
        forwardAnimationCurve: forwardAnimationCurve ?? Curves.easeOutCirc,
        reverseAnimationCurve: reverseAnimationCurve ?? Curves.easeOutCirc,
        animationDuration: animationDuration ?? const Duration(seconds: 1),
        overlayBlur: overlayBlur ?? 0.0,
        overlayColor: overlayColor ?? Colors.transparent,
        userInputForm: userInputForm);

    final controller = SnackbarController(getSnackBar);
    if (instantInit) {
      controller.show(context);
    } else {
      //routing.isSnackbar = true;
      ambiguate(Engine.instance)!.addPostFrameCallback((_) {
        controller.show(context);
      });
    }
    return controller;
  }
}

extension GetNavigationExt on GetInterface {
  /// Returns true if a Snackbar, Dialog or BottomSheet is currently OPEN

  /// check if snackbar is open
  bool get isSnackbarOpen =>
      SnackbarController.isSnackbarBeingShown; //routing.isSnackbar;

  void closeAllSnackbars(BuildContext context) {
    SnackbarController.cancelAllSnackbars(context);
  }

  Future<void> closeCurrentSnackbar(BuildContext context) async {
    await SnackbarController.closeCurrentSnackbar(context);
  }

  /// The current null safe [WidgetsBinding]
  WidgetsBinding get engine {
    return WidgetsFlutterBinding.ensureInitialized();
  }

  /// The window to which this binding is bound.
  ui.FlutterView get window => PlatformDispatcher.instance.views.first;

  Locale? get deviceLocale => PlatformDispatcher.instance.locale;

  ///The number of device pixels for each logical pixel.
  double get pixelRatio =>
      PlatformDispatcher.instance.views.first.devicePixelRatio;

  Size get size =>
      PlatformDispatcher.instance.views.first.physicalSize / pixelRatio;

  ///The horizontal extent of this size.
  double get width => size.width;

  ///The vertical extent of this size
  double get height => size.height;

  ///The distance from the top edge to the first unpadded pixel,
  ///in physical pixels.
  double get statusBarHeight =>
      PlatformDispatcher.instance.views.first.padding.top;

  ///The distance from the bottom edge to the first unpadded pixel,
  ///in physical pixels.
  double get bottomBarHeight =>
      PlatformDispatcher.instance.views.first.padding.bottom;

  ///The system-reported text scale.
  double get textScaleFactor => PlatformDispatcher.instance.textScaleFactor;

  /// Check if dark mode theme is enable on platform on android Q+
  bool get isPlatformDarkMode =>
      (PlatformDispatcher.instance.platformBrightness == Brightness.dark);

  FocusNode? get focusScope => FocusManager.instance.primaryFocus;
}

extension OverlayExt on GetInterface {
  Future<T> showOverlay<T>(
    BuildContext context, {
    required Future<T> Function() asyncFunction,
    Color opacityColor = Colors.black,
    Widget? loadingWidget,
    double opacity = .5,
  }) async {
    final navigatorState = Navigator.of(context, rootNavigator: false);
    final overlayState = navigatorState.overlay!;

    final overlayEntryOpacity = OverlayEntry(builder: (context) {
      return Opacity(
          opacity: opacity,
          child: Container(
            color: opacityColor,
          ));
    });
    final overlayEntryLoader = OverlayEntry(builder: (context) {
      return loadingWidget ??
          const Center(
              child: SizedBox(
            height: 90,
            width: 90,
            child: Text('Loading...'),
          ));
    });
    overlayState.insert(overlayEntryOpacity);
    overlayState.insert(overlayEntryLoader);

    T data;

    try {
      data = await asyncFunction();
    } on Exception catch (_) {
      overlayEntryLoader.remove();
      overlayEntryOpacity.remove();
      rethrow;
    }

    overlayEntryLoader.remove();
    overlayEntryOpacity.remove();
    return data;
  }
}
