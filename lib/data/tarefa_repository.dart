import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tarefa.dart';

class TarefaRepository {
  TarefaRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _chave = 'taskflow_tarefas_v1';
  final SharedPreferencesAsync _preferences;

  Future<List<Tarefa>> carregar() async {
    final dados = await _preferences.getString(_chave);
    if (dados == null || dados.isEmpty) return [];
    final lista = jsonDecode(dados) as List<dynamic>;
    return lista
        .map((item) => Tarefa.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> salvar(List<Tarefa> tarefas) async {
    final dados = jsonEncode(tarefas.map((tarefa) => tarefa.toJson()).toList());
    await _preferences.setString(_chave, dados);
  }
}
