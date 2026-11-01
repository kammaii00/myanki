import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class MyAnkiApp extends ConsumerWidget {
  const MyAnkiApp({super.key});

  // 라우터와 라이트/다크 테마를 연결한 최상위 위젯을 그린다
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MyAnki',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
