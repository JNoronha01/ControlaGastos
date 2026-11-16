import 'package:flutter/material.dart';

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
      helpText: 'Data do gasto',
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
    if (!_formKey.currentState!.validate()) return;

    final gasto = Gasto(
      descricao: _descricaoController.text.trim(),
      valor: _lerValor()!,
      data: _data,
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
        title: const Text('Novo gasto'),
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
                  // Valor em destaque no topo: é o que mais importa.
                  const SizedBox(height: 12),
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
                    decoration: const InputDecoration(
                      hintText: 'Ex.: Mercado, Uber, Lanche',
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
                  child: const Text('Salvar gasto'),
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
