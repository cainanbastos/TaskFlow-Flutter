import 'dart:async';

import 'package:flutter/material.dart';

import '../data/tarefa_repository.dart';
import '../models/tarefa.dart';

enum FiltroTarefas { todas, pendentes, concluidas }

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final _campo = TextEditingController();
  final _repository = TarefaRepository();
  final List<Tarefa> _tarefas = [];
  FiltroTarefas _filtro = FiltroTarefas.todas;
  Future<void> _filaSalvamento = Future<void>.value();
  bool _carregando = true;
  bool _erroLeitura = false;
  String? _erroSalvamento;
  int _contadorIds = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroLeitura = false;
    });
    try {
      final salvas = await _repository.carregar();
      if (!mounted) return;
      setState(() {
        _tarefas
          ..clear()
          ..addAll(salvas);
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erroLeitura = true;
      });
    }
  }

  // Cada mudança salva uma foto imutável da lista em uma fila sequencial.
  // Isso evita que gravações simultâneas invertam a ordem das alterações.
  void _salvar() {
    final copia = List<Tarefa>.of(_tarefas);
    _filaSalvamento = _filaSalvamento
        .catchError((Object _) {})
        .then((_) async {
          try {
            await _repository.salvar(copia);
            if (mounted && _erroSalvamento != null) {
              setState(() => _erroSalvamento = null);
            }
          } catch (_) {
            if (!mounted) return;
            setState(() => _erroSalvamento =
                'Não foi possível salvar. Tente alterar uma tarefa novamente.');
          }
        });
  }

  void _adicionar() {
    final titulo = _campo.text.trim();
    if (titulo.isEmpty) {
      _mensagem('Digite o título da tarefa.');
      return;
    }
    final id = '${DateTime.now().microsecondsSinceEpoch}_${_contadorIds++}';
    setState(() {
      _tarefas.insert(0, Tarefa(id: id, titulo: titulo));
      _filtro = FiltroTarefas.todas;
      _campo.clear();
    });
    FocusScope.of(context).unfocus();
    _salvar();
  }

  void _alternar(Tarefa tarefa, bool? concluida) {
    final indice = _tarefas.indexWhere((item) => item.id == tarefa.id);
    if (indice < 0) return;
    setState(() {
      _tarefas[indice] = tarefa.copyWith(concluida: concluida ?? false);
    });
    _salvar();
  }

  void _excluir(Tarefa tarefa) {
    setState(() => _tarefas.removeWhere((item) => item.id == tarefa.id));
    _salvar();
    _mensagem('Tarefa excluída.');
  }

  Future<void> _editar(Tarefa tarefa) async {
    final controller = TextEditingController(text: tarefa.titulo);
    final novoTitulo = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar tarefa'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Título'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    // Mantém o controller vivo até a animação de fechamento do diálogo acabar.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    if (!mounted || novoTitulo == null) return;
    if (novoTitulo.isEmpty) {
      _mensagem('O título não pode ficar vazio.');
      return;
    }
    final indice = _tarefas.indexWhere((item) => item.id == tarefa.id);
    if (indice < 0) return;
    setState(() => _tarefas[indice] = _tarefas[indice].copyWith(titulo: novoTitulo));
    _salvar();
  }

  Future<void> _limparConcluidas() async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar tarefas concluídas?'),
        content: const Text('As tarefas concluídas serão removidas da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (!mounted || confirma != true) return;
    setState(() => _tarefas.removeWhere((item) => item.concluida));
    _salvar();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = _tarefas.where((item) => !item.concluida).length;
    final concluidas = _tarefas.length - pendentes;
    final visiveis = _tarefas.where((tarefa) => switch (_filtro) {
      FiltroTarefas.todas => true,
      FiltroTarefas.pendentes => !tarefa.concluida,
      FiltroTarefas.concluidas => tarefa.concluida,
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (concluidas > 0)
            IconButton(
              tooltip: 'Limpar concluídas',
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: _limparConcluidas,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Organize seu dia.',
                    style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Suas tarefas ficam salvas neste dispositivo.',
                    style: TextStyle(color: Color(0xFFADB9D2))),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF19253B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      _estatistica('Total', _tarefas.length, Icons.list_alt_rounded),
                      _estatistica('Pendentes', pendentes, Icons.schedule_rounded),
                      _estatistica('Concluídas', concluidas, Icons.check_circle_outline),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _campo,
                        enabled: !_carregando && !_erroLeitura,
                        maxLength: 120,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _adicionar(),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Qual é a próxima tarefa?',
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                          filled: true,
                          fillColor: const Color(0xFF18243A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _carregando || _erroLeitura ? null : _adicionar,
                        child: const Icon(Icons.add_rounded),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  if (_erroSalvamento != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_erroSalvamento!,
                        style: const TextStyle(color: Color(0xFFFFA8A8))),
                    ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<FiltroTarefas>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: FiltroTarefas.todas, label: Text('Todas')),
                        ButtonSegment(value: FiltroTarefas.pendentes, label: Text('Pendentes')),
                        ButtonSegment(value: FiltroTarefas.concluidas, label: Text('Concluídas')),
                      ],
                      selected: {_filtro},
                      onSelectionChanged: (valor) => setState(() => _filtro = valor.first),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: _carregando
                        ? const Center(child: CircularProgressIndicator())
                        : _erroLeitura
                            ? Center(child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Não foi possível carregar as tarefas.'),
                                  TextButton(onPressed: _carregar, child: const Text('Tentar novamente')),
                                ],
                              ))
                            : visiveis.isEmpty
                                ? Center(child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.task_alt_rounded, size: 65,
                                          color: Color(0xFF7589AE)),
                                      const SizedBox(height: 12),
                                      Text(_tarefas.isEmpty
                                          ? 'Nenhuma tarefa cadastrada.'
                                          : 'Nenhuma tarefa neste filtro.',
                                          style: const TextStyle(color: Color(0xFFADB9D2))),
                                    ],
                                  ))
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    itemCount: visiveis.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 9),
                                    itemBuilder: (context, index) {
                                      final tarefa = visiveis[index];
                                      return Container(
                                        key: ValueKey(tarefa.id),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF19253B),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                          leading: Checkbox(
                                            value: tarefa.concluida,
                                            onChanged: (valor) => _alternar(tarefa, valor),
                                          ),
                                          title: Text(tarefa.titulo,
                                            style: TextStyle(
                                              decoration: tarefa.concluida
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              color: tarefa.concluida
                                                  ? const Color(0xFF94A3BD)
                                                  : Colors.white,
                                            )),
                                          trailing: Wrap(spacing: 0, children: [
                                            IconButton(
                                              tooltip: 'Editar',
                                              onPressed: () => _editar(tarefa),
                                              icon: const Icon(Icons.edit_outlined),
                                            ),
                                            IconButton(
                                              tooltip: 'Excluir',
                                              onPressed: () => _excluir(tarefa),
                                              icon: const Icon(Icons.delete_outline_rounded),
                                            ),
                                          ]),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _estatistica(String titulo, int quantidade, IconData icone) =>
      Expanded(child: Column(children: [
        Icon(icone, color: const Color(0xFF9BAAFF), size: 20),
        const SizedBox(height: 7),
        Text('$quantidade', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        Text(titulo, style: const TextStyle(color: Color(0xFFB2BED3), fontSize: 12)),
      ]));
}
