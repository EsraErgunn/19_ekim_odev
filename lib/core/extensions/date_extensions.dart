/// Tarih biçimlendirme ve gün farkı hesaplama uzantıları.
extension DateFormattingExtension on DateTime {
  static const List<String> _turkishMonths = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// "19 Ekim 2026" biçiminde Türkçe tarih
  String toTurkishFormat() {
    return '$day ${_turkishMonths[month - 1]} $year';
  }

  /// "19 Eki" kısa biçim
  String toShortTurkishFormat() {
    final m = _turkishMonths[month - 1];
    final shortM = m.length > 3 ? m.substring(0, 3) : m;
    return '$day $shortM';
  }

  /// Başka bir tarihe kalan veya geçen gün sayısı
  int daysDifference(DateTime other) {
    final d1 = DateTime(year, month, day);
    final d2 = DateTime(other.year, other.month, other.day);
    return d2.difference(d1).inDays;
  }
}
