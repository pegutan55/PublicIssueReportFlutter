import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:public_issue_reporter/report_dialog.dart';

void main() {
  testWidgets('requires a photo or a description before submission', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ReportDialog())),
    );

    await tester.tap(find.widgetWithText(FilledButton, '故障報告をする'));
    await tester.pumpAndSettle();

    expect(find.text('写真、もしくは故障内容を入力してください'), findsOneWidget);
    expect(find.text('閉じる'), findsOneWidget);
  });

  testWidgets('cancelling confirmation keeps the report open', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ReportDialog())),
    );

    await tester.enterText(find.byType(TextField), '街灯が点灯していません');
    await tester.tap(find.widgetWithText(FilledButton, '故障報告をする'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'いいえ'));
    await tester.pumpAndSettle();

    expect(find.text('故障報告'), findsOneWidget);
    expect(find.text('故障報告を行います。よろしいですか？'), findsNothing);
  });

  testWidgets('cancel and confirm close require explicit confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ReportDialog())),
    );

    await tester.tap(find.byTooltip('閉じる'));
    await tester.pumpAndSettle();
    expect(find.text('故障報告をやめますか？'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'いいえ'));
    await tester.pumpAndSettle();
    expect(find.text('故障報告'), findsOneWidget);

    await tester.tap(find.byTooltip('閉じる'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'はい'));
    await tester.pumpAndSettle();
    expect(find.text('故障報告'), findsNothing);
  });

  testWidgets('confirms and completes a report with a description', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ReportDialog())),
    );

    await tester.enterText(find.byType(TextField), '街灯が点灯していません');
    await tester.tap(find.widgetWithText(FilledButton, '故障報告をする'));
    await tester.pumpAndSettle();

    expect(find.text('故障報告を行います。よろしいですか？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'はい'));
    await tester.pumpAndSettle();

    expect(find.text('故障報告を行いました'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '閉じる'));
    await tester.pumpAndSettle();
    expect(find.text('故障報告'), findsNothing);
  });
}
