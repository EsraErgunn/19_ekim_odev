/// Tamamlanan bir kan bağışı oturumuna ait kalıcı kayıt modeli.
class DonationRecord {
  const DonationRecord({
    required this.id,
    required this.date,
    required this.collectedMl,
    required this.duration,
    required this.averageFlowRate,
    this.pointsEarned = 150,
  });

  final String id;
  final DateTime date;
  final int collectedMl;
  final Duration duration;
  final double averageFlowRate; // ml / dk
  final int pointsEarned;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'collectedMl': collectedMl,
      'durationMs': duration.inMilliseconds,
      'averageFlowRate': averageFlowRate,
      'pointsEarned': pointsEarned,
    };
  }
}
