import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage>
    with SingleTickerProviderStateMixin {
  double pedalBike = 100;
  double value = -180;
  late AnimationController _animationController;
  AudioPlayer audioPlayer = AudioPlayer();

  late Animation<double> tween2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    tween2 = Tween<double>(begin: -180, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.addListener(() {
      setState(() {
        value = tween2.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010823),
      appBar: AppBar(
        backgroundColor: const Color(0xff02124e),
        title: const Text('Accelerator'),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                width: MediaQuery.of(context).size.width,
                child: CustomPaint(
                  painter: ExamplePainter(value, gradient),
                ),
              ),
              const Text(
                'Speed Meter',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: SliderTheme(
                  data: SliderThemeData(
                    trackShape:
                        GradientRectSliderTrackShape(gradient: gradient),
                  ),
                  child: Slider(
                      min: -180,
                      max: 0,
                      activeColor: Colors.tealAccent,
                      value: value,
                      onChanged: (newValue) {
                        setState(() {
                          value = newValue;
                        });
                      }),
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  setState(() {
                    pedalBike = 80;
                  });
                  print('starttt');
                },
                onLongPressStart: (_) {
                  _animationController.forward();
                  playLocal();
                  print('start 1');
                },
                onLongPressUp: () {
                  setState(() {
                    _animationController.reverse();
                    pedalBike = 100;
                  });

                  stopAudio();
                  print('end');
                },
                child: AnimatedContainer(
                  height: pedalBike,
                  width: pedalBike,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.pedal_bike,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  playLocal() async {
    String audioasset = "audio/car_audio.wav";
    ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    int result = await audioPlayer.playBytes(soundbytes);
  }

  stopAudio() async {
    await audioPlayer.stop();
  }

  final gradient = const LinearGradient(
    colors: [
      Colors.greenAccent,
      Colors.yellowAccent,
      Colors.redAccent,
    ],
    stops: [0, 0.5, 1],
  );
}

class ExamplePainter extends CustomPainter {
  double value;
  Gradient gradient;

  ExamplePainter(this.value, this.gradient);

  var dateTime = DateTime.now();

  @override
  void paint(Canvas canvas, Size size) {
    const centerArc = Offset(200, 200);
    final rect = Rect.fromCenter(center: centerArc, width: 300, height: 300);
    const double startAngle = -pi;
    const double sweepAngle = pi;
    const bool useCenter = false;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    var dashBrush = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);

    var secHandX = 200 + 120 * cos(value * (pi) / 180);
    var secHandY = 200 + 120 * sin(value * (pi) / 180);
    canvas.drawLine(centerArc, Offset(secHandX, secHandY), paint);

    var outerCircleRadius = 180;
    var innerCircleRadius = 180 - 14;
    for (double i = 180; i <= 360; i += 15) {
      var x1 = 200 + outerCircleRadius * cos(i * pi / 180);
      var y1 = 200 + outerCircleRadius * sin(i * pi / 180);

      var x2 = 200 + innerCircleRadius * cos(i * pi / 180);
      var y2 = 200 + innerCircleRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class GradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const GradientRectSliderTrackShape({
    required this.gradient,
    this.darkenInactive = true,
  });

  final Gradient gradient;
  final bool darkenInactive;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(sliderTheme.trackHeight != null && sliderTheme.trackHeight! > 0);

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeGradientRect = Rect.fromLTRB(
      trackRect.left,
      (textDirection == TextDirection.ltr)
          ? trackRect.top - (additionalActiveTrackHeight / 2)
          : trackRect.top,
      thumbCenter.dx,
      (textDirection == TextDirection.ltr)
          ? trackRect.bottom + (additionalActiveTrackHeight / 2)
          : trackRect.bottom,
    );

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = darkenInactive
        ? ColorTween(
            begin: sliderTheme.disabledInactiveTrackColor,
            end: sliderTheme.inactiveTrackColor)
        : activeTrackColorTween;
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(activeGradientRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular(trackRect.height / 2 + 1);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
      ),
      rightTrackPaint,
    );
  }
}
