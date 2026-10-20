# 🩸 Damla - Kan Bağışı & Akıllı Stok Yönetim Sistemi

**Damla**, kan bağışı sürecini bağışçılar için şeffaf, motive edici ve anlaşılır kılan; aynı zamanda kan stoklarını ve acil hastane ihtiyaçlarını gerçek zamanlı takip etmeyi sağlayan modern bir mobil sağlık uygulamasıdır.

Flutter ile geliştirilen bu projede, bağış süreci matematiksel ve fiziksel formüllerle modellenmiş **katmanlı kan torbası sıvı animasyonları**, **uygunluk değerlendirme algoritması**, **stok takip merkezi** ve **acil talep ağı** bir araya getirilmiştir.

---

## 📱 Ekran Görüntüleri & Özellikler

Uygulama 3 temel ana modülden ve dinamik tema desteğinden oluşur:

### 1. 💉 Bağış Süreci (Modül G1)
Kan bağışı adım adım 6 aşamalı bir durum makinesi (state machine) ile simüle edilir:
1. **Uygunluk Testi (Eligibility):** 
   - Yaş (18-65), kilo (min 50 kg), cinsiyet kuralı (erkekler için 90 gün, kadınlar için 120 gün aralık) ve sağlık soruları değerlendirilir.
   - Kurallara uymayan durumlarda bağışçıya net gerekçeler ve bekleme süresi sunulur.
2. **Hazırlık (Preparation):**
   - Tansiyon, nabız kontrolü, sterilizasyon ve damar yolu adımları tamamlanır.
3. **Aktif Bağış (Active Donation):**
   - **Fiziksel Sıvı Animasyonu:** Torbanın birebir anatomik maskesi (`bag_mask.png`) üzerinde çift fazlı sinüs dalgaları, hacimsel yan gölgeler ve menisküs yansıması ile kan seviyesi yükselir.
   - **Tüp ve Nabız Akışı:** Torbanın üst portundan uzanan tüpte kalp atışına bağlı ritmik akış çizgisi ve damlama/kabarcık efektleri yer alır.
   - **Sünger Top Etkileşimi:** Bağışçının kan akışını desteklemesi için dakikada 12-15 sıkım ritmi sunan etkileşimli sıkma butonu.
   - **Anlık Akış Hızı Grafiği:** `fl_chart` ile toplanan hacim ve anlık debi (ml/dk) canlı çizilir.
4. **Mühürleme (Sealing):**
   - Bağış tamamlandığında tüp klemplenir, mekanik mühürleme ve örnek tüplerin ayrılması animasyonla gösterilir.
5. **Dinlenme (Resting):**
   - 10 dakikalık güvenli dinlenme sayacı, sıvı takviyesi ve tansiyon dengeleme rehberliği.
6. **Tamamlandı (Completed):**
   - Altın parıltı efektleri (`SparklePainter`), bağış özeti ve bağışçı tebrik kartı.

---

### 2. 📊 Kan Grubu Stok Takibi
- **8 Temel Kan Grubu:** `0 Rh-`, `0 Rh+`, `A Rh-`, `A Rh+`, `B Rh-`, `B Rh+`, `AB Rh-`, `AB Rh+` stok seviyeleri.
- **Kritik Eşik Uyarıları:** Stok durumları *Kritik, Düşük, Yeterli, Optimum* rozetleriyle renk kodlu olarak gösterilir.
- **İnteraktif Uyumluluk Rehberi:** Kartlara tıklandığında seçilen kan grubunun **hangi gruplardan kan alabileceğini** ve **hangi gruplara kan verebileceğini** gösteren detaylı bilgi paneli açılır.
- **Filtreleme:** Tüm gruplar veya sadece kritik durumdaki stoklar tek tıkla filtrelenebilir.

---

### 3. 🚨 Acil Kan Talepleri
- **Hastane İhtiyaçları:** Şehir ve hastane bazlı acil kan talepleri listelenir.
- **Aciliyet Seviyeleri:** *Çok Acil*, *Kritik* ve *Acil* etiketleri.
- **İlerleme Durumu:** Gereken ve toplanan ünite sayıları canlı ilerleme çubuğuyla izlenir.
- **Destek Ol Butonu:** Bağışçıların anında bağış taahhüdünde bulunabilmesini sağlayan simülasyon desteği ve doğrudan iletişim numarası.

---

### 4. 🌗 Koyu & Aydınlık Tema Desteği
- Uygulama genelinde modern **Karanlık Mod (Dark Theme)** ve göz yormayan **Aydınlık Mod (Light Theme)** bulunur.
- Sağ üstteki tema butonuyla tüm sayfalar, alt navigasyon ve grafikler anında senkronize şekilde renk değiştirir.

---

## 🛠️ Teknik Mimari & Prensipler

- **Dil & Çatı:** Flutter 3.x / Dart 3.x
- **Durum Yönetimi:** Flutter'ın yerel ve hafif `ChangeNotifier`, `ValueNotifier` ve `ListenableBuilder` yapıları (üçüncü parti ağır kütüphaneler olmadan yüksek performans).
- **Özel Çizimler (CustomPainter):**
  - `BloodBagPainter`: Maskeli sıvı, hacim gradienti, menisküs bandı ve torba plastik yansımaları.
  - `LiquidWavePainter`: İki katmanlı sinüs dalga dinamiği.
  - `TubeFlowPainter`: Bezier eğrisi tüp ve kesikli nabız akış animasyonu.
  - `SplashPainter`: Damlama ve sıçrama parçacıkları.
  - `SealingClipPainter`: Tüp klempi ve mühür mekanizması.
  - `SparklePainter`: Başarı ekranı dönen yıldız ışıltıları.
- **Temiz Kod & Kurallar:**
  - Tüm `build` metotları 40 satırın altında tutulmuştur.
  - Sıkı `flutter analyze` kuralları: 0 hata, 0 uyarı.
  - 54 adet birim ve widget testi ile %100 test başarısı.

---

## 🚀 Projeyi Çalıştırma

Projeyi bilgisayarınızda çalıştırmak için:

### Gereksinimler
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24 veya üzeri önerilir)
- Android Studio / VS Code ve bir emülatör veya fiziksel cihaz

### Adımlar

1. **Depoyu klonlayın:**
   ```bash
   git clone https://github.com/EsraErgunn/19_ekim_odev.git
   cd 19_ekim_odev
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Statik analizi ve testleri çalıştırın:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Uygulamayı başlatın:**
   ```bash
   # Chrome (Web) üzerinde:
   flutter run -d chrome

   # Android emülatör üzerinde:
   flutter run
   ```

---

## 🧪 Test Kapsamı

Projede tüm modüller kapsamlı otomatik testlerle güvenceye alınmıştır:
- `test/core/theme/`: Tema değiştirici reaktiflik testleri.
- `test/features/donation_flow/`: Uygunluk kuralları, durum makinesi, sıvı ve tüp çizim matematik testleri, 320px dar ekran responsive testleri.
- `test/features/stock_tracker/`: Stok filtreleme, uyumluluk hesaplama ve UI render testleri.
- `test/features/emergency_requests/`: Acil talep listeleme, destek buton etkileşimi ve taşma kontrolleri.
- `test/widget_test.dart`: 3 ana sekme arası geçiş duman (smoke) testi.

---

## 📄 Lisans & Bilgilendirme

Bu proje eğitim ve sağlık simülasyonu amaçlı geliştirilmiştir. Arayüzde yer alan tüm sayısal değerler ve hasta/hastane kayıtları simülasyon niteliğindedir.
