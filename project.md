# Oyunlaştırılmış Kan Bağışı ve Sağlık Takip Uygulaması

Bu doküman, Flutter projesinde geliştirme yapacak olan Ajan (Antigravity) yapay zekâ ve yazılım geliştiriciler için **bağlayıcı bir kılavuzdur**. Projede üretilen her kod satırı buradaki kurallara **UYMAK ZORUNDADIR**. Teknik tarifler ve kod kalıpları için [skills.md](skills.md) dosyasına bakılır.

---

## 1. Proje Özeti ve Teknolojiler

- **Uygulama adı (çalışma adı):** Damla — oyunlaştırılmış kan bağışı ve iyileşme takip uygulaması
- **Hedef platform:** Önce iOS ve Android, ardından web ve masaüstü
- **Flutter SDK:** 3.29.0
- **Dart SDK:** 3.7.x (Flutter 3.29.0 ile birlikte gelen sürüm)
- **Tasarım dili:** Material 3, koyu ve açık tema desteği
- **Renk paleti:** "Klinik gece" paleti — derin lacivert/obsidyen zemin, kan kırmızısı (`#E53950`) vurgu, yenilenmeyi gösteren yeşil-turkuaz ikincil renk, altın rengi ödül tonları
- **Görsel dil:** Mobil oyun estetiğinde stilize 3D varlıklar (kan torbası, tüp, rozetler) + Apple Health tarzı sade veri grafikleri

### 1.1 Proje Vizyonu
Monoton sağlık uygulamalarının dışına çıkarak bağış sürecini **estetik animasyonlarla anlatan**, kullanıcının bağış geçmişini ve iyileşme sürecini **gerçek verilerle beslenen interaktif grafiklerle** gösteren bir deneyim sunmak. Uygulama yalnızca görsel değildir; güçlü bir **veri işleme ve sunum mimarisine** sahiptir. Kullanıcıya liste yerine grafik ve istatistik gösterilir.

---

## 2. Görsel Akış: 3 Aşamalı Bağış Deneyimi

| Aşama | Ekran durumu | Görsel | Bağlı grafik |
|---|---|---|---|
| **Pre-Donation** (Ön hazırlık) | Bağış öncesi kontrol listesi | Boş torba, kıvrık tüp, sakin nefes animasyonu | Uygunluk geri sayımı (dairesel ilerleme) |
| **Active Donation** (Aktif akış) | Bağış/simülasyon sürüyor | Tüpten akan kırmızı sıvı, dolan torba, sıvı dalgası | Canlı doluluk grafiği (Modül G1) |
| **Completed** (Kutlama) | Bağış tamamlandı | Mühürlenmiş dolu torba, parıltı/konfeti partikülleri | Etki paneline geçiş + rozet kazanımı |

- Aşamalar arası geçiş `AnimatedSwitcher` / implicit animasyonlarla yapılır; ani ekran değişimi yasaktır.
- Mikro etkileşimler: dokunuşta hafif ölçek animasyonu, başarı anında haptic feedback (`HapticFeedback.mediumImpact()`).

---

## 3. Veri Görselleştirme Modülleri (Hoca Kriterleri)

Grafikler bu projenin **çekirdek özelliğidir**. Her grafik gerçek bir veri modelinden beslenir; sabit (hardcoded) veriyle çizilmiş grafik kabul edilmez.

### G1 — Bağış Süreci Canlı Akış Grafiği (Radial Progress + Liquid Wave)
- **Ne gösterir:** Bağış anındaki doluluk yüzdesi (%) ve toplanan/kalan mililitre (standart ünite ≈ 450 ml).
- **Bileşenler:**
  - Torba içinde `CustomPainter` ile çizilen **sinüs dalgalı sıvı yüzeyi**; dalga seviyesi doluluk oranına bağlıdır.
  - Torbanın etrafında **dairesel ilerleme halkası** (gradient stroke).
  - Altta, son 60 saniyenin akış hızını gösteren küçük **gradient alan grafiği** (`fl_chart` LineChart, `belowBarData` dolgulu).
- **Veri kaynağı:** `DonationSessionController` her 250 ms'de bir `DonationTick(elapsed, collectedMl)` üretir (simülasyon modunda zamanlayıcı ile).
- **Kabul kriteri:** Halka, dalga ve sayısal metin aynı değerden beslenir; aralarında senkron farkı görülmez. Animasyon 60 FPS'te takılmadan çalışır.

