# Teknik ve Tasarım Yetkinlikleri — Kan Bağışı UI/UX Projesi

Bu dosya, ajanın [project.md](project.md) içindeki modülleri **nasıl** inşa edeceğini tanımlar: kullanılacak teknikler, kod kalıpları ve kalite ölçütleri. Kurallar project.md'dedir; çakışma olursa **project.md geçerlidir**.

---

## 1. UI/UX ve Motion Design

### 1.1 3D Varlık Entegrasyonu
- Mobil oyun estetiğinde stilize 3D varlıklar (kan torbası, tüp, rozetler) PNG/WebP olarak `assets/images/` altında tutulur; @2x ve @3x çözünürlükleri sağlanır.
- Statik 3D görsel + üzerine kod ile çizilen dinamik katman yaklaşımı kullanılır: torba görseli sabit, içindeki sıvı `CustomPainter` ile çizilir. Böylece doluluk gerçek veriyle değişir.
- Görseller `precacheImage` ile ekran açılmadan önce yüklenir; ilk karede titreme olmaz.

### 1.2 Motion UI ve Mikro Etkileşimler
- **Implicit animasyonlar** (tercih edilen): `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`, `TweenAnimationBuilder`.
- **Explicit animasyonlar** (sürekli hareket): `AnimationController` + `AnimatedBuilder` — sıvı dalgası, parıltı, nabız efekti.
- **Kutlama:** `lottie` ile konfeti; ya da paket istemeden `CustomPainter` tabanlı basit partikül sistemi.
- **Haptic:** başarı anında `HapticFeedback.mediumImpact()`.

### 1.3 Oyunlaştırma
- Rozet kartı açılışı: `Transform` + `Matrix4.rotationY` ile 3D flip animasyonu.
- Puan artışı: `TweenAnimationBuilder<int>` ile sayaç animasyonu.

---

## 2. Veri Görselleştirme ve Grafik Altyapısı

Tüm grafikler `fl_chart` ile çizilir; özel şekiller (sıvı dalgası, dairesel halka) `CustomPainter` ile yapılır.

### 2.1 Grafik teması (tek kaynak)
```dart
// lib/core/theme/app_chart_theme.dart
class AppChartTheme {
  const AppChartTheme._();

  static const Color primary = AppColors.bloodRed;
  static const Color recovery = AppColors.recoveryTeal;

  static LinearGradient areaGradient(Color base) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [base.withValues(alpha: 0.35), base.withValues(alpha: 0.0)],
      );
}
```

### 2.2 G2 — Gradient dolgulu, tooltip destekli zaman serisi (Apple Health tarzı)
```dart
LineChart(
  LineChartData(
    minY: 0,
    maxY: 100,
    gridData: const FlGridData(show: false),
    borderData: FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: points.map((p) => FlSpot(p.dayIndex.toDouble(), p.percent)).toList(),
        isCurved: true,
        curveSmoothness: 0.35,
        color: AppChartTheme.primary,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: AppChartTheme.areaGradient(AppChartTheme.primary),
        ),
      ),
    ],
    extraLinesData: ExtraLinesData(horizontalLines: [
      HorizontalLine(y: 100, dashArray: [6, 4], color: AppChartTheme.recovery),
    ]),
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (spots) => spots
            .map((s) => LineTooltipItem('%${s.y.toStringAsFixed(0)}', tooltipStyle))
            .toList(),
      ),
    ),
  ),
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOutCubic,
)
```
- Tahmini veri: `dashArray` ile kesikli çizgi; ölçülmüş veri: ayrı `LineChartBarData` içinde yalnızca noktalar (`FlDotData(show: true)`, `barWidth: 0`).
- Zaman aralığı değişiminde yeni `spots` verildiğinde `fl_chart` geçişi kendisi animasyonlar.

