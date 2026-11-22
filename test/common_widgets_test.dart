import 'dart:async';

import 'package:app/widget/app_input_popup.dart';
import 'package:app/widget/app_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openPopup(
  WidgetTester tester,
  Future<void> Function(BuildContext) open, {
  NavigatorObserver? observer,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: observer == null ? [] : [observer],
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(onPressed: () => open(context), child: const Text('打开')),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('confirm and action sheets return typed choices and cancellation', (tester) async {
    bool? confirmed;
    await openPopup(tester, (context) async {
      confirmed = await showAppConfirmDialog(context, title: '提示', message: '确认操作');
    });
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);
    String? action;
    await openPopup(tester, (context) async {
      action = await showAppActionSheet(
        context,
        actions: const [
          AppAction(value: 'disabled', label: '不可用', enabled: false),
          AppAction(value: 'edit', label: '编辑'),
        ],
      );
    });
    await tester.tap(find.text('不可用'), warnIfMissed: false);
    await tester.pump();
    expect(find.byType(CupertinoActionSheet), findsOneWidget);
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    expect(action, 'edit');
  });

  testWidgets('input validates and returns trimmed text', (tester) async {
    String? result;
    await openPopup(tester, (context) async {
      result = await showAppInputPopup(context, title: '输入', validator: (value) => value.length < 2 ? '至少两个字' : null);
    });
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('请输入内容'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'a');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('至少两个字'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  内容  ');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(result, '内容');
  });

  testWidgets('quick replies obey formatters and character limits', (tester) async {
    await openPopup(tester, (context) async {
      await showAppInputPopup(
        context,
        title: '输入',
        quickReplies: ['a1234'],
        maxLength: 3,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    });
    await tester.tap(find.text('a1234'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '123');
  });

  testWidgets('password input preserves surrounding whitespace by default', (tester) async {
    String? result;
    await openPopup(tester, (context) async {
      result = await showAppInputPopup(context, title: '密码', obscureText: true, initialValue: ' a ');
    });
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(result, ' a ');
  });

  testWidgets('duplicate submit only pops one route', (tester) async {
    final observer = _PopObserver();
    await openPopup(tester, (context) async {
      await showAppInputPopup(context, title: '输入', initialValue: '内容');
    }, observer: observer);
    await tester.tap(find.text('确定'));
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(observer.popCount, 1);
    expect(find.text('打开'), findsOneWidget);
  });

  testWidgets('async submit locks dismissal and retains input for retry', (tester) async {
    final pending = Completer<bool>();
    String? result;
    var calls = 0;
    await openPopup(tester, (context) async {
      result = await showAppInputPopup(
        context,
        title: '输入',
        initialValue: '保留内容',
        onSubmit: (_) => calls++ == 0 ? pending.future : Future.value(true),
      );
    });
    await tester.tap(find.text('确定'));
    await tester.pump();
    final context = tester.element(find.byType(TextField));
    await Navigator.of(context).maybePop();
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(result, isNull);
    pending.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('提交失败，请重试'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '保留内容');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(result, '保留内容');
    expect(calls, 2);
  });

  testWidgets('submit exceptions stay in the popup and release the busy state', (tester) async {
    await openPopup(tester, (context) async {
      await showAppInputPopup(
        context,
        title: '输入',
        initialValue: '内容',
        onSubmit: (_) async => throw StateError('failed'),
      );
    });
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('提交失败，请重试'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screens, large text and keyboard insets remain scrollable', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2), viewInsets: const EdgeInsets.only(bottom: 240)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  showAppInputPopup(context, title: '一段较长的输入标题', maxLines: 3, quickReplies: const ['常用内容一', '常用内容二']),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('确定'));
    expect(tester.takeException(), isNull);
  });
}

class _PopObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => popCount++;
}
