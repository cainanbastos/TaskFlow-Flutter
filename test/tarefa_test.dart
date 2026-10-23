import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_flutter/models/tarefa.dart';

void main() {
  test('serializa e restaura titulo e conclusao', () {
    const original = Tarefa(id: '1', titulo: 'Estudar Flutter', concluida: true);
    final restaurada = Tarefa.fromJson(original.toJson());
    expect(restaurada.id, '1');
    expect(restaurada.titulo, 'Estudar Flutter');
    expect(restaurada.concluida, isTrue);
  });

  test('permite alternar conclusao sem perder o titulo', () {
    const original = Tarefa(id: '2', titulo: 'Ler PDF');
    final modificada = original.copyWith(concluida: true);
    expect(modificada.concluida, isTrue);
    expect(modificada.titulo, original.titulo);
    expect(original.concluida, isFalse);
  });
}
