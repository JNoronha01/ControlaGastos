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
  });

  testWidgets('tela inicial mostra o total zerado', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Controle de Gastos'), findsOneWidget);
    expect(find.text('R\$ 0,00'), findsNWidgets(1));
    expect(find.text('Total geral: R\$ 0,00'), findsOneWidget);
  });
}
