import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/dialogs.dart';
import 'data/card_providers.dart';

class CardEditScreen extends ConsumerStatefulWidget {
  const CardEditScreen({super.key, this.cardId, this.initialDeckId});

  final String? cardId; // null이면 새 카드 추가
  final String? initialDeckId; // 새 카드를 넣을 기본 덱

  // 카드 편집 화면의 상태(입력칸, 선택한 덱)를 만든다
  @override
  ConsumerState<CardEditScreen> createState() => _CardEditScreenState();
}

class _CardEditScreenState extends ConsumerState<CardEditScreen> {
  final _front = TextEditingController();
  final _back = TextEditingController();
  final _frontFocus = FocusNode();
  String? _deckId;
  bool _missing = false; // 편집할 카드를 찾지 못함 (다른 곳에서 삭제됨 등)

  bool get _isNew => widget.cardId == null;

  // 편집이면 기존 카드 내용을, 새 카드면 시작 덱을 채운다 (목록 화면에서 이미 받아 둔 데이터 사용)
  @override
  void initState() {
    super.initState();
    if (_isNew) {
      _deckId =
          widget.initialDeckId ??
          ref.read(decksProvider).value?.firstOrNull?.id;
      return;
    }
    final card = ref
        .read(cardsProvider)
        .value
        ?.where((c) => c.id == widget.cardId)
        .firstOrNull;
    if (card == null) {
      _missing = true;
      return;
    }
    _front.text = card.front;
    _back.text = card.back;
    _deckId = card.deckId;
  }

  // 화면이 사라질 때 입력칸 컨트롤러와 포커스를 정리한다
  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    _frontFocus.dispose();
    super.dispose();
  }

  // 화면 아래에 짧은 안내 문구를 띄운다
  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // 입력 내용을 저장한다. 새 카드는 입력칸을 비워 계속 추가할 수 있게, 편집은 저장 후 이전 화면으로 돌아간다
  void _save() {
    final front = _front.text.trim();
    final back = _back.text.trim();
    final deckId = _deckId;
    if (deckId == null) return _toast('덱을 선택해 주세요.');
    if (front.isEmpty) return _toast('앞면을 입력해 주세요.');

    final repo = ref.read(cardRepositoryProvider);
    if (_isNew) {
      repo.create(deckId: deckId, front: front, back: back);
      _front.clear();
      _back.clear();
      _frontFocus.requestFocus();
      _toast('추가했습니다.');
    } else {
      repo.update(widget.cardId!, deckId: deckId, front: front, back: back);
      context.pop();
    }
  }

  // 확인을 받은 뒤 카드를 지우고 이전 화면으로 돌아간다
  Future<void> _delete() async {
    final repo = ref.read(cardRepositoryProvider);
    final ok = await showConfirmDialog(
      context,
      title: '카드 삭제',
      message: '이 카드를 삭제합니다. 되돌릴 수 없습니다.',
    );
    if (!ok || !mounted) return;
    repo.delete(widget.cardId!);
    context.pop();
  }

  // 덱 선택, 앞면·뒷면 입력칸, 저장 버튼을 그린다
  @override
  Widget build(BuildContext context) {
    final decks = ref.watch(decksProvider).value ?? const [];
    final selected = decks.any((d) => d.id == _deckId) ? _deckId : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? '카드 추가' : '카드 편집'),
        actions: [
          if (!_isNew && !_missing)
            IconButton(
              tooltip: '삭제',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _missing
          ? const Center(child: Text('카드를 찾을 수 없습니다.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  items: [
                    for (final d in decks)
                      DropdownMenuItem(value: d.id, child: Text(d.name)),
                  ],
                  onChanged: (v) => setState(() => _deckId = v),
                  decoration: const InputDecoration(
                    labelText: '덱',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _front,
                  focusNode: _frontFocus,
                  autofocus: _isNew,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: '앞면 (영어 문장)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _back,
                  minLines: 2,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: '뒷면 (뜻·메모)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Text(_isNew ? '추가' : '저장'),
                ),
                if (_isNew) ...[
                  const SizedBox(height: 8),
                  Text(
                    '추가하면 입력칸이 비워져 다음 카드를 바로 입력할 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
    );
  }
}
