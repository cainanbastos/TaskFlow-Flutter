# TaskFlow — Lista de Tarefas Persistente

Atividade da professora Andreza Quintas, baseada no PDF `Atividade_Persistencia_SharedPreferences.pdf`.

## Instalar

1. Extraia o ZIP em uma nova pasta; **não misture com o GeoProfile**.
2. No Windows, dê dois cliques em `INSTALAR_NO_WINDOWS.bat` ou use no terminal da pasta:

```bash
flutter create --platforms=android --project-name taskflow_flutter .
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run
```

3. Selecione seu tablet Android em `flutter devices` / `flutter run -d ID_DO_TABLET`.
4. Ao publicar no GitHub, inclua toda a estrutura gerada pelo `flutter create`, exceto arquivos ignorados por `.gitignore`.

## Recursos obrigatórios

- Campo de entrada e cadastro com validação de título.
- Lista de tarefas, checkbox de conclusão e exclusão individual.
- Persistência assíncrona usando `SharedPreferencesAsync` e JSON, guardando título, estado e ID.
- Leitura ao abrir e gravação após criar, concluir, editar ou excluir.

## Desafio adicional

- Editar uma tarefa.
- Contadores de total, pendentes e concluídas.
- Filtrar todas, pendentes e concluídas.
- Limpar concluídas com confirmação.
- Layout escuro responsivo para celular ou tablet.

## Teste de persistência exigido no PDF

1. Cadastre 3 tarefas; conclua 1.
2. Feche completamente e reabra o aplicativo.
3. Confira títulos e estados.
4. Exclua 1 tarefa, feche e reabra novamente; ela não deve reaparecer.
5. Faça capturas de tela antes/depois para comprovar.

**Nota:** Shared Preferences armazena dados localmente e não sincroniza com nuvem. A remoção dos dados do aplicativo ou sua desinstalação pode apagá-los.

## Limitações de validação

O SDK Flutter não está instalado neste ambiente de preparação: por isso, não foi possível executar `flutter analyze`, `flutter test` ou compilar um APK aqui. O instalador executa essas verificações no seu computador.


## Correção 23/10/2026
Corrigidos: nomes de parametros repetidos no separatorBuilder, argumento inexistente de Wrap e teste gerado que referencia MyApp. O arquivo test/widget_test.dart agora faz parte do projeto, evitando a criação do teste padrão.