### 2.3 G3 — Yuvarlatılmış sütun grafiği
```dart
BarChartGroupData(
  x: monthIndex,
  barRods: [
    BarChartRodData(
      toY: donationCount.toDouble(),
      width: 14,
      borderRadius: BorderRadius.circular(6),
      gradient: const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [AppColors.bloodRedDark, AppColors.bloodRed],
      ),
    ),
  ],
)
```
- Giriş animasyonu: ilk karede tüm `toY` değerleri 0 verilir, ardından gerçek değerlerle yeniden çizilir; `BarChart(duration: ...)` yükselme efektini üretir.

### 2.4 G1 — Sıvı dalgası (CustomPainter)
```dart
class LiquidWavePainter extends CustomPainter {
  LiquidWavePainter({required this.fill, required this.phase, required this.color});

  final double fill;   // 0.0 – 1.0, controller'dan gelir
  final double phase;  // 0 – 2π, AnimationController ile döner
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final level = size.height * (1 - fill);
    final path = Path()..moveTo(0, level);
    for (double x = 0; x <= size.width; x++) {
      final y = level + 6 * math.sin((x / size.width * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(LiquidWavePainter old) =>
      old.fill != fill || old.phase != phase;
}
```
- Torba şeklinin dışına taşmaması için painter `ClipPath` (torba silüeti) içine alınır.
- `RepaintBoundary` zorunludur; dalga ekranın geri kalanını yeniden çizdirmemelidir.

### 2.5 G1/G4 — Gradient dairesel ilerleme halkası
- `CustomPainter` içinde `canvas.drawArc` + `SweepGradient` shader ile çizilir; başlangıç açısı `-math.pi / 2` (saat 12 yönü).
- Değer değişimi `TweenAnimationBuilder<double>` ile yumuşatılır; halka zıplamaz.

---

## 3. Veri ve Hesaplama Katmanı

- **Simülasyon:** `DonationSessionController extends ChangeNotifier` — `Timer.periodic(250 ms)` ile `collectedMl` artırır; tamamlanınca aşamayı `completed` yapar. Gerçek cihaz verisi olmadığı için bağış akışı simülasyondur ve böyle etiketlenir.
- **İyileşme tahmini:** `RecoveryEstimator` saf (pure) bir Dart sınıfıdır; tarih alır, `List<RecoveryPoint>` döner. Flutter import etmez, bu yüzden birim testi kolaydır.
- **Dönüştürücüler:** Bağış listesi → aylık sütun verisi, bağış listesi → istatistik kartları. Hepsi saf fonksiyonlardır ve test edilir.
- **Sabitler:** Ünite hacmi, bağış aralıkları, etki çarpanı yalnızca `donation_rules.dart` içinde bulunur.

---

## 4. Frontend ve Mobil Geliştirme Yığını

| Katman | Teknoloji |
|---|---|
| Framework | Flutter 3.29.0 (Dart 3.7.x), Material 3 |
| Grafikler | `fl_chart` |
| Özel çizim | `CustomPainter`, `ClipPath`, `SweepGradient` |
| Animasyon | Implicit/explicit Flutter animasyonları, `lottie` (opsiyonel) |
| State | `ChangeNotifier`, `ValueNotifier`, `ListenableBuilder` |
| Tasarım | Figma, AI destekli stilize 3D varlık üretimi |
| Test | `flutter_test` (birim + widget testleri) |

---

## 5. Kalite Ölçütleri

- Animasyonlu ekranlarda profil modunda **60 FPS**, jank yok.
- Her grafik: boş durum, tek veri noktası ve çok veri noktası senaryolarında doğru render.
- Her grafik ve ilerleme halkası `Semantics` etiketiyle ekran okuyucuya anlamlı bilgi verir.
- Tahmini veriler her zaman "tahmini" olarak etiketlenir ve ölçümlerden görsel olarak ayrılır.
- `flutter analyze` 0 uyarı / 0 hata, `flutter test` tamamen geçer.