### G2 — Biyolojik İyileşme Çizgi Grafiği (Time-Series Line/Area Chart)
- **Ne gösterir:** Son bağıştan sonra **hemoglobin** ve **demir depolarının (ferritin)** zamanla toparlanma eğrisi.
- **Tasarım:** Apple Health tarzı; yumuşak eğri (`isCurved: true`), altı yarı saydam kırmızı gradient, parmakla dokununca tarih + değer gösteren tooltip, "bugün" çizgisi ve "bir sonraki bağışa uygun" eşik çizgisi.
- **Zaman aralığı seçici:** 1 Ay / 3 Ay / 6 Ay (`SegmentedButton`).
- **Veri kaynağı:** `RecoveryEstimator` sınıfı — bağış tarihinden itibaren **tahmini** toparlanma eğrisi üretir. Kullanıcı tahlil sonucu girerse (opsiyonel) bu noktalar gerçek ölçüm olarak ayrı işaretle (dolu nokta) gösterilir.
- **Zorunlu etiket:** Grafik altında "Tahmini model — tıbbi ölçüm değildir" ibaresi bulunur. Tahmini ve ölçülmüş veriler görsel olarak ayrılır (kesikli çizgi = tahmin, dolu nokta = ölçüm).

### G3 — Yıllık Hayat Kurtarma Etki Paneli (Rounded Bar Chart + İstatistik Kartları)
- **Ne gösterir:** Aylara göre bağış sayısı ve toplam tahmini etki ("1 ünite kan 3 kişiye kadar yardım edebilir" yaklaşımıyla hesaplanır ve "tahmini" olarak etiketlenir).
- **Tasarım:** Köşeleri yuvarlatılmış sütunlar (`BorderRadius.circular(6)`), yıllık hedef çizgisi; hedefe ulaşıldığında sütunlar yukarı doğru yükselen giriş animasyonuyla yeniden çizilir.
- **İstatistik kartları:** Toplam bağış, toplam ml, tahmini yardım edilen kişi, en uzun düzenli bağış serisi.

### G4 — Uygunluk Geri Sayımı (Circular Countdown)
- **Ne gösterir:** Bir sonraki bağışa kalan gün; halka zamanla dolar.
- **Kural:** Bağış aralığı ve yıllık üst sınır `core/constants/donation_rules.dart` içinde **tek yerde** tanımlanır (Türk Kızılay genel kuralı: erkek 90 gün / yılda en fazla 4, kadın 120 gün / yılda en fazla 3). Sayılar kod içine dağıtılmaz.

### Ortak grafik kuralları
- Tüm grafik renkleri ve metin stilleri tema dosyasından gelir (`AppChartTheme`).
- Her grafik boş veri durumunu (ilk kullanım) özel bir boş-durum widget'ı ile gösterir; boş eksenli grafik çizilmez.
- Tooltip ve eksen metinleri Türkçe tarih biçimiyle gösterilir.
- Erişilebilirlik: Her grafiğin `Semantics` etiketi vardır (örn. "Hemoglobin tahmini, bugün yüzde 85 toparlandı").

---

## 4. Oyunlaştırma (Gamification)

- **Rozetler:** İlk bağış, 3 bağış, yıllık hedef, düzenli bağışçı (art arda uygun dönemde bağış), "bilgi kurdu" (eğitim kartlarını okuma).
- **Puan sistemi:** Bağış = 100 puan, uygunluk tarihinde zamanında bağış = +50 bonus, eğitim kartı = 10 puan.
- **Kutlama:** Rozet kazanımında partikül/konfeti animasyonu + rozet kartının 3D döndürme (flip) animasyonu.
- **Kırmızı çizgi:** Oyunlaştırma kullanıcıyı **uygunluk süresi dolmadan bağışa teşvik edemez**. Puan/rozet mantığı `donation_rules.dart` kurallarına tabidir.

---

## 5. Mimari Yapı: Özellik Bazlı (Feature-First)

Kodlar kesinlikle tek bir yerde toplanmayacaktır. Her modül kendi feature klasöründe kodlanacaktır.

```text
lib/
  core/
    constants/
      app_colors.dart
      donation_rules.dart        # bağış aralıkları, ünite ml, etki çarpanı
    theme/
      app_theme.dart
      app_chart_theme.dart       # grafik renkleri, gradient'ler, eksen stilleri
    extensions/
      date_extensions.dart
    widgets/
      empty_state.dart           # ortak boş durum widget'ı

  features/
    donation_flow/               # 3 aşamalı akış + G1
      controller/
      models/
      view/
      widget/                    # liquid_bag_painter.dart, radial_progress.dart
    recovery_tracker/            # G2 + G4
      controller/
      models/                    # recovery_point.dart, recovery_estimator.dart
      view/
      widget/
    impact_stats/                # G3
      controller/
      models/
      view/
      widget/
    achievement/                 # rozet, puan, kutlama animasyonları
      controller/
      models/
      view/
      widget/

  main.dart                      # sadece uygulama başlatma ve tema
```

- `main.dart` yalnızca uygulamayı başlatır ve temayı bağlar; iş mantığı içermez.
- Feature'lar birbirinin `view/` veya `widget/` klasörünü import etmez; paylaşılan şey `core/` altına taşınır.
- Grafik verisini hazırlayan dönüşümler (ör. bağış listesi → aylık sütun verisi) **controller/model katmanında** yapılır; `build` metodu içinde hesaplama yapılmaz.

