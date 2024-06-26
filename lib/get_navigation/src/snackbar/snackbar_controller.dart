import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_snack_bar/get_utils/get_utils.dart';

import '../../../get_snack_bar.dart';

class SnackbarController {
  static final _snackBarQueue = _SnackBarQueue();
  static bool get isSnackbarBeingShown => _snackBarQueue._isJobInProgress;
  final key = GlobalKey<SSSnackBarState>();

  late Animation<double> _filterBlurAnimation;
  late Animation<Color?> _filterColorAnimation;

  final SSSnackBar snackbar;
  final _transitionCompleter = Completer();

  late SnackbarStatusCallback? _snackbarStatus;
  late final Alignment? _initialAlignment;
  late final Alignment? _endAlignment;

  bool _wasDismissedBySwipe = false;

  bool _onTappedDismiss = false;

  Timer? _timer;

  /// The animation that drives the route's transition and the previous route's
  /// forward transition.
  late final Animation<Alignment> _animation;

  /// The animation controller that the route uses to drive the transitions.
  ///
  /// The animation itself is exposed by the [animation] property.
  late final AnimationController _controller;

  SnackbarStatus? _currentStatus;

  final _overlayEntries = <OverlayEntry>[];

  OverlayState? _overlayState;

  SnackbarController(this.snackbar);

  Future<void> get future => _transitionCompleter.future;

  /// Close the snackbar with animation
  Future<void> close(BuildContext context, {bool withAnimations = true}) async {
    if (!withAnimations) {
      _removeOverlay(context);
      return;
    }
    _removeEntry();
    await future;
  }

  /// Adds GetSnackbar to a view queue.
  /// Only one GetSnackbar will be displayed at a time, and this method returns
  /// a future to when the snackbar disappears.
  Future<void> show(BuildContext context) {
    return _snackBarQueue._addJob(context, this);
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  // ignore: avoid_returning_this
  void _configureAlignment(SnackPosition snackPosition) {
    switch (snackbar.snackPosition) {
      case SnackPosition.top:
        {
          _initialAlignment = const Alignment(-1.0, -2.0);
          _endAlignment = const Alignment(-1.0, -1.0);
          break;
        }
      case SnackPosition.bottom:
        {
          _initialAlignment = const Alignment(-1.0, 2.0);
          _endAlignment = const Alignment(-1.0, 1.0);
          break;
        }
    }
  }

  void _configureOverlay(BuildContext context) {
    _overlayState = Overlay.of(context);
    _overlayEntries.clear();
    _overlayEntries.addAll(_createOverlayEntries(_getBodyWidget()));
    _overlayState!.insertAll(_overlayEntries);

    _configureSnackBarDisplay(context);
  }

  void _configureSnackBarDisplay(BuildContext context) {
    assert(!_transitionCompleter.isCompleted,
        'Cannot configure a snackbar after disposing it.');
    _controller = _createAnimationController();
    _configureAlignment(snackbar.snackPosition);
    _snackbarStatus = snackbar.snackbarStatus;
    _filterBlurAnimation = _createBlurFilterAnimation();
    _filterColorAnimation = _createColorOverlayColor();
    _animation = _createAnimation();
    _animation
        .addStatusListener((status) => _handleStatusChanged(context, status));
    _configureTimer();
    _controller.forward();
  }

  void _configureTimer() {
    if (snackbar.duration != null) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      _timer = Timer(snackbar.duration!, _removeEntry);
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  /// Called to create the animation that exposes the current progress of
  /// the transition controlled by the animation controller created by
  /// `createAnimationController()`.
  Animation<Alignment> _createAnimation() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animation from a disposed snackbar');
    return AlignmentTween(begin: _initialAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _controller,
        curve: snackbar.forwardAnimationCurve,
        reverseCurve: snackbar.reverseAnimationCurve,
      ),
    );
  }

