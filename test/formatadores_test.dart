import 'package:flutter_test/flutter_test.dart';

import 'package:controlagastos/formatadores.dart';

void main() {
  group('formatarMoeda', () {
    test('põe ponto de milhar e vírgula nos centavos', () {
      expect(formatarMoeda(0), 'R\$ 0,00');
      expect(formatarMoeda(18.4), 'R\$ 18,40');
      expect(formatarMoeda(999.99), 'R\$ 999,99');
      expect(formatarMoeda(1234.5), 'R\$ 1.234,50');
      expect(formatarMoeda(1234567.891), 'R\$ 1.234.567,89');
    });

    test('mostra o sinal de negativo antes do R\$', () {
      expect(formatarMoeda(-1500), '-R\$ 1.500,00');
    });
  });

  group('formatarDiaDaLista', () {
    // Domingo, 15/11/2026
    final hoje = DateTime(2026, 11, 15, 10, 30);

    test('usa Hoje e Ontem', () {
      expect(
        formatarDiaDaLista(DateTime(2026, 11, 15), hoje: hoje),
        'Hoje, 15 nov',
      );
      expect(
        formatarDiaDaLista(DateTime(2026, 11, 14, 23), hoje: hoje),
        'Ontem, 14 nov',
      );
    });

    test('usa o dia da semana para datas mais antigas', () {
      expect(
        formatarDiaDaLista(DateTime(2026, 11, 12), hoje: hoje),
        'Quinta, 12 nov',
      );
      expect(
        formatarDiaDaLista(DateTime(2026, 10, 31), hoje: hoje),
        'Sábado, 31 out',
      );
    });
  });
}
