import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'aparencia.dart';
import 'cartoes_resumo.dart';
import 'formatadores.dart';
import 'gasto.dart';
import 'seletor_mes.dart';
import 'tela_novo_gasto.dart';
import 'tema.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Gastos',
      debugShowCheckedModeBanner: false,
      // Cores, fonte e estilos do Figma (ver lib/tema.dart).
      theme: criarTema(),
      // Deixa os textos prontos do Flutter (como o calendário)
      // em português do Brasil.
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // No navegador do computador, o app fica com largura de celular
      // no meio da tela, em vez de esticar de ponta a ponta.
      builder: (context, child) => ColoredBox(
        color: Cores.fundo,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Medidas.larguraMaxima),
            child: child,
          ),
        ),
      ),
      home: const TelaGastos(),
    );
  }
}

class TelaGastos extends StatefulWidget {
  const TelaGastos({super.key});

  @override
  State<TelaGastos> createState() => _TelaGastosState();
}

/// Como a tela mostra os gastos: um mês por vez, ou tudo junto.
enum ModoVisao { mes, tudo }

class _TelaGastosState extends State<TelaGastos> {
  final ControleGastos _controle = ControleGastos();

  // Começa mostrando o mês atual, como no Figma ("Novembro de 2026").
  ModoVisao _modo = ModoVisao.mes;

