import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanki/features/cards/data/flashcard.dart';

// 카드 모델 변환과 검색 규칙을 확인한다
void main() {
  test('fromMap: 문서 값을 읽고, 빠진 값은 기본값으로 채운다', () {
    final created = DateTime(2026, 11, 1, 9);
    final card = Flashcard.fromMap('c1', {
      'deckId': 'd1',
      'front': 'How have you been?',
      'createdAt': Timestamp.fromDate(created),
    });
    expect(card.id, 'c1');
    expect(card.deckId, 'd1');
    expect(card.front, 'How have you been?');
    expect(card.back, '');
    expect(card.tags, isEmpty);
    expect(card.suspended, isFalse);
    expect(card.createdAt, created);
    expect(card.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('matches: 앞면·뒷면·태그를 대소문자 구분 없이 찾는다', () {
    final card = Flashcard.fromMap('c1', {
      'front': 'Long time no see.',
      'back': '오랜만이야',
      'tags': ['Greeting'],
    });
    expect(card.matches(''), isTrue);
    expect(card.matches('  time NO  '), isTrue);
    expect(card.matches('오랜만'), isTrue);
    expect(card.matches('greet'), isTrue);
    expect(card.matches('goodbye'), isFalse);
  });
}
