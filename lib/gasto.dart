class Gasto {
  final String descricao;
  final double valor;

  Gasto({required this.descricao, required this.valor});
}

class ControleGastos {
  final List<Gasto> _gastos = [];

  List<Gasto> get gastos => _gastos;

  void adicionarGasto(Gasto gasto) {
    _gastos.add(gasto);
  }

  void removerGasto(Gasto gasto) {
    _gastos.remove(gasto);
  }

    double get total {
    double soma = 0.0;
    for (var gasto in _gastos) {
      soma += gasto.valor;
    }
    return soma;
  }
}


