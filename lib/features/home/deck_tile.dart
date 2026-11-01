import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/dialogs.dart';
import '../cards/data/card_providers.dart';
import '../cards/data/deck.dart';

enum _DeckAction { rename, delete }

class DeckTile extends ConsumerWidget {
  const DeckTile({super.key, required this.deck, required this.cardCount});

  final Deck deck;
  final int cardCount;

  // 덱 이름과 카드 수를 보여주고, 오른쪽 메뉴로 이름 변경·삭제를 제공한다
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.style_outlined),
      title: Text(deck.name),
      subtitle: Text('카드 $cardCount장'),
      onTap: () => context.push('/decks/${deck.id}'),
      trailing: PopupMenuButton<_DeckAction>(
        onSelected: (action) => _onAction(context, ref, action),
        itemBuilder: (_) => const [
          PopupMenuItem(value: _DeckAction.rename, child: Text('이름 변경')),
          PopupMenuItem(value: _DeckAction.delete, child: Text('삭제')),
        ],
      ),
    );
  }

  // 메뉴에서 고른 작업(이름 변경/삭제)을 실행한다
  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _DeckAction action,
  ) async {
    final repo = ref.read(deckRepositoryProvider);
    switch (action) {
      case _DeckAction.rename:
        final name = await showTextInputDialog(
          context,
          title: '덱 이름 변경',
          initial: deck.name,
          confirmLabel: '변경',
        );
        if (name != null) repo.rename(deck.id, name);
      case _DeckAction.delete:
        final cardIds = (ref.read(cardsProvider).value ?? const [])
            .where((c) => c.deckId == deck.id)
            .map((c) => c.id)
            .toList();
        final ok = await showConfirmDialog(
          context,
          title: '덱 삭제',
          message:
              "'${deck.name}' 덱과 카드 ${cardIds.length}장을 모두 삭제합니다.\n"
              '되돌릴 수 없습니다.',
        );
        if (ok) repo.delete(deck.id, cardIds);
    }
  }
}
