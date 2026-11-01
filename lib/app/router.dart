import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_repository.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';

// 로그인 여부에 따라 로그인 화면과 홈 화면 사이를 자동으로 오가는 라우터
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = _AuthRefresh(auth.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  // 로그인 상태가 바뀔 때마다 라우터가 redirect를 다시 계산하도록 알린다
  _AuthRefresh(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _sub;

  // 화면이 사라질 때 로그인 상태 구독을 해제한다
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
