import 'dart:math' as math;

import 'package:flutter/material.dart';

class KingColors {
  KingColors._();

  static const Color orange = Color(0xFFFF7A1A);
  static const Color amber = Color(0xFFFFB066);
  static const Color ground = Color(0xFF0A0908);
  static const Color panel = Color(0xFF141210);
  static const Color panelHigh = Color(0xFF181512);
  static const Color line = Color(0xFF3A2C20);
  static const Color lineSoft = Color(0xFF2A211A);
  static const Color text = Color(0xFFEDE6DD);
  static const Color muted = Color(0xFFA8998A);
}

const String kKingLogoAsset = 'assets/king_logo.webp';

// Turns the black-ink-on-white logo into orange ink on black.
const ColorFilter kKingLogoFilter = ColorFilter.matrix(<double>[
  -0.299, -0.587, -0.114, 0, 255, //
  -0.143, -0.281, -0.054, 0, 122, //
  -0.030, -0.060, -0.012, 0, 26, //
  0, 0, 0, 1, 0, //
]);

bool _motionDisabled(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

class _Looping extends StatefulWidget {
  final Duration period;
  final bool reverse;
  final Widget Function(BuildContext, Animation<double>) builder;

  const _Looping({
    required this.period,
    required this.builder,
    this.reverse = false,
  });

  @override
  State<_Looping> createState() => _LoopingState();
}

class _LoopingState extends State<_Looping>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionDisabled(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: widget.reverse);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}

class KingGear extends StatelessWidget {
  final double size;
  final int teeth;
  final Color color;
  final Duration period;
  final bool clockwise;

  const KingGear({
    super.key,
    required this.size,
    this.teeth = 14,
    this.color = KingColors.orange,
    this.period = const Duration(seconds: 14),
    this.clockwise = true,
  });

  @override
  Widget build(BuildContext context) {
    return _Looping(
      period: period,
      builder: (context, anim) => AnimatedBuilder(
        animation: anim,
        builder: (context, child) => Transform.rotate(
          angle: (clockwise ? 1 : -1) * anim.value * 2 * math.pi,
          child: child,
        ),
        child: CustomPaint(
          size: Size.square(size),
          painter: _GearPainter(teeth: teeth, color: color),
        ),
      ),
    );
  }
}

class _GearPainter extends CustomPainter {
  final int teeth;
  final Color color;

  _GearPainter({required this.teeth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final rim = outer * 0.78;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, outer * 0.07);
    final fill = Paint()..color = color;

    final toothW = 2 * math.pi * rim / teeth * 0.5;
    for (var i = 0; i < teeth; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * 2 * math.pi / teeth);
      canvas.drawRect(
          Rect.fromLTRB(-toothW / 2, -outer, toothW / 2, -rim + 1), fill);
      canvas.restore();
    }
    canvas.drawCircle(c, rim, stroke);
    canvas.drawCircle(c, rim * 0.28, stroke);
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * rim * 0.28,
        c + Offset(math.cos(a), math.sin(a)) * rim,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_GearPainter old) =>
      old.teeth != teeth || old.color != color;
}

/// Two meshing gears turning in opposite directions.
class KingGearPair extends StatelessWidget {
  final double size;

