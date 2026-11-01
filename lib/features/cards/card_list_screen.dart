import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'card_tile.dart';
import 'data/card_providers.dart';

class CardListScreen extends ConsumerStatefulWidget {
  const CardListScreen({super.key, this.deckId});

  final String? deckId; // null이면 모든 덱의 카드를 보여줌

  // 카드 목록 화면의 상태(검색어)를 만든다
  @override
  ConsumerState<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends ConsumerState<CardListScreen> {
  String _query = '';

  // 검색창과 카드 목록을 그린다. 모든 카드 보기에서는 카드마다 덱 이름도 표시한다
  @override
  Widget build(BuildContext context) {
    final deckId = widget.deckId;
    final decks = ref.watch(decksProvider).value ?? const [];
    final deckNames = {for (final d in decks) d.id: d.name};
    final title = deckId == null ? '모든 카드' : (deckNames[deckId] ?? '덱');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '앞면·뒷면·태그 검색',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: ref
          .watch(cardsProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('카드를 불러오지 못했습니다.\n$e')),
            data: (all) {
              final cards = all
                  .where((c) => deckId == null || c.deckId == deckId)
                  .where((c) => c.matches(_query))
                  .toList();
              if (cards.isEmpty) {
                return Center(
                  child: Text(_query.isEmpty ? '카드가 없습니다.' : '검색 결과가 없습니다.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: cards.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) => CardTile(
                  card: cards[i],
                  deckName: deckId == null ? deckNames[cards[i].deckId] : null,
                ),
              );
            },
          ),
      floatingActionButton: decks.isEmpty
          ? null
          : FloatingActionButton(
              tooltip: '카드 추가',
              onPressed: () => context.push(
                deckId == null ? '/cards/new' : '/cards/new?deckId=$deckId',
              ),
              child: const Icon(Icons.add),
            ),
    );
  }
}
