import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:lottie/lottie.dart';

const TextStyle style = TextStyle(fontSize: 13, color: Color(0xff666666));

class LottieHeader extends Header {
  String asset;
  final GlobalKey<_LottieContainerState> _key = GlobalKey<_LottieContainerState>();
  Widget endWidget;
  Widget errorWidget;
  Widget noMoreWidget;
  int? duration;

  LottieHeader({
    double extent = 60.0,
    double triggerDistance = 70.0,
    bool float = false,
    Duration completeDuration = const Duration(seconds: 1),
    bool enableInfiniteLoad = true,
    bool enableHapticFeedback = true,
    bool overScroll = true,
    bool safeArea = true,
    EdgeInsets? padding,
    this.duration,
    required this.asset,
    this.endWidget = const Center(child: Text('加载完成', style: style)),
    this.errorWidget = const Center(child: Text('加载错误，请稍后再试', style: style)),
    this.noMoreWidget = const Center(child: Text('没有更多了', style: style)),
  }) : super(
          extent: extent,
          triggerDistance: triggerDistance,
          float: float,
          completeDuration: completeDuration,
          enableHapticFeedback: enableHapticFeedback,
          overScroll: overScroll,
        );

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration? completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    Widget widget = LottieHeaderContainer(
      asset: asset,
      key: _key,
      duration: duration,
    );

    switch (refreshState) {
      case RefreshMode.drag:
        double progress = pulledExtent / refreshTriggerPullDistance;
        _key.currentState?.controllProgress(progress);
        break;
      case RefreshMode.armed:
      case RefreshMode.refresh:
        _key.currentState?.startAnimation();
        break;
      case RefreshMode.refreshed:
        Timer(completeDuration!, () {
          _key.currentState?.stopAnimation();
        });
        break;
      case RefreshMode.inactive:
      case RefreshMode.done:
        _key.currentState?.stopAnimation();
        break;
    }

    return widget;
  }
}

class LottieHeaderContainer extends StatefulWidget {
  String asset;
  int? duration;

  LottieHeaderContainer({
    Key? key,
    required this.asset,
    this.duration,
  }) : super(key: key);

  @override
  _LottieContainerState createState() => _LottieContainerState();
}

class _LottieContainerState extends State<LottieHeaderContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _startLoop = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration ?? 5),
    )..addListener(() {
        if (_startLoop) {
          if (_controller.isCompleted) {
            _controller.reset();
            _controller.forward();
          }
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void controllProgress(double progress) {
    if (!_startLoop) {
      _controller.animateTo(
        progress > 1 ? 1 : progress,
        duration: Duration.zero,
      );
    }
  }

  void startAnimation() {
    _startLoop = true;
    _controller.forward(from: 0);
  }

  void stopAnimation() {
    _startLoop = false;
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.asset,
      fit: BoxFit.contain,
      controller: _controller,
    );
  }
}
