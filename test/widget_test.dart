import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_flutter/main.dart';

void main() {
  test('a classe principal do aplicativo existe', () {
    const app = TaskFlowApp();
    expect(app, isA<TaskFlowApp>());
  });
}
