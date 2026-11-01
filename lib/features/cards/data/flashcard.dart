import '../../../services/firestore_helpers.dart';

// 카드 한 장. 음성(audio)은 2단계, 복습 상태(srs)는 3단계에서 문서에 추가되며
// 이 모델은 그 필드를 읽지도 덮어쓰지도 않는다 (수정은 바꾼 필드만 update)
class Flashcard {
  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.tags,
    required this.suspended,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String deckId;
  final String front;
  final String back;
  final List<String> tags;
  final bool suspended; // 일시정지 카드는 복습에 나오지 않음
  final DateTime createdAt;
  final DateTime updatedAt;

  // Firestore 문서 데이터를 Flashcard로 바꾼다 (빠진 값은 기본값으로 채움)
  factory Flashcard.fromMap(String id, Map<String, dynamic> map) => Flashcard(
    id: id,
    deckId: map['deckId'] as String? ?? '',
    front: map['front'] as String? ?? '',
    back: map['back'] as String? ?? '',
    tags: List<String>.from(map['tags'] as List? ?? const []),
    suspended: map['suspended'] as bool? ?? false,
    createdAt: toDate(map['createdAt']),
    updatedAt: toDate(map['updatedAt']),
  );

  // 검색어가 앞면·뒷면·태그 중 하나에 들어 있는지 대소문자 구분 없이 확인한다
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return front.toLowerCase().contains(q) ||
        back.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}
