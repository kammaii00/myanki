import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/dialogs.dart';
import '../auth/auth_repository.dart';
import '../cards/data/card_providers.dart';
import 'deck_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // 덱 목록을 보여주는 홈 화면. 덱을 누르면 그 덱의 카드 목록으로 이동한다
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);
    final counts = ref.watch(deckCardCountsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyAnki'),
        actions: [
          IconButton(
            tooltip: '모든 카드 검색',
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/cards'),
          ),
          PopupMenuButton<void>(
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ],
      ),
      body: decks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('덱을 불러오지 못했습니다.\n$e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                  '덱이 없습니다.\n아래 [새 덱] 버튼으로 시작하세요.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  for (final deck in list)
                    DeckTile(deck: deck, cardCount: counts[deck.id] ?? 0),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createDeck(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('새 덱'),
      ),
    );
  }

  // 새 덱 이름을 입력받아 덱을 만든다
  Future<void> _createDeck(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(deckRepositoryProvider);
    final name = await showTextInputDialog(
      context,
      title: '새 덱',
      confirmLabel: '만들기',
    );
    if (name != null) repo.create(name);
  }
}
