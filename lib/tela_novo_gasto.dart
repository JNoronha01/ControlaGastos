import 'package:flutter/material.dart';

import 'aparencia.dart';
import 'formatadores.dart';
import 'gasto.dart';
import 'tema.dart';

/// Tela com o formulário para cadastrar um gasto (tela "Novo gasto" do Figma).
/// Ao salvar, ela "devolve" o Gasto criado para a tela anterior
/// usando Navigator.pop(context, gasto).
class TelaNovoGasto extends StatefulWidget {
  const TelaNovoGasto({super.key});

  @override
  State<TelaNovoGasto> createState() => _TelaNovoGastoState();
}

class _TelaNovoGastoState extends State<TelaNovoGasto> {
  // Chave que dá acesso ao Form para validar todos os campos de uma vez.
  final _formKey = GlobalKey<FormState>();

  // Controllers: as "alças" para ler o que foi digitado em cada campo.
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  // Começa com a data de hoje; o usuário pode trocar pelo calendário.
  DateTime _data = DateTime.now();

  // Gasto, entrada ou investimento. Começa em "Gasto", o mais comum.
  TipoLancamento _tipo = TipoLancamento.gasto;

  // Categoria escolhida (só para gastos). null = ainda não escolheu.
  Categoria? _categoria;

  // Mostra o aviso "Escolha uma categoria" depois de tentar salvar.
  bool _faltouCategoria = false;

  bool get _ehGasto => _tipo == TipoLancamento.gasto;

  // Controllers precisam ser descartados quando a tela fecha,
  // para liberar memória.
  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  /// Converte o texto digitado em número. Aceita "35,50" e "1.234,50".
  /// Devolve null se não for um número válido.
  double? _lerValor() {
    var texto = _valorController.text.trim();
    // Se tem vírgula, os pontos são separador de milhar: tira eles.
    if (texto.contains(',')) texto = texto.replaceAll('.', '');
    return double.tryParse(texto.replaceAll(',', '.'));
  }

