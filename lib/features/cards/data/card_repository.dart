import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/firestore_helpers.dart';
import 'flashcard.dart';

// 카드 저장소: users/{uid}/cards 읽기·쓰기
class CardRepository {
  CardRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _cards =>
      userCollection(_db, _uid, 'cards');

  // 모든 카드를 최근 추가순으로 실시간 구독한다.
  // 개인용 규모(수천 장)라 전체를 받아 화면에서 거른다 — 쿼리·인덱스가 필요 없다
  Stream<List<Flashcard>> watchAll() => _cards.snapshots().map((snap) {
    final cards = snap.docs
        .map((d) => Flashcard.fromMap(d.id, d.data()))
        .toList();
    cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return cards;
  });

  // 새 카드를 추가한다 (복습 상태가 없는 카드는 '새 카드'로 취급됨)
  void create({
    required String deckId,
    required String front,
    required String back,
  }) {
    final now = Timestamp.now();
    fireAndForget(
      _cards.doc().set({
        'deckId': deckId,
        'front': front,
        'back': back,
        'tags': <String>[],
        'suspended': false,
        'createdAt': now,
        'updatedAt': now,
      }),
    );
  }

  // 카드의 덱·앞면·뒷면만 고친다 (복습 상태와 음성 정보는 그대로 둠)
  void update(
    String id, {
    required String deckId,
    required String front,
    required String back,
  }) {
    fireAndForget(
      _cards.doc(id).update({
        'deckId': deckId,
        'front': front,
        'back': back,
        'updatedAt': Timestamp.now(),
      }),
    );
  }

  // 카드를 일시정지하거나 해제한다
  void setSuspended(String id, bool suspended) {
    fireAndForget(
      _cards.doc(id).update({
        'suspended': suspended,
        'updatedAt': Timestamp.now(),
      }),
    );
  }

  // 카드를 지운다
  void delete(String id) {
    fireAndForget(_cards.doc(id).delete());
  }
}
