import 'package:flutter/material.dart';

import 'formatadores.dart';
import 'gasto.dart';

/// Tela com o formulário para cadastrar um gasto.
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

  /// Converte o texto digitado em número. Aceita vírgula ("35,50").
  /// Devolve null se não for um número válido.
  double? _lerValor() {
    final texto = _valorController.text.trim().replaceAll(',', '.');
    return double.tryParse(texto);
  }

  /// Abre o calendário. Só deixa escolher datas dos últimos 30 dias.
  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: hoje.subtract(const Duration(days: 30)),
      lastDate: hoje,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo gasto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex.: Mercado, Uber, Lanche',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (texto) {
                if (texto == null || texto.trim().isEmpty) {
                  return 'Informe uma descrição';
                }
                return null; // null = campo válido
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                hintText: '0,00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (_) {
                final valor = _lerValor();
                if (valor == null) return 'Digite um valor válido';
                if (valor <= 0) return 'O valor deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // InkWell deixa a "caixa" da data clicável; InputDecorator
            // desenha a borda igual à dos outros campos.
            InkWell(
              onTap: _escolherData,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                child: Text(formatarData(_data)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Salvar gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