  /// Abre o calendário. Deixa escolher qualquer dia de 2000 até hoje
  /// (toque no ano, no topo do calendário, para trocar de ano).
  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: dataMinima,
      lastDate: DateTime.now(),
      helpText: 'Data',
    );

    // Se o usuário cancelar, o calendário devolve null.
    if (escolhida != null) {
      setState(() {
        _data = escolhida;
      });
    }
  }

  void _salvar() {
    // validate() roda o validator de cada campo e mostra as mensagens
    // de erro. Se algum falhar, não salva.
    final camposOk = _formKey.currentState!.validate();
    final categoriaOk = !_ehGasto || _categoria != null;
    setState(() => _faltouCategoria = !categoriaOk);
    if (!camposOk || !categoriaOk) return;

    final gasto = Gasto(
      descricao: _descricaoController.text.trim(),
      valor: _lerValor()!,
      data: _data,
      tipo: _tipo,
      categoria: _categoria,
    );

    // Fecha esta tela e entrega o gasto para quem a abriu.
    Navigator.pop(context, gasto);
  }

  /// "Hoje, 15 nov · 15/11/2026" fica mais fácil de ler que só a data.
  /// Em outro ano o título já traz o ano ("Sexta, 10 nov 2023"),
  /// então a data em números seria repetição.
  String get _textoData {
    final dia = formatarDiaDaLista(_data);
    if (_data.year != DateTime.now().year) return dia;
    return '$dia · ${formatarData(_data)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          tooltip: 'Fechar',
        ),
        titleSpacing: 0,
        title: const Text('Novo lançamento'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Expanded + ListView: os campos rolam se o teclado ocupar
            // a tela, e o botão Salvar fica sempre embaixo.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Medidas.margemTela,
                ),
                children: [
                  const SizedBox(height: 8),
                  // O que é este lançamento: gasto, entrada ou investimento.
                  SegmentedButton<TipoLancamento>(
                    segments: [
                      for (final tipo in TipoLancamento.values)
                        ButtonSegment(
                          value: tipo,
                          label: Text(nomeDoTipo(tipo)),
                        ),
                    ],
                    selected: {_tipo},
                    showSelectedIcon: false,
                    onSelectionChanged: (escolha) => setState(() {
                      _tipo = escolha.first;
                      _faltouCategoria = false;
                    }),
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Cores.superficie,
                      foregroundColor: Cores.textoSecundario,
                      selectedBackgroundColor: Cores.primariaClara,
                      selectedForegroundColor: Cores.primaria,
                      side: const BorderSide(color: Cores.borda),
                      textStyle: Textos.corpoForte,
                    ),
                  ),
                  // Valor em destaque no topo: é o que mais importa.
                  const SizedBox(height: 16),
                  const Text(
                    'Valor',
                    textAlign: TextAlign.center,
                    style: Textos.legendaForte,
                  ),
                  // "R$" + campo no centro, lado a lado. IntrinsicWidth faz o
                  // campo ter só a largura do que foi digitado.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('R\$ ', style: Textos.valorDestaque),
                      ),
                      IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 96),
                          child: TextFormField(
                            controller: _valorController,
                            autofocus: true,
                            style: Textos.valorDestaque,
                            decoration: InputDecoration(
                              hintText: '0,00',
                              hintStyle: Textos.valorDestaque.copyWith(
                                color: Cores.borda,
                              ),
                              errorMaxLines: 2,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (_) {
                              final valor = _lerValor();
                              if (valor == null)
                                return 'Digite um valor válido';
                              if (valor <= 0) {
                                return 'O valor deve ser maior que zero';
                              }
                              return null; // null = campo válido
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  const _Rotulo('Descrição'),
                  TextFormField(
                    controller: _descricaoController,
                    style: Textos.corpo,
                    decoration: InputDecoration(
                      hintText: switch (_tipo) {
                        TipoLancamento.gasto => 'Ex.: Mercado, Uber, Lanche',
                        TipoLancamento.entrada => 'Ex.: Salário, Pix recebido',
                        TipoLancamento.investimento =>
                          'Ex.: Tesouro Direto, Poupança',
                      },
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _salvar(),
                    validator: (texto) {
                      if (texto == null || texto.trim().isEmpty) {
                        return 'Informe uma descrição';
                      }
                      return null;
                    },
                  ),
                  // Categoria: só aparece para gastos.
                  if (_ehGasto) ...[
                    const SizedBox(height: 20),
                    const _Rotulo('Categoria'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final categoria in Categoria.values)
                          ChoiceChip(
                            avatar: Icon(
                              iconeDaCategoria(categoria),
                              size: 18,
                              color: _categoria == categoria
                                  ? Cores.primaria
                                  : Cores.textoSecundario,
                            ),
                            label: Text(categoria.nome),
                            selected: _categoria == categoria,
                            showCheckmark: false,
                            onSelected: (_) => setState(() {
                              _categoria = categoria;
                              _faltouCategoria = false;
                            }),
                            labelStyle: Textos.corpo.copyWith(
                              color: _categoria == categoria
                                  ? Cores.primaria
                                  : Cores.texto,
                            ),
                            backgroundColor: Cores.superficie,
                            selectedColor: Cores.primariaClara,
                            side: BorderSide(
                              color: _categoria == categoria
                                  ? Cores.primaria
                                  : Cores.borda,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Medidas.raioCampo,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_faltouCategoria)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          'Escolha uma categoria',
                          style: Textos.legenda.copyWith(color: Cores.erro),
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),
                  const _Rotulo('Data'),
                  // InkWell deixa a "caixa" da data clicável; InputDecorator
                  // desenha a borda igual à dos outros campos.
                  InkWell(
                    onTap: _escolherData,
                    borderRadius: BorderRadius.circular(Medidas.raioCampo),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                          color: Cores.textoSecundario,
                        ),
                      ),
                      child: Text(_textoData, style: Textos.corpo),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Medidas.margemTela,
                  12,
                  Medidas.margemTela,
                  16,
                ),
                child: FilledButton(
                  onPressed: _salvar,
                  child: Text('Salvar ${nomeDoTipo(_tipo).toLowerCase()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rótulo sempre visível acima do campo, como no componente "Campo" do Figma.
class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(texto, style: Textos.legendaForte),
    );
  }
}
