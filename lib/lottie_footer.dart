import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:lottie/lottie.dart';

const TextStyle style = TextStyle(fontSize: 13, color: Color(0xff666666));

class LottieFooter extends Footer {
  String asset;
  final GlobalKey<_LottieContainerState> _key = GlobalKey<_LottieContainerState>();
  final Widget endWidget;
  final Widget errorWidget;
  final Widget noMoreWidget;
  int? duration;

  LottieFooter({
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
          enableInfiniteLoad: enableInfiniteLoad,
          enableHapticFeedback: enableHapticFeedback,
          overScroll: overScroll,
          safeArea: safeArea,
          padding: padding,
        );

  @override
  Widget contentBuilder(
    BuildContext context,
    LoadMode loadState,
    double pulledExtent,
    double loadTriggerPullDistance,
    double loadIndicatorExtent,
    AxisDirection axisDirection,
    bool float,
    Duration? completeDuration,
    bool enableInfiniteLoad,
    bool success,
    bool noMore,
  ) {
    Widget widget = LottieContainer(
      asset: asset,
      height: loadIndicatorExtent,
      key: _key,
      duration: duration,
    );

    switch (loadState) {
      case LoadMode.drag:
        double progress = pulledExtent / loadTriggerPullDistance;
        _key.currentState?.controllProgress(progress);
        break;
      case LoadMode.armed:
      case LoadMode.load:
        _key.currentState?.startAnimation();
        break;
      case LoadMode.loaded:
        _key.currentState?.stopAnimation();
        widget = endWidget;
        break;
      case LoadMode.inactive:
      case LoadMode.done:
        _key.currentState?.stopAnimation();
        if (success && !noMore) {
          if (enableInfiniteLoad) {
            widget = SizedBox.shrink();
          } else {
            widget = endWidget;
          }
        }
        if (!success) widget = errorWidget;
        if (success && noMore) widget = noMoreWidget;
        break;
    }

    return widget;
  }
}

class LottieContainer extends StatefulWidget {
  String asset;
  int? duration;
  double height;

  LottieContainer({
    Key? key,
    required this.asset,
    required this.height,
    this.duration,
  }) : super(key: key);

  @override
  _LottieContainerState createState() => _LottieContainerState();
}

class _LottieContainerState extends State<LottieContainer> with SingleTickerProviderStateMixin {
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
          if (_controller.isCompleted) _controller.reverse();
          if (_controller.isDismissed) _controller.forward();
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
        progress > 1 ? progress % progress.floor() : progress,
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
