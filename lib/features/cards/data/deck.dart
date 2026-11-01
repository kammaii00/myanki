import '../../../services/firestore_helpers.dart';

// 덱 한 개 (카드 묶음)
class Deck {
  const Deck({
    required this.id,
    required this.name,
    required this.newPerDay,
    required this.createdAt,
  });

  // 하루에 새로 볼 카드 수 기본값 (Anki 기본값과 같음)
  static const defaultNewPerDay = 20;

  final String id;
  final String name;
  final int newPerDay;
  final DateTime createdAt;

  // Firestore 문서 데이터를 Deck으로 바꾼다
  factory Deck.fromMap(String id, Map<String, dynamic> map) => Deck(
    id: id,
    name: map['name'] as String? ?? '',
    newPerDay: (map['newPerDay'] as num?)?.toInt() ?? defaultNewPerDay,
    createdAt: toDate(map['createdAt']),
  );
}
