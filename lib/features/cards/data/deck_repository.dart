import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/firestore_helpers.dart';
import 'deck.dart';

// 덱 저장소: users/{uid}/decks 읽기·쓰기
class DeckRepository {
  DeckRepository(this._db, this._uid);

  // Firestore 일괄 쓰기 한 번에 넣을 수 있는 최대 건수(500)보다 조금 작게 나눈다
  static const _batchSize = 450;

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _decks =>
      userCollection(_db, _uid, 'decks');
  CollectionReference<Map<String, dynamic>> get _cards =>
      userCollection(_db, _uid, 'cards');

  // 덱 목록을 이름순으로 실시간 구독한다
  Stream<List<Deck>> watchAll() => _decks.snapshots().map((snap) {
    final decks = snap.docs.map((d) => Deck.fromMap(d.id, d.data())).toList();
    decks.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return decks;
  });

  // 새 덱을 만든다
  void create(String name) {
    fireAndForget(
      _decks.doc().set({
        'name': name,
        'newPerDay': Deck.defaultNewPerDay,
        'createdAt': Timestamp.now(),
      }),
    );
  }

  // 덱 이름을 바꾼다
  void rename(String id, String name) {
    fireAndForget(_decks.doc(id).update({'name': name}));
  }

  // 덱과 그 안의 카드를 모두 지운다 (일괄 쓰기 건수 제한 때문에 나눠서 지움)
  void delete(String id, List<String> cardIds) {
    final refs = [...cardIds.map(_cards.doc), _decks.doc(id)];
    for (var i = 0; i < refs.length; i += _batchSize) {
      final batch = _db.batch();
      for (final ref in refs.skip(i).take(_batchSize)) {
        batch.delete(ref);
      }
      fireAndForget(batch.commit());
    }
  }
}
