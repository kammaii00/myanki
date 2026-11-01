import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // 로그인한 계정을 보여주는 임시 홈 화면 (1단계에서 덱 목록으로 바뀜)
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authStateProvider).value?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyAnki'),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$email 로 로그인됨'),
            const SizedBox(height: 8),
            const Text('덱 목록은 1단계에서 추가됩니다.'),
          ],
        ),
      ),
    );
  }
}
