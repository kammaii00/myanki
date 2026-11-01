import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_repository.dart';
import 'card_repository.dart';
import 'deck.dart';
import 'deck_repository.dart';
import 'flashcard.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// 현재 로그인한 사용자의 uid (로그아웃 상태면 null). 로그인 상태가 바뀌면 다시 계산된다
final uidProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(firebaseAuthProvider).currentUser?.uid;
});

// 덱 저장소 (로그인한 화면에서만 사용)
final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) throw StateError('로그인이 필요합니다.');
  return DeckRepository(ref.watch(firestoreProvider), uid);
});

// 카드 저장소 (로그인한 화면에서만 사용)
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) throw StateError('로그인이 필요합니다.');
  return CardRepository(ref.watch(firestoreProvider), uid);
});

// 덱 목록 (이름순)
final decksProvider = StreamProvider<List<Deck>>((ref) {
  if (ref.watch(uidProvider) == null) return Stream.value(const []);
  return ref.watch(deckRepositoryProvider).watchAll();
});

// 모든 카드 (최근 추가순)
final cardsProvider = StreamProvider<List<Flashcard>>((ref) {
  if (ref.watch(uidProvider) == null) return Stream.value(const []);
  return ref.watch(cardRepositoryProvider).watchAll();
});

// 덱별 카드 수 (홈 화면 표시용)
final deckCardCountsProvider = Provider<Map<String, int>>((ref) {
  final counts = <String, int>{};
  for (final card in ref.watch(cardsProvider).value ?? const <Flashcard>[]) {
    counts[card.deckId] = (counts[card.deckId] ?? 0) + 1;
  }
  return counts;
});
