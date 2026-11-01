import 'package:flutter/material.dart';

// 한 줄 입력 대화상자를 띄운다. 확인을 누르면 앞뒤 공백을 뺀 입력값을, 취소하거나 비워 두면 null을 돌려준다
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String confirmLabel = '확인',
}) async {
  final value = await showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: title,
      initial: initial,
      confirmLabel: confirmLabel,
    ),
  );
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

// 확인/취소 대화상자를 띄우고, 확인을 누르면 true를 돌려준다
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '삭제',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

// 입력창 컨트롤러를 대화상자 수명에 맞춰 관리하기 위한 위젯
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.initial,
    required this.confirmLabel,
  });

  final String title;
  final String initial;
  final String confirmLabel;

  // 대화상자 상태(입력창 컨트롤러)를 만든다
  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  // 대화상자가 닫힐 때 입력창 컨트롤러를 정리한다
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 제목, 입력창, 취소/확인 버튼을 그린다
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