  // Mês que está sendo visto no modo "Por mês" (sempre o dia 1).
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);

  // Dia escolhido no filtro do calendário. null = sem filtro de dia.
  DateTime? _diaFiltrado;

  /// Pode avançar o mês só até o mês atual (não existe gasto no futuro).
  bool get _podeAvancarMes {
    final agora = DateTime.now();
    return _mes.isBefore(DateTime(agora.year, agora.month));
  }

  /// Volta (-1) ou avança (+1) um mês. DateTime(2020, 13) vira jan/2021
  /// sozinho, então a virada de ano funciona sem conta extra.
  void _mudarMes(int quantidade) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + quantidade);
      _diaFiltrado = null;
    });
  }

  /// Abre a janela para escolher qualquer mês e ano.
  Future<void> _escolherMes() async {
    final escolhido = await escolherMes(context, _mes);
    if (escolhido != null) {
      setState(() {
        _mes = escolhido;
        _diaFiltrado = null;
      });
    }
  }

  void _mudarModo(ModoVisao modo) {
    setState(() {
      _modo = modo;
      _diaFiltrado = null;
    });
  }

  /// Abre a tela de cadastro e ESPERA (await) ela fechar.
  /// Se o usuário salvou, recebemos o Gasto; se voltou, recebemos null.
  Future<void> _abrirNovoGasto() async {
    final gasto = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(builder: (context) => const TelaNovoGasto()),
    );

    if (gasto != null) {
      setState(() {
        _controle.adicionarGasto(gasto);
        // Tira o filtro de dia e, no modo "Por mês", vai para o mês do
        // gasto: assim o gasto que acabou de ser salvo sempre aparece.
        _diaFiltrado = null;
        _mes = DateTime(gasto.data.year, gasto.data.month);
      });
    }
  }

  void _removerGasto(Gasto gasto) {
    setState(() {
      _controle.removerGasto(gasto);
    });
    // Mostra o aviso com a opção de desfazer, para um toque sem querer
    // na lixeira não apagar o gasto de vez.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${gasto.descricao}" removido'),
          // Some sozinho depois de 4 segundos. Sem o persist: false, o
          // Flutter deixa o aviso na tela até alguém tocar em "Desfazer".
          duration: const Duration(seconds: 4),
          persist: false,
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () {
              setState(() {
                _controle.adicionarGasto(gasto);
              });
            },
          ),
        ),
      );
  }

  /// Abre o calendário para ver os gastos de um dia específico.
  Future<void> _filtrarPorDia() async {
    final hoje = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: _diaFiltrado ?? hoje,
      // Qualquer dia de 2000 até hoje, não só os últimos 30.
      firstDate: dataMinima,
      lastDate: hoje,
      helpText: 'Ver gastos do dia',
    );

    if (dia != null) {
      setState(() {
        _diaFiltrado = dia;
        // Ao limpar o filtro, a tela volta para o mês desse dia.
        _mes = DateTime(dia.year, dia.month);
      });
    }
  }

  void _limparFiltro() {
    setState(() {
      _diaFiltrado = null;
    });
  }

  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Lista que aparece na tela: o dia escolhido no calendário (se houver);
  /// senão, o mês escolhido ou todos os gastos, conforme o modo.
  List<Gasto> get _gastosVisiveis {
    final dia = _diaFiltrado;
    if (dia != null) return _controle.gastosDoDia(dia);
    if (_modo == ModoVisao.mes) return _controle.lancamentosDoMes(_mes);
    return _controle.todosOrdenados;
  }

  /// Separa a lista (que já vem do mais recente para o mais antigo)
  /// em grupos, um por dia, como na tela "Gastos" do Figma.
  List<List<Gasto>> _agruparPorDia(List<Gasto> gastos) {
    final grupos = <List<Gasto>>[];
    for (final gasto in gastos) {
      if (grupos.isNotEmpty && _mesmoDia(grupos.last.first.data, gasto.data)) {
        grupos.last.add(gasto);
      } else {
        grupos.add([gasto]);
      }
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    final gastos = _gastosVisiveis;
    final grupos = _agruparPorDia(gastos);
    final porMes = _modo == ModoVisao.mes;
    final categorias = _controle.totalPorCategoria(porMes ? _mes : null);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          // Espaço embaixo para o botão "Novo gasto" não cobrir o último item.
          padding: const EdgeInsets.fromLTRB(
            Medidas.margemTela,
            16,
            Medidas.margemTela,
            104,
          ),
          children: [
            _Topo(onFiltrarPorDia: _filtrarPorDia),
            const SizedBox(height: 16),
            _OpcaoModo(modo: _modo, onMudar: _mudarModo),
            if (porMes) ...[
              const SizedBox(height: 12),
              _NavegadorDeMes(
                mes: _mes,
                podeAvancar: _podeAvancarMes,
                onAnterior: () => _mudarMes(-1),
                onProximo: () => _mudarMes(1),
                onEscolher: _escolherMes,
              ),
            ],
            const SizedBox(height: 16),
            // Saldo + gráfico (gasto, investido, sobrando). No modo
            // "Por mês" mostra só o mês escolhido, sem nada do total geral.
            CartaoSaldo(
              titulo: porMes
                  ? 'Saldo de ${formatarMes(_mes, maiuscula: false)}'
                  : 'Saldo total',
              resumo: porMes
                  ? _controle.resumoDoMes(_mes)
                  : _controle.resumoGeral,
            ),
            if (categorias.isNotEmpty) ...[
              const SizedBox(height: 16),
              CartaoCategorias(itens: categorias),
            ],
            const SizedBox(height: 28),
            _CabecalhoLista(
              titulo: porMes ? 'Lançamentos do mês' : 'Todos os lançamentos',
              diaFiltrado: _diaFiltrado,
              quantidade: gastos.length,
              onLimparFiltro: _limparFiltro,
            ),
            const SizedBox(height: 8),
            if (gastos.isEmpty)
              _ListaVazia(
                mensagem: _diaFiltrado != null
                    ? 'Nada registrado neste dia.'
                    : porMes
                    ? 'Nada registrado em ${formatarMes(_mes, maiuscula: false)}.'
                    : 'Nada registrado ainda.\n'
                          'Toque em "Novo lançamento" para começar.',
              )
            else
              for (final grupo in grupos)
                _GrupoDoDia(gastos: grupo, onRemover: _removerGasto),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoGasto,
        icon: const Icon(Icons.add),
        label: const Text('Novo lançamento'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets menores usados na tela. Separar em partes deixa o build() acima
// curto e fácil de ler. São Stateless porque só mostram o que recebem.
// ---------------------------------------------------------------------------

/// Título da tela e botão do calendário.
class _Topo extends StatelessWidget {
  const _Topo({required this.onFiltrarPorDia});

  final VoidCallback onFiltrarPorDia;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('Controle de Gastos', style: Textos.tituloTela),
        ),
        IconButton(
          onPressed: onFiltrarPorDia,
          icon: const Icon(Icons.calendar_month_outlined),
          color: Cores.texto,
          tooltip: 'Filtrar por dia',
        ),
      ],
    );
  }
}

/// Escolha entre ver "Por mês" ou "Tudo".
class _OpcaoModo extends StatelessWidget {
  const _OpcaoModo({required this.modo, required this.onMudar});

  final ModoVisao modo;
  final ValueChanged<ModoVisao> onMudar;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ModoVisao>(
      segments: const [
        ButtonSegment(value: ModoVisao.mes, label: Text('Por mês')),
        ButtonSegment(value: ModoVisao.tudo, label: Text('Tudo')),
      ],
      selected: {modo},
      showSelectedIcon: false,
      onSelectionChanged: (escolha) => onMudar(escolha.first),
      style: SegmentedButton.styleFrom(
        backgroundColor: Cores.superficie,
        foregroundColor: Cores.textoSecundario,
        selectedBackgroundColor: Cores.primariaClara,
        selectedForegroundColor: Cores.primaria,
        side: const BorderSide(color: Cores.borda),
        textStyle: Textos.corpoForte,
      ),
    );
  }
}

