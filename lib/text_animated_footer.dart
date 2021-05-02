import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// 文字动画的底部组件
class TextAnimatedFooter extends Footer {
  final String loadingText;
  final String dragingText;
  final String dragedText;
  final String endText;
  final String noMoreText;
  final String errorText;

  TextAnimatedFooter({
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
    late Widget widget;
    String dragText = pulledExtent >= loadTriggerPullDistance ? dragedText : dragingText;
    String loadedText = noMore ? noMoreText : endText;
    String errorText = this.errorText;

    switch (loadState) {
      case LoadMode.drag:
        widget = LoadFooterContext(
          height: loadIndicatorExtent,
          text: dragText,
        );
        break;
      case LoadMode.armed:
      case LoadMode.load:
        widget = TextAnimated(
          text: loadingText,
          mode: loadState,
          key: ValueKey('load'),
          height: loadIndicatorExtent,
        );
        break;
      case LoadMode.loaded:
        widget = TextAnimated(
          text: endText,
          mode: loadState,
          key: ValueKey('loaded'),
          height: loadIndicatorExtent,
        );
        break;
      case LoadMode.inactive:
      case LoadMode.done:
        if (success && !noMore) {
          if (enableInfiniteLoad) {
            widget = SizedBox.shrink();
          } else {
            widget = TextAnimated(
              text: loadedText,
              mode: loadState,
              key: ValueKey('done'),
              height: loadIndicatorExtent,
            );
          }
        }
        if (!success) {
          widget = TextAnimated(
            text: errorText,
            mode: loadState,
            key: ValueKey('error'),
            height: loadIndicatorExtent,
          );
        }
        if (success && noMore) {
          widget = TextAnimated(
            text: loadedText,
            mode: loadState,
            key: ValueKey('noMore'),
            height: loadIndicatorExtent,
          );
        }
        break;
    }

    return widget;
  }
}

class LoadFooterContext extends StatelessWidget {
  final double? height;
  final String? text;

  const LoadFooterContext({this.height, this.text});

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
            Text(text!, style: TextStyle(fontSize: 13, color: Color(0xff666666))),
          ],
        ),
      ),
    );
  }
}

class TextAnimated extends StatelessWidget {
  final String text;
  final LoadMode mode;
  final double height;
  final TextStyle style = TextStyle(fontSize: 13);

  AnimatedText get _animatedItem {
    if (mode == LoadMode.load || mode == LoadMode.armed) {
      return ColorAnimatedText(
        text,
        colors: [
          Colors.white,
          Color(0xff666666),
          Colors.white,
          Color(0xff666666),
        ],
        textStyle: style,
      );
    } else {
      return TypewriterAnimatedText(
        text,
        speed: Duration(milliseconds: 60),
        cursor: '|',
      );
    }
  }

  bool get _isLoad => mode == LoadMode.load || mode == LoadMode.armed;

  TextAnimated({
    Key? key,
    required this.text,
    required this.mode,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedTextKit(
        pause: Duration.zero,
        totalRepeatCount: 1,
        repeatForever: _isLoad,
        animatedTexts: [
          _animatedItem,
        ],
      ),
    );
  }
}

/// 重写颜色过渡动画，防止切换时的闪烁问题
class ColorAnimatedText extends AnimatedText {
  /// The [Duration] of the delay between the apparition of each characters
  ///
  /// By default it is set to 200 milliseconds.
  final Duration speed;

  /// Set the colors for the gradient animation of the text.
  ///
  /// The [List] should contain at least two values of [Color] in it.
  final List<Color> colors;

  /// Specifies the [TextDirection] for animation direction.
  ///
  /// By default it is set to [TextDirection.ltr]
  final TextDirection textDirection;

  ColorAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    required TextStyle textStyle,
    this.speed = const Duration(milliseconds: 200),
    required this.colors,
    this.textDirection = TextDirection.ltr,
  })  : assert(null != textStyle.fontSize),
        assert(colors.length > 1),
        super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: speed * text.characters.length,
        );

  late Animation<double> _colorShifter;
  // Copy of colors that may be reversed when RTL.
  late List<Color> _colors;

  @override
  void initAnimation(AnimationController controller) {
    // Note: This calculation is the only reason why [textStyle] is required
    final tuning = (300.0 * colors.length) * (textStyle!.fontSize! / 24.0) * 0.75 * (textCharacters.length / 15.0);

    final colorShift = colors.length * tuning;
    final colorTween = textDirection == TextDirection.ltr
        ? Tween<double>(
            begin: 0.0,
            end: colorShift,
          )
        : Tween<double>(
            begin: colorShift,
            end: 0.0,
          );
    _colorShifter = colorTween.animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    // With RTL, colors need to be reversed to compensate for colorTween
    // counting down instead of up.
    _colors = textDirection == TextDirection.ltr ? colors : colors.reversed.toList(growable: false);
  }

  @override
  Widget completeText(BuildContext context) {
    final linearGradient = LinearGradient(colors: _colors).createShader(
      Rect.fromLTWH(0.0, 0.0, _colorShifter.value, 0.0),
    );

    return DefaultTextStyle.merge(
      style: textStyle,
      child: Text(
        text,
        style: TextStyle(foreground: Paint()..shader = linearGradient),
        textAlign: textAlign,
      ),
    );
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    return Opacity(
      opacity: 1,
      child: completeText(context),
    );
  }
}

@Deprecated('Use AnimatedTextKit with ColorizeAnimatedText instead.')
class ColorizeAnimatedTextKit extends AnimatedTextKit {
  ColorizeAnimatedTextKit({
    Key? key,
    required List<String> text,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
    required TextStyle textStyle,
    required List<Color> colors,
    Duration speed = const Duration(milliseconds: 200),
    Duration pause = const Duration(milliseconds: 1000),
    VoidCallback? onTap,
    void Function(int, bool)? onNext,
    void Function(int, bool)? onNextBeforePause,
    VoidCallback? onFinished,
    bool isRepeatingAnimation = true,
    int totalRepeatCount = 3,
    bool repeatForever = false,
    bool displayFullTextOnTap = false,
    bool stopPauseOnTap = false,
  }) : super(
          key: key,
          animatedTexts: _animatedTexts(
            text,
            textAlign,
            textStyle,
            speed,
            colors,
            textDirection,
          ),
          pause: pause,
          displayFullTextOnTap: displayFullTextOnTap,
          stopPauseOnTap: stopPauseOnTap,
          onTap: onTap,
          onNext: onNext,
          onNextBeforePause: onNextBeforePause,
          onFinished: onFinished,
          isRepeatingAnimation: isRepeatingAnimation,
          totalRepeatCount: totalRepeatCount,
          repeatForever: repeatForever,
        );

  static List<AnimatedText> _animatedTexts(
    List<String> text,
    TextAlign textAlign,
    TextStyle textStyle,
    Duration speed,
    List<Color> colors,
    TextDirection textDirection,
  ) =>
      text
          .map((_) => ColorizeAnimatedText(
                _,
                textAlign: textAlign,
                textStyle: textStyle,
                speed: speed,
                colors: colors,
                textDirection: textDirection,
              ))
          .toList();
}
