class Tarefa {
  const Tarefa({
    required this.id,
    required this.titulo,
    this.concluida = false,
  });

  final String id;
  final String titulo;
  final bool concluida;

  Tarefa copyWith({String? titulo, bool? concluida}) => Tarefa(
        id: id,
        titulo: titulo ?? this.titulo,
        concluida: concluida ?? this.concluida,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'concluida': concluida,
      };

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      concluida: json['concluida'] as bool? ?? false,
    );
  }
}
