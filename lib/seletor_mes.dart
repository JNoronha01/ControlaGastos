import 'package:flutter/material.dart';

import 'formatadores.dart';
import 'gasto.dart';
import 'tema.dart';

/// Abre uma janela para escolher mês e ano (ex.: dezembro de 2020).
/// O Flutter não tem um seletor só de mês pronto, então ele é feito aqui:
/// setas para trocar o ano e uma grade com os 12 meses.
/// Devolve o primeiro dia do mês escolhido, ou null se o usuário cancelar.
Future<DateTime?> escolherMes(BuildContext context, DateTime inicial) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => _SeletorDeMes(inicial: inicial),
  );
}

class _SeletorDeMes extends StatefulWidget {
  const _SeletorDeMes({required this.inicial});

  final DateTime inicial;

  @override
  State<_SeletorDeMes> createState() => _SeletorDeMesState();
}

class _SeletorDeMesState extends State<_SeletorDeMes> {
  late int _ano = widget.inicial.year;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();

    return AlertDialog(
      backgroundColor: Cores.superficie,
      surfaceTintColor: Colors.transparent,
      title: const Text('Escolher mês', style: Textos.tituloSecao),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linha do ano: ‹ 2020 ›
            Row(
              children: [
                IconButton(
                  onPressed: _ano > dataMinima.year
                      ? () => setState(() => _ano--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Ano anterior',
                ),
                Expanded(
                  child: Text(
                    '$_ano',
                    textAlign: TextAlign.center,
                    style: Textos.tituloSecao,
                  ),
                ),
                IconButton(
                  onPressed: _ano < hoje.year
                      ? () => setState(() => _ano++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Próximo ano',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Grade com os 12 meses, 3 por linha.
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 2.2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (var mes = 1; mes <= 12; mes++)
                  _BotaoMes(
                    nome: mesesPorExtenso[mes - 1].substring(0, 3),
                    selecionado:
                        _ano == widget.inicial.year &&
                        mes == widget.inicial.month,
                    // Meses que ainda não chegaram ficam desativados.
                    ativo: DateTime(
                      _ano,
                      mes,
                    ).isBefore(DateTime(hoje.year, hoje.month + 1)),
                    onTap: () => Navigator.pop(context, DateTime(_ano, mes)),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _BotaoMes extends StatelessWidget {
  const _BotaoMes({
    required this.nome,
    required this.selecionado,
    required this.ativo,
    required this.onTap,
  });

  final String nome;
  final bool selecionado;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final corTexto = selecionado
        ? Cores.sobrePrimaria
        : (ativo ? Cores.texto : Cores.borda);

    return Material(
      color: selecionado ? Cores.primaria : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Medidas.raioCampo),
        side: BorderSide(color: selecionado ? Cores.primaria : Cores.borda),
      ),
      child: InkWell(
        onTap: ativo ? onTap : null,
        borderRadius: BorderRadius.circular(Medidas.raioCampo),
        child: Center(
          child: Text(nome, style: Textos.corpoForte.copyWith(color: corTexto)),
        ),
      ),
    );
  }
}