  const KingGearPair({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final small = size * 0.66;
    return SizedBox(
      width: size + small * 0.8,
      height: size + small * 0.55,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: KingGear(size: size, teeth: 14),
          ),
          Positioned(
            left: size * 0.82,
            top: size * 0.6,
            child: KingGear(
              size: small,
              teeth: 10,
              color: KingColors.amber,
              period: const Duration(milliseconds: 9800),
              clockwise: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// The logo in a round frame, ringed by a turning gear and a soft pulse.
class KingEmblem extends StatelessWidget {
  final double size;

  const KingEmblem({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.7;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          KingGear(size: size, teeth: 22, period: const Duration(seconds: 18)),
          _Looping(
            period: const Duration(milliseconds: 1300),
            reverse: true,
            builder: (context, anim) => AnimatedBuilder(
              animation: anim,
              builder: (context, child) => Container(
                width: inner,
                height: inner,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: KingColors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: KingColors.orange.withOpacity(0.55 * anim.value),
                      blurRadius: 18 * anim.value,
                    ),
                  ],
                ),
                child: child,
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: kKingLogoFilter,
                  child: Transform.scale(
                    scale: 1.06,
                    child: Image.asset(
                      kKingLogoAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated orange/black warning stripes.
class KingHazardStripe extends StatelessWidget {
  final double height;
  final Color color;

  const KingHazardStripe(
      {super.key, this.height = 6, this.color = KingColors.orange});

  @override
  Widget build(BuildContext context) {
    return _Looping(
      period: const Duration(milliseconds: 1400),
      builder: (context, anim) => SizedBox(
        width: double.infinity,
        height: height,
        child: AnimatedBuilder(
          animation: anim,
          builder: (context, _) => CustomPaint(
              painter: _HazardPainter(phase: anim.value, color: color)),
        ),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  final double phase;
  final Color color;

  _HazardPainter({required this.phase, this.color = KingColors.orange});

  @override
  void paint(Canvas canvas, Size size) {
    const band = 10.0;
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1A1512));
    final paint = Paint()..color = color;
    final shift = phase * band * 2;
    for (var x = -size.height - band * 2 + shift;
        x < size.width + band;
        x += band * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + band, size.height)
        ..lineTo(x + band + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_HazardPainter old) =>
      old.phase != phase || old.color != color;
}

/// Full-window startup screen laid over [child]; fades out on its own or on tap.
class KingSplashOverlay extends StatefulWidget {
  final Widget child;
  final String title;

  const KingSplashOverlay({super.key, required this.child, required this.title});

  @override
  State<KingSplashOverlay> createState() => _KingSplashOverlayState();
}

class _KingSplashOverlayState extends State<KingSplashOverlay> {
  static bool _shownOnce = false;
  static const _hold = Duration(milliseconds: 2400);
  static const _fade = Duration(milliseconds: 500);

  bool _visible = !_shownOnce;
  bool _fading = false;

  @override
  void initState() {
    super.initState();
    if (_visible) {
      _shownOnce = true;
      Future.delayed(_hold, _dismiss);
    }
  }

  void _dismiss() {
    if (!mounted || _fading) return;
    setState(() => _fading = true);
    Future.delayed(_fade, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _fading,
            child: AnimatedOpacity(
              opacity: _fading ? 0 : 1,
              duration: _fade,
              child: GestureDetector(
                onTap: _dismiss,
                child: _KingSplashBody(title: widget.title, hold: _hold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KingSplashBody extends StatelessWidget {
  final String title;
  final Duration hold;

  const _KingSplashBody({required this.title, required this.hold});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KingColors.ground,
      child: Column(
        children: [
          const KingHazardStripe(height: 8),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const KingEmblem(size: 220),
                    const SizedBox(height: 28),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: KingColors.text,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 320,
                      height: 14,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: KingColors.orange),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.05, end: 1),
                        duration: hold,
                        curve: Curves.easeInOut,
                        builder: (context, v, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: v,
                            child: const KingHazardStripe(height: 8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const KingHazardStripe(height: 8),
        ],
      ),
    );
  }
}

const String kKingMono = 'KingMono';
const Color kKingRed = Color(0xFFFF3B2F);

TextStyle kingMono(
        {double size = 12,
        Color color = KingColors.text,
        FontWeight weight = FontWeight.w400,
        double spacing = 1.5}) =>
    TextStyle(
        fontFamily: kKingMono,
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing);

/// Cuts the corners of a rectangle at 45 degrees.
class KingChamferClipper extends CustomClipper<Path> {
  final double cut;
  final bool allCorners;

  const KingChamferClipper({this.cut = 12, this.allCorners = false});

  @override
  Path getClip(Size size) {
    final c = math.min(cut, size.shortestSide / 2);
    final p = Path();
    if (allCorners) {
      p
        ..moveTo(c, 0)
        ..lineTo(size.width - c, 0)
        ..lineTo(size.width, c)
        ..lineTo(size.width, size.height - c)
        ..lineTo(size.width - c, size.height)
        ..lineTo(c, size.height)
        ..lineTo(0, size.height - c)
        ..lineTo(0, c);
    } else {
      p
        ..moveTo(c, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height - c)
        ..lineTo(size.width - c, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, c);
    }
    return p..close();
  }

  @override
  bool shouldReclip(KingChamferClipper old) =>
      old.cut != cut || old.allCorners != allCorners;
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(s.width / 2, 0)
    ..lineTo(s.width, s.height * 0.25)
    ..lineTo(s.width, s.height * 0.75)
    ..lineTo(s.width / 2, s.height)
    ..lineTo(0, s.height * 0.75)
    ..lineTo(0, s.height * 0.25)
    ..close();

  @override
  bool shouldReclip(_HexClipper old) => false;
}

/// Small orange section tag such as "[01] LOCAL UNIT".
class KingTag extends StatelessWidget {
  final String text;
  final Color color;

  const KingTag(this.text, {super.key, this.color = KingColors.orange});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: kingMono(size: 10, color: color, spacing: 3));
}

/// Dashed-row status table entry.
class KingStatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool pulse;

  const KingStatusRow(
      {super.key,
      required this.label,
      required this.value,
      this.valueColor = KingColors.orange,
      this.pulse = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: KingColors.lineSoft))),
      child: Row(
        children: [
          Text(label,
              style: kingMono(size: 10, color: KingColors.muted, spacing: 2)),
          const Spacer(),
          if (pulse) KingPulse(child: Text('● ', style: kingMono(size: 10, color: valueColor))),
          Text(value, style: kingMono(size: 10, color: valueColor, spacing: 2)),
        ],
      ),
    );
  }
}

/// Fades its child in and out.
class KingPulse extends StatelessWidget {
  final Widget child;
  final Duration period;

  const KingPulse(
      {super.key,
      required this.child,
      this.period = const Duration(milliseconds: 700)});

  @override
  Widget build(BuildContext context) {
    return _Looping(
      period: period,
      reverse: true,
      builder: (context, anim) => AnimatedBuilder(
        animation: anim,
        builder: (context, c) => Opacity(opacity: 0.25 + 0.75 * anim.value, child: c),
        child: child,
      ),
    );
  }
}

/// Bouncing level bars.
class KingEqualizer extends StatelessWidget {
  final int bars;
  final double height;
  final double barWidth;

  const KingEqualizer(
      {super.key, this.bars = 8, this.height = 32, this.barWidth = 6});

  @override
  Widget build(BuildContext context) {
    const periods = [450, 650, 350, 550, 700, 400, 600, 500, 380, 620, 470, 530];
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(bars, (i) {
          return Padding(
            padding: EdgeInsets.only(right: barWidth / 2),
            child: _Looping(
              period: Duration(milliseconds: periods[i % periods.length]),
              reverse: true,
              builder: (context, anim) => AnimatedBuilder(
                animation: anim,
                builder: (context, _) => Container(
                  width: barWidth,
                  height: height * (0.18 + 0.82 * anim.value),
                  color: i % 3 == 2 ? KingColors.amber : KingColors.orange,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Scrolling one-line status ticker.
class KingTicker extends StatelessWidget {
  final String text;

  const KingTicker(
      {super.key,
      this.text =
          '// SYSTEM ONLINE // ENCRYPTION E2E ARMED // TUNNEL DIRECT // AWAITING TARGET '});

  @override
  Widget build(BuildContext context) {
    final style = kingMono(size: 10, color: KingColors.muted, spacing: 3);
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0806),
        border: Border(top: BorderSide(color: KingColors.lineSoft)),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: double.infinity,
          child: _Looping(
            period: const Duration(seconds: 18),
            builder: (context, anim) => AnimatedBuilder(
              animation: anim,
              builder: (context, child) => FractionalTranslation(
                  translation: Offset(-0.5 * anim.value, 0), child: child),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text * 3, style: style, maxLines: 1, softWrap: false),
                  Text(text * 3, style: style, maxLines: 1, softWrap: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CRT scanlines plus a glowing beam sweeping down; ignores pointer input.
class KingScanOverlay extends StatelessWidget {
  const KingScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ScanlinePainter())),
          Positioned.fill(
            child: _Looping(
              period: const Duration(milliseconds: 4500),
              reverse: true,
              builder: (context, anim) => AnimatedBuilder(
                animation: anim,
                builder: (context, child) => Align(
                  alignment: Alignment(0, -0.95 + 1.9 * Curves.easeInOut.transform(anim.value)),
                  child: child,
                ),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0x00FF7A1A),
                      KingColors.orange,
                      Color(0xFFFFE3C8),
                      KingColors.orange,
                      Color(0x00FF7A1A),
                    ]),
                    boxShadow: [
                      BoxShadow(
                          color: KingColors.orange.withOpacity(0.45),
                          blurRadius: 24,
                          spreadRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x1A000000);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), p);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => false;
}

/// Radar with a rotating sweep, toothed outer ring, blips and a target lock.
class KingRadar extends StatelessWidget {
  final double size;

  const KingRadar({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.72;
    return SizedBox(
      width: size,
      height: size + 34,
      child: Column(
        children: [
          SizedBox.square(
            dimension: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                KingGear(
                    size: size,
                    teeth: 48,
                    period: const Duration(seconds: 20)),
                Container(
                  width: inner + 10,
                  height: inner + 10,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: KingColors.ground),
                ),
                SizedBox.square(
                  dimension: inner,
                  child: ClipOval(
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: CustomPaint(painter: _RadarGridPainter())),
                        Positioned.fill(
                          child: _Looping(
                            period: const Duration(milliseconds: 2400),
                            builder: (context, anim) => AnimatedBuilder(
                              animation: anim,
                              builder: (context, _) => CustomPaint(
                                  painter: _SweepPainter(anim.value)),
                            ),
                          ),
                        ),
                        _blip(inner, 0.66, 0.24, KingColors.amber),
                        _blip(inner, 0.28, 0.68, KingColors.orange),
                        Positioned(
                          left: inner * 0.66 - 14,
                          top: inner * 0.24 - 14,
                          child: KingPulse(
                            period: const Duration(milliseconds: 1200),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                  border: Border.all(color: kKingRed)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          KingPulse(
            child: Text('SCANNING_',
                style: kingMono(size: 10, color: KingColors.orange, spacing: 4)),
          ),
        ],
      ),
    );
  }

  Widget _blip(double box, double fx, double fy, Color color) {
    return Positioned(
      left: box * fx - 4,
      top: box * fy - 4,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _Looping(
            period: const Duration(milliseconds: 2400),
            builder: (context, anim) => AnimatedBuilder(
              animation: anim,
              builder: (context, _) => Transform.scale(
                scale: 1 + 2.5 * anim.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: color.withOpacity(1 - anim.value)),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final line = Paint()
      ..color = KingColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(c, r * 0.5, line);
    canvas.drawCircle(c, r - 1, line);
    canvas.drawLine(Offset(0, c.dy), Offset(size.width, c.dy), line);
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height), line);
  }

  @override
  bool shouldRepaint(_RadarGridPainter old) => false;
}

class _SweepPainter extends CustomPainter {
  final double t;

  _SweepPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final start = t * 2 * math.pi;
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi / 2.2,
        colors: [
          KingColors.orange.withOpacity(0),
          KingColors.orange.withOpacity(0.7),
        ],
        transform: GradientRotation(start - math.pi / 2.2),
      ).createShader(rect);
    canvas.drawArc(rect, start - math.pi / 2.2, math.pi / 2.2, true, paint);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.t != t;
}

/// Big glowing chamfered button with running chevrons.
class KingConnectButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;

  const KingConnectButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.height = 40});

  @override
  Widget build(BuildContext context) {
    return _Looping(
      period: const Duration(milliseconds: 900),
      reverse: true,
      builder: (context, anim) => AnimatedBuilder(
        animation: anim,
        builder: (context, child) => Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: KingColors.orange.withOpacity(0.55 * anim.value),
                blurRadius: 18 * anim.value),
          ]),
          child: child,
        ),
        child: ClipPath(
          clipper: const KingChamferClipper(cut: 10),
          child: Material(
            color: KingColors.orange,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label.toUpperCase(),
                          style: kingMono(
                              size: 14,
                              color: const Color(0xFF140A02),
                              weight: FontWeight.w800,
                              spacing: 4)),
                      const SizedBox(width: 10),
                      const _Chevrons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chevrons extends StatelessWidget {
  const _Chevrons();

  @override
  Widget build(BuildContext context) {
    return _Looping(
      period: const Duration(milliseconds: 1100),
      builder: (context, anim) => AnimatedBuilder(
        animation: anim,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (anim.value - i * 0.18) % 1.0;
            final o = phase < 0.3 ? phase / 0.3 : 1 - (phase - 0.3) / 0.7;
            return Icon(Icons.play_arrow,
                size: 13,
                color: const Color(0xFF140A02).withOpacity(0.2 + 0.8 * o));
          }),
        ),
      ),
    );
  }
}

/// Hexagonal initial badge with a turning dashed ring.
class KingHexAvatar extends StatelessWidget {
  final String letter;
  final double size;

  const KingHexAvatar({super.key, required this.letter, this.size = 70});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.78;
    final h = size * 0.88;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          KingGear(
              size: size,
              teeth: 18,
              color: KingColors.amber,
              period: const Duration(seconds: 12),
              clockwise: false),
          ClipPath(
            clipper: _HexClipper(),
            child: Container(
              width: w,
              height: h,
              color: KingColors.orange,
              alignment: Alignment.center,
              child: ClipPath(
                clipper: _HexClipper(),
                child: Container(
                  width: w - 6,
                  height: h - 6,
                  color: const Color(0xFF1A120C),
                  alignment: Alignment.center,
                  child: Text(letter.toUpperCase(),
                      style: kingMono(
                          size: size * 0.36,
                          color: KingColors.orange,
                          weight: FontWeight.w800,
                          spacing: 0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Octagonal permission toggle used in the connection manager.
class KingPermTile extends StatelessWidget {
  final bool enabled;
  final bool canModify;
  final IconData icon;
  final VoidCallback? onTap;

  const KingPermTile(
      {super.key,
      required this.enabled,
      required this.icon,
      required this.canModify,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final edge = enabled
        ? (canModify ? KingColors.orange : KingColors.orange.withOpacity(0.6))
        : KingColors.line;
    final fill = enabled ? const Color(0xFF2C170A) : const Color(0xFF0E0B09);
    final ink = enabled ? const Color(0xFFFFA05A) : const Color(0xFF8A7A6A);
    return ClipPath(
      clipper: const KingChamferClipper(cut: 12, allCorners: true),
      child: Container(
        color: edge,
        padding: const EdgeInsets.all(2.5),
        child: ClipPath(
          clipper: const KingChamferClipper(cut: 11, allCorners: true),
          child: Material(
            color: fill,
            child: InkWell(
              onTap: canModify ? onTap : null,
              child: Center(child: Icon(icon, color: ink, size: 22)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Red "terminate" bar with running warning stripes and an alarm glow.
class KingTerminateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const KingTerminateButton(
      {super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const KingHazardStripe(height: 5, color: kKingRed),
        _Looping(
          period: const Duration(milliseconds: 800),
          reverse: true,
          builder: (context, anim) => AnimatedBuilder(
            animation: anim,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C0A08),
                border: const Border(
                  left: BorderSide(color: kKingRed, width: 2),
                  right: BorderSide(color: kKingRed, width: 2),
                  bottom: BorderSide(color: kKingRed, width: 2),
                ),
                boxShadow: [
                  BoxShadow(
                      color: kKingRed.withOpacity(0.45 * anim.value),
                      blurRadius: 16 * anim.value),
                ],
              ),
              child: child,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.power_settings_new,
                          color: Color(0xFFFF6B5C), size: 16),
                      const SizedBox(width: 10),
                      Text(label.toUpperCase(),
                          style: kingMono(
                              size: 13,
                              color: const Color(0xFFFF6B5C),
                              weight: FontWeight.w800,
                              spacing: 4)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
