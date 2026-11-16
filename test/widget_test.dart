import 'package:flutter_test/flutter_test.dart';

import 'package:controlagastos/formatadores.dart';
import 'package:controlagastos/gasto.dart';
import 'package:controlagastos/main.dart';

void main() {
  group('ControleGastos', () {
    test('total soma o valor de todos os gastos', () {
      final controle = ControleGastos();
      controle.adicionarGasto(
        Gasto(descricao: 'Mercado', valor: 100.0, data: DateTime.now()),
      );
      controle.adicionarGasto(
        Gasto(descricao: 'Lanche', valor: 25.5, data: DateTime.now()),
      );

      expect(controle.total, 125.5);
    });

    test('total começa em zero', () {
      expect(ControleGastos().total, 0.0);
    });

    test('gastos com mais de 30 dias ficam fora da lista recente', () {
      final controle = ControleGastos();
      final antigo = Gasto(
        descricao: 'Antigo',
        valor: 50.0,
        data: DateTime.now().subtract(const Duration(days: 45)),
      );
      final recente = Gasto(
        descricao: 'Recente',
        valor: 20.0,
        data: DateTime.now(),
      );
      controle.adicionarGasto(antigo);
      controle.adicionarGasto(recente);

      expect(controle.gastosRecentes(), [recente]);
      expect(controle.totalRecente(), 20.0);
      expect(controle.total, 70.0); // o total geral continua somando tudo
    });

    test('remover tira o gasto da lista', () {
      final controle = ControleGastos();
      final gasto = Gasto(descricao: 'Uber', valor: 18.0, data: DateTime.now());
      controle.adicionarGasto(gasto);
      controle.removerGasto(gasto);

      expect(controle.gastos, isEmpty);
      expect(controle.total, 0.0);
    });

    test('gastosDoDia acha gastos de qualquer data, até de anos atrás', () {
      final controle = ControleGastos();
      final antigo = Gasto(
        descricao: 'Material escolar',
        valor: 80.0,
        data: DateTime(2023, 2, 10, 14, 30),
      );
      final mesmoDia = Gasto(
        descricao: 'Lanche',
        valor: 12.0,
        data: DateTime(2023, 2, 10, 9, 0),
      );
      final outroDia = Gasto(
        descricao: 'Uber',
        valor: 20.0,
        data: DateTime(2023, 2, 11),
      );
      controle.adicionarGasto(mesmoDia);
      controle.adicionarGasto(antigo);
      controle.adicionarGasto(outroDia);

      // Do mais recente (14h30) para o mais antigo (9h) do mesmo dia.
      expect(controle.gastosDoDia(DateTime(2023, 2, 10)), [antigo, mesmoDia]);
      expect(controle.gastosRecentes(), isEmpty); // fora dos 30 dias
    });

    test('todosOrdenados junta gastos de anos diferentes, do mais novo ao mais antigo', () {
      final controle = ControleGastos();
      final de2022 = Gasto(
        descricao: 'Curso',
        valor: 300.0,
        data: DateTime(2022, 5, 3),
      );
      final hoje = Gasto(
        descricao: 'Almoço',
        valor: 1016.0,
        data: DateTime.now(),
      );
      final de2016 = Gasto(
        descricao: 'Livro',
        valor: 45.0,
        data: DateTime(2016, 8, 20),
      );
      controle.adicionarGasto(de2022);
      controle.adicionarGasto(hoje);
      controle.adicionarGasto(de2016);

      expect(controle.todosOrdenados, [hoje, de2022, de2016]);
      expect(controle.total, 1361.0); // 300 + 1016 + 45
    });

    test('gastosDoMes e totalDoMes pegam só o mês escolhido', () {
      final controle = ControleGastos();
      final natal = Gasto(
        descricao: 'Presentes',
        valor: 250.0,
        data: DateTime(2020, 12, 24),
      );
      final virada = Gasto(
        descricao: 'Ceia',
        valor: 120.0,
        data: DateTime(2020, 12, 31),
      );
      final janeiro = Gasto(
        descricao: 'IPVA',
        valor: 900.0,
        data: DateTime(2021, 1, 5),
      );
      final dezembroDeOutroAno = Gasto(
        descricao: 'Mercado',
        valor: 80.0,
        data: DateTime(2021, 12, 10),
      );
      for (final g in [natal, janeiro, virada, dezembroDeOutroAno]) {
        controle.adicionarGasto(g);
      }

      expect(controle.gastosDoMes(DateTime(2020, 12)), [virada, natal]);
      expect(controle.totalDoMes(DateTime(2020, 12)), 370.0);
      expect(controle.totalDoMes(DateTime(2021, 1)), 900.0);
      expect(controle.gastosDoMes(DateTime(2019, 6)), isEmpty);
    });

    test('saldo = entradas − gastos − investido, só do mês escolhido', () {
      final controle = ControleGastos();
      final nov = DateTime(2026, 11, 5);
      controle.adicionarGasto(
        Gasto(
          descricao: 'Salário',
          valor: 2000,
          data: nov,
          tipo: TipoLancamento.entrada,
        ),
      );
      controle.adicionarGasto(
        Gasto(
          descricao: 'Mercado',
          valor: 100,
          data: nov,
          categoria: Categoria.mercado,
        ),
      );
      controle.adicionarGasto(
        Gasto(
          descricao: 'Tesouro',
          valor: 500,
          data: nov,
          tipo: TipoLancamento.investimento,
        ),
      );
      // Outro mês: não entra no resumo de novembro.
      controle.adicionarGasto(
        Gasto(descricao: 'Uber', valor: 50, data: DateTime(2026, 10, 1)),
      );

      final resumo = controle.resumoDoMes(DateTime(2026, 11));
      expect(resumo.entradas, 2000);
      expect(resumo.gastos, 100);
      expect(resumo.investido, 500);
      expect(resumo.saldo, 1400);

      // total e totalDoMes continuam somando só gastos.
      expect(controle.total, 150);
      expect(controle.totalDoMes(DateTime(2026, 11)), 100);
      expect(controle.lancamentosDoMes(DateTime(2026, 11)).length, 3);
      expect(controle.gastosDoMes(DateTime(2026, 11)).length, 1);
    });

    test('totalPorCategoria soma cada categoria, da maior para a menor', () {
      final controle = ControleGastos();
      final dia = DateTime(2026, 11, 10);
      controle.adicionarGasto(
        Gasto(
          descricao: 'Uber',
          valor: 50,
          data: dia,
          categoria: Categoria.transporte,
        ),
      );
      controle.adicionarGasto(
        Gasto(
          descricao: 'Mercado',
          valor: 100,
          data: dia,
          categoria: Categoria.mercado,
        ),
      );
      controle.adicionarGasto(
        Gasto(
          descricao: 'Streaming',
          valor: 219,
          data: dia,
          categoria: Categoria.assinaturas,
        ),
      );
      controle.adicionarGasto(
        Gasto(
          descricao: 'Feira',
          valor: 30,
          data: dia,
          categoria: Categoria.mercado,
        ),
      );

      final porCategoria = controle.totalPorCategoria(DateTime(2026, 11));
      expect(porCategoria.map((e) => e.key).toList(), [
        Categoria.assinaturas,
        Categoria.mercado,
        Categoria.transporte,
      ]);
      expect(porCategoria[1].value, 130);
      expect(controle.totalPorCategoria(DateTime(2026, 10)), isEmpty);
    });

    test('entradas e investimentos não têm categoria; gasto sem categoria vira Outros', () {
      final entrada = Gasto(
        descricao: 'Pix',
        valor: 10,
        data: DateTime.now(),
        tipo: TipoLancamento.entrada,
        categoria: Categoria.mercado,
      );
      expect(entrada.categoria, isNull);
      expect(
        Gasto(descricao: 'X', valor: 1, data: DateTime.now()).categoria,
        Categoria.outros,
      );
    });

    test('calendário vai de 2000 até hoje, sem limite de 30 dias', () {
      expect(dataMinima, DateTime(2000, 1, 1));
      expect(
        dataMinima.isBefore(DateTime.now().subtract(const Duration(days: 365))),
        isTrue,
      );
    });
  });

  testWidgets('tela inicial abre no mês atual, sem o total geral', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final mesAtual = formatarMes(DateTime.now(), maiuscula: false);
    expect(find.text('Controle de Gastos'), findsOneWidget);
    expect(find.text('Saldo de $mesAtual'), findsOneWidget);
    expect(find.text('Saldo total'), findsNothing);
    // Legenda do gráfico.
    expect(find.text('Gasto'), findsOneWidget);
    expect(find.text('Investido'), findsOneWidget);
    expect(find.text('Sobrando'), findsOneWidget);
  });

  testWidgets('opção "Tudo" mostra o saldo total', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tudo'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo total'), findsOneWidget);
    expect(find.text('Todos os lançamentos'), findsOneWidget);
  });

  testWidgets('formulário pede categoria só para gasto', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Novo lançamento'));
    await tester.pumpAndSettle();
    expect(find.text('Categoria'), findsOneWidget);

    await tester.tap(find.text('Entrada'));
    await tester.pumpAndSettle();
    expect(find.text('Categoria'), findsNothing);
    expect(find.text('Salvar entrada'), findsOneWidget);
  });

  testWidgets('setas trocam o mês e não deixam passar do mês atual', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final agora = DateTime.now();

    await tester.tap(find.byTooltip('Mês anterior'));
    await tester.pump();
    expect(
      find.text(formatarMes(DateTime(agora.year, agora.month - 1))),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pump();
    expect(find.text(formatarMes(agora)), findsOneWidget);

    // No mês atual a seta de avançar fica desativada.
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pump();
    expect(find.text(formatarMes(agora)), findsOneWidget);
  });
}
