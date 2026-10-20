import 'dart:ui' as ui;
import 'package:damla/core/constants/app_colors.dart';
import 'package:damla/features/donation_flow/models/bag_geometry.dart';
import 'package:damla/features/donation_flow/models/donation_stage.dart';
import 'package:damla/features/donation_flow/widget/painters/blood_bag_painter.dart';
import 'package:damla/features/donation_flow/widget/painters/radial_progress_painter.dart';
import 'package:damla/features/donation_flow/widget/painters/sealing_clip_painter.dart';
import 'package:damla/features/donation_flow/widget/painters/sparkle_painter.dart';
import 'package:damla/features/donation_flow/widget/painters/splash_painter.dart';
import 'package:damla/features/donation_flow/widget/painters/tube_flow_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> createTestImage([int width = 10, int height = 10]) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = Colors.white,
  );
  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const geometryA = BagGeometry();

  group('BloodBagPainter Tek Tuval & Boyut Doğrulama Testleri', () {
    test('Boyutlar eşit olduğunda başarıyla oluşturulup çizilmeli', () async {
      final bag = await createTestImage(100, 100);
      final mask = await createTestImage(100, 100);

      final painter = BloodBagPainter(
        bagEmptyImage: bag,
        maskImage: mask,
        fillRatio: 0.5,
        wavePhase: 1.0,
        waveAmplitude: 7.0,
        stage: DonationStage.active,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      expect(() => painter.paint(canvas, const Size(100, 100)), returnsNormally);
    });

    test('Maske ve görsel piksel boyutları farklıysa FlutterError fırlatılmalı', () async {
      final bag = await createTestImage(100, 100);
      final maskMismatch = await createTestImage(120, 100);

      expect(
        () => BloodBagPainter(
          bagEmptyImage: bag,
          maskImage: maskMismatch,
          fillRatio: 0.5,
          wavePhase: 1.0,
          waveAmplitude: 7.0,
          stage: DonationStage.active,
        ),
        throwsA(isA<FlutterError>()),
      );
    });

    test('BloodBagPainter shouldRepaint testleri', () async {
      final bag = await createTestImage(50, 50);
      final mask = await createTestImage(50, 50);

      final p1 = BloodBagPainter(
        bagEmptyImage: bag,
        maskImage: mask,
        fillRatio: 0.5,
        wavePhase: 0.0,
        waveAmplitude: 7.0,
        stage: DonationStage.active,
      );
      final p2 = BloodBagPainter(
        bagEmptyImage: bag,
        maskImage: mask,
        fillRatio: 0.5,
        wavePhase: 0.0,
        waveAmplitude: 7.0,
        stage: DonationStage.active,
      );
      final pDiff = BloodBagPainter(
        bagEmptyImage: bag,
        maskImage: mask,
        fillRatio: 0.8,
        wavePhase: 0.0,
        waveAmplitude: 7.0,
        stage: DonationStage.active,
      );

      expect(p1.shouldRepaint(p2), isFalse);
      expect(pDiff.shouldRepaint(p1), isTrue);
    });
  });

  group('TubeFlowPainter shouldRepaint & Paint Testleri', () {
    test('Aynı değerlerle shouldRepaint false dönmeli', () {
      final p1 = TubeFlowPainter(
        geometry: geometryA,
        isActive: true,
        flowOffset: 0.2,
      );
      final p2 = TubeFlowPainter(
        geometry: geometryA,
        isActive: true,
        flowOffset: 0.2,
      );
      expect(p1.shouldRepaint(p2), isFalse);
    });

    test('Değerler değiştiğinde shouldRepaint true dönmeli', () {
      final pBase = TubeFlowPainter(
        geometry: geometryA,
        isActive: false,
        flowOffset: 0.0,
      );
      final pActive = TubeFlowPainter(
        geometry: geometryA,
        isActive: true,
        flowOffset: 0.0,
      );
      expect(pActive.shouldRepaint(pBase), isTrue);
    });

    test('Çizim fonksiyonu hatasız çalışmalı', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final p = TubeFlowPainter(
        geometry: geometryA,
        isActive: true,
        flowOffset: 0.5,
      );
      expect(() => p.paint(canvas, const Size(200, 300)), returnsNormally);
    });
  });

  group('SealingClipPainter shouldRepaint & Paint Testleri', () {
    test('shouldRepaint doğrulaması', () {
      final p1 = SealingClipPainter(clipProgress: 0.5, portOffset: const Offset(100, 50));
      final p2 = SealingClipPainter(clipProgress: 0.5, portOffset: const Offset(100, 50));
      final p3 = SealingClipPainter(clipProgress: 1.0, portOffset: const Offset(100, 50));

      expect(p1.shouldRepaint(p2), isFalse);
      expect(p3.shouldRepaint(p1), isTrue);
    });

    test('Çizim fonksiyonu hatasız çalışmalı', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final p = SealingClipPainter(clipProgress: 1.0, portOffset: const Offset(100, 50));
      expect(() => p.paint(canvas, const Size(200, 300)), returnsNormally);
    });
  });

  group('SplashPainter shouldRepaint Testleri', () {
    test('Aynı ve farklı değerler için shouldRepaint doğrulaması', () {
      final p1 = SplashPainter(progress: 0.3, geometry: geometryA);
      final p2 = SplashPainter(progress: 0.3, geometry: geometryA);
      final p3 = SplashPainter(progress: 0.7, geometry: geometryA);

      expect(p1.shouldRepaint(p2), isFalse);
      expect(p3.shouldRepaint(p1), isTrue);
    });
  });

  group('SparklePainter shouldRepaint Testleri', () {
    test('Aynı ve farklı değerler için shouldRepaint doğrulaması', () {
      final p1 = SparklePainter(animationValue: 0.4);
      final p2 = SparklePainter(animationValue: 0.4);
      final p3 = SparklePainter(animationValue: 0.8);
      final p4 = SparklePainter(animationValue: 0.4, color: AppColors.recoveryTeal);

      expect(p1.shouldRepaint(p2), isFalse);
      expect(p3.shouldRepaint(p1), isTrue);
      expect(p4.shouldRepaint(p1), isTrue);
    });
  });

  group('RadialProgressPainter shouldRepaint Testleri', () {
    test('Aynı ve farklı değerler için shouldRepaint doğrulaması', () {
      final p1 = RadialProgressPainter(progress: 0.25);
      final p2 = RadialProgressPainter(progress: 0.25);
      final p3 = RadialProgressPainter(progress: 0.75);

      expect(p1.shouldRepaint(p2), isFalse);
      expect(p3.shouldRepaint(p1), isTrue);
    });
  });
}
