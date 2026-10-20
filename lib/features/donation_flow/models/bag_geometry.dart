import 'package:flutter/material.dart';

/// Kan torbası ve tüpün oransal (0.0 - 1.0) koordinat sistemi.
/// Painter'larda sihirli sayı kullanılmaz; tüm geometrik oranlar buradan okunur.
class BagGeometry {
  const BagGeometry({
    this.innerLeftRatio = 0.20,
    this.innerRightRatio = 0.20,
    this.innerTopRatio = 0.29,
    this.innerBottomRatio = 0.17,
    this.cornerRadiusRatio = 0.10,
    this.portOffsetRatio = const Offset(0.50, 0.22),
    this.tubeStartRatio = const Offset(1.15, -0.05),
    this.tubeControl1Ratio = const Offset(0.95, 0.24),
    this.tubeControl2Ratio = const Offset(0.38, -0.04),
    this.showGeometryOverlay = false,
  });

  /// Sol iç girinti oranı (0.0 - 1.0)
  final double innerLeftRatio;

  /// Sağ iç girinti oranı (0.0 - 1.0)
  final double innerRightRatio;

  /// Üst iç girinti oranı (0.0 - 1.0)
  final double innerTopRatio;

  /// Alt iç girinti oranı (0.0 - 1.0)
  final double innerBottomRatio;

  /// İç alan köşe yuvarlama yarıçapı oranı (iç genişliğe göre)
  final double cornerRadiusRatio;

  /// Sıvının girdiği üst port konumu oranı
  final Offset portOffsetRatio;

  /// Tüpün başladığı dış nokta oranı (ör. donör yönü)
  final Offset tubeStartRatio;

  /// Tüpün ilk Bezier kontrol noktası oranı
  final Offset tubeControl1Ratio;

  /// Tüpün ikinci Bezier kontrol noktası oranı
  final Offset tubeControl2Ratio;

  /// Debug modunda iç alanı ve tüp yolunu yarı saydam çizen bayrak
  final bool showGeometryOverlay;

  /// Widget boyutuna göre torbanın iç dikdörtgen alanını hesaplar.
  Rect getInnerRect(Size size) {
    final left = size.width * innerLeftRatio;
    final top = size.height * innerTopRatio;
    final width = size.width * (1.0 - innerLeftRatio - innerRightRatio);
    final height = size.height * (1.0 - innerTopRatio - innerBottomRatio);
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Sıvının ClipRRect ile kırpılacağı yuvarlatılmış iç dikdörtgeni hesaplar.
  RRect getInnerRRect(Size size) {
    final rect = getInnerRect(size);
    final radiusValue = rect.width * cornerRadiusRatio;
    return RRect.fromRectAndRadius(
      rect,
      Radius.circular(radiusValue),
    );
  }

  /// Sıvı giriş portunun piksel koordinatını döner.
  Offset getPortOffset(Size size) {
    return Offset(
      size.width * portOffsetRatio.dx,
      size.height * portOffsetRatio.dy,
    );
  }

  /// Tüpün başladığı piksel koordinatını döner.
  Offset getTubeStart(Size size) {
    return Offset(
      size.width * tubeStartRatio.dx,
      size.height * tubeStartRatio.dy,
    );
  }

  /// Tüpün cubic Bezier eğrisini döner (Yukarıdan aşağıya porta doğru).
  Path getTubePath(Size size) {
    final start = getTubeStart(size);
    final c1 = Offset(
      size.width * tubeControl1Ratio.dx,
      size.height * tubeControl1Ratio.dy,
    );
    final c2 = Offset(
      size.width * tubeControl2Ratio.dx,
      size.height * tubeControl2Ratio.dy,
    );
    final end = getPortOffset(size);

    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
  }

  /// Parametreleri kopyalayıp yenilemek için copyWith metodu
  BagGeometry copyWith({
    double? innerLeftRatio,
    double? innerRightRatio,
    double? innerTopRatio,
    double? innerBottomRatio,
    double? cornerRadiusRatio,
    Offset? portOffsetRatio,
    Offset? tubeStartRatio,
    Offset? tubeControl1Ratio,
    Offset? tubeControl2Ratio,
    bool? showGeometryOverlay,
  }) {
    return BagGeometry(
      innerLeftRatio: innerLeftRatio ?? this.innerLeftRatio,
      innerRightRatio: innerRightRatio ?? this.innerRightRatio,
      innerTopRatio: innerTopRatio ?? this.innerTopRatio,
      innerBottomRatio: innerBottomRatio ?? this.innerBottomRatio,
      cornerRadiusRatio: cornerRadiusRatio ?? this.cornerRadiusRatio,
      portOffsetRatio: portOffsetRatio ?? this.portOffsetRatio,
      tubeStartRatio: tubeStartRatio ?? this.tubeStartRatio,
      tubeControl1Ratio: tubeControl1Ratio ?? this.tubeControl1Ratio,
      tubeControl2Ratio: tubeControl2Ratio ?? this.tubeControl2Ratio,
      showGeometryOverlay: showGeometryOverlay ?? this.showGeometryOverlay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BagGeometry &&
          runtimeType == other.runtimeType &&
          innerLeftRatio == other.innerLeftRatio &&
          innerRightRatio == other.innerRightRatio &&
          innerTopRatio == other.innerTopRatio &&
          innerBottomRatio == other.innerBottomRatio &&
          cornerRadiusRatio == other.cornerRadiusRatio &&
          portOffsetRatio == other.portOffsetRatio &&
          tubeStartRatio == other.tubeStartRatio &&
          tubeControl1Ratio == other.tubeControl1Ratio &&
          tubeControl2Ratio == other.tubeControl2Ratio &&
          showGeometryOverlay == other.showGeometryOverlay;

  @override
  int get hashCode => Object.hash(
        innerLeftRatio,
        innerRightRatio,
        innerTopRatio,
        innerBottomRatio,
        cornerRadiusRatio,
        portOffsetRatio,
        tubeStartRatio,
        tubeControl1Ratio,
        tubeControl2Ratio,
        showGeometryOverlay,
      );
}
