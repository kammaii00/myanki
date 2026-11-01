import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// 사용자별 컬렉션(users/{uid}/{name}) 참조를 만든다
CollectionReference<Map<String, dynamic>> userCollection(
  FirebaseFirestore db,
  String uid,
  String name,
) => db.collection('users').doc(uid).collection(name);

// Firestore Timestamp를 DateTime으로 바꾼다 (값이 없으면 1970-01-01)
DateTime toDate(Object? value) => value is Timestamp
    ? value.toDate()
    : DateTime.fromMillisecondsSinceEpoch(0);

// 쓰기 작업을 기다리지 않고 실행한다.
// Firestore는 오프라인이면 서버 응답이 올 때까지 Future가 끝나지 않으므로,
// 화면은 즉시 반영되는 로컬 캐시만 믿고 넘어가고 실패만 로그로 남긴다
void fireAndForget(Future<void> write) {
  unawaited(
    write.catchError((Object e) => debugPrint('[Firestore] 쓰기 실패: $e')),
  );
}
