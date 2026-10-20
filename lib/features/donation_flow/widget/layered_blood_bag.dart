import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bag_geometry.dart';
import '../models/donation_stage.dart';
import 'painters/blood_bag_painter.dart';

/// Tek tuval (BloodBagPainter) üzerinde çalışan, AspectRatio ile orantılı kan torbası bileşeni.
class LayeredBloodBag extends StatefulWidget {
  const LayeredBloodBag({
    super.key,
    required this.fillRatio,
    required this.stage,
    this.geometry = const BagGeometry(),
    this.showDebugMask = false,
    this.showGeometryOverlay = false,
    this.assetPath = 'assets/images/bag_empty.png',
    this.maskAssetPath = 'assets/images/bag_mask.png',
    this.bagEmptyImage,
    this.maskImage,
  });

  final double fillRatio;
  final DonationStage stage;
  final BagGeometry geometry;
  final bool showDebugMask;
  final bool showGeometryOverlay;
  final String assetPath;
  final String maskAssetPath;

  /// Testler veya doğrudan enjeksiyon için
  final ui.Image? bagEmptyImage;
  final ui.Image? maskImage;

  @override
  State<LayeredBloodBag> createState() => _LayeredBloodBagState();
}

class _LayeredBloodBagState extends State<LayeredBloodBag>
    with TickerProviderStateMixin {
  static ui.Image? _cachedBagEmpty;
  static ui.Image? _cachedMask;

  ui.Image? _bagEmptyImage;
  ui.Image? _maskImage;

  late final AnimationController _waveController;
  late final AnimationController _floatController;
  late final AnimationController _sloshController;
  late final AnimationController _clipController;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _sloshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _clipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.stage.isClosing) {
      _clipController.forward(from: 0.0);
    } else if (widget.stage.isResting || widget.stage.isCompleted) {
      _clipController.value = 1.0;
    }

    _loadImages();
  }

  @override
  void didUpdateWidget(LayeredBloodBag oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.fillRatio > oldWidget.fillRatio && widget.stage.isActive) {
      _sloshController.forward(from: 0.0);
    }

    if (widget.stage.isClosing && !oldWidget.stage.isClosing) {
      _clipController.forward(from: 0.0);
    } else if (widget.stage.isResting || widget.stage.isCompleted) {
      _clipController.value = 1.0;
    } else if (!widget.stage.isClosing && !widget.stage.isResting && !widget.stage.isCompleted) {
      _clipController.reset();
    }
  }

  Future<void> _loadImages() async {
    if (widget.bagEmptyImage != null) {
      _bagEmptyImage = widget.bagEmptyImage;
    } else if (_cachedBagEmpty != null) {
      _bagEmptyImage = _cachedBagEmpty;
    } else {
      try {
        final data = await rootBundle.load(widget.assetPath);
        final img = await decodeImageFromList(data.buffer.asUint8List());
        _cachedBagEmpty = img;
        _bagEmptyImage = img;
      } catch (_) {}
    }

    if (widget.maskImage != null) {
      _maskImage = widget.maskImage;
    } else if (_cachedMask != null) {
      _maskImage = _cachedMask;
    } else {
      try {
        final data = await rootBundle.load(widget.maskAssetPath);
        final img = await decodeImageFromList(data.buffer.asUint8List());
        _cachedMask = img;
        _maskImage = img;
      } catch (_) {}
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _waveController.dispose();
    _floatController.dispose();
    _sloshController.dispose();
    _clipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bag = _bagEmptyImage;
    final mask = _maskImage;

    final aspectRatio = (bag != null)
        ? (bag.width / bag.height)
        : (600.0 / 800.0);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: (bag == null || mask == null)
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: Listenable.merge([
                _waveController,
                _floatController,
                _sloshController,
                _clipController,
              ]),
              builder: (context, _) => _buildCanvasWithMotion(bag, mask),
            ),
    );
  }

  Widget _buildCanvasWithMotion(ui.Image bag, ui.Image mask) {
    final floatY = math.sin(_floatController.value * 2 * math.pi) * 6.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: widget.fillRatio),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, animatedFill, _) {
        final scaleX = 1.0 + (0.03 * animatedFill);

        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: 1.0,
            alignment: Alignment.center,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: BloodBagPainter(
                  bagEmptyImage: bag,
                  maskImage: mask,
                  fillRatio: animatedFill,
                  wavePhase: _waveController.value * 2 * math.pi,
                  waveAmplitude: widget.stage.isActive ? 7.0 : 2.5,
                  sloshAmplitude: (1.0 - _sloshController.value) * 6.0,
                  bubbleProgress: _waveController.value,
                  tubeFlowOffset: _waveController.value,
                  clipProgress: _clipController.value,
                  sparkleProgress: _waveController.value,
                  stage: widget.stage,
                  geometry: widget.geometry,
                  showDebugMask: widget.showDebugMask,
                  showGeometryOverlay: widget.showGeometryOverlay,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
