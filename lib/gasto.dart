/// Data mais antiga que os calendários deixam escolher.
/// A mais nova é sempre "hoje", então o intervalo cresce sozinho
/// a cada dia, sem nunca esconder os dias antigos.
final DateTime dataMinima = DateTime(2000, 1, 1);

/// Representa UM gasto registrado pelo usuário.
class Gasto {
  final String descricao;
  final double valor;
  final DateTime data;

  Gasto({required this.descricao, required this.valor, required this.data});
}

/// Guarda a LISTA de gastos e faz os cálculos sobre ela.
class ControleGastos {
  final List<Gasto> _gastos = [];

  /// Devolve uma cópia que não pode ser alterada: quem estiver fora da
  /// classe só consegue mudar a lista pelos métodos abaixo (encapsulamento).
  List<Gasto> get gastos => List.unmodifiable(_gastos);

  void adicionarGasto(Gasto gasto) {
    _gastos.add(gasto);
  }

  void removerGasto(Gasto gasto) {
    _gastos.remove(gasto);
  }

  /// Soma o valor de TODOS os gastos (o getter pedido no enunciado).
  double get total {
    double soma = 0.0;
    for (var gasto in _gastos) {
      soma += gasto.valor;
    }
    return soma;
  }

  /// Gastos feitos nos últimos [dias] dias, do mais recente para o mais antigo.
  List<Gasto> gastosRecentes({int dias = 30}) {
    final limite = _inicioDoDia(DateTime.now()).subtract(Duration(days: dias));

    final recentes = _gastos
        .where((gasto) => !gasto.data.isBefore(limite))
        .toList();

    // b.compareTo(a) ordena do maior (mais recente) para o menor.
    recentes.sort((a, b) => b.data.compareTo(a.data));
    return recentes;
  }

  /// Todos os gastos de um dia específico (de qualquer data, não só
  /// dos últimos 30 dias), do mais recente para o mais antigo.
  List<Gasto> gastosDoDia(DateTime dia) {
    final inicio = _inicioDoDia(dia);
    final doDia = _gastos
        .where((gasto) => _inicioDoDia(gasto.data) == inicio)
        .toList();
    doDia.sort((a, b) => b.data.compareTo(a.data));
    return doDia;
  }

  /// Soma só os gastos dos últimos [dias] dias.
  double totalRecente({int dias = 30}) {
    double soma = 0.0;
    for (var gasto in gastosRecentes(dias: dias)) {
      soma += gasto.valor;
    }
    return soma;
  }

  /// Zera as horas: 13/11 às 15h30 vira 13/11 às 00h00.
  DateTime _inicioDoDia(DateTime data) =>
      DateTime(data.year, data.month, data.day);
}
