import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider)),
);

// 현재 로그인한 사용자 (로그아웃 상태면 null)
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;
  bool _googleReady = false;

  // Google 로그인 모듈을 처음 한 번만 초기화한다 (웹 클라이언트 ID는 google-services.json에서 자동으로 읽음)
  Future<GoogleSignIn> _google() async {
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize();
      _googleReady = true;
    }
    return google;
  }

  // Google 계정 선택 창을 띄우고, 받은 토큰으로 Firebase에 로그인한다. 사용자가 취소하면 false를 돌려준다
  Future<bool> signInWithGoogle() async {
    try {
      final account = await (await _google()).authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'Google 토큰을 받지 못했습니다.',
        );
      }
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return false;
      }
      rethrow;
    }
  }

  // Google과 Firebase 양쪽에서 로그아웃한다 (다음 로그인 때 계정을 다시 고를 수 있게)
  Future<void> signOut() async {
    await (await _google()).signOut();
    await _auth.signOut();
  }
}
