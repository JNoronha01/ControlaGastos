import 'package:flutter/material.dart';

import 'aparencia.dart';
import 'formatadores.dart';
import 'gasto.dart';
import 'tema.dart';

/// "45%" — porcentagem sem casas decimais.
String _porcento(double parte, double todo) =>
    todo <= 0 ? '0%' : '${(parte / todo * 100).round()}%';

/// Cartão do saldo: quanto sobra e um gráfico de barra mostrando
/// para onde foi o dinheiro que entrou (gasto, investido, sobrando).
class CartaoSaldo extends StatelessWidget {
  const CartaoSaldo({super.key, required this.titulo, required this.resumo});

  final String titulo; // ex.: "Saldo de novembro"
  final Resumo resumo;

  @override
  Widget build(BuildContext context) {
    final saldo = resumo.saldo;
    final sobrando = saldo > 0 ? saldo : 0.0;
    // A barra representa tudo o que entrou. Se saiu mais do que entrou,
    // ela representa o que saiu, para o gráfico continuar fazendo sentido.
    final base = [
      resumo.entradas,
      resumo.gastos + resumo.investido,
    ].reduce((a, b) => a > b ? a : b);
    final semEntradas = resumo.entradas <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        border: Border.all(color: Cores.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Textos.legendaForte),
          const SizedBox(height: 4),
          Text(
            formatarMoeda(saldo),
            style: Textos.valorDestaque.copyWith(
              color: saldo < 0 ? Cores.erro : Cores.texto,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            semEntradas
                ? 'Nenhuma entrada registrada'
                : 'Entrou ${formatarMoeda(resumo.entradas)}',
            style: Textos.legenda,
          ),
          const SizedBox(height: 16),
          _BarraDoSaldo(
            base: base,
            gastos: resumo.gastos,
            investido: resumo.investido,
            sobrando: sobrando,
          ),
          const SizedBox(height: 16),
          _LinhaLegenda(
            cor: Cores.graficoGasto,
            nome: 'Gasto',
            valor: resumo.gastos,
            porcento: semEntradas
                ? null
                : _porcento(resumo.gastos, resumo.entradas),
          ),
          _LinhaLegenda(
            cor: Cores.graficoInvestido,
            nome: 'Investido',
            valor: resumo.investido,
            porcento: semEntradas
                ? null
                : _porcento(resumo.investido, resumo.entradas),
          ),
          _LinhaLegenda(
            cor: Cores.graficoSobrando,
            nome: 'Sobrando',
            valor: sobrando,
            porcento: semEntradas ? null : _porcento(sobrando, resumo.entradas),
          ),
          if (saldo < 0) ...[
            const SizedBox(height: 8),
            Text(
              'Saiu ${formatarMoeda(-saldo)} a mais do que entrou.',
              style: Textos.legendaForte.copyWith(color: Cores.erro),
            ),
          ] else if (semEntradas) ...[
            const SizedBox(height: 8),
            const Text(
              'Registre uma entrada (ex.: salário) para ver quanto sobra.',
              style: Textos.legenda,
            ),
          ],
        ],
      ),
    );
  }
}

/// Barra horizontal dividida em três partes proporcionais.
class _BarraDoSaldo extends StatelessWidget {
  const _BarraDoSaldo({
    required this.base,
    required this.gastos,
    required this.investido,
    required this.sobrando,
  });

  final double base;
  final double gastos;
  final double investido;
  final double sobrando;

  @override
  Widget build(BuildContext context) {
    final partes = [
      (gastos, Cores.graficoGasto),
      (investido, Cores.graficoInvestido),
      (sobrando, Cores.graficoSobrando),
    ].where((p) => p.$1 > 0).toList();

    return Semantics(
      label:
          'Gráfico: gasto ${formatarMoeda(gastos)}, '
          'investido ${formatarMoeda(investido)}, '
          'sobrando ${formatarMoeda(sobrando)}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: double.infinity,
          height: 14,
          child: base <= 0 || partes.isEmpty
              // Sem dados: só o trilho vazio.
              ? const ColoredBox(color: Cores.superficie2)
              : Row(
                  // stretch: cada parte ocupa toda a altura da barra.
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < partes.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Expanded(
                        // flex precisa ser inteiro: usa milésimos da base.
                        flex: (partes[i].$1 / base * 1000).round().clamp(
                          1,
                          1000,
                        ),
                        child: ColoredBox(color: partes[i].$2),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _LinhaLegenda extends StatelessWidget {
  const _LinhaLegenda({
    required this.cor,
    required this.nome,
    required this.valor,
    this.porcento,
  });

  final Color cor;
  final String nome;
  final double valor;
  final String? porcento;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(nome, style: Textos.corpo)),
          if (porcento != null) ...[
            Text(porcento!, style: Textos.legenda),
            const SizedBox(width: 12),
          ],
          Text(formatarMoeda(valor), style: Textos.corpoForte),
        ],
      ),
    );
  }
}

/// Cartão "Gastos por categoria": quanto foi gasto com cada coisa,
/// da categoria mais cara para a mais barata.
class CartaoCategorias extends StatelessWidget {
  const CartaoCategorias({super.key, required this.itens});

  final List<MapEntry<Categoria, double>> itens;

  @override
  Widget build(BuildContext context) {
    final maior = itens.isEmpty ? 0.0 : itens.first.value;
    var totalGastos = 0.0;
    for (final item in itens) {
      totalGastos += item.value;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      decoration: BoxDecoration(
        color: Cores.superficie,
        borderRadius: BorderRadius.circular(Medidas.raioCartao),
        border: Border.all(color: Cores.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gastos por categoria', style: Textos.tituloSecao),
          const SizedBox(height: 8),
          for (final item in itens)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Cores.superficie2,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconeDaCategoria(item.key),
                      size: 18,
                      color: Cores.textoSecundario,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.key.nome,
                                style: Textos.corpoForte,
                              ),
                            ),
                            Text(
                              _porcento(item.value, totalGastos),
                              style: Textos.legenda,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              formatarMoeda(item.value),
                              style: Textos.corpoForte,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Barra fina proporcional à categoria mais cara.
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: maior <= 0 ? 0 : item.value / maior,
                            minHeight: 6,
                            color: Cores.graficoGasto,
                            backgroundColor: Cores.superficie2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