---

## 6. Kırmızı Çizgiler — Kod Kalite Standartları

1. **State yönetimi standartları**
   - Sayfa düzeyinde ağır `setState` **KULLANILMAYACAKTIR**.
   - Durum yönetimi Flutter'ın yerel API'leriyle yapılır: `ChangeNotifier`, `ValueNotifier`, `ListenableBuilder` / `ValueListenableBuilder`.
   - Yalnızca yerel arayüz durumunu yöneten (buton animasyonu, `AnimationController` sahibi widget vb.) `StatefulWidget` kabul edilir.

2. **UI ve performans kuralları**
   - Statik tüm widget'larda `const` zorunludur.
   - Renk ve metin stilleri kesinlikle tema dosyalarına yazılacaktır; widget içinde `Color(0x...)` veya sabit `TextStyle` yasaktır.
   - Büyük build metotları yasaktır: **40 satırı geçen** build metotları özel widget'lara bölünecektir.
   - Her `AnimationController` `dispose()` içinde kapatılır.
   - Sürekli tekrar çizilen animasyonlar (sıvı dalgası, partikül) `RepaintBoundary` içine alınır.
   - `CustomPainter.shouldRepaint` yalnızca değer değiştiğinde `true` döner.

3. **Paket politikası**
   - Onaylı paketler: `fl_chart` (tüm grafikler), `lottie` (kutlama animasyonları, opsiyonel).
   - Bunların dışında harici paket — özellikle ağır state paketleri (Riverpod, Bloc, GetX vb.) ve lisans gerektiren grafik paketleri — **onay olmadan EKLENMEYECEKTİR**.
   - Dart'ın ve Flutter'ın yerel çekirdek API'lerini kullanmak esastır.

4. **Veri dürüstlüğü**
   - Tahmini değerler ile kullanıcı tarafından girilmiş ölçümler model düzeyinde ayrılır (`isEstimated` alanı) ve grafikte farklı gösterilir.
   - Uygulama tıbbi tavsiye vermez; iyileşme ekranında bilgilendirme notu zorunludur.

---

## 7. Geliştirme, Analiz ve Test Komutları

Ajan yaptığı herhangi bir kod değişikliğinden sonra mutlaka aşağıdaki komutların başarıyla çalıştığını doğrulamalıdır.

* **Statik kod analizi (0 uyarı ve 0 hata şart):**
```bash
flutter analyze
```

* **Birim ve widget testleri:**
```bash
flutter test
```
  Zorunlu test kapsamı:
  - `RecoveryEstimator` — bağış günü, ara günler ve tam toparlanma noktaları için değer testleri
  - `donation_rules` — uygunluk tarihi hesaplaması (erkek/kadın, yıllık sınır)
  - Aylık sütun verisi dönüştürücüsü — boş yıl, tek bağış, çok bağış senaryoları
  - Her grafik widget'ı için boş veri ve dolu veri durumunda render testi

* **Projeyi çalıştırma:**
```bash
flutter run
```

* **Performans kontrolü (animasyon ekranları için):**
```bash
flutter run --profile
```
  DevTools Performance sekmesinde G1 ekranında jank (16 ms'yi aşan kare) olmamalıdır.

---

## 8. Ajanın Çıktı ve Yanıt Verme Standartları

- **Açıklamalar:** Türkçe; teknik terimlerin özü bozulmadan net ve doğrudan.
- **Değişiklik sunumları:** Örneğin 500 satırlık bir dosyada 3 satır değiştiyse tüm dosya baştan sona basılmaz; yalnızca hedef satırlar ve diff yapısı gösterilir.
- **Dosya yolları:** Bahsedilen ve üretilen her dosya için projeye göre tıklanabilir link verilir.
- **Grafik değişiklikleri:** Bir grafik eklendiğinde/değiştiğinde hangi modelden beslendiği ve hangi kabul kriterini karşıladığı tek cümleyle belirtilir.
- **Doğrulama:** Kod yazıldıktan sonra kullanıcıya doğrulama yönergesi verilir: "Şimdi `flutter analyze` ve `flutter test` ile kontrol edebilirsin."

---

## 9. Geliştirme Sırası (Yol Haritası)

1. `core/` — tema, `app_chart_theme.dart`, `donation_rules.dart`
2. `donation_flow` — modeller + simülasyon controller'ı, ardından G1 (sıvı dalgası + halka)
3. `recovery_tracker` — `RecoveryEstimator` + testleri, ardından G2 ve G4
4. `impact_stats` — veri dönüştürücü + testleri, ardından G3
5. `achievement` — puan/rozet mantığı, kutlama animasyonları
6. Cila — geçiş animasyonları, erişilebilirlik etiketleri, profil modunda performans kontrolü

Her adım `flutter analyze` ve `flutter test` temiz geçmeden bir sonrakine geçilmez.