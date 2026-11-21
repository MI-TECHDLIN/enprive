import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// True when the primary focus is the nearest focus node that owns [target],
/// i.e. the control rendering [target] itself holds keyboard focus.
bool focusIsOn(WidgetTester tester, Finder target) {
  final primary = FocusManager.instance.primaryFocus;
  if (primary == null || primary is FocusScopeNode) return false;
  final owner = Focus.maybeOf(tester.element(target), createDependency: false);
  return identical(owner, primary);
}

/// Presses Tab until [target] holds keyboard focus. Returns the number of Tab
/// presses it took, or fails the test when focus never reaches it.
Future<int> tabTo(
  WidgetTester tester,
  Finder target, {
  int maxTabs = 40,
}) async {
  for (var i = 1; i <= maxTabs; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    if (focusIsOn(tester, target)) return i;
  }
  fail('Tab never moved keyboard focus onto $target within $maxTabs presses.');
}
