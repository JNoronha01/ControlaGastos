/// Data mais antiga que os calendários deixam escolher.
/// A mais nova é sempre "hoje", então o intervalo cresce sozinho
/// a cada dia, sem nunca esconder os dias antigos.
final DateTime dataMinima = DateTime(2000, 1, 1);

/// O que aconteceu com o dinheiro:
/// - gasto: saiu (mercado, Uber, assinatura...)
/// - entrada: entrou (salário, pix recebido...)
/// - investimento: saiu da conta, mas foi guardado/investido
enum TipoLancamento { gasto, entrada, investimento }

/// Categorias de gasto. Lista fixa: é rápida de escolher e deixa o
/// resumo "quanto gastei com cada coisa" sempre organizado.
enum Categoria {
  mercado('Mercado'),
  alimentacao('Alimentação'),
  transporte('Transporte'),
  moradia('Moradia'),
  assinaturas('Assinaturas'),
  lazer('Lazer'),
  saude('Saúde'),
  outros('Outros');

  const Categoria(this.nome);

  /// Nome que aparece na tela.
  final String nome;
}

/// Representa UM lançamento registrado pelo usuário: um gasto,
/// uma entrada de dinheiro ou um investimento.
/// (O nome da classe continua Gasto para não quebrar o código do grupo.)
class Gasto {
  final String descricao;
  final double valor;
  final DateTime data;
  final TipoLancamento tipo;

  /// Só gastos têm categoria. Entradas e investimentos ficam com null.
  final Categoria? categoria;

  Gasto({
    required this.descricao,
    required this.valor,
    required this.data,
    this.tipo = TipoLancamento.gasto,
    Categoria? categoria,
  }) : categoria = tipo == TipoLancamento.gasto
           ? (categoria ?? Categoria.outros)
           : null;

  bool get ehGasto => tipo == TipoLancamento.gasto;
}

/// Resumo do dinheiro de um período: quanto entrou, quanto foi gasto,
/// quanto foi investido e quanto ainda sobra.
class Resumo {
  const Resumo({
    required this.entradas,
    required this.gastos,
    required this.investido,
  });

  final double entradas;
  final double gastos;
  final double investido;

  /// O que ainda sobra: entradas − gastos − investido.
  /// Fica negativo se saiu mais dinheiro do que entrou.
  double get saldo => entradas - gastos - investido;
}

/// Guarda a LISTA de lançamentos e faz os cálculos sobre ela.
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
  /// Entradas e investimentos não entram nessa conta.
  double get total => _somar(_gastos, TipoLancamento.gasto);

  /// Gastos feitos nos últimos [dias] dias, do mais recente para o mais antigo.
  List<Gasto> gastosRecentes({int dias = 30}) {
    final limite = _inicioDoDia(DateTime.now()).subtract(Duration(days: dias));
    return _ordenar(
      _gastos.where((g) => g.ehGasto && !g.data.isBefore(limite)),
    );
  }

  /// Todos os lançamentos, de qualquer data, do mais recente para o mais
  /// antigo. É a lista que aparece na tela inicial no modo "Tudo".
  List<Gasto> get todosOrdenados => _ordenar(_gastos);

  /// Todos os lançamentos de um dia específico (de qualquer data),
  /// do mais recente para o mais antigo.
  List<Gasto> gastosDoDia(DateTime dia) {
    final inicio = _inicioDoDia(dia);
    return _ordenar(_gastos.where((g) => _inicioDoDia(g.data) == inicio));
  }

  /// Lançamentos de um mês (ex.: dezembro de 2020), do mais recente para o
  /// mais antigo. Só o ano e o mês de [mes] importam; o dia é ignorado.
  List<Gasto> lancamentosDoMes(DateTime mes) => _ordenar(_doMes(mes));

  /// Só os GASTOS de um mês, do mais recente para o mais antigo.
  List<Gasto> gastosDoMes(DateTime mes) =>
      _ordenar(_doMes(mes).where((g) => g.ehGasto));

  /// Soma só os gastos de um mês.
  double totalDoMes(DateTime mes) => _somar(_doMes(mes), TipoLancamento.gasto);

  /// Soma só os gastos dos últimos [dias] dias.
  double totalRecente({int dias = 30}) =>
      _somar(gastosRecentes(dias: dias), TipoLancamento.gasto);

  /// Entradas, gastos, investido e saldo de um mês.
  Resumo resumoDoMes(DateTime mes) => _resumir(_doMes(mes));

  /// Entradas, gastos, investido e saldo de todos os lançamentos.
  Resumo get resumoGeral => _resumir(_gastos);

  /// Quanto foi gasto em cada categoria, da maior para a menor.
  /// Com [mes] = null, considera todos os meses.
  /// Categorias sem gasto não aparecem.
  List<MapEntry<Categoria, double>> totalPorCategoria([DateTime? mes]) {
    final lista = mes == null ? _gastos : _doMes(mes);
    final somas = <Categoria, double>{};
    for (final g in lista) {
      if (!g.ehGasto) continue;
      somas[g.categoria!] = (somas[g.categoria!] ?? 0) + g.valor;
    }
    final ordenado = somas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ordenado;
  }

  // ----- ajudantes -----

  Iterable<Gasto> _doMes(DateTime mes) => _gastos.where(
    (g) => g.data.year == mes.year && g.data.month == mes.month,
  );

  /// b.compareTo(a) ordena do maior (mais recente) para o menor.
  List<Gasto> _ordenar(Iterable<Gasto> lista) =>
      lista.toList()..sort((a, b) => b.data.compareTo(a.data));

  double _somar(Iterable<Gasto> lista, TipoLancamento tipo) {
    double soma = 0.0;
    for (final g in lista) {
      if (g.tipo == tipo) soma += g.valor;
    }
    return soma;
  }

  Resumo _resumir(Iterable<Gasto> lista) => Resumo(
    entradas: _somar(lista, TipoLancamento.entrada),
    gastos: _somar(lista, TipoLancamento.gasto),
    investido: _somar(lista, TipoLancamento.investimento),
  );

  /// Zera as horas: 13/11 às 15h30 vira 13/11 às 00h00.
  DateTime _inicioDoDia(DateTime data) =>
      DateTime(data.year, data.month, data.day);
}
