# Controle de Gastos

App Flutter para registrar gastos do dia a dia e acompanhar quanto foi gasto nos últimos 30 dias.

Projeto da disciplina de Flutter (Engenharia de Software, UMC), 2º semestre de 2026.

## Funcionalidades

- Cadastrar um gasto com descrição, valor e data (escolhida num calendário)
- Ver o total gasto nos últimos 30 dias e o total geral
- Listar os gastos dos últimos 30 dias, do mais recente para o mais antigo
- Filtrar a lista por um dia específico pelo calendário
- Remover um gasto

## Estrutura do código

| Arquivo | O que faz |
|---|---|
| `lib/gasto.dart` | Modelo: classe `Gasto` (descrição, valor, data) e `ControleGastos` (lista e getter `total`) |
| `lib/formatadores.dart` | Mostra valores como `R$ 10,50` e datas como `03/11/2026` |
| `lib/main.dart` | Tela principal: totais, lista e filtro por dia |
| `lib/tela_novo_gasto.dart` | Formulário de cadastro com validação |
| `test/widget_test.dart` | Testes do `ControleGastos` e da tela inicial |

## Como rodar

```
flutter pub get
flutter run
```

Para rodar os testes:

```
flutter test
```

## Melhorias futuras

- Salvar os gastos no aparelho (hoje eles somem ao fechar o app)
- Cofrinho com meta de economia e barra de progresso
- Categorias de gasto