/// Linha "‹ Dezembro de 2020 ›". Tocar no nome abre o seletor de mês.
class _NavegadorDeMes extends StatelessWidget {
  const _NavegadorDeMes({
    required this.mes,
    required this.podeAvancar,
    required this.onAnterior,
    required this.onProximo,
    required this.onEscolher,
  });

  final DateTime mes;
  final bool podeAvancar;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;
  final VoidCallback onEscolher;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(Medidas.raioCampo),
        border: Border.all(color: Cores.borda),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onAnterior,
            icon: const Icon(Icons.chevron_left),
            color: Cores.texto,
            tooltip: 'Mês anterior',
          ),
          Expanded(
            child: TextButton(
              onPressed: onEscolher,
              child: Text(
                formatarMes(mes),
                style: Textos.corpoForte.copyWith(color: Cores.texto),
              ),
            ),
          ),
          IconButton(
            // null desativa a seta: não dá para ir para meses futuros.
            onPressed: podeAvancar ? onProximo : null,
            icon: const Icon(Icons.chevron_right),
            color: Cores.texto,
            disabledColor: Cores.borda,
            tooltip: 'Próximo mês',
          ),
        ],
      ),
    );
  }
}

/// Título acima da lista e, se houver filtro, um botão para limpar.
class _CabecalhoLista extends StatelessWidget {
  const _CabecalhoLista({
    required this.titulo,
    required this.diaFiltrado,
    required this.quantidade,
    required this.onLimparFiltro,
  });

  final String titulo; // "Gastos do mês" ou "Todos os gastos"
  final DateTime? diaFiltrado;
  final int quantidade;
  final VoidCallback onLimparFiltro;

  @override
  Widget build(BuildContext context) {
    final dia = diaFiltrado;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dia == null ? titulo : 'Dia ${formatarData(dia)}',
                style: Textos.tituloSecao,
              ),
              Text(
                quantidade == 1 ? '1 lançamento' : '$quantidade lançamentos',
                style: Textos.legenda,
              ),
            ],
          ),
        ),
        if (dia != null)
          TextButton.icon(
            onPressed: onLimparFiltro,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Limpar dia'),
          ),
      ],
    );
  }
}

/// Um dia da lista: "Hoje, 15 nov" + total do dia, e os gastos daquele dia.
class _GrupoDoDia extends StatelessWidget {
  const _GrupoDoDia({required this.gastos, required this.onRemover});

  final List<Gasto> gastos;
  final void Function(Gasto) onRemover;

  @override
  Widget build(BuildContext context) {
    // O total do dia soma só os gastos (entradas e investimentos não).
    double totalDoDia = 0;
    for (final gasto in gastos) {
      if (gasto.ehGasto) totalDoDia += gasto.valor;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatarDiaDaLista(gastos.first.data),
                  style: Textos.legendaForte,
                ),
              ),
              if (totalDoDia > 0)
                Text(formatarMoeda(totalDoDia), style: Textos.legenda),
            ],
          ),
          const SizedBox(height: 4),
          for (final gasto in gastos)
            _ItemGasto(gasto: gasto, onRemover: () => onRemover(gasto)),
        ],
      ),
    );
  }
}

/// Uma linha da lista de gastos (componente "Item de gasto" do Figma).
class _ItemGasto extends StatelessWidget {
  const _ItemGasto({required this.gasto, required this.onRemover});

  final Gasto gasto;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final entrada = gasto.tipo == TipoLancamento.entrada;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Círculo neutro com o ícone, sem cor chamativa.
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Cores.superficie2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconeDoLancamento(gasto),
              size: 20,
              color: Cores.textoSecundario,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gasto.descricao,
                  style: Textos.corpoForte,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(rotuloDoLancamento(gasto), style: Textos.legenda),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Entradas aparecem com "+" e em verde: é dinheiro chegando.
          Text(
            entrada
                ? '+${formatarMoeda(gasto.valor)}'
                : formatarMoeda(gasto.valor),
            style: Textos.corpoForte.copyWith(
              color: entrada ? Cores.primaria : Cores.texto,
            ),
          ),
          IconButton(
            onPressed: onRemover,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Cores.textoSecundario,
            tooltip: 'Remover',
          ),
        ],
      ),
    );
  }
}

/// O que aparece quando não há gastos para mostrar.
class _ListaVazia extends StatelessWidget {
  const _ListaVazia({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.savings_outlined,
            size: 56,
            color: Cores.textoSecundario,
          ),
          const SizedBox(height: 12),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: Textos.corpo.copyWith(color: Cores.textoSecundario),
          ),
        ],
      ),
    );
  }
}
