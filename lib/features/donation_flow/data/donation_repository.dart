import '../models/donation_record.dart';

/// Bağış kayıtları veri erişim sözleşmesi (Repository pattern).
abstract class DonationRepository {
  Future<List<DonationRecord>> getDonations();
  Future<void> addDonation(DonationRecord record);
  Future<void> clear();
}

/// Bellek içi (in-memory) bağış deposu uygulaması.
class InMemoryDonationRepository implements DonationRepository {
  InMemoryDonationRepository([List<DonationRecord>? initialRecords])
      : _records = List.of(initialRecords ?? []);

  final List<DonationRecord> _records;

  @override
  Future<List<DonationRecord>> getDonations() async {
    return List.unmodifiable(_records);
  }

  @override
  Future<void> addDonation(DonationRecord record) async {
    _records.add(record);
  }

  @override
  Future<void> clear() async {
    _records.clear();
  }

  int get count => _records.length;
}
