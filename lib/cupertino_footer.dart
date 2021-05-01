import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class CupertinoLoadFooter extends Footer {
  final String loadingText;
  final String dragingText;
  final String dragedText;
  final String endText;
  final String noMoreText;
  final String errorText;

  CupertinoLoadFooter({
    double extent = 60.0,
    double triggerDistance = 70.0,
    bool float = false,
    Duration completeDuration = const Duration(seconds: 1),
    bool enableInfiniteLoad = true,
    bool enableHapticFeedback = true,
    bool overScroll = true,
    bool safeArea = true,
    EdgeInsets? padding,
    this.loadingText = '正在加载中',
    this.dragingText = '上拉触发加载更多',
    this.dragedText = '松手加载更多',
    this.endText = '加载完成',
    this.noMoreText = '我也是有底线的~',
    this.errorText = '加载失败，请稍后再试',
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
    Widget? widget;
    String dragText = pulledExtent >= loadTriggerPullDistance ? dragedText : dragingText;
    String loadedText = noMore ? noMoreText : endText;
    String errorText = this.errorText;
    Widget icon = CupertinoActivityIndicator();

    switch (loadState) {
      case LoadMode.drag:
        widget = CustomSelfFooterContext(
          height: loadIndicatorExtent,
          text: dragText,
        );
        break;
      case LoadMode.armed:
      case LoadMode.load:
        widget = CustomSelfFooterContext(
          height: loadIndicatorExtent,
          text: loadingText,
          icon: icon,
        );
        break;
      case LoadMode.inactive:
      case LoadMode.loaded:
      case LoadMode.done:
        if (success && !noMore) {
          if (enableInfiniteLoad) {
            widget = null;
          } else {
            widget = CustomSelfFooterContext(
              height: loadIndicatorExtent,
              text: endText,
            );
          }
        }
        if (!success) {
          widget = CustomSelfFooterContext(
            height: loadIndicatorExtent,
            text: errorText,
          );
        }
        if (success && noMore) {
          widget = CustomSelfFooterContext(
            height: loadIndicatorExtent,
            text: loadedText,
          );
        }
        break;
    }

    return widget!;
  }
}

class CustomSelfFooterContext extends StatelessWidget {
  final double? height;
  final String? text;
  final Widget? icon;

  const CustomSelfFooterContext({this.height, this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(),
      child: FractionallySizedBox(
        widthFactor: .8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, SizedBox(width: 15)],
            Text(text!, style: TextStyle(fontSize: 13, color: Color(0xff666666))),
          ],
        ),
      ),
    );
  }
}
