import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'formatadores.dart';
import 'gasto.dart';
import 'tela_novo_gasto.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Deixa os textos prontos do Flutter (como o calendário)
      // em português do Brasil.
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const TelaGastos(),
    );
  }
}

class TelaGastos extends StatefulWidget {
  const TelaGastos({super.key});

  @override
  State<TelaGastos> createState() => _TelaGastosState();
}

class _TelaGastosState extends State<TelaGastos> {
  final ControleGastos _controle = ControleGastos();

  // Dia escolhido no filtro do calendário. null = mostrar os 30 dias.
  DateTime? _diaFiltrado;

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
      });
    }
  }

  void _removerGasto(Gasto gasto) {
    setState(() {
      _controle.removerGasto(gasto);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${gasto.descricao}" removido')),
    );
  }

  /// Abre o calendário para ver os gastos de um dia específico.
  Future<void> _filtrarPorDia() async {
    final hoje = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: _diaFiltrado ?? hoje,
      firstDate: hoje.subtract(const Duration(days: 30)),
      lastDate: hoje,
      helpText: 'Ver gastos do dia',
    );

    if (dia != null) {
      setState(() {
        _diaFiltrado = dia;
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

  /// Lista que aparece na tela: últimos 30 dias, ou só o dia filtrado.
  List<Gasto> get _gastosVisiveis {
    final recentes = _controle.gastosRecentes(dias: 30);
    final dia = _diaFiltrado;
    if (dia == null) return recentes;
    return recentes.where((gasto) => _mesmoDia(gasto.data, dia)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gastos = _gastosVisiveis;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Gastos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _filtrarPorDia,
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filtrar por dia',
          ),
        ],
      ),
      body: Column(
        children: [
          _CartaoTotal(
            totalMes: _controle.totalRecente(dias: 30),
            totalGeral: _controle.total,
          ),
          _CabecalhoLista(
            diaFiltrado: _diaFiltrado,
            quantidade: gastos.length,
            onLimparFiltro: _limparFiltro,
          ),
          // Expanded: a lista ocupa todo o espaço que sobra na Column.
          Expanded(
            child: gastos.isEmpty
                ? _ListaVazia(filtrando: _diaFiltrado != null)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: gastos.length,
                    itemBuilder: (context, index) {
                      final gasto = gastos[index];
                      return _ItemGasto(
                        gasto: gasto,
                        onRemover: () => _removerGasto(gasto),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoGasto,
        icon: const Icon(Icons.add),
        label: const Text('Novo gasto'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets menores usados na tela. Separar em partes deixa o build() acima
// curto e fácil de ler. São Stateless porque só mostram o que recebem.
// ---------------------------------------------------------------------------

/// Cartão do topo com os totais.
class _CartaoTotal extends StatelessWidget {
  const _CartaoTotal({required this.totalMes, required this.totalGeral});

  final double totalMes;
  final double totalGeral;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.all(16),
      color: cores.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gasto nos últimos 30 dias', style: textos.titleSmall),
            const SizedBox(height: 4),
            Text(
              formatarMoeda(totalMes),
              style: textos.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cores.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total geral: ${formatarMoeda(totalGeral)}',
              style: textos.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha acima da lista: título e, se houver filtro, um botão para limpar.
class _CabecalhoLista extends StatelessWidget {
  const _CabecalhoLista({
    required this.diaFiltrado,
    required this.quantidade,
    required this.onLimparFiltro,
  });

  final DateTime? diaFiltrado;
  final int quantidade;
  final VoidCallback onLimparFiltro;

  @override
  Widget build(BuildContext context) {
    final dia = diaFiltrado;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dia == null
                  ? 'Últimos 30 dias ($quantidade)'
                  : 'Dia ${formatarData(dia)} ($quantidade)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (dia != null)
            TextButton.icon(
              onPressed: onLimparFiltro,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Ver todos'),
            ),
        ],
      ),
    );
  }
}

/// Uma linha da lista de gastos.
class _ItemGasto extends StatelessWidget {
  const _ItemGasto({required this.gasto, required this.onRemover});

  final Gasto gasto;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
        title: Text(gasto.descricao),
        subtitle: Text(formatarData(gasto.data)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatarMoeda(gasto.valor),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: onRemover,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover',
            ),
          ],
        ),
      ),
    );
  }
}

/// O que aparece quando não há gastos para mostrar.
class _ListaVazia extends StatelessWidget {
  const _ListaVazia({required this.filtrando});

  final bool filtrando;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              filtrando
                  ? 'Nenhum gasto neste dia.'
                  : 'Nenhum gasto registrado.\nToque em "Novo gasto" para começar.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
