import 'package:flutter_test/flutter_test.dart';

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

    test('calendário vai de 2000 até hoje, sem limite de 30 dias', () {
      expect(dataMinima, DateTime(2000, 1, 1));
      expect(
        dataMinima.isBefore(DateTime.now().subtract(const Duration(days: 365))),
        isTrue,
      );
    });
  });

  testWidgets('tela inicial mostra o total zerado', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Controle de Gastos'), findsOneWidget);
    expect(find.text('R\$ 0,00'), findsNWidgets(1));
    expect(find.text('Total geral: R\$ 0,00'), findsOneWidget);
  });
}