  /// Called to create the animation controller that will drive the transitions
  /// to this route from the previous one, and back to the previous route
  /// from this one.
  AnimationController _createAnimationController() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animationController from a disposed snackbar');
    assert(snackbar.animationDuration >= Duration.zero);
    return AnimationController(
      duration: snackbar.animationDuration,
      debugLabel: '$runtimeType',
      vsync: _overlayState!,
    );
  }

  Animation<double> _createBlurFilterAnimation() {
    return Tween(begin: 0.0, end: snackbar.overlayBlur).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Animation<Color?> _createColorOverlayColor() {
    return ColorTween(
            begin: const Color(0x00000000), end: snackbar.overlayColor)
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Iterable<OverlayEntry> _createOverlayEntries(Widget child) {
    return <OverlayEntry>[
      if (snackbar.overlayBlur > 0.0) ...[
        OverlayEntry(
          builder: (context) => GestureDetector(
            onTap: () {
              if (snackbar.isDismissible && !_onTappedDismiss) {
                _onTappedDismiss = true;
                close(context);
              }
            },
            child: AnimatedBuilder(
              animation: _filterBlurAnimation,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: max(0.001, _filterBlurAnimation.value),
                    sigmaY: max(0.001, _filterBlurAnimation.value),
                  ),
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    color: _filterColorAnimation.value,
                  ),
                );
              },
            ),
          ),
          maintainState: false,
          opaque: false,
        ),
      ],
      OverlayEntry(
        builder: (context) => Semantics(
          focused: false,
          container: true,
          explicitChildNodes: true,
          child: AlignTransition(
            alignment: _animation,
            child: snackbar.isDismissible
                ? _getDismissibleSnack(child)
                : _getSnackbarContainer(child),
          ),
        ),
        maintainState: false,
        opaque: false,
      ),
    ];
  }

  Widget _getBodyWidget() {
    return Builder(builder: (_) {
      return MouseRegion(
        onEnter: (_) =>
            snackbar.onHover?.call(snackbar, SnackHoverState.entered),
        onExit: (_) => snackbar.onHover?.call(snackbar, SnackHoverState.exited),
        child: GestureDetector(
          onTap: snackbar.onTap != null
              ? () => snackbar.onTap?.call(snackbar)
              : null,
          child: snackbar,
        ),
      );
    });
  }

  DismissDirection _getDefaultDismissDirection() {
    if (snackbar.snackPosition == SnackPosition.top) {
      return DismissDirection.up;
    }
    return DismissDirection.down;
  }

  Widget _getDismissibleSnack(Widget child) {
    return Dismissible(
      direction: snackbar.dismissDirection ?? _getDefaultDismissDirection(),
      resizeDuration: null,
      confirmDismiss: (_) {
        if (_currentStatus == SnackbarStatus.opening ||
            _currentStatus == SnackbarStatus.closing) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      key: const Key('dismissible'),
      onDismissed: (_) {
        _wasDismissedBySwipe = true;
        _removeEntry();
      },
      child: _getSnackbarContainer(child),
    );
  }

  Widget _getSnackbarContainer(Widget child) {
    return Container(
      margin: snackbar.margin,
      child: child,
    );
  }

  void _handleStatusChanged(BuildContext context, AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _currentStatus = SnackbarStatus.open;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;

        break;
      case AnimationStatus.forward:
        _currentStatus = SnackbarStatus.opening;
        _snackbarStatus?.call(_currentStatus);
        break;
      case AnimationStatus.reverse:
        _currentStatus = SnackbarStatus.closing;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        assert(!_overlayEntries.first.opaque);
        _currentStatus = SnackbarStatus.closed;
        _snackbarStatus?.call(_currentStatus);
        _removeOverlay(context);
        break;
    }
  }

  void _removeEntry() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot remove entry from a disposed snackbar',
    );

    _cancelTimer();

    if (_wasDismissedBySwipe) {
      Timer(const Duration(milliseconds: 200), _controller.reset);
      _wasDismissedBySwipe = false;
    } else {
      _controller.reverse();
    }
  }

  void _removeOverlay(BuildContext context) {
    assert(!_transitionCompleter.isCompleted,
        'Cannot remove overlay from a disposed snackbar');
    _controller.dispose();
    _overlayEntries.clear();
    _transitionCompleter.complete();
  }

  Future<void> _show(BuildContext context) {
    _configureOverlay(context);
    return future;
  }

  static void cancelAllSnackbars(BuildContext context) {
    _snackBarQueue._cancelAllJobs(context);
  }

  static Future<void> closeCurrentSnackbar(BuildContext context) async {
    await _snackBarQueue._closeCurrentJob(context);
  }
}

class _SnackBarQueue {
  final _queue = GetQueue();
  final _snackbarList = <SnackbarController>[];

  SnackbarController? get _currentSnackbar {
    if (_snackbarList.isEmpty) return null;
    return _snackbarList.first;
  }

  bool get _isJobInProgress => _snackbarList.isNotEmpty;

  Future<void> _addJob(BuildContext context, SnackbarController job) async {
    _snackbarList.add(job);
    final data = await _queue.add(() => job._show(context));
    _snackbarList.remove(job);
    return data;
  }

  Future<void> _cancelAllJobs(BuildContext context) async {
    await _currentSnackbar?.close(context);
    _queue.cancelAllJobs();
    _snackbarList.clear();
  }

  Future<void> _closeCurrentJob(BuildContext context) async {
    if (_currentSnackbar == null) return;
    await _currentSnackbar!.close(context);
  }
}
