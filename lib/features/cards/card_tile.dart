import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/dialogs.dart';
import 'data/card_providers.dart';
import 'data/flashcard.dart';

enum _CardAction { toggleSuspend, delete }

class CardTile extends ConsumerWidget {
  const CardTile({super.key, required this.card, this.deckName});

  final Flashcard card;
  final String? deckName; // 모든 카드 보기에서만 표시

  // 카드 앞면·뒷면 미리보기. 누르면 편집, 길게 누르면 일시정지/삭제 메뉴를 띄운다
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = card.suspended ? Theme.of(context).disabledColor : null;
    final subtitle = [
      ?deckName,
      if (card.back.isNotEmpty) card.back,
    ].join(' · ');
    return ListTile(
      title: Text(
        card.front,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: muted),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: card.suspended
          ? Tooltip(
              message: '일시정지됨',
              child: Icon(Icons.pause_circle_outline, color: muted),
            )
          : null,
      onTap: () => context.push('/cards/${card.id}'),
      onLongPress: () => _showActions(context, ref),
    );
  }

  // 길게 눌렀을 때 아래에서 메뉴를 띄우고, 고른 작업(일시정지 전환/삭제)을 실행한다
  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(cardRepositoryProvider);
    final action = await showModalBottomSheet<_CardAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                card.suspended
                    ? Icons.play_circle_outline
                    : Icons.pause_circle_outline,
              ),
              title: Text(card.suspended ? '일시정지 해제' : '일시정지'),
              onTap: () => Navigator.pop(context, _CardAction.toggleSuspend),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('삭제'),
              onTap: () => Navigator.pop(context, _CardAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _CardAction.toggleSuspend:
        repo.setSuspended(card.id, !card.suspended);
      case _CardAction.delete:
        final ok = await showConfirmDialog(
          context,
          title: '카드 삭제',
          message: '이 카드를 삭제합니다. 되돌릴 수 없습니다.',
        );
        if (ok) repo.delete(card.id);
    }
  }
}
